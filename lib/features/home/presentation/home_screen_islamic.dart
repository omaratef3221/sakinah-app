import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/core/theme/app_theme.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:sakinah_flow/features/habits/providers/active_context_provider.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';

class HomeScreenIslamic extends HookConsumerWidget {
  const HomeScreenIslamic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(initializeDatabaseProvider);

    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);
    final activeContext = ref.watch(activeContextNotifierProvider);
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);
    final themeColors = ref.watch(themeColorsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeColors.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Islamic Header
              SliverToBoxAdapter(
                child: _buildIslamicHeader(context),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),

                    // Prayer Times Ornate Card
                    _buildPrayerTimesOrnate(context, prayerTimesAsync)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),

                    // Current Context
                    _buildContextOrnate(context, activeContext)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),

                    // Fard Section
                    _buildIslamicSection(
                      context,
                      ref,
                      'Fard',
                      'الفرائض',
                      fardHabitsAsync,
                      true,
                    ).animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 20),

                    // Sunnah Section
                    _buildIslamicSection(
                      context,
                      ref,
                      'Sunnah',
                      'السنن',
                      sunnahHabitsAsync,
                      false,
                    ).animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideX(begin: 0.2, end: 0),
                    const SizedBox(height: 80), // Bottom padding
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIslamicHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String arabicGreeting;

    if (hour < 12) {
      greeting = 'As-salamu alaykum';
      arabicGreeting = 'السلام عليكم';
    } else if (hour < 17) {
      greeting = 'As-salamu alaykum';
      arabicGreeting = 'السلام عليكم';
    } else {
      greeting = 'As-salamu alaykum';
      arabicGreeting = 'السلام عليكم';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Islamic Star Pattern
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.nights_stay,
                  color: Color(0xFFD4AF37),
                  size: 32,
                ),
              ),
            ),
          ).animate()
              .scale(duration: 800.ms, curve: Curves.easeOut)
              .rotate(duration: 20000.ms, begin: 0, end: 1),
          const SizedBox(height: 20),

          // Greeting Text
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Color(0xFFD4AF37),
              letterSpacing: 1,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
          const SizedBox(height: 8),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabicGreeting,
              style: AppTheme.arabicHeadingStyle.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 100.ms).slideY(begin: -0.2, end: 0),
          ),

          const SizedBox(height: 12),

          // Decorative Line
          Container(
            width: 100,
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFD4AF37),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate().scaleX(duration: 800.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesOrnate(BuildContext context, AsyncValue prayerTimesAsync) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: prayerTimesAsync.when(
              data: (prayerTimes) {
                if (prayerTimes == null) return const SizedBox();
                return Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, Color(0xFFD4AF37)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Prayer Times',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPrayerTimeItem('Fajr', 'الفجر', prayerTimes.fajr),
                    _buildPrayerTimeItem('Dhuhr', 'الظهر', prayerTimes.dhuhr),
                    _buildPrayerTimeItem('Asr', 'العصر', prayerTimes.asr),
                    _buildPrayerTimeItem('Maghrib', 'المغرب', prayerTimes.maghrib),
                    _buildPrayerTimeItem('Isha', 'العشاء', prayerTimes.isha),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              ),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeItem(String name, String arabic, DateTime time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A5F4E).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(3),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    arabic,
                    style: AppTheme.arabicTextStyle.copyWith(
                      fontSize: 14,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F1A),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextOrnate(BuildContext context, ActiveContext context_) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.2),
            const Color(0xFFD4AF37).withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Current Time',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFD4AF37),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context_.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              context_.arabicName,
              style: AppTheme.arabicTextStyle.copyWith(
                fontSize: 18,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    String titleArabic,
    AsyncValue<List<Habit>> habitsAsync,
    bool isFard,
  ) {
    return Column(
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFard
                  ? [
                      const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    ]
                  : [
                      const Color(0xFF4A9B7F).withValues(alpha: 0.3),
                      const Color(0xFF4A9B7F).withValues(alpha: 0.15),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFard
                  ? const Color(0xFFD4AF37).withValues(alpha: 0.5)
                  : const Color(0xFF4A9B7F).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFard ? Icons.star_rounded : Icons.favorite_rounded,
                color: isFard ? const Color(0xFFD4AF37) : const Color(0xFF4A9B7F),
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      titleArabic,
                      style: AppTheme.arabicTextStyle.copyWith(
                        fontSize: 16,
                        color: isFard ? const Color(0xFFD4AF37) : const Color(0xFF4A9B7F),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Habits List
        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) return const SizedBox();
            return Column(
              children: habits
                  .asMap()
                  .entries
                  .map((entry) => _buildIslamicHabitCard(
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
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          ),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildIslamicHabitCard(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    bool isFard,
    int index,
  ) {
    final database = ref.read(habitsDatabaseProvider);
    final isCompleted = habit.lastCompleted != null &&
        DateTime.now().difference(habit.lastCompleted!).inHours < 24;

    final accentColor = isFard ? const Color(0xFFD4AF37) : const Color(0xFF4A9B7F);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.2),
                        accentColor.withValues(alpha: 0.1),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isCompleted
                    ? null
                    : () async {
                        await database.completeHabit(habit.id);
                      },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Checkbox
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isCompleted
                                  ? LinearGradient(colors: [accentColor, accentColor.withValues(alpha: 0.7)])
                                  : null,
                              border: Border.all(
                                color: accentColor,
                                width: 2,
                              ),
                            ),
                            child: isCompleted
                                ? Icon(Icons.check, color: Color(0xFF0A1F1A), size: 18)
                                : null,
                          ),
                          const SizedBox(width: 14),

                          // Title
                          Expanded(
                            child: Text(
                              habit.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.white,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),

                          // Streak
                          if (habit.currentStreak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: accentColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_fire_department, color: accentColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${habit.currentStreak}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      if (habit.ayahReference != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1F1A).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            habit.ayahReference!,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: accentColor.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
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
        .fadeIn(duration: 400.ms, delay: (80 * index).ms)
        .slideX(begin: isFard ? -0.1 : 0.1, end: 0, delay: (80 * index).ms);
  }
}
