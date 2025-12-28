import 'package:adhan/adhan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';

part 'active_context_provider.g.dart';

/// Represents the current spiritual context based on prayer times
enum ActiveContext {
  beforeFajr,
  fajrTime,
  morningTime,
  beforeDhuhr,
  dhuhrTime,
  afternoonTime,
  beforeAsr,
  asrTime,
  beforeMaghrib,
  maghribToIshaTime, // Special: Between Maghrib and Isha
  ishaTime,
  nightTime;

  String get displayName {
    switch (this) {
      case ActiveContext.beforeFajr:
        return 'Before Fajr';
      case ActiveContext.fajrTime:
        return 'Fajr Time';
      case ActiveContext.morningTime:
        return 'Morning Time';
      case ActiveContext.beforeDhuhr:
        return 'Before Dhuhr';
      case ActiveContext.dhuhrTime:
        return 'Dhuhr Time';
      case ActiveContext.afternoonTime:
        return 'Afternoon Time';
      case ActiveContext.beforeAsr:
        return 'Before Asr';
      case ActiveContext.asrTime:
        return 'Asr Time';
      case ActiveContext.beforeMaghrib:
        return 'Before Maghrib';
      case ActiveContext.maghribToIshaTime:
        return 'Between Maghrib & Isha';
      case ActiveContext.ishaTime:
        return 'Isha Time';
      case ActiveContext.nightTime:
        return 'Night Time';
    }
  }

  String get arabicName {
    switch (this) {
      case ActiveContext.beforeFajr:
        return 'قبل الفجر';
      case ActiveContext.fajrTime:
        return 'وقت الفجر';
      case ActiveContext.morningTime:
        return 'وقت الصباح';
      case ActiveContext.beforeDhuhr:
        return 'قبل الظهر';
      case ActiveContext.dhuhrTime:
        return 'وقت الظهر';
      case ActiveContext.afternoonTime:
        return 'وقت العصر';
      case ActiveContext.beforeAsr:
        return 'قبل العصر';
      case ActiveContext.asrTime:
        return 'وقت العصر';
      case ActiveContext.beforeMaghrib:
        return 'قبل المغرب';
      case ActiveContext.maghribToIshaTime:
        return 'بين المغرب والعشاء';
      case ActiveContext.ishaTime:
        return 'وقت العشاء';
      case ActiveContext.nightTime:
        return 'وقت الليل';
    }
  }
}

@riverpod
class ActiveContextNotifier extends _$ActiveContextNotifier {
  @override
  ActiveContext build() {
    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);

    return prayerTimesAsync.when(
      data: (prayerTimes) {
        if (prayerTimes == null) return ActiveContext.morningTime;
        return _calculateActiveContext(prayerTimes);
      },
      loading: () => ActiveContext.morningTime,
      error: (_, __) => ActiveContext.morningTime,
    );
  }

  ActiveContext _calculateActiveContext(PrayerTimes prayerTimes) {
    final now = DateTime.now();

    final fajr = prayerTimes.fajr;
    final sunrise = prayerTimes.sunrise;
    final dhuhr = prayerTimes.dhuhr;
    final asr = prayerTimes.asr;
    final maghrib = prayerTimes.maghrib;
    final isha = prayerTimes.isha;

    // Before Fajr (night time until Fajr)
    if (now.isBefore(fajr)) {
      return ActiveContext.beforeFajr;
    }

    // Fajr time (Fajr to Sunrise)
    if (now.isAfter(fajr) && now.isBefore(sunrise)) {
      return ActiveContext.fajrTime;
    }

    // Morning time (After Sunrise until before Dhuhr)
    if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
      return ActiveContext.morningTime;
    }

    // Dhuhr time
    if (now.isAfter(dhuhr) && now.isBefore(asr)) {
      return ActiveContext.dhuhrTime;
    }

    // Asr time
    if (now.isAfter(asr) && now.isBefore(maghrib)) {
      return ActiveContext.asrTime;
    }

    // Special: Between Maghrib and Isha (Priority time for evening practices)
    if (now.isAfter(maghrib) && now.isBefore(isha)) {
      return ActiveContext.maghribToIshaTime;
    }

    // Isha time and after
    if (now.isAfter(isha)) {
      return ActiveContext.ishaTime;
    }

    return ActiveContext.morningTime;
  }

  // Check if currently in a specific context
  bool isInContext(ActiveContext context) {
    return state == context;
  }

  // Check if it's time for evening practices (Maghrib to Isha)
  bool get isEveningPracticeTime {
    return state == ActiveContext.maghribToIshaTime;
  }
}
