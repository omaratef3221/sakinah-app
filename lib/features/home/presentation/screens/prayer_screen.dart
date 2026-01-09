import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerScreen extends HookConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);

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
        child: prayerTimesAsync.when(
          data: (prayerTimes) {
            final nextPrayer = prayerTimes?.nextPrayer();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildNextPrayerHero(prayerTimes, nextPrayer),
                        const SizedBox(height: 24),
                        _buildPrayerTimesGrid(prayerTimes, nextPrayer),
                        const SizedBox(height: 24),
                        _buildQiblaCompass(prayerTimes),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load prayer times',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your location settings',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prayer Times',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            Text(
              'مواقيت الصلاة',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        Container(
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
            Icons.mosque_rounded,
            color: Color(0xFF0A1F1A),
            size: 24,
          ),
        ),
      ],
    );
  }

  IconData _getPrayerIcon(Prayer? prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight_rounded;
      case Prayer.sunrise:
        return Icons.wb_sunny_rounded;
      case Prayer.dhuhr:
        return Icons.light_mode_rounded;
      case Prayer.asr:
        return Icons.wb_cloudy_rounded;
      case Prayer.maghrib:
        return Icons.nightlight_rounded;
      case Prayer.isha:
        return Icons.dark_mode_rounded;
      default:
        return Icons.mosque_rounded;
    }
  }

  String _getTimeRemaining(PrayerTimes? prayerTimes, Prayer? nextPrayer) {
    if (prayerTimes == null || nextPrayer == null || nextPrayer == Prayer.none) {
      return '--';
    }

    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    if (nextPrayerTime == null) return '--';

    final duration = nextPrayerTime.difference(DateTime.now());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return 'in ${hours}h ${minutes}m';
    } else {
      return 'in ${minutes}m';
    }
  }

  Widget _buildNextPrayerHero(PrayerTimes? prayerTimes, Prayer? nextPrayer) {
    final nextPrayerTime = prayerTimes?.timeForPrayer(nextPrayer ?? Prayer.none);
    final formattedTime = nextPrayerTime != null
        ? '${_formatTime(nextPrayerTime)} ${_formatPeriod(nextPrayerTime)}'
        : '--:--';

    return GlassCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFD4AF37).withValues(alpha: 0.3),
          const Color(0xFF1E40AF).withValues(alpha: 0.3),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Prayer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTimeRemaining(prayerTimes, nextPrayer),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1F1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextPrayer?.englishName ?? 'Loading',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    nextPrayer?.arabicName ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  _getPrayerIcon(nextPrayer),
                  size: 48,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_rounded, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    final format = DateFormat('h:mm');
    return format.format(time);
  }

  String _formatPeriod(DateTime? time) {
    if (time == null) return 'AM';
    return DateFormat('a').format(time);
  }

  String _getIqamahTime(DateTime? adhanTime) {
    if (adhanTime == null) return '--:--';
    // Add 15 minutes for iqamah (can be customized per prayer)
    final iqamah = adhanTime.add(const Duration(minutes: 15));
    return _formatTime(iqamah);
  }

  Widget _buildPrayerTimesGrid(PrayerTimes? prayerTimes, Prayer? nextPrayer) {
    final prayers = [
      {
        'name': 'Fajr',
        'arabic': 'الفجر',
        'time': _formatTime(prayerTimes?.fajr),
        'period': _formatPeriod(prayerTimes?.fajr),
        'iqamah': _getIqamahTime(prayerTimes?.fajr),
        'icon': Icons.wb_twilight_rounded,
        'color': const Color(0xFF818CF8),
        'prayer': Prayer.fajr,
      },
      {
        'name': 'Sunrise',
        'arabic': 'الشروق',
        'time': _formatTime(prayerTimes?.sunrise),
        'period': _formatPeriod(prayerTimes?.sunrise),
        'iqamah': null,
        'icon': Icons.wb_sunny_rounded,
        'color': const Color(0xFFFBBF24),
        'prayer': Prayer.sunrise,
      },
      {
        'name': 'Dhuhr',
        'arabic': 'الظهر',
        'time': _formatTime(prayerTimes?.dhuhr),
        'period': _formatPeriod(prayerTimes?.dhuhr),
        'iqamah': _getIqamahTime(prayerTimes?.dhuhr),
        'icon': Icons.light_mode_rounded,
        'color': const Color(0xFFF59E0B),
        'prayer': Prayer.dhuhr,
      },
      {
        'name': 'Asr',
        'arabic': 'العصر',
        'time': _formatTime(prayerTimes?.asr),
        'period': _formatPeriod(prayerTimes?.asr),
        'iqamah': _getIqamahTime(prayerTimes?.asr),
        'icon': Icons.wb_cloudy_rounded,
        'color': const Color(0xFFF97316),
        'prayer': Prayer.asr,
      },
      {
        'name': 'Maghrib',
        'arabic': 'المغرب',
        'time': _formatTime(prayerTimes?.maghrib),
        'period': _formatPeriod(prayerTimes?.maghrib),
        'iqamah': _getIqamahTime(prayerTimes?.maghrib),
        'icon': Icons.nightlight_rounded,
        'color': const Color(0xFFEC4899),
        'prayer': Prayer.maghrib,
      },
      {
        'name': 'Isha',
        'arabic': 'العشاء',
        'time': _formatTime(prayerTimes?.isha),
        'period': _formatPeriod(prayerTimes?.isha),
        'iqamah': _getIqamahTime(prayerTimes?.isha),
        'icon': Icons.dark_mode_rounded,
        'color': const Color(0xFF8B5CF6),
        'prayer': Prayer.isha,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'جدول اليوم',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            final prayerType = prayer['prayer'] as Prayer;
            final isActive = prayerType == nextPrayer;

            return _buildPrayerGridCard(
              prayer['name'] as String,
              prayer['arabic'] as String,
              prayer['time'] as String,
              prayer['period'] as String,
              prayer['icon'] as IconData,
              prayer['color'] as Color,
              isActive: isActive,
              iqamah: prayer['iqamah'] as String?,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrayerGridCard(
    String name,
    String arabicName,
    String time,
    String period,
    IconData icon,
    Color color, {
    bool isActive = false,
    String? iqamah,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      gradient: isActive
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            )
          : null,
      border: isActive
          ? Border.all(
              color: const Color(0xFFD4AF37),
              width: 2,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFFD4AF37) : color,
                size: 28,
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1F1A),
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                arabicName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFFD4AF37) : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? const Color(0xFFD4AF37)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              if (iqamah != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Iqamah: $iqamah',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'North';
    if (degrees >= 22.5 && degrees < 67.5) return 'Northeast';
    if (degrees >= 67.5 && degrees < 112.5) return 'East';
    if (degrees >= 112.5 && degrees < 157.5) return 'Southeast';
    if (degrees >= 157.5 && degrees < 202.5) return 'South';
    if (degrees >= 202.5 && degrees < 247.5) return 'Southwest';
    if (degrees >= 247.5 && degrees < 292.5) return 'West';
    return 'Northwest';
  }

  Widget _buildQiblaCompass(PrayerTimes? prayerTimes) {
    // Calculate Qibla direction from current location
    double calculatedQiblaDirection = 0;
    if (prayerTimes != null) {
      final qibla = Qibla(prayerTimes.coordinates);
      calculatedQiblaDirection = qibla.direction;
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        // Use calculated Qibla direction (works in simulator and real device)
        double qiblaDirection = calculatedQiblaDirection;

        // Get device heading from stream (only works on real device with compass)
        double deviceHeading = 0;
        if (snapshot.hasData) {
          deviceHeading = snapshot.data!.direction;
        }

        final cardinalDirection = _getCardinalDirection(qiblaDirection);

        // Calculate the angle to rotate: Qibla direction minus device heading
        // This makes the needle point to Qibla regardless of phone orientation
        final qiblaAngleRadians = (qiblaDirection - deviceHeading) * math.pi / 180;

        return GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.explore_rounded,
                    color: Color(0xFFD4AF37),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Qibla Direction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'اتجاه القبلة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              // Instruction text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Point your phone toward the Kaaba icon',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      const Color(0xFFD4AF37).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle compass tick marks (no labels)
                    ...List.generate(8, (index) {
                      final angle = (index * 45) * math.pi / 180;
                      return Transform.rotate(
                        angle: angle,
                        child: Container(
                          width: 2,
                          height: 180,
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 2,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      );
                    }),
                    // Center dot for reference
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    // Kaaba icon and arrow - rotated to actual Qibla direction
                    Transform.rotate(
                      angle: qiblaAngleRadians,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Kaaba icon at the top (direction to face)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0A1F1A).withValues(alpha: 0.8),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mosque_rounded,
                              size: 28,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Label below icon
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'QIBLA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A1F1A),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Arrow pointing toward Kaaba
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 40,
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                            shadows: [
                              Shadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Direction info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${qiblaDirection.toStringAsFixed(1)}° $cardinalDirection',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'toward Makkah Al-Mukarramah',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
