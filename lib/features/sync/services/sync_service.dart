import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bidirectional Drift <-> Firestore sync for one user.
///
/// On [start]:
///   1. Push any local rows updated since the last successful sync.
///   2. Pull remote rows (one-shot full read on first ever sync, or a
///      snapshot listener that fires for every remote change after that).
///
/// Strategy notes:
/// - Drift remains the source of truth for reads (UI streams from Drift).
/// - Conflict resolution is last-write-wins by `updatedAt`.
/// - Soft deletes (`deletedAt != null`) propagate so a delete on one device
///   removes the row on others.
/// - Each user's data is scoped to `users/{uid}/...` — Firestore rules
///   reject any cross-user access on the server.
class SyncService {
  SyncService({
    required HabitsDatabase database,
    required this.uid,
    FirebaseFirestore? firestore,
  })  : _db = database,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final HabitsDatabase _db;
  final String uid;
  final FirebaseFirestore _firestore;

  StreamSubscription<List<Habit>>? _localHabitsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteHabitsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteCompletionsSub;

  // Pending push debounce timer.
  Timer? _pushDebounce;

  // Guards re-entrant pushes (we set a remoteId in Drift right after a write,
  // which would otherwise trigger another local change -> another push).
  bool _suppressLocalPush = false;

  String get _lastSyncedAtKey => 'sync_last_synced_at_$uid';

  CollectionReference<Map<String, dynamic>> get _habitsRef =>
      _firestore.collection('users').doc(uid).collection('habits');

  CollectionReference<Map<String, dynamic>> get _completionsRef =>
      _firestore.collection('users').doc(uid).collection('completions');

  /// Initial sync + attach listeners.
  Future<void> start() async {
    // 1. Push everything that's changed locally since last sync.
    await _pushPendingLocalChanges();

    // 2. Initial pull of remote -> local.
    await _initialRemotePull();

    // 3. Listen for remote changes (Firestore snapshots).
    _remoteHabitsSub = _habitsRef.snapshots().listen(
      _onRemoteHabitsSnapshot,
      onError: (e) => debugPrint('Sync: habits listener error: $e'),
    );
    _remoteCompletionsSub = _completionsRef.snapshots().listen(
      _onRemoteCompletionsSnapshot,
      onError: (e) => debugPrint('Sync: completions listener error: $e'),
    );

    // 4. Listen for local changes (Drift) and push them up. We watch all
    //    habits (which fires on any habits-table change). For completions
    //    we don't have an "all completions" stream, so we piggy-back on
    //    habits changes — completeHabit writes both tables atomically.
    _localHabitsSub = _db.watchAllHabits().listen((_) {
      _scheduleLocalPush();
    });
  }

  Future<void> stop() async {
    _pushDebounce?.cancel();
    await _localHabitsSub?.cancel();
    await _remoteHabitsSub?.cancel();
    await _remoteCompletionsSub?.cancel();
    _localHabitsSub = null;
    _remoteHabitsSub = null;
    _remoteCompletionsSub = null;
  }

  // ---------------- Push (Drift -> Firestore) ----------------

  void _scheduleLocalPush() {
    if (_suppressLocalPush) return;
    _pushDebounce?.cancel();
    _pushDebounce = Timer(const Duration(milliseconds: 800), () {
      _pushPendingLocalChanges().catchError(
        (e) => debugPrint('Sync: push failed: $e'),
      );
    });
  }

