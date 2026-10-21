import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/constants.dart';
import '../../core/package_info_provider.dart';
import '../settings/widgets/settings_section_header.dart';
import '../settings/widgets/settings_card.dart';
import '../settings/widgets/settings_nav_tile.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(packageInfoProvider);
    final strings = AppStrings.of(context);
    final bgColor = AppColors.background(context);
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    final divider = Divider(
      height: 1,
      color: textSecondary.withValues(alpha: 0.2),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () {
            AudioHapticHelper.playClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          strings.aboutTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // ── App Logo / Title ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: accent.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.extension_rounded,
                              color: accent,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appFullName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ── DYNAMIC VERSION HERE ──
                  versionAsync.when(
                    data: (info) => Text(
                      strings.aboutVersion(info.version),
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => Text(
                      strings.aboutVersion('1.1.2'),
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Developer Credits ──
            SettingsSectionHeader(title: 'DEVELOPER', color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.aboutDeveloper,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.aboutOriginalConcept,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                divider,
                SettingsNavTile(
                  icon: Icons.language_rounded,
                  title: strings.aboutVisitWebsite,
                  onTap: () => _launchUrl('https://ahbdev.dev'),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Music Credits ──
            SettingsSectionHeader(title: strings.aboutMusicTitle, color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                _buildCreditTile(
                  title: strings.aboutUnderwaterTheme,
                  author: 'CleytonKauffman (CC0)',
                  context: context,
                ),
                divider,
                _buildCreditTile(
                  title: strings.aboutCallerTheme,
                  author: 'SpringySpringo (CC-BY 3.0)',
                  context: context,
                ),
                divider,
                _buildCreditTile(
                  title: strings.aboutGrooveTheme,
                  author: 'Spring Spring / Julie Damsgaard (CC-BY 4.0)',
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                strings.aboutMusicSource,
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── SVG Icons & Art ──
            SettingsSectionHeader(title: strings.aboutIconsTitle, color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                _buildIconCreditTile(title: strings.aboutIconsCredit1, context: context),
                divider,
                _buildIconCreditTile(title: strings.aboutIconsCredit2, context: context),
                divider,
                _buildIconCreditTile(title: strings.aboutIconsCredit3, context: context),
                divider,
                _buildIconCreditTile(title: strings.aboutIconsCredit4, context: context),
                divider,
                SettingsNavTile(
                  icon: Icons.link_rounded,
                  title: strings.aboutVisitSvgRepo,
                  onTap: () => _launchUrl('https://www.svgrepo.com'),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Open Source Libraries ──
            SettingsSectionHeader(title: strings.aboutOpenSourceTitle, color: textSecondary),
            SettingsCard(
              cardColor: cardColor,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.aboutOpenSourceBody,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _techChip('Flutter', accent),
                          _techChip('Flame', accent),
                          _techChip('Riverpod', accent),
                          _techChip('Audioplayers', accent),
                          _techChip('Hive', accent),
                          _techChip('Appwrite', accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ── Footer ──
            Center(
              child: Text(
                strings.aboutCopyright,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditTile({
    required String title,
    required String author,
    required BuildContext context,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.music_note_rounded, color: textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCreditTile({
    required String title,
    required BuildContext context,
  }) {
    final strings = AppStrings.of(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.brush_rounded, color: textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.aboutIconsAuthors,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techChip(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: accent,
        ),
      ),
    );
  }
}