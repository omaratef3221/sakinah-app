import 'package:flutter/material.dart';
import 'package:sakinah_flow/core/constants/app_colors.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';

class AppTheme {
  AppTheme._();

  // Builds a Material theme that matches the user-selected ThemeColors.
  // The visual app is mostly dark-on-gradient; this theme tunes Material
  // surfaces (dialogs, inputs, snackbars, FAB) to match the active accent.
  static ThemeData buildTheme(ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,

      colorScheme: ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.goldOnDark,
        primaryContainer: colors.primary,
        onPrimaryContainer: Colors.white,
        secondary: colors.accent,
        onSecondary: Colors.white,
        surface: colors.background,
        onSurface: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 57, fontWeight: FontWeight.w700, color: Colors.white),
        displayMedium: TextStyle(fontFamily: 'Inter', fontSize: 45, fontWeight: FontWeight.w700, color: Colors.white),
        displaySmall: TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w600, color: Colors.white),
        headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
        headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        titleSmall: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
        bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
      ),

      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white.withValues(alpha: 0.06),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: colors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.goldOnDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.goldOnDark,
        elevation: 4,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.backgroundDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      iconTheme: const IconThemeData(color: Colors.white),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Arabic Text Style
  static const TextStyle arabicTextStyle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static const TextStyle arabicHeadingStyle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.6,
  );
}
