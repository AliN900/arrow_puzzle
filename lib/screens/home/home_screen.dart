import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/board_themes.dart';
import '../../core/game_mode.dart';
import '../../core/items.dart';
import '../../data/models/trophy.dart';
import '../../main.dart';
import '../../widgets/coin_pill.dart';
import '../../widgets/daily_reward_popup.dart';
import '../../widgets/zen_mode.dart';
import '../game/game_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import '../trophies/trophies_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _preWarmLevels();

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      await _maybeShowDailyPopup();
    });
  }

  Future<void> _maybeShowDailyPopup() async {
    final coinsRepo = ref.read(coinsRepositoryProvider);
    if (!coinsRepo.shouldShowDailyPopup) return;
    if (!mounted) return;

    await coinsRepo.markDailyPopupShown();
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DailyRewardPopup(),
    );
  }

  void _preWarmLevels() {
    final progress = ref.read(progressRepositoryProvider);
    final levelRepo = ref.read(levelRepositoryProvider);
    final currentLevel = progress.currentLevel;
    for (int i = 0; i < 4; i++) {
      levelRepo.preGenerateAsync(currentLevel + i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final auth = ref.watch(authServiceProvider);

    final bgColor = AppColors.background(context);
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    final int currentLevel = progress.currentLevel;
    final int highestLevel = progress.highestUnlockedLevel;
    final bool skinsUnlocked = progress.skinsUnlocked;
    final int starsEarned = List.generate(highestLevel, (i) => i + 1)
        .fold(0, (sum, l) => sum + progress.getStarsForLevel(l));

    final bool dailyReady = coinsRepo.shouldShowDailyPopup;

    const int freeArrowSkins = 4;
    final int ownedSkins = skinsUnlocked
        ? freeArrowSkins + progress.purchasedArrows.length
        : freeArrowSkins + progress.purchasedArrows.length;

    final int totalTrophies = TrophyConstants.allTrophies.length;
    final int unlockedTrophies = progress.unlockedTrophies.length;

    const coinYellow = Color(0xFFFFD54F);
    const trophyRed = Color(0xFFFF5A5F);
    const inventoryGreen = Color(0xFF00C853);
    const dailyBlue = Color(0xFF448AFF);

    final int totalSkins = GameTheme.values.length;

    final int ownedBoards =
        BoardThemes.all.where((b) => progress.isBoardUnlocked(b)).length;
    final int totalBoards = BoardThemes.all.length;

    final int ownedCollections = ownedSkins + ownedBoards;
    final int totalCollections = totalSkins + totalBoards;

    int totalItems = 0;
    for (final item in ItemType.values) {
      totalItems += coinsRepo.getItemCount(item);
    }

    final String inventorySubtitle;
    if (skinsUnlocked) {
      inventorySubtitle = strings.homeInventoryAllUnlocked(totalItems);
    } else if (totalCollections == 0 && totalItems == 0) {
      inventorySubtitle = strings.homeInventoryBrowse;
    } else {
      inventorySubtitle = strings.homeInventoryCounts(
        ownedCollections,
        totalCollections,
        totalItems,
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      AudioHapticHelper.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        image: auth.avatarUrl != null && auth.avatarUrl!.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(auth.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: auth.avatarUrl == null || auth.avatarUrl!.isEmpty
                          ? Center(
                        child: Text(
                          auth.isGuest ? 'P' : auth.avatarInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isGuest ? strings.homePlayer : auth.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          strings.homeLevelStars(currentLevel, starsEarned),
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CoinPill(),
                ],
              ),

              const SizedBox(height: 24),

              // --- Continue Level Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow(context),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.homeContinueLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.homeLevelNumber(currentLevel),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isNavigating
                            ? null
                            : () async {
                          AudioHapticHelper.playClick();
                          if (!mounted) return;
                          setState(() => _isNavigating = true);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                level: currentLevel,
                                gameMode: GameMode.classic,
                              ),
                            ),
                          );
                          if (mounted) {
                            setState(() => _isNavigating = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              strings.homeContinue,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const ZenModeCard(),

              const SizedBox(height: 16),

              // --- 2x2 Grid Section ---
              Row(
                children: [
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: strings.homeDaily,
                      subtitle: dailyReady
                          ? strings.homeDailyReady
                          : strings.homeDailyClaimed,
                      icon: Icons.calendar_today_rounded,
                      iconColor: dailyBlue,
                      hasBadge: dailyReady,
                      badgeColor: trophyRed,
                      onTap: () {
                        ref.read(currentTabProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: strings.homeLeaderboard,
                      subtitle: strings.homeComingSoon,
                      icon: Icons.leaderboard_rounded,
                      iconColor: coinYellow,
                      badgeColor: trophyRed,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: strings.homeInventory,
                      subtitle: inventorySubtitle,
                      icon: Icons.grid_view_rounded,
                      iconColor: inventoryGreen,
                      badgeColor: trophyRed,
                      onTap: () {
                        ref.read(currentTabProvider.notifier).state = 2;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGridCard(
                      context: context,
                      title: strings.homeTrophies,
                      subtitle:
                      strings.homeTrophiesCount(unlockedTrophies, totalTrophies),
                      icon: Icons.emoji_events_rounded,
                      iconColor: trophyRed,
                      badgeColor: trophyRed,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrophiesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow(context),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28),
                if (hasBadge)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}