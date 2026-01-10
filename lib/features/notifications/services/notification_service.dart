import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    // Configure audio player for iOS
    _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Available adhan types
  static const List<String> adhanTypes = [
    'Adhan 1',
    'Adhan 2',
    'Adhan 3',
    'Adhan 4',
    'Adhan 5',
  ];

  Future<void> initialize() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings - don't request permissions here, do it manually
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to prayer screen or perform other actions
  }

  Future<bool> requestPermission() async {
    // Request iOS notification permissions using flutter_local_notifications
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImpl != null) {
      final result = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    // For Android, use permission_handler
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    // Check iOS permissions
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImpl != null) {
      final settings = await iosImpl.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    // Check Android permissions
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> schedulePrayerNotifications(
    PrayerTimes prayerTimes,
    bool enabled,
  ) async {
    if (!enabled) {
      await cancelAllNotifications();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final selectedAdhan = prefs.getString('selected_adhan') ?? 'Mecca';

    // Schedule notifications for each prayer
    await _schedulePrayerNotification(
      id: 1,
      prayer: Prayer.fajr,
      time: prayerTimes.fajr,
      adhanType: selectedAdhan,
    );

    await _schedulePrayerNotification(
      id: 2,
      prayer: Prayer.dhuhr,
      time: prayerTimes.dhuhr,
      adhanType: selectedAdhan,
    );

    await _schedulePrayerNotification(
      id: 3,
      prayer: Prayer.asr,
      time: prayerTimes.asr,
      adhanType: selectedAdhan,
    );

    await _schedulePrayerNotification(
      id: 4,
      prayer: Prayer.maghrib,
      time: prayerTimes.maghrib,
      adhanType: selectedAdhan,
    );

    await _schedulePrayerNotification(
      id: 5,
      prayer: Prayer.isha,
      time: prayerTimes.isha,
      adhanType: selectedAdhan,
    );
  }

  Future<void> _schedulePrayerNotification({
    required int id,
    required Prayer prayer,
    required DateTime time,
    required String adhanType,
  }) async {
    final now = DateTime.now();
    if (time.isBefore(now)) {
      // If prayer time has passed for today, skip it
      return;
    }

    final prayerName = _getPrayerName(prayer);
    final prayerNameArabic = _getPrayerNameArabic(prayer);

    const androidDetails = AndroidNotificationDetails(
      'prayer_reminders',
      'Prayer Reminders',
      channelDescription: 'Notifications for prayer times with Adhan',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notifications.zonedSchedule(
      id,
      'Time for $prayerName Prayer',
      'وقت صلاة $prayerNameArabic',
      _convertToTZDateTime(time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Play adhan audio when notification is shown
    // Note: Audio playback in background requires additional setup
    // This will play when the app is in foreground
  }

  Future<void> playAdhan(String adhanType) async {
    try {
      final audioPath = _getAdhanAudioPath(adhanType);
      await _audioPlayer.stop(); // Stop any currently playing audio

      // Set player mode for better iOS compatibility
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);

      // Play the audio
      await _audioPlayer.play(AssetSource(audioPath));
      print('Playing adhan: $audioPath');
    } catch (e) {
      print('Error playing adhan: $e');
    }
  }

  Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
      print('Stopped adhan');
    } catch (e) {
      print('Error stopping adhan: $e');
    }
  }

  String _getAdhanAudioPath(String adhanType) {
    switch (adhanType) {
      case 'Adhan 1':
        return 'audio/adhan/azan1.mp3';
      case 'Adhan 2':
        return 'audio/adhan/azan2.mp3';
      case 'Adhan 3':
        return 'audio/adhan/azan3.mp3';
      case 'Adhan 4':
        return 'audio/adhan/azan4.mp3';
      case 'Adhan 5':
        return 'audio/adhan/azan5.mp3';
      default:
        return 'audio/adhan/azan1.mp3';
    }
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    // Convert DateTime to TZDateTime using local timezone
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> saveSelectedAdhan(String adhanType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_adhan', adhanType);
  }

  Future<String> getSelectedAdhan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_adhan') ?? 'Adhan 1';
  }

  Future<void> savePrayerRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_reminders_enabled', enabled);
  }

  Future<bool> getPrayerRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('prayer_reminders_enabled') ?? true;
  }
}
