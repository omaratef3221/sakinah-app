import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sakinah_flow/features/habits/data/models/habit_data_model.dart';

class HabitsJsonLoader {
  static const String _jsonPath = 'assets/data/habits.json';

  /// Loads habits data from JSON file
  static Future<HabitsJsonData> loadHabitsData() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return HabitsJsonData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load habits data from JSON: $e');
    }
  }

  /// Get all fard habits from JSON
  static Future<List<HabitDataModel>> loadFardHabits() async {
    final data = await loadHabitsData();
    return data.fardHabits;
  }

  /// Get all sunnah habits from JSON
  static Future<List<HabitDataModel>> loadSunnahHabits() async {
    final data = await loadHabitsData();
    return data.sunnahHabits;
  }

  /// Get all habits from JSON
  static Future<List<HabitDataModel>> loadAllHabits() async {
    final data = await loadHabitsData();
    return data.allHabits;
  }
}
