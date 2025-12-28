import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';

class DatabaseSeeder {
  final HabitsDatabase database;

  DatabaseSeeder(this.database);

  /// Initialize the database (no auto-seeding, users select habits)
  Future<void> seedInitialHabits() async {
    // Just initialize the database connection
    // Users will add habits manually from the preset list
  }
}
