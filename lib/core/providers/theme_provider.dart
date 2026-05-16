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

  // Get theme colors based on selected theme.
  //
  // Each palette has its own distinct identity (no more "they all look
  // the same"). All four stay in the "calm & dignified" register —
  // dark, low-to-mid saturation, never neon.
  //
  // Cues used to make them feel different at a glance:
  //   • Green (Madinah)   → cool emerald-on-charcoal, classical mosque
  //   • Blue Ocean        → cool indigo-on-midnight, distinctly cooler
  //   • Desert Gold       → warm cocoa-on-mocha, distinctly warmer
  //   • Night Purple      → cool aubergine-on-plum, distinctly violet
  //
  // Each palette's `primary` is also unique so buttons, tab pills and
  // chips read differently across themes.
  ThemeColors getThemeColors() {
    switch (state) {
      // ────────────────────────────────────────────────────────────
      case 'Blue Ocean':
        // Cool midnight sea. Distinctly bluer than the default emerald.
        // Background bottom is almost-black with a navy whisper so the
        // theme reads "deep water at night" not "vibrant blue app".
        return ThemeColors(
          primary: const Color(0xFF4F8CC9),       // muted seafoam-blue
          primaryDark: const Color(0xFF2E5C8F),   // deep slate blue
          accent: const Color(0xFF7FB3E0),        // soft sky highlight
          background: const Color(0xFF0C1A2E),    // deep navy
          backgroundDark: const Color(0xFF050B17),// almost black
          backgroundMid: const Color(0xFF18304F), // top of gradient
        );

      // ────────────────────────────────────────────────────────────
      case 'Desert Gold':
        // Warm cocoa & mocha. Reads as "old leather-bound Quran on a
        // wooden table". The only WARM theme — so it stands out
        // clearly from the three cool ones.
        return ThemeColors(
          primary: const Color(0xFFC9962B),       // antique gold
          primaryDark: const Color(0xFF8C6815),   // burnished brass
          accent: const Color(0xFFE5C788),        // pale sand
          background: const Color(0xFF241712),    // deep cocoa
          backgroundDark: const Color(0xFF140C09),// near-black brown
          backgroundMid: const Color(0xFF3A2418), // top of gradient (mocha)
        );

      // ────────────────────────────────────────────────────────────
      case 'Night Purple':
        // Deep aubergine. Distinctly violet — not "purple app", more
        // "Damascus mosaic at night". The accent leans toward rose to
        // separate it from the cooler blue/green themes.
        return ThemeColors(
          primary: const Color(0xFF8B5CF6),       // muted royal violet
          primaryDark: const Color(0xFF5B21B6),   // deep eggplant
          accent: const Color(0xFFC4A0E8),        // dusty lilac
          background: const Color(0xFF1A1130),    // deep indigo
          backgroundDark: const Color(0xFF0C0820),// near-black violet
          backgroundMid: const Color(0xFF2A1B4D), // top of gradient
        );

      // ────────────────────────────────────────────────────────────
      case 'Green (Default)':
      default:
        // Madinah green. The most classical: emerald on near-black
        // charcoal with a hint of green. Reads as "library inside a
        // historic mosque".
        return ThemeColors(
          primary: const Color(0xFF14B889),       // crisp emerald
          primaryDark: const Color(0xFF0B6B4F),   // deep forest
          accent: const Color(0xFF5FD9A8),        // mint highlight
          background: const Color(0xFF0E2520),    // charcoal-green
          backgroundDark: const Color(0xFF06140F),// near-black
          backgroundMid: const Color(0xFF173C32), // top of gradient
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
  final Color backgroundMid;

  ThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.backgroundDark,
    required this.backgroundMid,
  });

  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryDark],
      );

  // 3-stop background gradient. Previously ended in `primary`, which made
  // every screen feel loud because `primary` is a saturated action color.
  // Now uses three muted background shades for a calm, dignified backdrop;
  // `primary` is reserved for buttons and accents.
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [backgroundMid, background, backgroundDark],
      );
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

// Helper provider to get current theme colors.
//
// CRITICAL: watch `themeProvider` (the state), NOT `themeProvider.notifier`
// (the notifier instance, which never changes). Watching the notifier means
// this provider never rebuilds when the theme is changed, so theme toggles
// in Settings appear to do nothing.
final themeColorsProvider = Provider<ThemeColors>((ref) {
  ref.watch(themeProvider); // <-- triggers rebuild on theme changes
  return ref.read(themeProvider.notifier).getThemeColors();
});
