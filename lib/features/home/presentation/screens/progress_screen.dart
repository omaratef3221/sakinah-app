import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class ProgressScreen extends HookConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);
    final isHijri = useState(false); // Toggle between Gregorian and Hijri calendar

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
                    _buildMonthlyCalendar(isHijri),
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

  Widget _buildMonthlyCalendar(ValueNotifier<bool> isHijri) {
    final now = DateTime.now();
    final hijriNow = HijriCalendar.now();

    // Calendar data based on type
    String currentMonth;
    int daysInMonth;
    int firstWeekday;
    DateTime today;
    HijriCalendar? currentHijriMonth; // Store current Hijri month for date conversion

    if (isHijri.value) {
      // Hijri calendar
      currentMonth = '${hijriNow.getLongMonthName()} ${hijriNow.hYear}';
      daysInMonth = hijriNow.lengthOfMonth;
      currentHijriMonth = hijriNow; // Store for date conversion
      // Calculate first day of Hijri month - create new HijriCalendar for day 1
      final firstDayHijri = HijriCalendar()
        ..hYear = hijriNow.hYear
        ..hMonth = hijriNow.hMonth
        ..hDay = 1;
      // The HijriCalendar automatically calculates the weekday
      firstWeekday = (firstDayHijri.wkDay ?? 0) % 7;
      today = DateTime(now.year, now.month, now.day);
    } else {
      // Gregorian calendar
      currentMonth = DateFormat('MMMM yyyy').format(now);
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      daysInMonth = lastDayOfMonth.day;
      firstWeekday = firstDayOfMonth.weekday % 7;
      today = DateTime(now.year, now.month, now.day);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentMonth,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monthly Activity',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Calendar type toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildCalendarToggleButton(
                    'Gregorian',
                    'ميلادي',
                    !isHijri.value,
                    () => isHijri.value = false,
                  ),
                  const SizedBox(width: 4),
                  _buildCalendarToggleButton(
                    'Hijri',
                    'هجري',
                    isHijri.value,
                    () => isHijri.value = true,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFD4AF37).withValues(alpha: 0.08),
              const Color(0xFF10B981).withValues(alpha: 0.05),
            ],
          ),
          child: Column(
            children: [
              // Day headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                  return SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Calendar grid with empty cells for proper alignment
              _buildCalendarGrid(firstWeekday, daysInMonth, today, currentHijriMonth),
              const SizedBox(height: 20),
              // Legend with encouragement
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('0-33%', const Color(0xFF1E40AF)),
                        const SizedBox(width: 12),
                        _buildLegendItem('34-66%', const Color(0xFF3B82F6)),
                        const SizedBox(width: 12),
                        _buildLegendItem('67-99%', const Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        _buildLegendItem('100%', const Color(0xFFD4AF37)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep your streak alive! Every day counts 🌟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(int firstWeekday, int daysInMonth, DateTime today, HijriCalendar? hijriMonth) {
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        // Calculate the day number
        final dayNumber = index - firstWeekday + 1;

        // Empty cell before month starts or after month ends
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        // Convert Hijri date to Gregorian for database queries
        DateTime date;
        if (hijriMonth != null) {
          // Create Hijri date for this day and convert to Gregorian
          final hijriDate = HijriCalendar();
          date = hijriDate.hijriToGregorian(hijriMonth.hYear, hijriMonth.hMonth, dayNumber);
        } else {
          // Use Gregorian date directly
          date = DateTime(today.year, today.month, dayNumber);
        }

        final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
        final isPast = date.isBefore(today);
        final isFuture = date.isAfter(today);

        return _buildCalendarDay(dayNumber, isToday, isPast, isFuture, date);
      },
    );
  }

  Widget _buildCalendarDay(int day, bool isToday, bool isPast, bool isFuture, DateTime date) {
    return Consumer(
      builder: (context, ref, child) {
        final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
        final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);
        final database = ref.watch(habitsDatabaseProvider);

        return fardHabitsAsync.when(
          data: (fardHabits) => sunnahHabitsAsync.when(
            data: (sunnahHabits) {
              final allHabits = [...fardHabits, ...sunnahHabits];

              if (allHabits.isEmpty) {
                return _buildDayCell(day, isToday, isPast, isFuture, 0, 0);
              }

              // Use FutureBuilder to check completions for this specific date
              return FutureBuilder<int>(
                future: _getCompletionsForDate(database, allHabits, date),
                builder: (context, snapshot) {
                  final completedCount = snapshot.data ?? 0;
                  final completionRate = allHabits.isEmpty
                      ? 0
                      : (completedCount / allHabits.length * 100).round();

                  return _buildDayCell(
                    day,
                    isToday,
                    isPast,
                    isFuture,
                    completionRate,
                    completedCount,
                  );
                },
              );
            },
            loading: () => _buildDayCell(day, isToday, isPast, isFuture, 0, 0),
            error: (_, __) => _buildDayCell(day, isToday, isPast, isFuture, 0, 0),
          ),
          loading: () => _buildDayCell(day, isToday, isPast, isFuture, 0, 0),
          error: (_, __) => _buildDayCell(day, isToday, isPast, isFuture, 0, 0),
        );
      },
    );
  }

  Future<int> _getCompletionsForDate(
    HabitsDatabase database,
    List<dynamic> habits,
    DateTime date,
  ) async {
    int completedCount = 0;

    for (final habit in habits) {
      final isCompleted = await database.isCompletedOnDate(habit.id, date);
      if (isCompleted) {
        completedCount++;
      }
    }

    return completedCount;
  }

  Widget _buildDayCell(
    int day,
    bool isToday,
    bool isPast,
    bool isFuture,
    int completionRate,
    int completedCount,
  ) {
    Color backgroundColor;
    Color textColor;
    bool hasBorder = false;
    bool hasGlow = false;

    if (isToday) {
      backgroundColor = const Color(0xFFD4AF37);
      textColor = const Color(0xFF0A1F1A);
      hasBorder = true;
      hasGlow = true;
    } else if (isFuture) {
      backgroundColor = Colors.white.withValues(alpha: 0.05);
      textColor = Colors.white.withValues(alpha: 0.3);
    } else if (completionRate == 100) {
      backgroundColor = const Color(0xFFD4AF37);
      textColor = const Color(0xFF0A1F1A);
      hasGlow = true;
    } else if (completionRate >= 67) {
      backgroundColor = const Color(0xFF10B981);
      textColor = Colors.white;
    } else if (completionRate >= 34) {
      backgroundColor = const Color(0xFF3B82F6);
      textColor = Colors.white;
    } else if (completionRate > 0) {
      backgroundColor = const Color(0xFF1E40AF);
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white.withValues(alpha: 0.05);
      textColor = Colors.white.withValues(alpha: 0.4);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: hasBorder
            ? Border.all(
                color: const Color(0xFF0A1F1A),
                width: 2.5,
              )
            : null,
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (completedCount > 0 && !isToday)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: completionRate == 100
                      ? const Color(0xFF0A1F1A)
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (isToday)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A1F1A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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

  Widget _buildCalendarToggleButton(
    String label,
    String arabicLabel,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF0A1F1A) : const Color(0xFFD4AF37),
              ),
            ),
            Text(
              arabicLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF0A1F1A).withValues(alpha: 0.8)
                    : const Color(0xFFD4AF37).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
