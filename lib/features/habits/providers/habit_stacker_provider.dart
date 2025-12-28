import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/features/habits/providers/active_context_provider.dart';

part 'habit_stacker_provider.g.dart';

/// Represents a suggested habit in the stack
class HabitStackItem {
  final String title;
  final String titleArabic;
  final String description;
  final String ayahReference;
  final int priority;
  final String category;

  const HabitStackItem({
    required this.title,
    required this.titleArabic,
    required this.description,
    required this.ayahReference,
    required this.priority,
    required this.category,
  });
}

@riverpod
class HabitStackerNotifier extends _$HabitStackerNotifier {
  @override
  List<HabitStackItem> build() {
    final context = ref.watch(activeContextNotifierProvider);
    return _buildHabitStack(context);
  }

  List<HabitStackItem> _buildHabitStack(ActiveContext context) {
    switch (context) {
      case ActiveContext.beforeFajr:
        return _beforeFajrStack();
      case ActiveContext.fajrTime:
        return _fajrStack();
      case ActiveContext.morningTime:
        return _morningStack();
      case ActiveContext.maghribToIshaTime:
        return _eveningStack(); // Special stack for Maghrib-Isha time
      case ActiveContext.ishaTime:
        return _ishaStack();
      case ActiveContext.nightTime:
        return _nightStack();
      default:
        return _defaultStack();
    }
  }

  // Special: Evening Stack (Maghrib to Isha)
  // Priority: 1. Maghrib Sunnah, 2. Evening Athkar, 3. Reviewing Ayah on gratitude
  List<HabitStackItem> _eveningStack() {
    return [
      const HabitStackItem(
        title: 'Maghrib Sunnah Prayer',
        titleArabic: 'سنة المغرب',
        description: 'Pray 2 rakaat Sunnah after Maghrib',
        ayahReference: 'The Prophet ﷺ never missed the Sunnah prayers',
        priority: 1,
        category: 'Sunnah',
      ),
      const HabitStackItem(
        title: 'Evening Athkar',
        titleArabic: 'أذكار المساء',
        description: 'Recite the evening remembrance',
        ayahReference: 'وَاذْكُر رَّبَّكَ فِي نَفْسِكَ تَضَرُّعًا وَخِيفَةً',
        priority: 2,
        category: 'Athkar',
      ),
      const HabitStackItem(
        title: 'Reflect on Gratitude',
        titleArabic: 'تأمل في الشكر',
        description: 'Review an Ayah about being grateful',
        ayahReference: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ - Ibrahim 14:7',
        priority: 3,
        category: 'Reflection',
      ),
    ];
  }

  List<HabitStackItem> _beforeFajrStack() {
    return [
      const HabitStackItem(
        title: 'Tahajjud Prayer',
        titleArabic: 'صلاة التهجد',
        description: 'Pray voluntary night prayer',
        ayahReference: 'وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ - Al-Isra 17:79',
        priority: 1,
        category: 'Sunnah',
      ),
      const HabitStackItem(
        title: 'Pre-Fajr Dua',
        titleArabic: 'دعاء قبل الفجر',
        description: 'Make sincere dua before Fajr',
        ayahReference: 'The last third of night - best time for dua',
        priority: 2,
        category: 'Athkar',
      ),
    ];
  }

  List<HabitStackItem> _fajrStack() {
    return [
      const HabitStackItem(
        title: 'Fajr Prayer',
        titleArabic: 'صلاة الفجر',
        description: 'Pray Fajr in congregation or on time',
        ayahReference: 'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ - Al-Isra 17:78',
        priority: 1,
        category: 'Fard',
      ),
      const HabitStackItem(
        title: 'Morning Athkar',
        titleArabic: 'أذكار الصباح',
        description: 'Recite morning remembrance',
        ayahReference: 'وَاذْكُر رَّبَّكَ كَثِيرًا - Al-Anfal 8:45',
        priority: 2,
        category: 'Athkar',
      ),
    ];
  }

  List<HabitStackItem> _morningStack() {
    return [
      const HabitStackItem(
        title: 'Quran Recitation',
        titleArabic: 'تلاوة القرآن',
        description: 'Read and reflect on Quran',
        ayahReference: 'إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا - Al-Isra 17:78',
        priority: 1,
        category: 'Athkar',
      ),
      const HabitStackItem(
        title: 'Duha Prayer',
        titleArabic: 'صلاة الضحى',
        description: 'Pray 2-8 rakaat in Duha time',
        ayahReference: 'Sunnah of the Prophet ﷺ',
        priority: 2,
        category: 'Sunnah',
      ),
    ];
  }

  List<HabitStackItem> _ishaStack() {
    return [
      const HabitStackItem(
        title: 'Isha Prayer',
        titleArabic: 'صلاة العشاء',
        description: 'Pray Isha in congregation or on time',
        ayahReference: 'حَافِظُوا عَلَى الصَّلَوَاتِ - Al-Baqarah 2:238',
        priority: 1,
        category: 'Fard',
      ),
      const HabitStackItem(
        title: 'Witr Prayer',
        titleArabic: 'صلاة الوتر',
        description: 'Pray Witr before sleeping',
        ayahReference: 'The Prophet ﷺ never left Witr',
        priority: 2,
        category: 'Sunnah',
      ),
    ];
  }

  List<HabitStackItem> _nightStack() {
    return [
      const HabitStackItem(
        title: 'Sleeping Dua',
        titleArabic: 'أذكار النوم',
        description: 'Recite before sleeping',
        ayahReference: 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
        priority: 1,
        category: 'Athkar',
      ),
    ];
  }

  List<HabitStackItem> _defaultStack() {
    return [
      const HabitStackItem(
        title: 'Remember Allah',
        titleArabic: 'ذكر الله',
        description: 'Keep your tongue moist with dhikr',
        ayahReference: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ - Ar-Rad 13:28',
        priority: 1,
        category: 'Athkar',
      ),
    ];
  }

  // Get top priority habit
  HabitStackItem? get topPriorityHabit {
    if (state.isEmpty) return null;
    return state.first;
  }

  // Get all habits sorted by priority
  List<HabitStackItem> get sortedByPriority {
    final list = [...state];
    list.sort((a, b) => a.priority.compareTo(b.priority));
    return list;
  }
}
