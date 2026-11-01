import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/board_themes.dart';
import '../../core/items.dart';
import '../../core/music_player.dart';
import '../../data/models/trophy.dart';
import '../../dev/mine_arrow_dev_screen.dart';
import '../multiplayer/multiplayer_screen.dart';
import '../../dev/test_mine_level.dart';
import '../../main.dart';
import '../../widgets/coin_pill.dart';
import '../../widgets/custom_pop_dialog.dart';
import '../../widgets/daily_reward_popup.dart';
import '../../widgets/home_hero_card.dart';
import '../../widgets/zen_mode.dart';
import '../game/game_screen.dart';
import '../level_select/level_select_screen.dart';
import '../profile/profile_screen.dart';
import '../trophies/trophies_screen.dart';

/// Compile-time build flag:
/// - Defaults to `false` for standard Production builds.
/// - Set to `true` via `--dart-define=ENABLE_MP=true` for Open Testing builds.
const bool kEnableMultiplayer =
bool.fromEnvironment('ENABLE_MP', defaultValue: false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _exitChannel = MethodChannel('ahb.dev.arrow_puzzle/exit');

  @override
  void initState() {
    super.initState();
    MusicPlayer.instance.play(MusicPlayer.trackMenu);
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

  // ─────────────────────────────────────────────────────────────────
  // Exit flow
  // ─────────────────────────────────────────────────────────────────

  Future<void> _handleExit() async {
    AudioHapticHelper.playClick();

    final strings = AppStrings.of(context);
    final accent = AppColors.accent(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomPopDialog(
        title: strings.dialogExitTitle,
        message: strings.dialogExitMessage,
        icon: Icon(
          Icons.exit_to_app_rounded,
          color: accent,
          size: 34,
        ),
        confirmText: strings.buttonExit,
        onConfirm: () {},
        onCancel: () {},
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      await _exitChannel.invokeMethod('killApp');
    } on MissingPluginException catch (e) {
      debugPrint('🔴 [exit] channel missing: $e');
      if (mounted) await SystemNavigator.pop();
    } on PlatformException catch (e) {
      debugPrint('🔴 [exit] platform error: $e');
      if (mounted) await SystemNavigator.pop();
    } catch (e) {
      debugPrint('🔴 [exit] unknown: $e');
      if (mounted) await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final auth = ref.watch(authServiceProvider);

    final bgColor = AppColors.background(context);
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
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        image: auth.avatarUrl != null &&
                            auth.avatarUrl!.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(auth.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: auth.avatarUrl == null ||
                          auth.avatarUrl!.isEmpty
                          ? Center(
                        child: Text(
                          auth.avatarInitial,
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
                          auth.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          strings.homeLevelStars(
                              currentLevel, starsEarned),
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

              // --- Continue card → opens Level Select ---
              HomeHeroCard(
                label: strings.homeContinueLabel,
                title: strings.homeLevelNumber(currentLevel),
                icon: Icons.play_arrow_rounded,
                iconColor: accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen(),
                    ),
                  );
                },
              ),

              // ── 1v1 MULTIPLAYER CARD (Renders when ENABLE_MP=true) ──
              if (kEnableMultiplayer) ...[
                const SizedBox(height: 16),
                IgnorePointer(
                  ignoring: auth.isGuest,
                  child: GestureDetector(
                    onTap: () {
                      AudioHapticHelper.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MultiplayerScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: auth.isGuest
                              ? [Colors.grey.shade500, Colors.grey.shade700]
                              : [
                            accent,
                            accent.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            // 👈 NEW: Grey shadow for guests
                            color: auth.isGuest
                                ? Colors.black.withValues(alpha: 0.2)
                                : accent.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              // 👈 NEW: Lock icon for guests
                              auth.isGuest
                                  ? Icons.lock_rounded
                                  : Icons.sports_esports_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.homeMpTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  // 👈 NEW: Prompt text for guests
                                  auth.isGuest
                                      ? 'Sign in / Sign up to play'
                                      : strings.homeMpSubtitle,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            // 👈 NEW: Change arrow to lock for guests
                            auth.isGuest
                                ? Icons.lock_rounded
                                : Icons.arrow_forward_ios_rounded,
                            color: auth.isGuest ? Colors.white54 : Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              const ZenModeCard(),

              const SizedBox(height: 16),

              // ── DEBUG / DEV ONLY TOOLS (OVERFLOW SAFE) ──
              if (kDebugMode) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bug_report_rounded,
                              color: Colors.amber, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'DEV PROTOTYPES (DEBUG MODE ONLY)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _debugDevScreenButton(
                              context,
                              label: 'MINE STAIRCASE',
                              icon: Icons.grid_goldenratio_rounded,
                              color: const Color(0xFFFF9800),
                              screen: const MineArrowDevScreen(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _debugDevScreenButton(
                              context,
                              label: '1v1 RACE',
                              icon: Icons.sports_esports_rounded,
                              color: const Color(0xFF00E676),
                              screen: const MultiplayerScreen(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _debugMineButton(context, 250)),
                          const SizedBox(width: 8),
                          Expanded(child: _debugMineButton(context, 400)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                      subtitle: progress.isLeaderboardUnlocked
                          ? '${_formatLc(progress.lbAllTimeScore)} LC'
                          : '${_formatLc(progress.lbAllTimeScore)} / '
                          '${_formatLc(progress.leaderboardUnlockTarget)} LC',
                      icon: progress.isLeaderboardUnlocked
                          ? Icons.leaderboard_rounded
                          : Icons.lock_rounded,
                      iconColor: coinYellow,
                      badgeColor: trophyRed,
                      progress: progress.isLeaderboardUnlocked
                          ? null
                          : progress.leaderboardUnlockProgress,
                      onTap: () {},
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
                      subtitle: strings.homeTrophiesCount(
                          unlockedTrophies, totalTrophies),
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

              const SizedBox(height: 24),

              // ── Exit button ──
              _buildExitButton(context, strings),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton(BuildContext context, AppStrings strings) {
    const redTop = Color(0xFFE53935);
    const redBottom = Color(0xFFB71C1C);

    return GestureDetector(
      onTap: _handleExit,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [redTop, redBottom],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: redTop.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.power_settings_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              strings.buttonExit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
    double? progress,
  }) {
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 132,
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
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (progress != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(iconColor),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLc(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Widget _debugDevScreenButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required Widget screen,
      }) {
    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black87, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _debugMineButton(BuildContext context, int levelNumber) {
    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              level: levelNumber,
              prebuiltLevel: TestMineLevel.create(levelNumber: levelNumber),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.science_rounded,
                  color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                'TEST L$levelNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}