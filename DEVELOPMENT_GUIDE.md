# Sakinah Flow - Development Guide

## Quick Reference for Common Patterns

### 1. Creating a New Riverpod Provider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'your_provider.g.dart';

@riverpod
class YourNotifier extends _$YourNotifier {
  @override
  YourType build() {
    // Initialize state
    return initialValue;
  }

  // Add methods to mutate state
  void updateSomething() {
    state = newValue;
  }
}
```

**Don't forget to run:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Using Providers in Widgets

```dart
class MyScreen extends HookConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch a provider (rebuilds when it changes)
    final value = ref.watch(yourNotifierProvider);

    // Read a provider (one-time access, no rebuild)
    final notifier = ref.read(yourNotifierProvider.notifier);

    // Watch async provider
    final asyncValue = ref.watch(asyncProviderProvider);

    return asyncValue.when(
      data: (data) => Text('Data: $data'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 3. Adding Arabic Text with RTL Support

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: Text(
    'النص العربي هنا',
    style: AppTheme.arabicTextStyle.copyWith(
      fontSize: 18,
      color: AppColors.emerald,
    ),
  ),
)
```

### 4. Adding a New Habit Category

**Step 1**: Update enum in [lib/core/shared_models/habit_category.dart](lib/core/shared_models/habit_category.dart)

```dart
enum HabitCategory {
  fard,
  sunnah,
  athkar,
  yourNewCategory; // Add here

  String get displayName {
    switch (this) {
      case HabitCategory.yourNewCategory:
        return 'Your Category';
      // ... other cases
    }
  }

  String get displayNameArabic {
    switch (this) {
      case HabitCategory.yourNewCategory:
        return 'فئتك الجديدة';
      // ... other cases
    }
  }
}
```

**Step 2**: Run build_runner
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Database Operations

#### Get Database Instance
```dart
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(habitsDatabaseProvider);

    // Use database...
  }
}
```

#### Create a Habit
```dart
final database = ref.read(habitsDatabaseProvider);

await database.createHabit(
  HabitsCompanion.insert(
    title: 'Morning Dhikr',
    category: HabitCategory.athkar,
    ayahReference: Value('Al-Ahzab 33:41'),
  ),
);
```

#### Complete a Habit (Update Streak)
```dart
await database.completeHabit(habitId);
// This automatically:
// - Increments streak if done consecutively
// - Resets to 1 if days were missed (and not shielded)
// - Preserves streak if shielded
```

#### Toggle Shield Mode
```dart
await database.toggleShield(habitId, true); // Enable shield
await database.toggleShield(habitId, false); // Disable shield
```

#### Watch Habits (Real-time Stream)
```dart
@riverpod
Stream<List<Habit>> watchMyHabits(WatchMyHabitsRef ref) {
  final database = ref.watch(habitsDatabaseProvider);
  return database.watchAllHabits();
}

// In widget:
final habitsAsync = ref.watch(watchMyHabitsProvider);

