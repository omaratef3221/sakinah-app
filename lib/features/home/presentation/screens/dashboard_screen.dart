import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/presentation/add_habit_screen.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:sakinah_flow/shared/services/location_provider.dart';

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
                    _buildHeader(context),
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
                    _buildStatsOverview(fardHabitsAsync, sunnahHabitsAsync),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
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
        GestureDetector(
          onTap: () {
            // Show date picker
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFD4AF37),
                      onPrimary: Color(0xFF0A1F1A),
                      surface: Color(0xFF0F3D30),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF0A1F1A),
              size: 24,
            ),
          ),
        ),
      ],
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
      final nextPrayerEnum = prayerTimes.nextPrayer();
      nextPrayer = nextPrayerEnum.englishName;
      final nextPrayerDateTime = prayerTimes.timeForPrayer(nextPrayerEnum);
      nextPrayerTime = _formatTime(nextPrayerDateTime);
      prayerIcon = _getPrayerIcon(nextPrayerEnum);
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

  Widget _buildQuickActions(BuildContext context) {
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
                  DefaultTabController.of(context).animateTo(4);
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
