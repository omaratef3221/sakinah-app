# Sakinah - Islamic Habit Tracker

Transform your spiritual journey with Sakinah, an Islamic habit tracker that helps Muslims build lasting positive habits and strengthen their connection with Allah.

![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-Proprietary-red)

## Features

### 🕌 Prayer Times & Qibla
- Accurate prayer times based on your location
- Dubai calculation method (18-degree horizon)
- GPS-based Qibla compass
- Never miss Fajr, Dhuhr, Asr, Maghrib, or Isha

### 📿 Smart Habit Tracking
- Track daily Islamic habits (Quran recitation, dhikr, Sunnah practices)
- Set personalized goals and streaks
- Visual progress with beautiful charts
- Categories: Worship, Knowledge, Character, Health

### 🤲 Dua of the Day
- Daily curated duas from authentic Islamic sources
- Arabic text with English transliteration and translation
- 15+ duas with Quran and Hadith references

### 📖 Islamic Resources
- Complete Athkar collection (morning/evening remembrance)
- Umrah and Hajj step-by-step guides
- Easy access to essential Islamic knowledge

### ✨ Beautiful Design
- Modern, elegant Islamic-inspired interface
- Dark/Light mode support
- Smooth animations and gradients
- Clean, distraction-free experience

## Tech Stack

- **Framework**: Flutter 3.24.5
- **State Management**: Riverpod + Flutter Hooks
- **Database**: Drift (SQLite)
- **Prayer Times**: adhan package
- **Location**: geolocator, geocoding
- **Qibla**: flutter_qiblah
- **Animations**: flutter_animate
- **Fonts**: Google Fonts (Poppins, Amiri)

## Installation

### Prerequisites
- Flutter SDK >= 3.24.5
- Dart SDK >= 3.5.0
- Xcode 15+ (for iOS)
- Android Studio (for Android)

### Setup

1. **Clone and install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android
   ```

## Project Structure

```
lib/
├── core/
│   ├── theme/              # App theme configuration
│   └── constants/          # Constants and colors
│
├── features/
│   ├── home/              # Dashboard screen
│   ├── salah/             # Prayer times service
│   ├── habits/            # Habit tracking
│   │   ├── data/
│   │   │   └── database/  # Drift database
│   │   └── providers/     # Riverpod providers
│   ├── athkar/            # Remembrance collection
│   └── qibla/             # Qibla compass
│
└── shared/
    └── services/          # Location and other services

assets/
├── data/
│   ├── habits.json        # Habit data
│   ├── preset_habits.json # Preset habits
│   └── duas.json          # Dua collection
└── fonts/                 # Custom fonts
```

## Building for Release

### Android (Play Store)

1. **Build release AAB**
   ```bash
   flutter build appbundle --release
   ```

2. **Output location**
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

3. **Signing configuration**
   - Keystore: `android/sakinah-release-key.jks`
   - Config: `android/key.properties`
   - Package: `com.sakinahflow.app`

### iOS (App Store)

1. **Open in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing**
   - Team: Your Apple Developer team
   - Bundle ID: `com.sakinahflow.app`
   - Enable "Automatically manage signing"

3. **Create archive**
   - Product → Archive
   - Distribute App → App Store Connect → Upload

## Publishing Status

### Google Play Store
- **Package**: com.sakinahflow.app
- **Version**: 1.0.0 (Build 1)
- **Status**: Ready for submission
- **Store Listing**: Complete
- **Privacy Policy**: https://omaratef3221.github.io/sakinah-app/privacy.html

### Apple App Store
- **Bundle ID**: com.sakinahflow.app
- **Version**: 1.0.0 (Build 1)
- **Status**: Ready for submission
- **App Store Connect**: App created
- **Privacy Policy**: https://omaratef3221.github.io/sakinah-app/privacy.html

## Configuration Files

### Android
- `android/app/build.gradle` - Build configuration
- `android/app/src/main/AndroidManifest.xml` - App manifest
- `android/key.properties` - Signing credentials (gitignored)
- `android/sakinah-release-key.jks` - Release keystore (gitignored)

### iOS
- `ios/Runner.xcodeproj/project.pbxproj` - Xcode project
- `ios/Runner/Info.plist` - App configuration
- Bundle ID configured: `com.sakinahflow.app`

## Privacy & Data

All user data is stored locally on the device:
- Location data processed locally for prayer times
- No data collection or transmission to external servers
- No third-party analytics or advertising
- Complete privacy and security

## Development

### Code Generation

When modifying Drift tables or Riverpod providers:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Running Tests
```bash
flutter test
```

### Code Style
- All UI components use `HookConsumerWidget`
- Follow Flutter best practices
- Use `flutter_animate` for animations
- Arabic text with RTL support

## App Features by Screen

### Dashboard
- Prayer times countdown
- Next prayer notification
- Daily dua popup
- Quick habit tracking

### Habits Screen
- All habits list with progress
- Streak tracking
- Category filtering
- Completion toggle

### Prayer Times Screen
- All 5 daily prayers
- Sunrise time
- Location-based calculation
- Countdown timers

### Qibla Screen
- Compass pointing to Qibla
- GPS-based calculation
- Beautiful animations

### More Menu
- Athkar collection
- Umrah guide
- Hajj guide
- App settings

## Contributing

This is a personal project. For questions or suggestions, please open an issue.

## Support

- **Email**: omaratef.dev@gmail.com
- **Privacy Policy**: https://omaratef3221.github.io/sakinah-app/privacy.html
- **GitHub**: https://github.com/omaratef3221/sakinah-app

## License

Copyright © 2026 Omar Atef. All rights reserved.

This is proprietary software for personal and educational use.

---

**Built with ❤️ for the Muslim Ummah**

*"Indeed, in the remembrance of Allah do hearts find rest." - Quran 13:28*