  Future<void> _pushPendingLocalChanges() async {
    final since = await _readLastSyncedAt();
    final habits = await _db.getHabitsUpdatedSince(since);
    final completions = await _db.getCompletionsUpdatedSince(since);

    if (habits.isEmpty && completions.isEmpty) return;

    // Use a batch where possible (max 500 writes per batch).
    final batch = _firestore.batch();
    final habitWrites = <Future<void> Function()>[];

    for (final habit in habits) {
      final remoteId = habit.remoteId;
      final docRef =
          remoteId != null ? _habitsRef.doc(remoteId) : _habitsRef.doc();
      batch.set(docRef, _habitToMap(habit), SetOptions(merge: true));
      if (remoteId == null) {
        // We assigned a new doc id; persist it locally so next sync uses it.
        habitWrites.add(() async {
          _suppressLocalPush = true;
          try {
            await _db.setHabitRemoteId(habit.id, docRef.id);
          } finally {
            _suppressLocalPush = false;
          }
        });
      }
    }

    final completionWrites = <Future<void> Function()>[];
    for (final completion in completions) {
      final remoteId = completion.remoteId;
      final docRef = remoteId != null
          ? _completionsRef.doc(remoteId)
          : _completionsRef.doc();
      // Find remote habit ID — we need to map local habitId -> remote habitId.
      final habit = await _db.getHabitById(completion.habitId);
      final habitRemoteId = habit?.remoteId;
      if (habitRemoteId == null) {
        // Habit hasn't been pushed yet (first-ever sync ordering). Skip;
        // it'll be picked up next push cycle once the habit has a remoteId.
        continue;
      }
      batch.set(
        docRef,
        _completionToMap(completion, habitRemoteId: habitRemoteId),
        SetOptions(merge: true),
      );
      if (remoteId == null) {
        completionWrites.add(() async {
          _suppressLocalPush = true;
          try {
            await _db.setCompletionRemoteId(completion.id, docRef.id);
          } finally {
            _suppressLocalPush = false;
          }
        });
      }
    }

    await batch.commit();

    // Persist the new remoteIds locally now that the server accepted them.
    for (final w in habitWrites) {
      await w();
    }
    for (final w in completionWrites) {
      await w();
    }

    await _writeLastSyncedAt(DateTime.now());
  }

  // ---------------- Pull (Firestore -> Drift) ----------------

  Future<void> _initialRemotePull() async {
    try {
      final habitsSnap = await _habitsRef.get();
      for (final doc in habitsSnap.docs) {
        await _applyRemoteHabit(doc.id, doc.data());
      }
      final completionsSnap = await _completionsRef.get();
      for (final doc in completionsSnap.docs) {
        await _applyRemoteCompletion(doc.id, doc.data());
      }
    } catch (e) {
      debugPrint('Sync: initial pull failed: $e');
    }
  }

  Future<void> _onRemoteHabitsSnapshot(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    for (final change in snap.docChanges) {
      // Skip changes that originated locally and are still propagating.
      // Firestore has built-in "metadata.hasPendingWrites" but local pushes
      // already write through Drift first, so any echo here just becomes a
      // no-op upsert (same updatedAt).
      await _applyRemoteHabit(change.doc.id, change.doc.data() ?? const {});
    }
  }

  Future<void> _onRemoteCompletionsSnapshot(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    for (final change in snap.docChanges) {
      await _applyRemoteCompletion(
        change.doc.id,
        change.doc.data() ?? const {},
      );
    }
  }

  Future<void> _applyRemoteHabit(
    String remoteId,
    Map<String, dynamic> data,
  ) async {
    if (data.isEmpty) return;
    final remoteUpdatedAt = _readTimestamp(data['updatedAt']) ?? DateTime.now();
    final companion = HabitsCompanion(
      title: drift.Value(data['title'] as String? ?? ''),
      category: drift.Value(_categoryFromIndex(data['category'])),
      ayahReference: drift.Value(data['ayahReference'] as String?),
      currentStreak: drift.Value((data['currentStreak'] as num?)?.toInt() ?? 0),
      bestStreak: drift.Value((data['bestStreak'] as num?)?.toInt() ?? 0),
      lastCompleted: drift.Value(_readTimestamp(data['lastCompleted'])),
      isShielded: drift.Value(data['isShielded'] as bool? ?? false),
      createdAt: drift.Value(
          _readTimestamp(data['createdAt']) ?? DateTime.now()),
      deletedAt: drift.Value(_readTimestamp(data['deletedAt'])),
    );

    _suppressLocalPush = true;
    try {
      await _db.upsertHabitFromRemote(
        remoteId: remoteId,
        data: companion,
        remoteUpdatedAt: remoteUpdatedAt,
      );
    } finally {
      _suppressLocalPush = false;
    }
  }

