import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ──── Brand Colors ────
  static const Color primary = Color(0xFF6C63FF);       // Vibrant violet
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF4A43CC);

  static const Color secondary = Color(0xFF00D9A6);     // Mint green
  static const Color secondaryLight = Color(0xFF4DFFCE);
  static const Color secondaryDark = Color(0xFF00A67E);

  static const Color accent = Color(0xFFFF6584);        // Coral pink
  static const Color accentOrange = Color(0xFFFF9F43);  // Warm orange
  static const Color accentBlue = Color(0xFF54A0FF);    // Sky blue

  static const Color error = Color(0xFFFF5252);

  // ──── Gradient Palettes ────
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9C54FF),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF00D9A6),
    Color(0xFF00B0D9),
  ];
  static const List<Color> warmGradient = [
    Color(0xFFFF6584),
    Color(0xFFFF9F43),
  ];
  static const List<Color> coolGradient = [
    Color(0xFF54A0FF),
    Color(0xFF6C63FF),
  ];
  static const List<Color> greenGradient = [
    Color(0xFF00D9A6),
    Color(0xFF00A67E),
  ];

  // ──── Light Mode ────
  static const Color backgroundLight = Color(0xFFF5F6FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE8ECF0);

  static const Color textPrimaryLight = Color(0xFF1A1D2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // ──── Dark Mode ────
  static const Color backgroundDark = Color(0xFF0F1120);
  static const Color surfaceDark = Color(0xFF1A1D2E);
  static const Color cardDark = Color(0xFF1E2235);
  static const Color dividerDark = Color(0xFF2D3147);

  static const Color textPrimaryDark = Color(0xFFF0F1F5);
  static const Color textSecondaryDark = Color(0xFF8B93A7);
  static const Color textTertiaryDark = Color(0xFF5C6478);

  // ──── Semantic Colors ────
  static const Color success = Color(0xFF00D9A6);
  static const Color warning = Color(0xFFFF9F43);
  static const Color info = Color(0xFF54A0FF);

  // ──── Step Status Colors ────
  static const Color stepActive = Color(0xFF6C63FF);
  static const Color stepIdle = Color(0xFF8B93A7);

  // ──── Chart Colors ────
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF00D9A6),
    Color(0xFFFF6584),
    Color(0xFFFF9F43),
    Color(0xFF54A0FF),
    Color(0xFF9C54FF),
    Color(0xFFFF6B9D),
  ];

  // ──── Stat Card Colors ────
  static const Color stepsCardStart = Color(0xFF6C63FF);
  static const Color stepsCardEnd = Color(0xFF9C54FF);
  static const Color caloriesCardStart = Color(0xFFFF6584);
  static const Color caloriesCardEnd = Color(0xFFFF9F43);
  static const Color distanceCardStart = Color(0xFF00D9A6);
  static const Color distanceCardEnd = Color(0xFF00B0D9);
  static const Color timeCardStart = Color(0xFF54A0FF);
  static const Color timeCardEnd = Color(0xFF6C63FF);
}
