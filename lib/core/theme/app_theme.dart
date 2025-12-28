import 'package:flutter/material.dart';
import 'package:sakinah_flow/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.emerald,
        primaryContainer: AppColors.emeraldLight,
        secondary: AppColors.sand,
        secondaryContainer: AppColors.sandLight,
        surface: AppColors.slateLightest,
        onPrimary: Colors.white,
        onSecondary: AppColors.slateDark,
        onSurface: AppColors.slateDarkest,
        error: AppColors.error,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: AppColors.slateDarkest,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: AppColors.slateDarkest,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppColors.slateDarkest,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.slateDarkest,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.slateDarkest,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.slateDarkest,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.slateDarkest,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.slateDark,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.slateDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.slate,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.slate,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.slateLight,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slateLightest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slateLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slateLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.slate,
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
