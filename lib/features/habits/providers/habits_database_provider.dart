import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';
import 'package:sakinah_flow/features/habits/data/database/database_seeder.dart';

part 'habits_database_provider.g.dart';

// keepAlive: a Drift database must be a singleton for the app's lifetime.
// Auto-dispose causes the connection to close and reopen against the same
// SQLite file as widgets remount, which Drift treats as a hard error
// ("Can't re-open a database after closing it") and risks corruption.
@Riverpod(keepAlive: true)
HabitsDatabase habitsDatabase(Ref ref) {
  final database = HabitsDatabase();
  // One-shot cleanup of any duplicate completions left behind by an earlier
  // sync race (multiple rows for the same habit+day). Cheap no-op once clean.
  database.dedupeCompletions();
  ref.onDispose(() => database.close());
  return database;
}

// Initialize database with seed data
@riverpod
Future<void> initializeDatabase(Ref ref) async {
  final database = ref.watch(habitsDatabaseProvider);
  final seeder = DatabaseSeeder(database);
  await seeder.seedInitialHabits();
}

// Stream all habits
@riverpod
Stream<List<Habit>> watchAllHabits(Ref ref) {
  final database = ref.watch(habitsDatabaseProvider);
  return database.watchAllHabits();
}

// Stream Fard habits
@riverpod
Stream<List<Habit>> watchFardHabits(Ref ref) {
  final database = ref.watch(habitsDatabaseProvider);
  return database.watchHabitsByCategory(HabitCategory.fard);
}

// Stream Sunnah habits
@riverpod
Stream<List<Habit>> watchSunnahHabits(Ref ref) {
  final database = ref.watch(habitsDatabaseProvider);
  return database.watchHabitsByCategory(HabitCategory.sunnah);
}

// Stream habits with active streaks
@riverpod
Stream<List<Habit>> watchHabitsWithStreaks(Ref ref) {
  final database = ref.watch(habitsDatabaseProvider);
  return database.watchHabitsWithStreaks();
}