habitsAsync.when(
  data: (habits) => ListView.builder(
    itemCount: habits.length,
    itemBuilder: (context, index) => HabitCard(habit: habits[index]),
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### 6. Adding a New Time Context

**File**: [lib/features/habits/providers/active_context_provider.dart](lib/features/habits/providers/active_context_provider.dart)

```dart
enum ActiveContext {
  // ... existing contexts
  yourNewContext;

  String get displayName {
    switch (this) {
      case ActiveContext.yourNewContext:
        return 'Your Context Name';
      // ... other cases
    }
  }

  String get arabicName {
    switch (this) {
      case ActiveContext.yourNewContext:
        return 'اسم السياق بالعربية';
      // ... other cases
    }
  }
}

// In _calculateActiveContext method:
ActiveContext _calculateActiveContext(PrayerTimes prayerTimes) {
  final now = DateTime.now();

  // Add your condition
  if (yourCondition) {
    return ActiveContext.yourNewContext;
  }

  // ... other conditions
}
```

### 7. Creating a Context-Specific Habit Stack

**File**: [lib/features/habits/providers/habit_stacker_provider.dart](lib/features/habits/providers/habit_stacker_provider.dart)

```dart
List<HabitStackItem> _yourContextStack() {
  return [
    const HabitStackItem(
      title: 'Your Habit Title',
      titleArabic: 'عنوان العادة',
      description: 'Clear description of what to do',
      ayahReference: 'Quran reference or hadith',
      priority: 1,
      category: 'Sunnah',
    ),
    // Add more items...
  ];
}

// In _buildHabitStack method:
List<HabitStackItem> _buildHabitStack(ActiveContext context) {
  switch (context) {
    case ActiveContext.yourNewContext:
      return _yourContextStack();
    // ... other cases
  }
}
```

### 8. Custom Animations with flutter_animate

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Fade in animation
Text('Hello')
  .animate()
  .fade(duration: 600.ms)
  .slide();

// Custom animation sequence
Container(/* ... */)
  .animate()
  .fadeIn(duration: 800.ms)
  .then(delay: 200.ms)
  .slide(begin: Offset(0, 0.2), duration: 600.ms);
```

### 9. Using Prayer Times in Your Code

```dart
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);

    return prayerTimesAsync.when(
      data: (prayerTimes) {
        if (prayerTimes == null) return Text('Location unavailable');

        // Access prayer times
        final fajr = prayerTimes.fajr;
        final dhuhr = prayerTimes.dhuhr;
        final asr = prayerTimes.asr;
        final maghrib = prayerTimes.maghrib;
        final isha = prayerTimes.isha;

        // Get next prayer
        final next = prayerTimes.nextPrayer();

        // Get current prayer
        final current = prayerTimes.currentPrayer();

        return Column(
          children: [
            Text('Fajr: ${fajr.hour}:${fajr.minute}'),
            Text('Next: ${next.englishName} (${next.arabicName})'),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading prayer times'),
    );
  }
}
```

### 10. Color Usage Guidelines

```dart
// Primary actions, emphasis
color: AppColors.emerald

// Warm highlights, backgrounds
color: AppColors.sand

// Text, subtle elements
color: AppColors.slate

// Category-specific colors
color: AppColors.fardColor    // For Fard prayers
color: AppColors.sunnahColor  // For Sunnah practices
color: AppColors.athkarColor  // For Athkar/Dhikr
```

## Best Practices

### DO ✅

- Always use `HookConsumerWidget` for components that need state
- Wrap Arabic text in `Directionality(textDirection: TextDirection.rtl)`
- Use Amiri font for Arabic, Inter for English
- Keep methods small and focused (single responsibility)
- Use descriptive variable names
- Add comments for complex business logic
- Run `build_runner` after changing providers or database schema
- Use `.when()` for handling AsyncValue states properly

### DON'T ❌

- Mix Arabic and English in the same `Text` widget without proper handling
- Directly access `state` outside of notifier methods
- Forget to add `part 'file.g.dart'` when using code generation
- Use `setState` (this is a Riverpod app!)
- Hard-code colors (use AppColors constants)
- Create stateful widgets (use HookConsumerWidget instead)
- Skip error handling for async operations

## Common Issues & Solutions

### Issue: Provider not found
**Solution**: Make sure you've run `build_runner` and the generated file is imported.

### Issue: Arabic text displays left-to-right
**Solution**: Wrap in `Directionality` widget with `TextDirection.rtl`.

### Issue: Database changes not reflecting
**Solution**:
1. Check if you ran `build_runner` after schema changes
2. Verify you're using `.watch()` for streams, not one-time queries
3. For testing, delete the app and reinstall to reset database

### Issue: Location not updating
**Solution**:
1. Check permissions are granted (iOS Info.plist, Android Manifest)
2. Test on physical device (simulator may have issues)
3. Call `ref.read(locationNotifierProvider.notifier).refreshLocation()`

### Issue: Prayer times incorrect
**Solution**:
1. Verify location accuracy
2. Check calculation method (currently Muslim World League)
3. Adjust madhab setting if needed (currently Shafi)

## Performance Tips

1. **Use `.select()` for granular updates**
```dart
final count = ref.watch(
  habitsProvider.select((habits) => habits.length)
);
// Only rebuilds when count changes, not when habit details change
```

2. **Debounce expensive operations**
```dart
final debounce = useDebounce(searchQuery, Duration(milliseconds: 500));
```

3. **Use `ListView.builder` for long lists**
```dart
ListView.builder(
  itemCount: habits.length,
  itemBuilder: (context, index) => HabitCard(habit: habits[index]),
)
```

## Testing Commands

```bash
# Run the app
flutter run

# Build for release
flutter build apk  # Android
flutter build ios  # iOS

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests (when added)
flutter test

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-generate)
dart run build_runner watch --delete-conflicting-outputs
```

---

**Remember**: Keep the code clean, focused, and spiritually mindful. Every line of code is an act of service to the Muslim community.

May Allah accept this work as a means of guidance and benefit for the Ummah. آمين
