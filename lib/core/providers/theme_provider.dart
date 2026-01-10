import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme state notifier
class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('Green (Default)') {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selected_theme') ?? 'Green (Default)';
  }

  Future<void> setTheme(String theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
  }

  // Get theme colors based on selected theme
  ThemeColors getThemeColors() {
    switch (state) {
      case 'Blue Ocean':
        return ThemeColors(
          primary: const Color(0xFF3B82F6),
          primaryDark: const Color(0xFF2563EB),
          accent: const Color(0xFF60A5FA),
          background: const Color(0xFF1E3A8A),
          backgroundDark: const Color(0xFF1E40AF),
        );
      case 'Desert Gold':
        return ThemeColors(
          primary: const Color(0xFFD4AF37),
          primaryDark: const Color(0xFFB8941C),
          accent: const Color(0xFFE5C158),
          background: const Color(0xFF78350F),
          backgroundDark: const Color(0xFF92400E),
        );
      case 'Night Purple':
        return ThemeColors(
          primary: const Color(0xFF9333EA),
          primaryDark: const Color(0xFF7C3AED),
          accent: const Color(0xFFA855F7),
          background: const Color(0xFF581C87),
          backgroundDark: const Color(0xFF6B21A8),
        );
      case 'Green (Default)':
      default:
        return ThemeColors(
          primary: const Color(0xFF10B981),
          primaryDark: const Color(0xFF059669),
          accent: const Color(0xFF34D399),
          background: const Color(0xFF064E3B),
          backgroundDark: const Color(0xFF065F46),
        );
    }
  }
}

// Theme colors class
class ThemeColors {
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color backgroundDark;

  ThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.backgroundDark,
  });

  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryDark],
      );

  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [background, backgroundDark, primary],
      );
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

// Helper provider to get current theme colors
final themeColorsProvider = Provider<ThemeColors>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.getThemeColors();
});
