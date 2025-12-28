import 'package:sakinah_flow/core/shared_models/habit_category.dart';

class HabitDataModel {
  final String title;
  final String titleArabic;
  final String description;
  final HabitCategory category;
  final String ayahReference;
  final int priority;
  final String icon;

  HabitDataModel({
    required this.title,
    required this.titleArabic,
    required this.description,
    required this.category,
    required this.ayahReference,
    required this.priority,
    required this.icon,
  });

  factory HabitDataModel.fromJson(Map<String, dynamic> json) {
    return HabitDataModel(
      title: json['title'] as String,
      titleArabic: json['title_arabic'] as String,
      description: json['description'] as String,
      category: _parseCategoryFromString(json['category'] as String),
      ayahReference: json['ayah_reference'] as String,
      priority: json['priority'] as int,
      icon: json['icon'] as String,
    );
  }

  static HabitCategory _parseCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'fard':
        return HabitCategory.fard;
      case 'sunnah':
        return HabitCategory.sunnah;
      case 'athkar':
        return HabitCategory.athkar;
      default:
        return HabitCategory.sunnah;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'title_arabic': titleArabic,
      'description': description,
      'category': category.name,
      'ayah_reference': ayahReference,
      'priority': priority,
      'icon': icon,
    };
  }
}

class HabitsJsonData {
  final List<HabitDataModel> fardHabits;
  final List<HabitDataModel> sunnahHabits;

  HabitsJsonData({
    required this.fardHabits,
    required this.sunnahHabits,
  });

  factory HabitsJsonData.fromJson(Map<String, dynamic> json) {
    return HabitsJsonData(
      fardHabits: (json['fard_habits'] as List)
          .map((habit) => HabitDataModel.fromJson(habit as Map<String, dynamic>))
          .toList(),
      sunnahHabits: (json['sunnah_habits'] as List)
          .map((habit) => HabitDataModel.fromJson(habit as Map<String, dynamic>))
          .toList(),
    );
  }

  List<HabitDataModel> get allHabits => [...fardHabits, ...sunnahHabits];
}
