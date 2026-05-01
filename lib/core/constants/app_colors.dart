import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Islamic green)
  static const emerald = Color(0xFF064E3B);
  static const emeraldLight = Color(0xFF10B981);
  static const emeraldDark = Color(0xFF022C22);
  static const emeraldDeep = Color(0xFF0F3D30); // app scaffold backdrop
  static const emeraldTeal = Color(0xFF1A5F4E); // dialog accents

  // Accent Colors (gold) — primary highlight throughout the app
  static const gold = Color(0xFFD4AF37);
  static const goldDark = Color(0xFFB8941C);
  static const goldLight = Color(0xFFE5C158);
  static const goldOnDark = Color(0xFF0A1F1A); // text on gold backgrounds

  // Secondary Colors
  static const sand = Color(0xFFF3E5AB);
  static const sandLight = Color(0xFFFFF9E6);
  static const sandDark = Color(0xFFE0D299);

  // Neutral Colors
  static const slate = Color(0xFF475569);
  static const slateLightest = Color(0xFFF8FAFC);
  static const slateLight = Color(0xFF94A3B8);
  static const slateDark = Color(0xFF334155);
  static const slateDarkest = Color(0xFF0F172A);

  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Prayer Category Colors
  static const fardColor = emerald;
  static const sunnahColor = Color(0xFF8B5CF6);
  static const athkarColor = Color(0xFFEC4899);
}
