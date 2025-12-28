# Sakinah Flow

A high-end AI-powered Islamic Habit Tracker built with Flutter. Sakinah Flow helps Muslims build and maintain spiritual habits through intelligent prayer time awareness, context-sensitive habit suggestions, and streak tracking with compassionate "shield" protection.

## Features

### Phase 1: The Spiritual Engine
- **AdhanService**: Calculates accurate prayer times based on GPS coordinates using the `adhan` package
- **Location-aware**: Automatically detects your location to provide precise prayer times
- **Prayer Time Tracking**: Real-time tracking of all five daily prayers plus sunrise

### Phase 2: The Sunnah Bridge & Habit Stacker
- **Active Context Engine**: Intelligently determines the current time context (before Fajr, Fajr time, morning, etc.)
- **Smart Habit Stacking**: Prioritizes habits based on current prayer time context
- **Evening Stack (Maghrib-Isha)**: Special priority system that suggests:
  1. Maghrib Sunnah Prayer
  2. Evening Athkar (remembrance)
  3. Reflection on gratitude Ayahs

### Phase 3: The Mizan (Balance) UI
- **Emerald, Sand & Slate Theme**: Carefully crafted color palette for a calming spiritual experience
- **Bilingual Support**: Seamless Arabic (Amiri font) and English (Inter font) text
- **Breathable Animations**: Smooth transitions using `flutter_animate`

### Phase 4: Streak "Shield" Logic
- **Habit Tracking**: Comprehensive habit database with categories (Fard, Sunnah, Athkar)
- **Streak Protection**: "Shield" mode for travel or illness prevents streak resets
- **Ayah References**: Each habit linked to relevant Quranic verses

## Technical Stack

### State Management
- **HooksRiverpod**: Modern, declarative state management
- All UI components use `HookConsumerWidget` for reactive updates

### Local Database
- **Drift (SQLite)**: Type-safe SQL queries with powerful ORM
- Habit schema with streak tracking, categories, and Ayah references
- Real-time database streams for instant UI updates

### Prayer Times & Location
- **adhan package**: Accurate prayer time calculations
- **geolocator**: GPS-based location services

### UI & Animations
- **flutter_animate**: Smooth, breathable animations with `.fade()` and `.slide()` effects
- **Custom Theme**: Material Design 3 with custom color scheme

## Project Architecture

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart              # Theme configuration
│   ├── constants/
│   │   └── app_colors.dart             # Color palette
│   └── shared_models/
│       └── habit_category.dart         # Enums and models
│
├── features/
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart        # Main dashboard
│   │
│   ├── salah/
│   │   └── services/
│   │       └── adhan_service.dart      # Prayer times logic
│   │
│   ├── habits/
│   │   ├── data/
│   │   │   └── database/
│   │   │       └── habits_database.dart    # Drift schema
│   │   └── providers/
│   │       ├── active_context_provider.dart    # Time context logic
│   │       ├── habit_stacker_provider.dart     # Habit suggestions
│   │       └── habits_database_provider.dart   # DB access
│   │
│   └── athkar/
│
└── shared/
    └── services/
        └── location_provider.dart      # GPS service
```

## Getting Started

### Prerequisites
- Flutter SDK >= 3.5.0
- Dart SDK >= 3.5.0

### Installation

1. **Clone the repository**
   ```bash
   cd /path/to/Sakinah
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Add fonts** (Required for proper display)
   - Download Inter font family and place in `assets/fonts/`
     - Inter-Regular.ttf
     - Inter-Medium.ttf
     - Inter-SemiBold.ttf
     - Inter-Bold.ttf

   - Download Amiri font family and place in `assets/fonts/`
     - Amiri-Regular.ttf
     - Amiri-Bold.ttf

5. **Run the app**
   ```bash
   flutter run
   ```

## Key Components

### AdhanService
Located in [lib/features/salah/services/adhan_service.dart](lib/features/salah/services/adhan_service.dart)

Provides prayer times based on user location:
```dart
final prayerTimes = ref.watch(prayerTimesNotifierProvider);
```

Features:
- Calculates all 5 daily prayers + sunrise
- Returns `DateTime` objects for each prayer
- Uses Muslim World League calculation method
- Shafi madhab by default
- Extension methods for Arabic/English prayer names

### Active Context Provider
Located in [lib/features/habits/providers/active_context_provider.dart](lib/features/habits/providers/active_context_provider.dart)

Determines the current spiritual time context:
```dart
final context = ref.watch(activeContextNotifierProvider);
// Returns: beforeFajr, fajrTime, maghribToIshaTime, etc.
```

### Habit Stacker
Located in [lib/features/habits/providers/habit_stacker_provider.dart](lib/features/habits/providers/habit_stacker_provider.dart)

Provides context-aware habit suggestions:
```dart
final habitStack = ref.watch(habitStackerNotifierProvider);
// Returns prioritized list of HabitStackItem
```

Between Maghrib and Isha, automatically suggests:
1. Maghrib Sunnah (Priority 1)
2. Evening Athkar (Priority 2)
3. Gratitude Reflection (Priority 3)

### Habits Database
Located in [lib/features/habits/data/database/habits_database.dart](lib/features/habits/data/database/habits_database.dart)

Drift schema with:
- `id`: Auto-increment primary key
- `title`: Habit name
- `category`: Fard, Sunnah, or Athkar
- `ayah_reference`: Related Quranic verse
- `current_streak`: Days maintained
- `last_completed`: Last completion timestamp
- `is_shielded`: Protection during travel/illness

Key methods:
- `completeHabit(int id)`: Updates streak intelligently
- `toggleShield(int id, bool isShielded)`: Enable/disable streak protection
- `watchAllHabits()`: Real-time stream of all habits

## Color Palette

- **Emerald** (`#064E3B`): Primary color for actions and emphasis
- **Sand** (`#F3E5AB`): Secondary color for warmth and highlights
- **Slate** (`#475569`): Neutral color for text and backgrounds

## Code Style

- All UI components use `HookConsumerWidget`
- Methods are small and focused (single responsibility)
- Animations use `flutter_animate` with long, breathable durations
- Arabic text wrapped in `Directionality` widget with RTL and Amiri font
- English text uses Inter font family

## Next Steps

To continue development:

1. **Add font files** to `assets/fonts/` directory
2. **Implement notification_service** for prayer reminders
3. **Create Athkar mood-based engine**
4. **Build Mizan (Balance) UI** with custom painter
5. **Implement Sakinah Mode** (Do Not Disturb during prayer)
6. **Add habit CRUD UI** for user-created habits

## Build Runner

Whenever you modify:
- Drift database tables
- Riverpod providers with `@riverpod` annotation

Run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch for changes:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## License

This project is for personal and educational use.

---

**Built with ❤️ for the Muslim Ummah**
