import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- LIGHT THEME COLORS ---
  static const Color lightBackground = Color(0xFFF2F4F8);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceLight = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF1A1D20);
  static const Color lightTextSecondary = Color(0xFF8A8D93);
  static const Color lightTextMuted = Color(0xFF9E9E9E);

  // --- DARK THEME COLORS ---
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceLight = Color(0xFF2E3137);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextMuted = Color(0xFF6E727A);

  // --- EXISTING COLORS (Keep these so the rest of your app compiles) ---
  static const Color background = Color(0xFF161719);
  static const Color surface = Color(0xFF222428);
  static const Color surfaceLight = Color(0xFF2E3137);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF6E727A);
  static const Color primary = Color(0xFF76ED12);
  static const Color accent = Color(0xFF76ED12);
  static const Color accentDark = Color(0xFF5CB80D);
  static const Color accentOrange = Color(0xFFFF9800);
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF1C1D21), Color(0xFF121315)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}