import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakinah_flow/core/theme/app_theme.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/salah/services/adhan_service.dart';
import 'package:sakinah_flow/features/habits/providers/active_context_provider.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize database on first load
    ref.watch(initializeDatabaseProvider);

    final prayerTimesAsync = ref.watch(prayerTimesNotifierProvider);
    final activeContext = ref.watch(activeContextNotifierProvider);
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderGradient(context),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prayer Times Card
                  _buildPrayerTimesCard(context, prayerTimesAsync)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),

                  // Active Context Card
                  _buildActiveContextCard(context, activeContext)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 100.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),

                  // Fard Habits Section
                  _buildHabitsSection(
                    context,
                    ref,
                    'Obligatory',
                    'فرض',
                    fardHabitsAsync,
                    HabitCategory.fard,
                  ).animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),

                  // Sunnah Habits Section
                  _buildHabitsSection(
                    context,
                    ref,
                    'Recommended',
                    'سنة',
                    sunnahHabitsAsync,
                    HabitCategory.sunnah,
                  ).animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderGradient(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String greetingArabic;
    IconData icon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingArabic = 'صباح الخير';
      icon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingArabic = 'مساء الخير';
      icon = Icons.wb_cloudy;
    } else {
      greeting = 'Good Evening';
      greetingArabic = 'مساء الخير';
      icon = Icons.nightlight_round;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF064E3B),
            const Color(0xFF059669),
            const Color(0xFF10B981),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            greetingArabic,
                            style: AppTheme.arabicHeadingStyle.copyWith(
                              color: const Color(0xFFF3E5AB),
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesCard(BuildContext context, AsyncValue prayerTimesAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: prayerTimesAsync.when(
          data: (prayerTimes) {
            if (prayerTimes == null) {
              return const Text('Unable to load prayer times');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF064E3B), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Prayer Times',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPrayerTimeRow('Fajr', 'الفجر', prayerTimes.fajr, 0),
                _buildPrayerTimeRow('Dhuhr', 'الظهر', prayerTimes.dhuhr, 1),
                _buildPrayerTimeRow('Asr', 'العصر', prayerTimes.asr, 2),
                _buildPrayerTimeRow('Maghrib', 'المغرب', prayerTimes.maghrib, 3),
                _buildPrayerTimeRow('Isha', 'العشاء', prayerTimes.isha, 4),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Text('Error loading prayer times'),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String arabicName, DateTime time, int index) {
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF6366F1),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[index].withValues(alpha: 0.1),
            colors[index].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors[index].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors[index], colors[index].withValues(alpha: 0.6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
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
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    arabicName,
                    style: AppTheme.arabicTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors[index].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContextCard(BuildContext context, ActiveContext context_) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Current Context',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context_.displayName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78350F),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                context_.arabicName,
                style: AppTheme.arabicTextStyle.copyWith(
                  color: const Color(0xFF92400E),
                  fontSize: 20,
                ),
              ),
            ),
          ],
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
        ? const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
          )
        : const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
          );
    final icon = isFard ? Icons.star_rounded : Icons.favorite_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isFard ? const Color(0xFF7C3AED) : const Color(0xFF059669))
                    .withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        titleArabic,
                        style: AppTheme.arabicTextStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
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
        const SizedBox(height: 16),
        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No habits yet',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              );
            }
            return Column(
              children: habits
                  .asMap()
                  .entries
                  .map((entry) => _buildHabitCard(
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
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Text('Error loading habits'),
        ),
      ],
    );
  }

  Widget _buildHabitCard(
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isCompleted
              ? null
              : () async {
                  await database.completeHabit(habit.id);
                },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Streak Badge
                    if (habit.currentStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
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
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${habit.currentStreak} day${habit.currentStreak > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Completion Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                              )
                            : null,
                        color: isCompleted ? null : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? accentColor : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isCompleted ? Colors.grey[400] : Colors.black87,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (habit.ayahReference != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.ayahReference!,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: accentColor.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await database.completeHabit(habit.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: accentColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Mark Complete',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
  }
}
