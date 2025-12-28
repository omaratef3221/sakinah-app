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
}

// Completion history table to track each day a habit was completed
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Habits, HabitCompletions])
class HabitsDatabase extends _$HabitsDatabase {
  HabitsDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
    },
  );

  // CRUD Operations

  // Get all habits
  Future<List<Habit>> getAllHabits() => select(habits).get();

  // Get habits by category
  Future<List<Habit>> getHabitsByCategory(HabitCategory category) {
    return (select(habits)..where((h) => h.category.equals(category.index)))
        .get();
  }

  // Get a single habit by ID
  Future<Habit?> getHabitById(int id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  // Create a new habit
  Future<int> createHabit(HabitsCompanion habit) {
    return into(habits).insert(habit);
  }

  // Update an existing habit
  Future<bool> updateHabit(Habit habit) {
    return update(habits).replace(habit);
  }

  // Delete a habit
  Future<int> deleteHabit(int id) {
    return (delete(habits)..where((h) => h.id.equals(id))).go();
  }

  // Update habit streak (increment)
  Future<void> completeHabit(int id) async {
    final habit = await getHabitById(id);
    if (habit == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = habit.lastCompleted;

    // Check if already completed today
    final completedToday = await isCompletedOnDate(id, today);
    if (completedToday) return; // Don't complete again

    int newStreak = habit.currentStreak;
    int newBestStreak = habit.bestStreak;

    if (lastCompleted != null) {
      final lastDay = DateTime(lastCompleted.year, lastCompleted.month, lastCompleted.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      // If completed yesterday, increment streak
      if (lastDay.isAtSameMomentAs(yesterday)) {
        newStreak = habit.currentStreak + 1;
      }
      // If completed today (shouldn't happen due to check above)
      else if (lastDay.isAtSameMomentAs(today)) {
        newStreak = habit.currentStreak;
      }
      // If missed days and not shielded, reset to 1
      else if (!habit.isShielded) {
        newStreak = 1;
      }
      // If shielded, keep the current streak
      else {
        newStreak = habit.currentStreak;
      }
    } else {
      // First time completing
      newStreak = 1;
    }

    // Update best streak if current is higher
    if (newStreak > newBestStreak) {
      newBestStreak = newStreak;
    }

    // Add completion record
    await into(habitCompletions).insert(
      HabitCompletionsCompanion.insert(
        habitId: id,
        completedAt: today,
      ),
    );

    // Update habit streak
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        currentStreak: Value(newStreak),
        bestStreak: Value(newBestStreak),
        lastCompleted: Value(now),
      ),
    );
  }

  // Uncomplete a habit (remove today's completion)
  Future<void> uncompleteHabit(int id) async {
    final habit = await getHabitById(id);
    if (habit == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if completed today
    final completedToday = await isCompletedOnDate(id, today);
    if (!completedToday) return; // Nothing to uncomplete

    // Delete today's completion record
    await deleteCompletion(id, today);

    // Recalculate streak based on remaining completions
    final completions = await getCompletionsForHabit(id);

    int newStreak = 0;
    DateTime? newLastCompleted;

    if (completions.isNotEmpty) {
      newLastCompleted = completions.first.completedAt;

      // Calculate streak from most recent completion backwards
      final sortedCompletions = completions.toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

      DateTime expectedDate = DateTime(
        sortedCompletions.first.completedAt.year,
        sortedCompletions.first.completedAt.month,
        sortedCompletions.first.completedAt.day,
      );

      for (final completion in sortedCompletions) {
        final completionDate = DateTime(
          completion.completedAt.year,
          completion.completedAt.month,
          completion.completedAt.day,
        );

        if (completionDate.isAtSameMomentAs(expectedDate) ||
            (habit.isShielded && completionDate.isBefore(expectedDate))) {
          newStreak++;
          expectedDate = DateTime(
            expectedDate.year,
            expectedDate.month,
            expectedDate.day - 1,
          );
        } else if (!habit.isShielded) {
          break;
        }
      }
    }

    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        currentStreak: Value(newStreak),
        lastCompleted: Value(newLastCompleted),
      ),
    );
  }

  // Reset habit streak (when shield is removed and days were missed)
  Future<void> resetHabitStreak(int id) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      const HabitsCompanion(
        currentStreak: Value(0),
      ),
    );
  }

  // Toggle shield status (Travel Mode / Illness Mode)
  Future<void> toggleShield(int id, bool isShielded) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        isShielded: Value(isShielded),
      ),
    );
  }

  // Get habits with active streaks
  Future<List<Habit>> getHabitsWithStreaks() {
    return (select(habits)..where((h) => h.currentStreak.isBiggerThanValue(0)))
        .get();
  }

  // Stream all habits for real-time updates
  Stream<List<Habit>> watchAllHabits() => select(habits).watch();

  // Stream habits by category
  Stream<List<Habit>> watchHabitsByCategory(HabitCategory category) {
    return (select(habits)..where((h) => h.category.equals(category.index)))
        .watch();
  }

  // Stream habits with active streaks
  Stream<List<Habit>> watchHabitsWithStreaks() {
    return (select(habits)..where((h) => h.currentStreak.isBiggerThanValue(0)))
        .watch();
  }

  // Completion History Operations

  // Check if habit was completed on a specific date
  Future<bool> isCompletedOnDate(int habitId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final completion = await (select(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) &
              c.completedAt.isBiggerOrEqualValue(startOfDay) &
              c.completedAt.isSmallerOrEqualValue(endOfDay)))
        .getSingleOrNull();

    return completion != null;
  }

  // Get all completions for a habit
  Future<List<HabitCompletion>> getCompletionsForHabit(int habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();
  }

  // Get completions for a habit in a date range
  Future<List<HabitCompletion>> getCompletionsInRange(
    int habitId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) &
              c.completedAt.isBiggerOrEqualValue(startDate) &
              c.completedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();
  }

  // Delete a completion record
  Future<int> deleteCompletion(int habitId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return (delete(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) &
              c.completedAt.isBiggerOrEqualValue(startOfDay) &
              c.completedAt.isSmallerOrEqualValue(endOfDay)))
        .go();
  }

  // Get completion count for a habit
  Future<int> getCompletionCount(int habitId) async {
    final result = await (selectOnly(habitCompletions)
          ..addColumns([habitCompletions.id.count()])
          ..where(habitCompletions.habitId.equals(habitId)))
        .getSingle();

    return result.read(habitCompletions.id.count()) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sakinah_habits.sqlite'));
    return NativeDatabase(file);
  });
}
