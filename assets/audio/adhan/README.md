# Adhan Audio Files

This directory contains the Adhan (call to prayer) audio files.

## Current Files

The following adhan audio files are currently available:

1. **azan1.mp3** - Adhan 1
2. **azan2.mp3** - Adhan 2
3. **azan3.mp3** - Adhan 3
4. **azan4.mp3** - Adhan 4
5. **azan5.mp3** - Adhan 5

## File Naming Convention

All adhan files must follow this naming pattern:
- `azan1.mp3`
- `azan2.mp3`
- `azan3.mp3`
- etc.

## Adding More Adhans

To add more adhan options:

1. Add the MP3 file to this directory with the naming pattern `azanN.mp3` (where N is the next number)
2. Update the `adhanTypes` list in `lib/features/notifications/services/notification_service.dart`
3. Add the new case to the `_getAdhanAudioPath()` method
4. Update the `_adhans` list in `lib/features/home/presentation/screens/settings_screen.dart`

Example for adding Adhan 6:
```dart
// In notification_service.dart
static const List<String> adhanTypes = [
  'Adhan 1',
  'Adhan 2',
  'Adhan 3',
  'Adhan 4',
  'Adhan 5',
  'Adhan 6', // Add this
];

// In _getAdhanAudioPath()
case 'Adhan 6':
  return 'audio/adhan/azan6.mp3';

// In settings_screen.dart
final List<String> _adhans = [
  'Adhan 1',
  'Adhan 2',
  'Adhan 3',
  'Adhan 4',
  'Adhan 5',
  'Adhan 6', // Add this
];
```

## Technical Requirements

- **Format**: MP3
- **Quality**: Recommended bitrate: 128-192 kbps
- **Duration**: Keep under 5 minutes for better performance
- **Copyright**: Ensure you have the right to use these audio files in your app

## How Users Experience This

In the app, users will:
1. Go to Settings > Notifications
2. Enable Prayer Reminders
3. See the Adhan Sound selector
4. Tap the play button (▶️) next to each adhan to preview it
5. Tap anywhere on the adhan row to select it
6. The selected adhan will play at each prayer time notification

## Testing

After adding or modifying adhan files:
1. Run `flutter pub get` to ensure assets are recognized
2. Go to Settings > Notifications in the app
3. Enable Prayer Reminders
4. Test each adhan's play button
5. Select an adhan and verify it's marked as selected
6. Test that notifications play the selected adhan at prayer time
