import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../main.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/settings_nav_tile.dart';
import 'widgets/accent_color_picker.dart';
import 'widgets/arrow_speed_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<Color> accentColors = [
    Color(0xFF6C4CF1), // Purple
    Color(0xFF00C853), // Green
    Color(0xFF448AFF), // Blue
    Color(0xFFFF5A5F), // Red/Pink
    Color(0xFFFFD54F), // Yellow
    Color(0xFF00BCD4), // Cyan
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeMode = progress.themeMode;
    final accentColor = progress.accentColor;
    final isDark = themeMode == ThemeMode.dark;

    final bgColor =
    isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final divider = Divider(
      height: 1,
      color: textSecondary.withValues(alpha: 0.2),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // --- APPEARANCE ---
            SettingsSectionHeader(title: 'APPEARANCE', color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: textSecondary),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      ref
                          .read(progressRepositoryProvider)
                          .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                    activeThumbColor: accentColor,
                    activeTrackColor: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                divider,
                AccentColorPicker(
                  accentColors: accentColors,
                  selectedColor: accentColor,
                  onColorSelected: (color) {
                    ref
                        .read(progressRepositoryProvider)
                        .setAccentColor(color);
                  },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- AUDIO & HAPTICS ---
            SettingsSectionHeader(
              title: 'AUDIO & HAPTICS',
              color: textSecondary,
            ),
            SettingsCard(
              cardColor: cardColor,
              children: [
                SettingsSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound effects',
                  value: progress.soundEnabled,
                  onChanged: (_) =>
                      ref.read(progressRepositoryProvider).toggleSound(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsSwitchTile(
                  icon: Icons.music_note_outlined,
                  title: 'Music',
                  value: progress.musicEnabled,
                  onChanged: (_) =>
                      ref.read(progressRepositoryProvider).toggleMusic(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsSwitchTile(
                  icon: Icons.vibration_outlined,
                  title: 'Vibration',
                  value: progress.hapticsEnabled,
                  onChanged: (_) =>
                      ref.read(progressRepositoryProvider).toggleHaptics(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- ARROW SPEED ---
            SettingsSectionHeader(title: 'ARROW SPEED', color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                ArrowSpeedSection(
                  speed: progress.arrowSpeed,
                  onSpeedChanged: (value) => ref
                      .read(progressRepositoryProvider)
                      .setArrowSpeed(value),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- GENERAL ---
            SettingsSectionHeader(title: 'GENERAL', color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                SettingsNavTile(
                  icon: Icons.share_outlined,
                  title: 'Share with friends',
                  onTap: () {/* TODO: Share */},
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsNavTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate the app',
                  onTap: () {/* TODO: Rate */},
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsNavTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Contact support',
                  onTap: () {/* TODO: Contact */},
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- ABOUT ---
            SettingsSectionHeader(title: 'ABOUT', color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                SettingsNavTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () {/* TODO: Privacy */},
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsNavTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {/* TODO: Terms */},
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 40),

            Center(
              child: Column(
                children: [
                  Text(
                    'Arrows — Puzzle Escape',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (1)',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}