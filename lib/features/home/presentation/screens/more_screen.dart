import 'package:flutter/material.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/home/presentation/screens/account_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/quran_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/athkar_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/duaa_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/umrah_guide_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/hajj_guide_screen.dart';
import 'package:sakinah_flow/features/home/presentation/screens/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'More',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const Text(
                      'المزيد',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMenuCard(
                      context,
                      icon: Icons.person_rounded,
                      title: 'Account',
                      arabicTitle: 'الحساب',
                      color: const Color(0xFF3B82F6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context,
                      icon: Icons.menu_book_rounded,
                      title: 'Quran',
                      arabicTitle: 'القرآن الكريم',
                      color: const Color(0xFF10B981),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuranScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context,
                      icon: Icons.wb_twilight_rounded,
                      title: 'Athkar',
                      arabicTitle: 'الأذكار',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AthkarScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context,
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Duaa',
                      arabicTitle: 'الأدعية',
                      color: const Color(0xFFF59E0B),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DuaaScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context,
                      icon: Icons.mosque_rounded,
                      title: 'Umrah Guide',
                      arabicTitle: 'دليل العمرة',
                      color: const Color(0xFFEC4899),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UmrahGuideScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context,
                      icon: Icons.mosque_rounded,
                      title: 'Hajj Guide',
                      arabicTitle: 'دليل الحج',
                      color: const Color(0xFF14B8A6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HajjGuideScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context,
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      arabicTitle: 'الإعدادات',
                      color: const Color(0xFF6B7280),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ),
                    ),
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

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String arabicTitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
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
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    arabicTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
