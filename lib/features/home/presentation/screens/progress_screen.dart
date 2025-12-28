import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';

class ProgressScreen extends HookConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);

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
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(),
                    const SizedBox(height: 24),
                    _buildStreaksSection(fardHabitsAsync, sunnahHabitsAsync),
                    const SizedBox(height: 24),
                    _buildStatistics(fardHabitsAsync, sunnahHabitsAsync),
                    const SizedBox(height: 24),
                    _buildMonthlyCalendar(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            Text(
              'التقدم',
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
            Icons.trending_up_rounded,
            color: Color(0xFF0A1F1A),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final completionRates = [85, 90, 75, 95, 80, 70, 60];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final rate = completionRates[index];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Text(
                            weekDays[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: rate.toDouble(),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        const Color(0xFFD4AF37),
                                        const Color(0xFFB8941C),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$rate%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreaksSection(
    AsyncValue<List<dynamic>> fardHabitsAsync,
    AsyncValue<List<dynamic>> sunnahHabitsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Streaks',
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
              final allHabits = [...fardHabits, ...sunnahHabits];
              final habitsWithStreaks = allHabits
                  .where((h) => h.currentStreak > 0)
                  .toList()
                ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

              if (habitsWithStreaks.isEmpty) {
                return GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No active streaks yet. Start building your habits!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: habitsWithStreaks.take(5).map((habit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStreakCard(habit),
                  );
                }).toList(),
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

  Widget _buildStreakCard(dynamic habit) {
    final isFard = habit.category == HabitCategory.fard;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isFard
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              ),
            ),
            child: Icon(
              isFard ? Icons.star_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isFard ? 'Fard • فرض' : 'Sunnah • سنة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFF97316),
                size: 24,
              ),
              const SizedBox(width: 4),
              Text(
                '${habit.currentStreak}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(
    AsyncValue<List<dynamic>> fardHabitsAsync,
    AsyncValue<List<dynamic>> sunnahHabitsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
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
              final totalStreaks = fardHabits.fold<int>(0, (sum, h) => sum + h.currentStreak as int) +
                  sunnahHabits.fold<int>(0, (sum, h) => sum + h.currentStreak as int);
              final longestStreak = [...fardHabits, ...sunnahHabits]
                  .fold<int>(0, (max, h) => h.currentStreak > max ? h.currentStreak as int : max);
              final bestEverStreak = [...fardHabits, ...sunnahHabits]
                  .fold<int>(0, (max, h) => h.bestStreak > max ? h.bestStreak as int : max);

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Habits',
                          totalHabits.toString(),
                          Icons.format_list_bulleted_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Days',
                          totalStreaks.toString(),
                          Icons.calendar_today_rounded,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Current Streak',
                          '$longestStreak days',
                          Icons.local_fire_department_rounded,
                          const Color(0xFFF97316),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Best Streak',
                          '$bestEverStreak days',
                          Icons.emoji_events_rounded,
                          const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ],
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'December 2025',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                  return SizedBox(
                    width: 36,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isToday = day == 25;
                  final hasActivity = day <= 25;
                  final completionRate = hasActivity ? (60 + (day % 40)) : 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFFD4AF37)
                          : hasActivity
                              ? _getCompletionColor(completionRate)
                              : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: const Color(0xFF0A1F1A),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? const Color(0xFF0A1F1A)
                              : hasActivity
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Low', const Color(0xFF1E40AF)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Medium', const Color(0xFF3B82F6)),
                  const SizedBox(width: 16),
                  _buildLegendItem('High', const Color(0xFF10B981)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCompletionColor(int rate) {
    if (rate >= 80) {
      return const Color(0xFF10B981);
    } else if (rate >= 50) {
      return const Color(0xFF3B82F6);
    } else {
      return const Color(0xFF1E40AF);
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
