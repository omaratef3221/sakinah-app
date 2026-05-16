import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sakinah_flow/core/services/asset_data_cache.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/features/auth/presentation/widgets/guest_banner.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/presentation/add_habit_screen.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:sakinah_flow/shared/services/location_provider.dart';
import 'package:sakinah_flow/features/home/presentation/main_navigation.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  bool _isCompletedToday(dynamic habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted as DateTime;
    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }

  Future<void> _getCurrentLocation(
    ValueNotifier<String> locationState,
    AppLocalizations l,
  ) async {
    try {
      locationState.value = l.dashLocDetecting;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationState.value = l.dashLocDisabled;
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationState.value = l.dashLocDenied;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationState.value = l.dashLocDeniedForever;
        return;
      }

      // Try last-known position first — instant if available — and fall back
      // to a fresh medium-accuracy fix. High accuracy isn't needed for
      // prayer-time calc and is much slower on first launch.
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Location timeout'),
      );

      // Get address from coordinates
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];

        // Get the most accurate city name
        final city = place.locality ??
                     place.subAdministrativeArea ??
                     place.administrativeArea ??
                     l.dashLocUnknown;
        final country = place.country ?? '';

        locationState.value = country.isNotEmpty ? '$city, $country' : city;
      } else {
        locationState.value = l.dashLocDetected;
      }
    } catch (e) {
      locationState.value = l.dashLocUnable;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);
    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);
    final themeColors = ref.watch(themeColorsProvider);
    final l = AppLocalizations.of(context);
    final locationState = useState<String>(l.dashLocLoading);

    useEffect(() {
      // Get location immediately
      _getCurrentLocation(locationState, l);
      return null;
    }, [l]);

    return Container(
      decoration: BoxDecoration(
        gradient: themeColors.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, ref, l),
                    const SizedBox(height: 16),
                    const GuestBanner(),
                    prayerTimesAsync.when(
                      data: (prayerTimes) => _buildGreeting(
                        context,
                        locationState.value,
                        locationState,
                        prayerTimes,
                        ref,
                        l,
                      ),
                      loading: () => _buildGreeting(
                        context,
                        locationState.value,
                        locationState,
                        null,
                        ref,
                        l,
                      ),
                      error: (_, __) => _buildGreeting(
                        context,
                        locationState.value,
                        locationState,
                        null,
                        ref,
                        l,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDuaOfTheDay(context, l),
                    const SizedBox(height: 24),
                    _buildStatsOverview(fardHabitsAsync, sunnahHabitsAsync, l),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, ref, l),
                    const SizedBox(height: 24),
                    _buildTodayProgress(fardHabitsAsync, sunnahHabitsAsync, l),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, AppLocalizations l) {
    final now = DateTime.now();
    final hijriNow = HijriCalendar.now();

    // Format Gregorian date in the active locale.
    final gregorianDate = DateFormat('EEEE, MMMM d, yyyy',
            Localizations.localeOf(context).toString())
        .format(now);

    // Format Hijri date — month name is already Arabic; suffix "هـ" stays.
    final hijriDate =
        '${hijriNow.hDay} ${hijriNow.getLongMonthName()} ${hijriNow.hYear} هـ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.dashTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            // Date badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Color(0xFF0A1F1A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gregorianDate,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1F1A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hijriDate,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDuaPopup(BuildContext context) async {
    final data = await AssetDataCache.loadJson('assets/data/duas.json');
    final List<dynamic> duasList = data['duas'];

    // Get random dua of the day based on current date
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = seed % duasList.length;
    final dua = duasList[random];

    if (!context.mounted) return;
    final l = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A5F4E),
                Color(0xFF0F3D30),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFF0A1F1A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.dashDuaTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dua Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arabic Text
                        Text(
                          dua['arabic'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: Color(0xFFD4AF37),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),

                        // Transliteration
                        Text(
                          dua['transliteration'],
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Translation
                        Text(
                          dua['translation'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reference
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book_rounded,
                                size: 16,
                                color: const Color(0xFFD4AF37),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dua['reference'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Done Button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0A1F1A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l.commonDone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuaOfTheDay(BuildContext context, AppLocalizations l) {
    return GestureDetector(
      onTap: () => _showDuaPopup(context),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.2),
            const Color(0xFF1E40AF).withValues(alpha: 0.2),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF0A1F1A),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.dashDuaTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.dashDuaTapToRead,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFFD4AF37),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('h:mm a').format(time);
  }

  IconData _getPrayerIcon(Prayer? prayer) {
    if (prayer == null) return Icons.wb_sunny_rounded;
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight_rounded;
      case Prayer.sunrise:
        return Icons.wb_sunny_rounded;
      case Prayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case Prayer.asr:
        return Icons.wb_cloudy_rounded;
      case Prayer.maghrib:
        return Icons.nightlight_rounded;
      case Prayer.isha:
        return Icons.dark_mode_rounded;
      case Prayer.none:
        return Icons.wb_sunny_rounded;
    }
  }

  Widget _buildGreeting(
    BuildContext context,
    String location,
    ValueNotifier<String> locationState,
    PrayerTimes? prayerTimes,
    WidgetRef ref,
    AppLocalizations l,
  ) {
    final hour = DateTime.now().hour;
    String greeting;
    String nextPrayer;
    String nextPrayerTime;
    IconData prayerIcon;

    // Determine greeting based on time of day
    if (hour < 5) {
      greeting = l.dashGreetingEvening;
    } else if (hour < 12) {
      greeting = l.dashGreetingMorning;
    } else if (hour < 18) {
      greeting = l.dashGreetingAfternoon;
    } else {
      greeting = l.dashGreetingEvening;
    }

    String prayerName(Prayer p) {
      switch (p) {
        case Prayer.fajr:
          return l.prayerFajr;
        case Prayer.sunrise:
          return l.prayerSunrise;
        case Prayer.dhuhr:
          return l.prayerDhuhr;
        case Prayer.asr:
          return l.prayerAsr;
        case Prayer.maghrib:
          return l.prayerMaghrib;
        case Prayer.isha:
          return l.prayerIsha;
        case Prayer.none:
          return l.prayerLoading;
      }
    }

    // Get next prayer from real prayer times
    if (prayerTimes != null) {
      // Use the notifier's getNextPrayer() method which handles after-Isha case
      final nextPrayerEnum =
          ref.read(prayerTimesNotifierProvider.notifier).getNextPrayer();

      if (nextPrayerEnum != null && nextPrayerEnum != Prayer.none) {
        nextPrayer = prayerName(nextPrayerEnum);

        // For Fajr after Isha, calculate tomorrow's Fajr time
        DateTime? nextPrayerDateTime;
        if (nextPrayerEnum == Prayer.fajr &&
            prayerTimes.nextPrayer() == Prayer.none) {
          // After Isha, calculate tomorrow's Fajr
          final duration = ref
              .read(prayerTimesNotifierProvider.notifier)
              .getTimeUntilNextPrayer();
          if (duration != null) {
            nextPrayerDateTime = DateTime.now().add(duration);
          }
        } else {
          nextPrayerDateTime = prayerTimes.timeForPrayer(nextPrayerEnum);
        }

        nextPrayerTime = _formatTime(nextPrayerDateTime);
        prayerIcon = _getPrayerIcon(nextPrayerEnum);
      } else {
        // Fallback if no next prayer detected
        nextPrayer = l.prayerLoading;
        nextPrayerTime = '--:--';
        prayerIcon = Icons.access_time_rounded;
      }
    } else {
      // Fallback to basic logic if prayer times aren't loaded yet
      final loading = l.commonLoading;
      if (hour < 5) {
        nextPrayer = l.prayerFajr;
        nextPrayerTime = loading;
        prayerIcon = Icons.wb_twilight_rounded;
      } else if (hour < 12) {
        nextPrayer = l.prayerDhuhr;
        nextPrayerTime = loading;
        prayerIcon = Icons.wb_sunny_rounded;
      } else if (hour < 15) {
        nextPrayer = l.prayerAsr;
        nextPrayerTime = loading;
        prayerIcon = Icons.wb_cloudy_rounded;
      } else if (hour < 18) {
        nextPrayer = l.prayerMaghrib;
        nextPrayerTime = loading;
        prayerIcon = Icons.nightlight_rounded;
      } else {
        nextPrayer = l.prayerIsha;
        nextPrayerTime = loading;
        prayerIcon = Icons.dark_mode_rounded;
      }
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        // Refresh location in dashboard
                        await _getCurrentLocation(locationState, l);
                        // Refresh location provider which will trigger prayer times update
                        ref.read(locationNotifierProvider.notifier).refreshLocation();
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.refresh_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  const Color(0xFFB8941C).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  prayerIcon,
                  color: const Color(0xFFD4AF37),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.dashNextPrayer,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        nextPrayer,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  nextPrayerTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(
    AsyncValue<List<dynamic>> fardHabitsAsync,
    AsyncValue<List<dynamic>> sunnahHabitsAsync,
    AppLocalizations l,
  ) {
    return fardHabitsAsync.when(
      data: (fardHabits) => sunnahHabitsAsync.when(
        data: (sunnahHabits) {
          final totalHabits = fardHabits.length + sunnahHabits.length;
          final completedToday = fardHabits.where((h) => _isCompletedToday(h)).length +
              sunnahHabits.where((h) => _isCompletedToday(h)).length;
          final completionRate = totalHabits > 0
              ? (completedToday / totalHabits * 100).toInt()
              : 0;

          // Best current streak across all habits — honest 0 for new users.
          int bestCurrent = 0;
          for (final h in fardHabits) {
            if (h.currentStreak > bestCurrent) {
              bestCurrent = h.currentStreak as int;
            }
          }
          for (final h in sunnahHabits) {
            if (h.currentStreak > bestCurrent) {
              bestCurrent = h.currentStreak as int;
            }
          }
          final streakLabel = l.dashStreakDay(bestCurrent);

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l.dashStatCompletion,
                  '$completionRate%',
                  Icons.check_circle_rounded,
                  const Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l.dashStatToday,
                  '$completedToday/$totalHabits',
                  Icons.today_rounded,
                  const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l.dashStatStreak,
                  streakLabel,
                  Icons.local_fire_department_rounded,
                  const Color(0xFFF97316),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, WidgetRef ref, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dashQuickActions,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                l.dashAddHabit,
                Icons.add_circle_rounded,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHabitScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                l.dashViewStats,
                Icons.bar_chart_rounded,
                () {
                  // Navigate to Progress tab (index 4)
                  ref.read(navigationIndexProvider.notifier).state = 4;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress(
    AsyncValue<List<dynamic>> fardHabitsAsync,
    AsyncValue<List<dynamic>> sunnahHabitsAsync,
    AppLocalizations l,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dashTodayProgress,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 12),
        fardHabitsAsync.when(
          data: (fardHabits) => sunnahHabitsAsync.when(
            data: (sunnahHabits) {
              final totalHabits = fardHabits.length + sunnahHabits.length;
              final completedToday = fardHabits.where((h) => _isCompletedToday(h)).length +
                  sunnahHabits.where((h) => _isCompletedToday(h)).length;
              final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

              return GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.dashCompletedOfTotal(completedToday, totalHabits),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}
