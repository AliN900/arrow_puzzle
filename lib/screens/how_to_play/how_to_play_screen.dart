import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class HowToPlayScreen extends ConsumerWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings.howToPlayTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildSectionHeader(context, strings.howToPlayBasics),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.flag_rounded,
                iconColor: themeColors.accentColor,
                title: strings.howToPlayCoreTitle,
                description: strings.howToPlayCoreDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.navigation_rounded,
                iconColor: Colors.blueAccent,
                title: strings.howToPlayMovementTitle,
                description: strings.howToPlayMovementDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.block_rounded,
                iconColor: Colors.redAccent,
                title: strings.howToPlayObstaclesTitle,
                description: strings.howToPlayObstaclesDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFFF4D6D),
                title: strings.howToPlayLivesTitle,
                description: strings.howToPlayLivesDesc,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, strings.howToPlayBoardElements),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.change_circle_rounded,
                iconColor: Colors.amberAccent,
                title: strings.howToPlayTurnDotsTitle,
                description: strings.howToPlayTurnDotsDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.bolt_rounded,
                iconColor: Colors.orangeAccent,
                title: strings.howToPlayCombosTitle,
                description: strings.howToPlayCombosDesc,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, strings.howToPlayGameModes),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.play_arrow_rounded,
                iconColor: AppColors.accent(context),
                title: strings.howToPlayClassicTitle,
                description: strings.howToPlayClassicDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.spa_rounded,
                iconColor: Colors.greenAccent,
                title: strings.howToPlayZenTitle,
                description: strings.howToPlayZenDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.timer_rounded,
                iconColor: Colors.orangeAccent,
                title: strings.howToPlayTimeAttackTitle,
                description: strings.howToPlayTimeAttackDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.groups_rounded,
                iconColor: Colors.cyanAccent,
                title: strings.howToPlayMultiplayerTitle,
                description: strings.howToPlayMultiplayerDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.casino_rounded,
                iconColor: Colors.purpleAccent,
                title: strings.howToPlayRandomTitle,
                description: strings.howToPlayRandomDesc,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, strings.howToPlayProStrategies),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.lightbulb_rounded,
                iconColor: const Color(0xFFFFD700),
                title: strings.howToPlayUnpeelTitle,
                description: strings.howToPlayUnpeelDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.account_tree_rounded,
                iconColor: Colors.tealAccent,
                title: strings.howToPlayTraceTitle,
                description: strings.howToPlayTraceDesc,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(context, themeColors,
                icon: Icons.touch_app_rounded,
                iconColor: Colors.pinkAccent,
                title: strings.howToPlayTapAssistTitle,
                description: strings.howToPlayTapAssistDesc,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary(context),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildGuideCard(
      BuildContext context,
      ThemeColors themeColors, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String description,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColors.accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColors.accentDark.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}