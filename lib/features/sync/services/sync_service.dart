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

  // Mutex preventing concurrent _pushPendingLocalChanges calls. Without
  // this, a fast-firing debounce or a manual resync racing the timer could
  // both query the same rows, both set new remoteIds, and create duplicate
  // Firestore docs.
  Future<void>? _activePush;

  // Max writes per Firestore batch (Firestore's hard limit is 500).
  static const int _batchChunkSize = 400;

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
    // Mutex: if a push is already running, wait for it and return — no
    // need to re-run since the in-flight push already covers our changes.
    if (_activePush != null) {
      await _activePush;
      return;
    }
    final completer = Completer<void>();
    _activePush = completer.future;
    try {
      await _pushPendingLocalChangesInner();
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _activePush = null;
    }
  }

  Future<void> _pushPendingLocalChangesInner() async {
    final since = await _readLastSyncedAt();

    // Snapshot the cutoff BEFORE reading. We'll use this as the next
    // lastSyncedAt — so any row written after this snapshot (with a
    // higher updatedAt) is guaranteed to be picked up next cycle.
    // Drift stores DateTime as Unix-seconds, so we round down: any row
    // written within this same second is still > since (since we read with
    // strict `>`). This is correct because we read with `> since`, so we
    // catch all rows since the last cutoff.
    final cutoff = DateTime.now();

    final habits = await _db.getHabitsUpdatedSince(since);
    final completions = await _db.getCompletionsUpdatedSince(since);

    if (habits.isEmpty && completions.isEmpty) {
      // Even with nothing to push, advance the cutoff so we don't re-read
      // the same window forever once the user idles.
      if (cutoff.isAfter(since)) {
        await _writeLastSyncedAt(cutoff);
      }
      return;
    }

    // Step 1: Assign remoteIds for any new habits and persist them locally
    // BEFORE the batch is built. Completions reference habitRemoteId, so
    // this avoids the first-sync ordering bug where a new habit and its
    // first completion are pushed together — the completion would
    // otherwise see habit.remoteId == null and get skipped.
    _suppressLocalPush = true;
    final habitDocRefs = <int, DocumentReference<Map<String, dynamic>>>{};
    try {
      for (final habit in habits) {
        final remoteId = habit.remoteId;
        final ref = remoteId != null
            ? _habitsRef.doc(remoteId)
            : _habitsRef.doc();
        habitDocRefs[habit.id] = ref;
        if (remoteId == null) {
          await _db.setHabitRemoteId(habit.id, ref.id);
        }
      }
    } finally {
      _suppressLocalPush = false;
    }

    // Step 2: Pre-assign completion remoteIds and persist them locally.
    // Doing this BEFORE the batch.commit means: if commit fails (network,
    // permission), the next retry uses the same docRefs instead of
    // generating new ones — so we never duplicate Firestore docs.
    _suppressLocalPush = true;
    final completionDocRefs =
        <int, DocumentReference<Map<String, dynamic>>>{};
    final completionsToPush = <HabitCompletion>[];
    final habitRemoteIdByCompletion = <int, String>{};
    try {
      for (final completion in completions) {
        final habit = await _db.getHabitById(completion.habitId);
        final habitRemoteId = habit?.remoteId;
        if (habitRemoteId == null) {
          // Orphan completion (habit hard-deleted). Skip — it'll be cleaned
          // up by a future pass or never matter since the habit is gone.
          continue;
        }
        final remoteId = completion.remoteId;
        final ref = remoteId != null
            ? _completionsRef.doc(remoteId)
            : _completionsRef.doc();
        completionDocRefs[completion.id] = ref;
        habitRemoteIdByCompletion[completion.id] = habitRemoteId;
        completionsToPush.add(completion);
        if (remoteId == null) {
          await _db.setCompletionRemoteId(completion.id, ref.id);
        }
      }
    } finally {
      _suppressLocalPush = false;
    }

    // Step 3: Build and commit the batch(es). Firestore caps a batch at
    // 500 ops; we chunk at [_batchChunkSize] to stay well under.
    final ops = <_PendingWrite>[];
    for (final habit in habits) {
      ops.add(_PendingWrite(
        habitDocRefs[habit.id]!,
        _habitToMap(habit),
      ));
    }
    for (final completion in completionsToPush) {
      ops.add(_PendingWrite(
        completionDocRefs[completion.id]!,
        _completionToMap(
          completion,
          habitRemoteId: habitRemoteIdByCompletion[completion.id]!,
        ),
      ));
    }

    for (var i = 0; i < ops.length; i += _batchChunkSize) {
      final end = (i + _batchChunkSize) > ops.length
          ? ops.length
          : i + _batchChunkSize;
      final batch = _firestore.batch();
      for (final op in ops.sublist(i, end)) {
        batch.set(op.ref, op.data, SetOptions(merge: true));
      }
      await batch.commit();
    }

    // Step 4: Advance lastSyncedAt to our pre-read cutoff. This is safe
    // because we read with strict `>`: any row written *after* the cutoff
    // has updatedAt > cutoff and will be picked up next cycle.
    await _writeLastSyncedAt(cutoff);
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
  /// Static so it can run even when no [SyncService] is alive (e.g. the
  /// user signs in offline, then asks to delete their account before sync
  /// has had a chance to start).
  static Future<void> deleteAllRemoteDataFor({
    required String uid,
    FirebaseFirestore? firestore,
  }) async {
    final fs = firestore ?? FirebaseFirestore.instance;
    final habitsRef =
        fs.collection('users').doc(uid).collection('habits');
    final completionsRef =
        fs.collection('users').doc(uid).collection('completions');
    Future<void> deleteCollection(
      CollectionReference<Map<String, dynamic>> ref,
    ) async {
      while (true) {
        final snap = await ref.limit(_batchChunkSize).get();
        if (snap.docs.isEmpty) break;
        final batch = fs.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snap.docs.length < _batchChunkSize) break;
      }
    }

    await deleteCollection(completionsRef);
    await deleteCollection(habitsRef);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sync_last_synced_at_$uid');
  }

  Future<void> deleteAllRemoteData() async {
    await deleteAllRemoteDataFor(uid: uid, firestore: _firestore);
  }
}

/// Single Firestore set() operation, batched up by [SyncService].
class _PendingWrite {
  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic> data;
  _PendingWrite(this.ref, this.data);
}