  Future<void> _applyRemoteCompletion(
    String remoteId,
    Map<String, dynamic> data,
  ) async {
    if (data.isEmpty) return;
    final habitRemoteId = data['habitRemoteId'] as String?;
    if (habitRemoteId == null) return;
    // Map remote habit id -> local id.
    final localHabit = await _db.getHabitByRemoteId(habitRemoteId);
    if (localHabit == null) {
      // Habit hasn't synced yet; it'll come through and we'll try again on a
      // future snapshot. Drop for now.
      return;
    }
    final remoteUpdatedAt = _readTimestamp(data['updatedAt']) ?? DateTime.now();
    final completedAt =
        _readTimestamp(data['completedAt']) ?? DateTime.now();

    final companion = HabitCompletionsCompanion(
      habitId: drift.Value(localHabit.id),
      completedAt: drift.Value(completedAt),
      createdAt: drift.Value(
          _readTimestamp(data['createdAt']) ?? DateTime.now()),
      deletedAt: drift.Value(_readTimestamp(data['deletedAt'])),
    );

    _suppressLocalPush = true;
    try {
      await _db.upsertCompletionFromRemote(
        remoteId: remoteId,
        data: companion,
        remoteUpdatedAt: remoteUpdatedAt,
      );
    } finally {
      _suppressLocalPush = false;
    }
  }

  // ---------------- Mapping helpers ----------------

  Map<String, dynamic> _habitToMap(Habit h) => {
        'title': h.title,
        'category': h.category.index,
        'ayahReference': h.ayahReference,
        'currentStreak': h.currentStreak,
        'bestStreak': h.bestStreak,
        'lastCompleted': h.lastCompleted == null
            ? null
            : Timestamp.fromDate(h.lastCompleted!),
        'isShielded': h.isShielded,
        'createdAt': Timestamp.fromDate(h.createdAt),
        'updatedAt': Timestamp.fromDate(h.updatedAt),
        'deletedAt':
            h.deletedAt == null ? null : Timestamp.fromDate(h.deletedAt!),
      };

  Map<String, dynamic> _completionToMap(
    HabitCompletion c, {
    required String habitRemoteId,
  }) =>
      {
        'habitRemoteId': habitRemoteId,
        'completedAt': Timestamp.fromDate(c.completedAt),
        'createdAt': Timestamp.fromDate(c.createdAt),
        'updatedAt': Timestamp.fromDate(c.updatedAt),
        'deletedAt':
            c.deletedAt == null ? null : Timestamp.fromDate(c.deletedAt!),
      };

  HabitCategory _categoryFromIndex(dynamic raw) {
    final idx = (raw as num?)?.toInt() ?? 0;
    if (idx < 0 || idx >= HabitCategory.values.length) {
      return HabitCategory.fard;
    }
    return HabitCategory.values[idx];
  }

  DateTime? _readTimestamp(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }

  Future<DateTime> _readLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastSyncedAtKey);
    if (ms == null) {
      // First-ever sync for this user: push everything by using epoch 0.
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> _writeLastSyncedAt(DateTime when) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncedAtKey, when.millisecondsSinceEpoch);
  }

  // ---------------- Account deletion ----------------

  /// Deletes all of the user's Firestore data. Caller is responsible for
  /// then deleting the FirebaseAuth account.
  Future<void> deleteAllRemoteData() async {
    // Firestore deletes are not transactional across collections, so we
    // batch in chunks of 500.
    Future<void> deleteCollection(
      CollectionReference<Map<String, dynamic>> ref,
    ) async {
      while (true) {
        final snap = await ref.limit(400).get();
        if (snap.docs.isEmpty) break;
        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snap.docs.length < 400) break;
      }
    }

    await deleteCollection(_completionsRef);
    await deleteCollection(_habitsRef);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncedAtKey);
  }
}
