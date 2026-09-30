import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==========================================================
  // CONTEXT-AWARE HELPERS
  // Use these everywhere in your UI. They auto-switch between
  // light and dark based on the current Theme.
  // ==========================================================

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      _isDark(context) ? darkSurface : lightSurface;

  static Color surfaceLight(BuildContext context) =>
      _isDark(context) ? darkSurfaceLight : lightSurfaceLight;

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      _isDark(context) ? darkTextMuted : lightTextMuted;

  // Accent = whatever color the user picked in Settings
  static Color accent(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color divider(BuildContext context) => _isDark(context)
      ? const Color(0xFF2E3137)
      : const Color(0xFFE0E0E0);

  static Color cardShadow(BuildContext context) => Colors.black.withValues(
    alpha: _isDark(context) ? 0.3 : 0.04,
  );

  // ==========================================================
  // BASE COLOR CONSTANTS
  // Used internally by the helpers. Don't use directly in UI.
  // ==========================================================

  // --- LIGHT ---
  static const Color lightBackground = Color(0xFFF2F4F8);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceLight = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF1A1D20);
  static const Color lightTextSecondary = Color(0xFF8A8D93);
  static const Color lightTextMuted = Color(0xFF9E9E9E);

  // --- DARK ---
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceLight = Color(0xFF2E3137);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextMuted = Color(0xFF6E727A);
}