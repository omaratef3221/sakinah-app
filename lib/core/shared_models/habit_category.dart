enum HabitCategory {
  fard,
  sunnah,
  athkar;

  String get displayName {
    switch (this) {
      case HabitCategory.fard:
        return 'Fard';
      case HabitCategory.sunnah:
        return 'Sunnah';
      case HabitCategory.athkar:
        return 'Athkar';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case HabitCategory.fard:
        return 'فرض';
      case HabitCategory.sunnah:
        return 'سنة';
      case HabitCategory.athkar:
        return 'أذكار';
    }
  }
}
