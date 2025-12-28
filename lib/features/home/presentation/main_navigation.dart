import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/features/home/presentation/screens/dashboard_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/prayer_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/leaderboard_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/habits_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/progress_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/more_screen.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends HookConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const DashboardScreen(),
      const PrayerScreen(),
      const LeaderboardScreen(),
      const HabitsScreen(),
      const ProgressScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A5F4E).withValues(alpha: 0.95),
              const Color(0xFF0F3D30).withValues(alpha: 0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  ref,
                  0,
                  Icons.home_rounded,
                  'Home',
                  'الرئيسية',
                ),
                _buildNavItem(
                  context,
                  ref,
                  1,
                  Icons.access_time_rounded,
                  'Prayer',
                  'الصلاة',
                ),
                _buildNavItem(
                  context,
                  ref,
                  2,
                  Icons.emoji_events_rounded,
                  'Leaders',
                  'المتصدرين',
                ),
                _buildNavItem(
                  context,
                  ref,
                  3,
                  Icons.check_circle_rounded,
                  'Habits',
                  'العادات',
                ),
                _buildNavItem(
                  context,
                  ref,
                  4,
                  Icons.insights_rounded,
                  'Progress',
                  'التقدم',
                ),
                _buildNavItem(
                  context,
                  ref,
                  5,
                  Icons.menu_rounded,
                  'More',
                  'المزيد',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData icon,
    String label,
    String arabicLabel,
  ) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(navigationIndexProvider.notifier).state = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0A1F1A) : const Color(0xFFD4AF37),
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0A1F1A) : const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
