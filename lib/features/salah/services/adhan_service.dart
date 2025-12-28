import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/shared/services/location_provider.dart';

part 'adhan_service.g.dart';

@riverpod
class PrayerTimesNotifier extends _$PrayerTimesNotifier {
  @override
  Future<PrayerTimes?> build() async {
    // Watch location provider - this will automatically rebuild when location changes
    final location = await ref.watch(locationNotifierProvider.future);
    if (location == null) return null;

    return _calculatePrayerTimes(location);
  }

  PrayerTimes _calculatePrayerTimes(Position position) {
    final coordinates = Coordinates(
      position.latitude,
      position.longitude,
    );

    // Use Dubai calculation method (accurate for all regions)
    final params = CalculationMethod.dubai.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);
    return prayerTimes;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final location = await ref.read(locationNotifierProvider.future);
    if (location == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = AsyncValue.data(_calculatePrayerTimes(location));
  }

  // Get next prayer
  Prayer? getNextPrayer() {
    final times = state.value;
    if (times == null) return null;

    return times.nextPrayer();
  }

  // Get current prayer
  Prayer getCurrentPrayer() {
    final times = state.value;
    if (times == null) return Prayer.none;

    return times.currentPrayer();
  }

  // Get time for a specific prayer
  DateTime? getTimeForPrayer(Prayer prayer) {
    final times = state.value;
    if (times == null) return null;

    return times.timeForPrayer(prayer);
  }

  // Check if current time is between two prayers
  bool isTimeBetweenPrayers(Prayer startPrayer, Prayer endPrayer) {
    final times = state.value;
    if (times == null) return false;

    final now = DateTime.now();
    final startTime = times.timeForPrayer(startPrayer);
    final endTime = times.timeForPrayer(endPrayer);

    if (startTime == null || endTime == null) return false;

    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  // Get time until next prayer
  Duration? getTimeUntilNextPrayer() {
    final times = state.value;
    if (times == null) return null;

    final nextPrayer = times.nextPrayer();
    if (nextPrayer == Prayer.none) return null;

    final nextPrayerTime = times.timeForPrayer(nextPrayer);
    if (nextPrayerTime == null) return null;

    return nextPrayerTime.difference(DateTime.now());
  }
}

// Helper to get prayer name in Arabic
extension PrayerExtension on Prayer {
  String get arabicName {
    switch (this) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.none:
        return '';
    }
  }

  String get englishName {
    switch (this) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      case Prayer.none:
        return '';
    }
  }
}
