import 'package:arrow_puzzle/screens/settings/widgets/debug_level_jumper.dart';
import 'package:arrow_puzzle/screens/settings/widgets/share_qr_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/constants.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/leaderboard_service.dart';
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
    final strings = AppStrings.of(context);
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
          strings.settingsTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: _LanguageChip(
                currentCode: progress.languageCode,
                onTap: () => _showLanguagePicker(context, ref),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            SettingsSectionHeader(title: strings.settingsAppearance, color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: textSecondary),
                  title: Text(
                    strings.settingsDarkMode,
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
            SettingsCard(
              cardColor: cardColor,
              children: [
                SettingsSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: strings.settingsSoundEffects,
                  value: progress.soundEnabled,
                  onChanged: (_) =>
                      ref.read(progressRepositoryProvider).toggleSound(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
// ── Volume slider (only meaningful when sound is on) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        progress.soundVolume == 0
                            ? Icons.volume_off_rounded
                            : Icons.volume_down_rounded,
                        size: 20,
                        color: progress.soundEnabled
                            ? textSecondary
                            : textSecondary.withValues(alpha: 0.4),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: progress.soundEnabled
                                ? accentColor
                                : accentColor.withValues(alpha: 0.3),
                            thumbColor: progress.soundEnabled
                                ? accentColor
                                : accentColor.withValues(alpha: 0.3),
                            inactiveTrackColor: accentColor.withValues(alpha: 0.15),
                            overlayColor: accentColor.withValues(alpha: 0.1),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: progress.soundVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: progress.soundEnabled
                                ? (value) {
                              ref
                                  .read(progressRepositoryProvider)
                                  .setSoundVolume(value);
                            }
                                : null,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up_rounded,
                        size: 20,
                        color: progress.soundEnabled
                            ? textSecondary
                            : textSecondary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${(progress.soundVolume * 100).round()}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: progress.soundEnabled
                                ? textPrimary
                                : textPrimary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                divider,
                // SettingsSwitchTile(
                //   icon: Icons.music_note_outlined,
                //   title: 'Music',
                //   value: progress.musicEnabled,
                //   onChanged: (_) =>
                //       ref.read(progressRepositoryProvider).toggleMusic(),
                //   accentColor: accentColor,
                //   textPrimary: textPrimary,
                //   textSecondary: textSecondary,
                // ),
                // divider,
                SettingsSwitchTile(
                  icon: Icons.vibration_outlined,
                  title: strings.settingsVibration,
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
            SettingsSectionHeader(title: strings.settingsArrowSpeed, color: textSecondary),
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

            // --- ABOUT ---
            SettingsSectionHeader(title: strings.settingsAbout, color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                // DEBUG-ONLY: LB opt-in toggle. In release builds, opt-in is
                // automatic (see ProgressRepository default), so this tile is hidden.
                if (kDebugMode) ...[
                  SettingsSwitchTile(
                    icon: Icons.emoji_events_outlined,
                    title: strings.leaderboardOptInTitle,
                    value: progress.leaderboardOptIn,
                    onChanged: (value) async {
                      AudioHapticHelper.playClick();
                      final auth = ref.read(authServiceProvider);
                      final repo = ref.read(progressRepositoryProvider);
                      await repo.setLeaderboardOptIn(value);

                      if (value && !auth.isGuest) {
                        await LeaderboardRepository.instance.pushCurrentUser(
                          level: progress.currentLevel,
                          totalStars: progress.totalStars,
                          trophies: progress.unlockedTrophies.length,
                          weeklyScore: progress.lbWeeklyScore,
                          monthlyScore: progress.lbMonthlyScore,
                          allTimeScore: progress.lbAllTimeScore,
                          weeklyPeriodStart: progress.lbWeeklyPeriodStart ??
                              LeaderboardService.currentWeekStartUtc(),
                          monthlyPeriodStart: progress.lbMonthlyPeriodStart ??
                              LeaderboardService.currentMonthStartUtc(),
                          weeklyReachedAt: progress.lbWeeklyReachedAt,
                          monthlyReachedAt: progress.lbMonthlyReachedAt,
                        );
                      }
                    },
                    accentColor: accentColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  divider,
                ],
                SettingsNavTile(
                  icon: Icons.qr_code_rounded,
                  title: strings.settingsShareFriends,
                  onTap: () {
                    AudioHapticHelper.playClick();
                    showShareQR(context);
                  },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsNavTile(
                  icon: Icons.shield_outlined,
                  title: strings.settingsPrivacyPolicy,
                  onTap: () => launchUrl(
                    Uri.parse('https://ahbdev.dev/arrow-puzzle/privacy.html'),
                    mode: LaunchMode.externalApplication,
                  ),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                divider,
                SettingsNavTile(
                  icon: Icons.description_outlined,
                  title: strings.settingsTermsConditions,
                  onTap: () => launchUrl(
                    Uri.parse('https://ahbdev.dev/arrow-puzzle/terms.html'),
                    mode: LaunchMode.externalApplication,
                  ),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 40),

            Center(
              child: kDebugMode
                  ? GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) => const DebugLevelJumper(),
                  );
                },
                child: _buildVersionBadge(strings, textPrimary, textSecondary),
              )
                  : _buildVersionBadge(strings, textPrimary, textSecondary),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget _buildVersionBadge(
    AppStrings strings,
    Color textPrimary,
    Color textSecondary,
    ) {
  return Column(
    children: [
      Text(
        AppConstants.appFullName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        strings.settingsVersionLabel('1.0.0'),
        style: TextStyle(fontSize: 14, color: textSecondary),
      ),
    ],
  );
}

/// Small language chip shown in the Settings AppBar. Shows the current
/// language code + a chevron; tapping opens the picker bottom sheet.
class _LanguageChip extends StatelessWidget {
  final String currentCode;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.currentCode,
    required this.onTap,
  });

  /// Short label to display in the chip.
  String get _label {
    switch (currentCode) {
      case 'system':
        return 'AUTO';
      case 'en':
        return 'EN';
      case 'es':
        return 'ES';
      case 'pt':
        return 'PT';
      case 'id':
        return 'ID';
      case 'hi':
        return 'HI';
      case 'ar':
        return 'AR';
      case 'fr':
        return 'FR';
      default:
        return currentCode.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: accent,
            ),
            const SizedBox(width: 6),
            Text(
              _label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  final strings = AppStrings.of(context);
  final progress = ref.read(progressRepositoryProvider);
  final accent = AppColors.accent(context);
  final textPrimary = AppColors.textPrimary(context);
  final textSecondary = AppColors.textSecondary(context);

  final languages = <({String code, String name, String native})>[
    (code: 'system', name: strings.languageSystemDefault, native: 'Auto'),
    (code: 'en', name: strings.languageEnglish, native: 'English'),
    (code: 'es', name: strings.languageSpanish, native: 'Español'),
    (code: 'pt', name: strings.languagePortugueseBR, native: 'Português'),
    (code: 'id', name: strings.languageIndonesian, native: 'Bahasa Indonesia'),
    (code: 'hi', name: strings.languageHindi, native: 'हिन्दी'),
    (code: 'ar', name: strings.languageArabic, native: 'العربية'),
    (code: 'fr', name: strings.languageFrench, native: 'Français'),
  ];

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              strings.settingsChooseLanguage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (_, i) {
                final lang = languages[i];
                final selected = progress.languageCode == lang.code;
                return ListTile(
                  onTap: () {
                    AudioHapticHelper.playClick();
                    ref.read(progressRepositoryProvider).setLanguageCode(lang.code);
                    Navigator.pop(ctx);
                  },
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? accent : textSecondary,
                  ),
                  title: Text(
                    lang.name,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    lang.native,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}