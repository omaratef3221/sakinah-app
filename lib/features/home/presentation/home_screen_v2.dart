import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakinah_flow/core/theme/app_theme.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:sakinah_flow/features/habits/providers/active_context_provider.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';

class HomeScreenV2 extends HookConsumerWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(initializeDatabaseProvider);

    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);
    final activeContext = ref.watch(activeContextNotifierProvider);
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              const Color(0xFF334155),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAnimatedAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsRow(fardHabitsAsync, sunnahHabitsAsync)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 20),

                  _buildPrayerTimesGlass(context, prayerTimesAsync)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 20),

                  _buildContextGlass(context, activeContext)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),

                  _buildHabitsSection(
                    context,
                    ref,
                    'Obligatory Prayers',
                    'الصلوات المفروضة',
                    fardHabitsAsync,
                    HabitCategory.fard,
                  ).animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 24),

                  _buildHabitsSection(
                    context,
                    ref,
                    'Recommended Actions',
                    'الأعمال المستحبة',
                    sunnahHabitsAsync,
                    HabitCategory.sunnah,
                  ).animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideX(begin: 0.2, end: 0),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String greetingArabic;
    IconData icon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingArabic = 'صباح الخير';
      icon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingArabic = 'مساء الخير';
      icon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'Good Evening';
      greetingArabic = 'مساء الخير';
      icon = Icons.nightlight_rounded;
    }

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFA855F7),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ).animate().scale(duration: 600.ms).shimmer(delay: 400.ms, duration: 1000.ms),
                    const SizedBox(height: 16),
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        greetingArabic,
                        style: AppTheme.arabicHeadingStyle.copyWith(
                          color: const Color(0xFFFEF3C7),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideX(begin: 0.2, end: 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AsyncValue<List<Habit>> fardAsync, AsyncValue<List<Habit>> sunnahAsync) {
    final fardCount = fardAsync.value?.where((h) => h.lastCompleted != null &&
        DateTime.now().difference(h.lastCompleted!).inHours < 24).length ?? 0;
    final sunnahCount = sunnahAsync.value?.where((h) => h.lastCompleted != null &&
        DateTime.now().difference(h.lastCompleted!).inHours < 24).length ?? 0;
    final fardTotal = fardAsync.value?.length ?? 0;
    final sunnahTotal = sunnahAsync.value?.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Fard',
            '$fardCount/$fardTotal',
            Icons.star_rounded,
            const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
            fardTotal > 0 ? fardCount / fardTotal : 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Sunnah',
            '$sunnahCount/$sunnahTotal',
            Icons.favorite_rounded,
            const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
            sunnahTotal > 0 ? sunnahCount / sunnahTotal : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Gradient gradient, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.9)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesGlass(BuildContext context, AsyncValue prayerTimesAsync) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: prayerTimesAsync.when(
            data: (prayerTimes) {
              if (prayerTimes == null) return const Text('Unable to load');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Prayer Times',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPrayerRow('Fajr', 'الفجر', prayerTimes.fajr, const Color(0xFF8B5CF6)),
                  _buildPrayerRow('Dhuhr', 'الظهر', prayerTimes.dhuhr, const Color(0xFF3B82F6)),
                  _buildPrayerRow('Asr', 'العصر', prayerTimes.asr, const Color(0xFF10B981)),
                  _buildPrayerRow('Maghrib', 'المغرب', prayerTimes.maghrib, const Color(0xFFF59E0B)),
                  _buildPrayerRow('Isha', 'العشاء', prayerTimes.isha, const Color(0xFF6366F1)),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerRow(String name, String arabic, DateTime time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    arabic,
                    style: AppTheme.arabicTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextGlass(BuildContext context, ActiveContext context_) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFBBF24).withValues(alpha: 0.2),
                const Color(0xFFF59E0B).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context_.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        context_.arabicName,
                        style: AppTheme.arabicTextStyle.copyWith(
                          color: const Color(0xFFFEF3C7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    String titleArabic,
    AsyncValue<List<Habit>> habitsAsync,
    HabitCategory category,
  ) {
    final isFard = category == HabitCategory.fard;
    final gradient = isFard
        ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)])
        : const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]);
    final icon = isFard ? Icons.star_rounded : Icons.favorite_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isFard ? const Color(0xFF7C3AED) : const Color(0xFF059669))
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            titleArabic,
                            style: AppTheme.arabicTextStyle.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No habits yet',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
              );
            }
            return Column(
              children: habits
                  .asMap()
                  .entries
                  .map((entry) => _buildHabitGlassCard(
                        context,
                        ref,
                        entry.value,
                        isFard,
                        entry.key,
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildHabitGlassCard(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    bool isFard,
    int index,
  ) {
    final database = ref.read(habitsDatabaseProvider);
    final isCompleted = habit.lastCompleted != null &&
        DateTime.now().difference(habit.lastCompleted!).inHours < 24;

    final accentColor = isFard ? const Color(0xFF7C3AED) : const Color(0xFF059669);
    final hasStreak = habit.currentStreak > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.25),
                        accentColor.withValues(alpha: 0.1),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.08),
                      ],
                    ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCompleted
                    ? accentColor.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                splashColor: accentColor.withValues(alpha: 0.2),
                onTap: isCompleted
                    ? null
                    : () async {
                        await database.completeHabit(habit.id);
                      },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with icon, title and checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon badge
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isCompleted
                                    ? [accentColor.withValues(alpha: 0.3), accentColor.withValues(alpha: 0.2)]
                                    : [accentColor, accentColor.withValues(alpha: 0.8)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: !isCompleted
                                  ? [
                                      BoxShadow(
                                        color: accentColor.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isFard ? Icons.star_rounded : Icons.favorite_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title and streak
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.title,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: isCompleted ? Colors.white.withValues(alpha: 0.6) : Colors.white,
                                    letterSpacing: -0.3,
                                    height: 1.3,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    decorationColor: Colors.white.withValues(alpha: 0.5),
                                    decorationThickness: 2,
                                  ),
                                ),
                                if (hasStreak) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.local_fire_department_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${habit.currentStreak} day${habit.currentStreak > 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                fontSize: 12,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Completion checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? LinearGradient(
                                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isCompleted ? null : Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted ? accentColor : Colors.white.withValues(alpha: 0.3),
                                width: 2.5,
                              ),
                              boxShadow: isCompleted
                                  ? [
                                      BoxShadow(
                                        color: accentColor.withValues(alpha: 0.6),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isCompleted
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                                : null,
                          ),
                        ],
                      ),

                      // Reference section
                      if (habit.ayahReference != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: accentColor.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  habit.ayahReference!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.5,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Action button
                      if (!isCompleted) ...[
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              await database.completeHabit(habit.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: accentColor.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ).copyWith(
                              elevation: WidgetStateProperty.all(0),
                              shadowColor: WidgetStateProperty.all(accentColor.withValues(alpha: 0.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.check_rounded, size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Mark as Complete',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.celebration_rounded,
                                color: accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Completed Today!',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: (100 * index).ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: (100 * index).ms)
        .scale(begin: const Offset(0.85, 0.85), delay: (100 * index).ms);
  }
}
