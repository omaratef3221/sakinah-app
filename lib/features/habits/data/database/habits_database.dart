import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sakinah_flow/core/shared_models/habit_category.dart';

part 'habits_database.g.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  IntColumn get category => intEnum<HabitCategory>()();
  TextColumn get ayahReference => text().nullable()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompleted => dateTime().nullable()();
  BoolColumn get isShielded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Sync columns (v3)
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get remoteId => text().nullable()();
}

// Completion history table to track each day a habit was completed
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Sync columns (v3)
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get remoteId => text().nullable()();
}

@DriftDatabase(tables: [Habits, HabitCompletions])
class HabitsDatabase extends _$HabitsDatabase {
  HabitsDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add bestStreak column to existing habits table
        await m.addColumn(habits, habits.bestStreak);
        // Create new HabitCompletions table
        await m.create(habitCompletions);
      }
      if (from < 3) {
        // v3: cloud sync columns.
        //
        // SQLite rejects ALTER TABLE ADD COLUMN with non-constant defaults
        // (like CURRENT_TIMESTAMP), so we can't use Drift's m.addColumn for
        // updatedAt — its default in the schema is `currentDateAndTime`.
        // Workaround: add the column as nullable INTEGER, backfill with
        // strftime('%s','now'), then leave the Dart-side default to apply
        // for any new inserts. Drift treats nullable+with-default the same
        // as not-null in code, so this is safe.
        await customStatement(
            "ALTER TABLE habits ADD COLUMN updated_at INTEGER");
        await customStatement(
            "UPDATE habits SET updated_at = strftime('%s','now') WHERE updated_at IS NULL");
        await customStatement(
            "ALTER TABLE habits ADD COLUMN deleted_at INTEGER");
        await customStatement(
            "ALTER TABLE habits ADD COLUMN remote_id TEXT");
        await customStatement(
            "ALTER TABLE habit_completions ADD COLUMN updated_at INTEGER");
        await customStatement(
            "UPDATE habit_completions SET updated_at = strftime('%s','now') WHERE updated_at IS NULL");
        await customStatement(
            "ALTER TABLE habit_completions ADD COLUMN deleted_at INTEGER");
        await customStatement(
            "ALTER TABLE habit_completions ADD COLUMN remote_id TEXT");
      }
    },
  );

  // CRUD Operations

  // Get all habits (excluding soft-deleted)
  Future<List<Habit>> getAllHabits() =>
      (select(habits)..where((h) => h.deletedAt.isNull())).get();

  // Get habits by category (excluding soft-deleted)
  Future<List<Habit>> getHabitsByCategory(HabitCategory category) {
    return (select(habits)
          ..where((h) =>
              h.category.equals(category.index) & h.deletedAt.isNull()))
        .get();
  }

  // Get a single habit by ID
  Future<Habit?> getHabitById(int id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  // Create a new habit
  Future<int> createHabit(HabitsCompanion habit) {
    final withTimestamp = habit.copyWith(updatedAt: Value(DateTime.now()));
    return into(habits).insert(withTimestamp);
  }

  // Update an existing habit
  Future<bool> updateHabit(Habit habit) {
    return update(habits).replace(habit.copyWith(updatedAt: DateTime.now()));
  }

  // Soft-delete a habit (so sync can propagate the deletion)
  Future<int> deleteHabit(int id) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Hard-delete (used by sync internals only — bypasses soft-delete)
  Future<int> hardDeleteHabit(int id) {
    return (delete(habits)..where((h) => h.id.equals(id))).go();
  }

  // Mark a habit as complete for today and update its streak.
  //
  // Streak rules:
  //   - First-ever completion (no prior `lastCompleted` AND no completion
  //     rows): streak becomes 1.
  //   - Completed yesterday: streak += 1.
  //   - Completed today already: no-op (early return).
  //   - Missed at least one day, not shielded: streak resets to 1.
  //   - Shielded: streak preserved (Travel/Illness mode).
  //
  // The streak is recomputed from the completion-history table on every
  // call, so it stays correct even if `lastCompleted` got out of sync.
  // Wrapped in a transaction so UI watchers see one atomic update — no
  // intermediate "completed but old streak" flash.
  Future<void> completeHabit(int id) async {
    await transaction(() async {
      final habit = await getHabitById(id);
      if (habit == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Idempotency guard: already completed today.
      final completedToday = await isCompletedOnDate(id, today);
      if (completedToday) return;

      // Insert today's completion FIRST so the recompute below sees it.
      await into(habitCompletions).insert(
        HabitCompletionsCompanion.insert(
          habitId: id,
          completedAt: today,
          updatedAt: Value(now),
        ),
      );

      var newStreak = await _computeStreakFromHistory(id, habit.isShielded);

      // Sync-race guard: if the persisted streak was higher than the
      // history-derived streak, AND the persisted `lastCompleted` says
      // the user was on a streak (today or yesterday), trust the persisted
      // streak and add 1. This covers the case where habits synced down
      // from another device but their historical completion rows haven't
      // pulled yet — we don't want a tap to nuke a 30-day streak just
      // because the rows are still in transit.
      final lc = habit.lastCompleted;
      if (lc != null && habit.currentStreak >= newStreak) {
        final lcDay = DateTime(lc.year, lc.month, lc.day);
        final daysAgo = today.difference(lcDay).inDays;
        if (daysAgo == 0) {
          // Already counted as on-streak; keep persisted.
          newStreak = habit.currentStreak > newStreak
              ? habit.currentStreak
              : newStreak;
        } else if (daysAgo == 1) {
          // Persisted lastCompleted = yesterday: today's tap continues it.
          final continued = habit.currentStreak + 1;
          if (continued > newStreak) newStreak = continued;
        }
        // daysAgo > 1 with non-shielded: streak is genuinely broken — let
        // newStreak (history-based) win, which will be 1 (just today).
      }

      final newBestStreak =
          newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

      await (update(habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(
          currentStreak: Value(newStreak),
          bestStreak: Value(newBestStreak),
          lastCompleted: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  // Walk the completion history backwards from today and count consecutive
  // days. Shielded habits tolerate gaps (don't break the streak).
  //
  // Dedupes by day before walking — sync can produce transient duplicates
  // for the same (habit, day) and we don't want to undercount.
  //
  // Used by both [completeHabit] and [uncompleteHabit] — keeping the math
  // in one place avoids the two paths drifting out of sync.
  Future<int> _computeStreakFromHistory(int habitId, bool isShielded) async {
    final completions = await getCompletionsForHabit(habitId);
    if (completions.isEmpty) return 0;

    // Collapse to a sorted set of unique day-keys (most recent first).
    final uniqueDays = <DateTime>{};
    for (final c in completions) {
      uniqueDays.add(
        DateTime(c.completedAt.year, c.completedAt.month, c.completedAt.day),
      );
    }
    final days = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mostRecent = days.first;

    // If the most recent completion isn't today or yesterday, the streak
    // is already broken — return 0 (the user is not currently on a streak).
    final daysAgo = today.difference(mostRecent).inDays;
    if (daysAgo > 1 && !isShielded) return 0;

    var streak = 0;
    var expected = mostRecent;
    for (final day in days) {
      if (day.isAtSameMomentAs(expected)) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (isShielded && day.isBefore(expected)) {
        // Shielded: skip the gap, count this completion.
        streak++;
        expected = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Remove today's completion and recompute the streak from history.
  // Wrapped in a transaction so UI sees one atomic update.
  Future<void> uncompleteHabit(int id) async {
    await transaction(() async {
      final habit = await getHabitById(id);
      if (habit == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final completedToday = await isCompletedOnDate(id, today);
      if (!completedToday) return;

      await deleteCompletion(id, today);

      final newStreak = await _computeStreakFromHistory(id, habit.isShielded);

      // Most recent remaining completion (after the soft-delete) is the new
      // lastCompleted, or null if there are no completions left.
      final remaining = await getCompletionsForHabit(id);
      final newLastCompleted =
          remaining.isEmpty ? null : remaining.first.completedAt;

      await (update(habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(
          currentStreak: Value(newStreak),
          lastCompleted: Value(newLastCompleted),
          updatedAt: Value(now),
        ),
      );
    });
  }

  // Reset habit streak (when shield is removed and days were missed)
  Future<void> resetHabitStreak(int id) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        currentStreak: const Value(0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Toggle shield status (Travel Mode / Illness Mode)
  Future<void> toggleShield(int id, bool isShielded) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        isShielded: Value(isShielded),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Get habits with active streaks
  Future<List<Habit>> getHabitsWithStreaks() {
    return (select(habits)
          ..where((h) =>
              h.currentStreak.isBiggerThanValue(0) & h.deletedAt.isNull()))
        .get();
  }

  // Stream all habits for real-time updates (excluding soft-deleted)
  Stream<List<Habit>> watchAllHabits() =>
      (select(habits)..where((h) => h.deletedAt.isNull())).watch();

  // Stream habits by category (excluding soft-deleted)
  Stream<List<Habit>> watchHabitsByCategory(HabitCategory category) {
    return (select(habits)
          ..where((h) =>
              h.category.equals(category.index) & h.deletedAt.isNull()))
        .watch();
  }

  // Stream habits with active streaks (excluding soft-deleted)
  Stream<List<Habit>> watchHabitsWithStreaks() {
    return (select(habits)
          ..where((h) =>
              h.currentStreak.isBiggerThanValue(0) & h.deletedAt.isNull()))
        .watch();
  }

  // Completion History Operations

  // Check if habit was completed on a specific date (excluding soft-deleted).
  // Tolerates multiple rows for the same day — sync can occasionally produce
  // duplicates if a remote echo races with a local write. Any non-deleted
  // row counts as completed.
  Future<bool> isCompletedOnDate(int habitId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = selectOnly(habitCompletions)
      ..addColumns([habitCompletions.id.count()])
      ..where(habitCompletions.habitId.equals(habitId) &
          habitCompletions.completedAt.isBiggerOrEqualValue(startOfDay) &
          habitCompletions.completedAt.isSmallerOrEqualValue(endOfDay) &
          habitCompletions.deletedAt.isNull());
    final row = await query.getSingle();
    final count = row.read(habitCompletions.id.count()) ?? 0;
    return count > 0;
  }

  // Get all completions for a habit (excluding soft-deleted)
  Future<List<HabitCompletion>> getCompletionsForHabit(int habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();
  }

  // Get completions for a habit in a date range (excluding soft-deleted)
  Future<List<HabitCompletion>> getCompletionsInRange(
    int habitId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) &
              c.completedAt.isBiggerOrEqualValue(startDate) &
              c.completedAt.isSmallerOrEqualValue(endDate) &
              c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();
  }

  // Soft-delete a completion record so sync can propagate the deletion
  Future<int> deleteCompletion(int habitId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final now = DateTime.now();
    return (update(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) &
              c.completedAt.isBiggerOrEqualValue(startOfDay) &
              c.completedAt.isSmallerOrEqualValue(endOfDay) &
              c.deletedAt.isNull()))
        .write(HabitCompletionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // Get completion count for a habit (excluding soft-deleted)
  Future<int> getCompletionCount(int habitId) async {
    final result = await (selectOnly(habitCompletions)
          ..addColumns([habitCompletions.id.count()])
          ..where(habitCompletions.habitId.equals(habitId) &
              habitCompletions.deletedAt.isNull()))
        .getSingle();

    return result.read(habitCompletions.id.count()) ?? 0;
  }

  // ============================================================
  // Sync helpers — used by SyncService, not by UI code.
  // ============================================================

  // All habits modified after [since] (for push to Firestore).
  Future<List<Habit>> getHabitsUpdatedSince(DateTime since) {
    return (select(habits)..where((h) => h.updatedAt.isBiggerThanValue(since)))
        .get();
  }

  // All completions modified after [since] (for push to Firestore).
  Future<List<HabitCompletion>> getCompletionsUpdatedSince(DateTime since) {
    return (select(habitCompletions)
          ..where((c) => c.updatedAt.isBiggerThanValue(since)))
        .get();
  }

  // Get habit by remoteId (Firestore doc id).
  Future<Habit?> getHabitByRemoteId(String remoteId) {
    return (select(habits)..where((h) => h.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  // Get completion by remoteId.
  Future<HabitCompletion?> getCompletionByRemoteId(String remoteId) {
    return (select(habitCompletions)
          ..where((c) => c.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  // Set the remote ID after Firestore confirms a write.
  Future<void> setHabitRemoteId(int id, String remoteId) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(remoteId: Value(remoteId)),
    );
  }

  Future<void> setCompletionRemoteId(int id, String remoteId) async {
    await (update(habitCompletions)..where((c) => c.id.equals(id))).write(
      HabitCompletionsCompanion(remoteId: Value(remoteId)),
    );
  }

  // Upsert from a remote habit. If [remoteId] exists locally, update only when
  // the remote `updatedAt` is newer (last-write-wins). Otherwise insert.
  Future<void> upsertHabitFromRemote({
    required String remoteId,
    required HabitsCompanion data,
    required DateTime remoteUpdatedAt,
  }) async {
    final existing = await getHabitByRemoteId(remoteId);
    if (existing == null) {
      // Insert new — let local id auto-increment, store remoteId.
      final companion = data.copyWith(
        remoteId: Value(remoteId),
        updatedAt: Value(remoteUpdatedAt),
      );
      await into(habits).insert(companion);
    } else if (remoteUpdatedAt.isAfter(existing.updatedAt)) {
      await (update(habits)..where((h) => h.id.equals(existing.id))).write(
        data.copyWith(updatedAt: Value(remoteUpdatedAt)),
      );
    }
  }

  Future<void> upsertCompletionFromRemote({
    required String remoteId,
    required HabitCompletionsCompanion data,
    required DateTime remoteUpdatedAt,
  }) async {
    // 1. Match by remoteId first.
    var existing = await getCompletionByRemoteId(remoteId);

    // 2. Fallback: match by (habitId, day) regardless of deletedAt. This
    //    catches:
    //    a) a local insert that hasn't been pushed yet (no remoteId) and
    //       the same completion arrives from another device — without this
    //       we'd insert a duplicate
    //    b) a remote tombstone (deletedAt set) for a row that was created
    //       locally — we need to find the live row to mark it deleted, not
    //       insert a new deleted row alongside it
    if (existing == null && data.habitId.present && data.completedAt.present) {
      final habitId = data.habitId.value;
      final completedAt = data.completedAt.value;
      final startOfDay =
          DateTime(completedAt.year, completedAt.month, completedAt.day);
      final endOfDay = DateTime(
          completedAt.year, completedAt.month, completedAt.day, 23, 59, 59);
      existing = await (select(habitCompletions)
            ..where((c) =>
                c.habitId.equals(habitId) &
                c.completedAt.isBiggerOrEqualValue(startOfDay) &
                c.completedAt.isSmallerOrEqualValue(endOfDay))
            ..orderBy([(c) => OrderingTerm.asc(c.id)])
            ..limit(1))
          .getSingleOrNull();
    }

    int? affectedHabitId;
    if (existing == null) {
      final companion = data.copyWith(
        remoteId: Value(remoteId),
        updatedAt: Value(remoteUpdatedAt),
      );
      await into(habitCompletions).insert(companion);
      if (data.habitId.present) affectedHabitId = data.habitId.value;
    } else {
      // Always claim the remoteId on the existing row (even if remote isn't
      // newer) so future updates to this row find it by remoteId.
      if (existing.remoteId != remoteId) {
        await (update(habitCompletions)..where((c) => c.id.equals(existing!.id)))
            .write(HabitCompletionsCompanion(remoteId: Value(remoteId)));
      }
      if (remoteUpdatedAt.isAfter(existing.updatedAt)) {
        await (update(habitCompletions)..where((c) => c.id.equals(existing!.id)))
            .write(data.copyWith(updatedAt: Value(remoteUpdatedAt)));
      }
      affectedHabitId = existing.habitId;
    }

    // After a remote completion is applied, recompute the habit's streak
    // and `lastCompleted` from the actual history. Otherwise a sync race
    // (user taps "complete" on a habit before its remote completions have
    // finished pulling) can leave currentStreak stale — the local tap
    // recomputed against an empty/partial history and overwrote the synced
    // streak. Recomputing here corrects it as soon as the data arrives.
    if (affectedHabitId != null) {
      await _recomputeStreakAndLastCompleted(affectedHabitId);
    }
  }

  // Recompute `currentStreak` and `lastCompleted` from the completion
  // history. Used by sync after pulling completions. Does NOT change
  // `bestStreak` (best is monotonic) and does NOT bump `updatedAt` — so
  // the recompute itself doesn't push back into Firestore as a "user
  // change". The streak/lastCompleted field that comes down from the
  // other device gets stamped in by `_applyRemoteHabit`; this is just a
  // local consistency pass.
  Future<void> _recomputeStreakAndLastCompleted(int habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return;
    final newStreak = await _computeStreakFromHistory(habitId, habit.isShielded);
    final completions = await getCompletionsForHabit(habitId);
    final newLastCompleted =
        completions.isEmpty ? null : completions.first.completedAt;
    final newBestStreak =
        newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

    // Only write if something actually changed, to avoid re-firing watchers
    // and re-triggering a needless sync push.
    if (newStreak == habit.currentStreak &&
        newLastCompleted == habit.lastCompleted &&
        newBestStreak == habit.bestStreak) {
      return;
    }

    await (update(habits)..where((h) => h.id.equals(habitId))).write(
      HabitsCompanion(
        currentStreak: Value(newStreak),
        bestStreak: Value(newBestStreak),
        lastCompleted: Value(newLastCompleted),
      ),
    );
  }

  // Soft-delete duplicate completion rows for the same (habitId, day),
  // keeping the row with the lowest id. The soft-delete propagates via
  // sync, so the orphan Firestore docs eventually get tombstoned too.
  // Run once at startup as a defensive sweep — a no-op once everything
  // is clean.
  Future<int> dedupeCompletions() async {
    final all = await (select(habitCompletions)
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
    final seen = <String>{};
    final dupeIds = <int>[];
    for (final c in all) {
      final dayKey =
          '${c.habitId}-${c.completedAt.year}-${c.completedAt.month}-${c.completedAt.day}';
      if (!seen.add(dayKey)) {
        dupeIds.add(c.id);
      }
    }
    if (dupeIds.isEmpty) return 0;
    final now = DateTime.now();
    await (update(habitCompletions)..where((c) => c.id.isIn(dupeIds))).write(
      HabitCompletionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return dupeIds.length;
  }

  // Wipe all local data (used after sign-out -> sign-in as different user
  // when we want a clean slate, OR on account deletion).
  Future<void> wipeAllLocalData() async {
    await delete(habitCompletions).go();
    await delete(habits).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sakinah_habits.sqlite'));
    return NativeDatabase(file);
  });
}
