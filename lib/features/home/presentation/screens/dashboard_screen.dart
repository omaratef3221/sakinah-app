import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/presentation/add_habit_screen.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:sakinah_flow/shared/services/location_provider.dart';
import 'package:sakinah_flow/features/home/presentation/main_navigation.dart';

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

  Future<void> _getCurrentLocation(ValueNotifier<String> locationState) async {
    try {
      locationState.value = 'Detecting location...';

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationState.value = 'Location services disabled';
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationState.value = 'Location permission denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationState.value = 'Location permission permanently denied';
        return;
      }

      // Get current position with high accuracy
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          // Fallback to last known position
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return lastPosition;
          }
          throw Exception('Location timeout');
        },
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
                     'Unknown Location';
        final country = place.country ?? '';

        locationState.value = country.isNotEmpty ? '$city, $country' : city;
      } else {
        locationState.value = 'Location detected';
      }
    } catch (e) {
      locationState.value = 'Unable to detect location';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);
    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);
    final locationState = useState<String>('Loading...');

    useEffect(() {
      // Get location immediately
      _getCurrentLocation(locationState);
      return null;
    }, []);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A5F4E),
            Color(0xFF0F3D30),
            Color(0xFF0A1F1A),
          ],
        ),
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
                    _buildHeader(context, ref),
                    const SizedBox(height: 24),
                    prayerTimesAsync.when(
                      data: (prayerTimes) => _buildGreeting(
                        locationState.value,
                        locationState,
                        prayerTimes,
                        ref,
                      ),
                      loading: () => _buildGreeting(
                        locationState.value,
                        locationState,
                        null,
                        ref,
                      ),
                      error: (_, __) => _buildGreeting(
                        locationState.value,
                        locationState,
                        null,
                        ref,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDuaOfTheDay(context),
                    const SizedBox(height: 24),
                    _buildStatsOverview(fardHabitsAsync, sunnahHabitsAsync),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, ref),
                    const SizedBox(height: 24),
                    _buildTodayProgress(fardHabitsAsync, sunnahHabitsAsync),
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

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final hijriNow = HijriCalendar.now();

    // Format Gregorian date
    final gregorianDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    // Format Hijri date
    final hijriDate = '${hijriNow.hDay} ${hijriNow.getLongMonthName()} ${hijriNow.hYear} هـ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Text(
                  'لوحة القيادة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w300,
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
    // Load duas from JSON
    final String response = await rootBundle.loadString('assets/data/duas.json');
    final data = json.decode(response);
    final List<dynamic> duasList = data['duas'];

    // Get random dua of the day based on current date
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = seed % duasList.length;
    final dua = duasList[random];

    if (!context.mounted) return;

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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dua of the Day',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                            Text(
                              'دعاء اليوم',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.w300,
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
                    child: const Text(
                      'Done',
                      style: TextStyle(
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

  Widget _buildDuaOfTheDay(BuildContext context) {
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dua of the Day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'دعاء اليوم',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to read today\'s dua',
                    style: TextStyle(
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
    String location,
    ValueNotifier<String> locationState,
    PrayerTimes? prayerTimes,
    WidgetRef ref,
  ) {
    final hour = DateTime.now().hour;
    String greeting;
    String nextPrayer;
    String nextPrayerTime;
    IconData prayerIcon;

    // Determine greeting based on time of day
    if (hour < 5) {
      greeting = 'Good Evening';
    } else if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    // Get next prayer from real prayer times
    if (prayerTimes != null) {
      // Use the notifier's getNextPrayer() method which handles after-Isha case
      final nextPrayerEnum = ref.read(prayerTimesNotifierProvider.notifier).getNextPrayer();

      if (nextPrayerEnum != null && nextPrayerEnum != Prayer.none) {
        nextPrayer = nextPrayerEnum.englishName;

        // For Fajr after Isha, calculate tomorrow's Fajr time
        DateTime? nextPrayerDateTime;
        if (nextPrayerEnum == Prayer.fajr && prayerTimes.nextPrayer() == Prayer.none) {
          // After Isha, calculate tomorrow's Fajr
          final duration = ref.read(prayerTimesNotifierProvider.notifier).getTimeUntilNextPrayer();
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
        nextPrayer = 'Loading...';
        nextPrayerTime = '--:--';
        prayerIcon = Icons.access_time_rounded;
      }
    } else {
      // Fallback to basic logic if prayer times aren't loaded yet
      if (hour < 5) {
        nextPrayer = 'Fajr';
        nextPrayerTime = 'Loading...';
        prayerIcon = Icons.wb_twilight_rounded;
      } else if (hour < 12) {
        nextPrayer = 'Dhuhr';
        nextPrayerTime = 'Loading...';
        prayerIcon = Icons.wb_sunny_rounded;
      } else if (hour < 15) {
        nextPrayer = 'Asr';
        nextPrayerTime = 'Loading...';
        prayerIcon = Icons.wb_cloudy_rounded;
      } else if (hour < 18) {
        nextPrayer = 'Maghrib';
        nextPrayerTime = 'Loading...';
        prayerIcon = Icons.nightlight_rounded;
      } else {
        nextPrayer = 'Isha';
        nextPrayerTime = 'Loading...';
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
                        await _getCurrentLocation(locationState);
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
                        'Next Prayer',
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

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completion',
                  '$completionRate%',
                  Icons.check_circle_rounded,
                  const Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Today',
                  '$completedToday/$totalHabits',
                  Icons.today_rounded,
                  const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '7 days',
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

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
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
                'Add Habit',
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
                'View Stats',
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Progress',
          style: TextStyle(
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
                          '$completedToday of $totalHabits completed',
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
