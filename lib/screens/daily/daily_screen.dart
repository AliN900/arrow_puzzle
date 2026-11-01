import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/game_mode.dart';
import '../../core/leader_coins.dart';
import '../../main.dart';
import '../../widgets/attempts_stamp.dart';
import '../../widgets/status_flash.dart';
import '../game/game_screen.dart';
import '../profile/profile_screen.dart';
import 'arrow_rushcard.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  // ── LOGIC: DAILY ROTATION ──
  bool _isModeAvailableToday(GameMode mode) {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

    // Friday: All modes unlocked
    if (today == 5) return true;

    // 6-day rotation: Sat→Sun→Mon→Tue→Wed→Thu
    switch (today) {
      case 6: // Saturday
        return mode == GameMode.endlessRush;
      case 7: // Sunday
        return mode == GameMode.blitz;
      case 1: // Monday
        return mode == GameMode.timeBlitz;
      case 2: // Tuesday
        return mode == GameMode.endlessRush;
      case 3: // Wednesday
        return mode == GameMode.blitz;
      case 4: // Thursday
        return mode == GameMode.timeBlitz;
      default:
        return false;
    }
  }

  String _getNextUnlockDay(GameMode mode) {
    final now = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final nextWeekday = now.add(Duration(days: i)).weekday;

      // Friday unlocks everything
      if (nextWeekday == 5) return 'Friday';

      bool isAvailable = false;
      switch (nextWeekday) {
        case 6: isAvailable = mode == GameMode.endlessRush; break;
        case 7: isAvailable = mode == GameMode.blitz; break;
        case 1: isAvailable = mode == GameMode.timeBlitz; break;
        case 2: isAvailable = mode == GameMode.endlessRush; break;
        case 3: isAvailable = mode == GameMode.blitz; break;
        case 4: isAvailable = mode == GameMode.timeBlitz; break;
      }

      if (isAvailable) {
        const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return days[nextWeekday];
      }
    }
    return 'Friday';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final bg = AppColors.background(context);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    // ── SORTING LOGIC ──
    // Base order when all are unlocked: Rush -> Blitz -> Time Blitz
    const baseModes = [
      GameMode.endlessRush,
      GameMode.blitz,
      GameMode.timeBlitz,
    ];

    // Copy the list so we don't mutate the constant
    final sortedModes = List<GameMode>.from(baseModes);

    sortedModes.sort((a, b) {
      final aAvailable = _isModeAvailableToday(a);
      final bAvailable = _isModeAvailableToday(b);

      // Unlocked modes always go to the top
      if (aAvailable && !bAvailable) return -1;
      if (!aAvailable && bAvailable) return 1;

      // If both are unlocked or both are locked, sort by base order
      return baseModes.indexOf(a).compareTo(baseModes.indexOf(b));
    });

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                strings.dailyChallengesTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                strings.dailyChallengesSubtitle,
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              const SizedBox(height: 20),

              // Daily Rewards shortcut
              GestureDetector(
                onTap: () {
                  AudioHapticHelper.playClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.dailyRewardsTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.dailyRewardsSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                strings.activeChallengesTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // ── RENDER SORTED ACTIVE MODES ──
              ...sortedModes.map((mode) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCardForMode(context, ref, mode),
                );
              }),

              // ── MINE ARROWS (Always last) ──
              _buildChallengeCard(
                context: context,
                mode: GameMode.classic, // Placeholder
                title: strings.mineArrowsTitle,
                subtitle: strings.mineArrowsSubtitle,
                badgeText: strings.badgeComingSoon,
                badgeColor: Colors.grey,
                icon: Icons.bug_report_rounded,
                color: Colors.redAccent,
                isComingSoon: true,
                onTap: () {
                  StatusFlash.fail(context, strings.mineArrowsComingSoonSnack);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper to build the correct widget for a mode ──
  Widget _buildCardForMode(BuildContext context, WidgetRef ref, GameMode mode) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    final selected = progress.rushDifficulty;

    switch (mode) {
      case GameMode.endlessRush:
        return _buildGlassLock(
          context,
          mode,
          ArrowRushCard(
            progress: progress,
            selected: selected,
            accent: accent,
            card: card,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        );
      case GameMode.blitz:
        return _buildChallengeCard(
          context: context,
          mode: mode,
          title: strings.blitzTitle,
          subtitle: strings.blitzSubtitle,
          badgeText: strings.badgeNew,
          badgeColor: const Color(0xFF00BCD4),
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFF00BCD4),
          isComingSoon: false,
          attemptsRemaining: coinsRepo.lcAttemptsRemaining(LeaderCoins.modeBlitz),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GameScreen(
                  level: 1,
                  gameMode: GameMode.blitz,
                ),
              ),
            );
          },
        );
      case GameMode.timeBlitz:
        return _buildChallengeCard(
          context: context,
          mode: mode,
          title: strings.gameModeTimeBlitz,
          subtitle: strings.timeBlitzDesc,
          badgeText: strings.badgeNew,
          badgeColor: const Color(0xFFFF5722),
          icon: Icons.hourglass_bottom_rounded,
          color: const Color(0xFFFF5722),
          isComingSoon: false,
          attemptsRemaining: coinsRepo.lcAttemptsRemaining(LeaderCoins.modeTimeBlitz),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GameScreen(
                  level: 1,
                  gameMode: GameMode.timeBlitz,
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }


  // ── UNIFIED WRAPPER: Adds the glass smog and lock icon if locked ──
  Widget _buildGlassLock(BuildContext context, GameMode mode, Widget child) {
    final isLocked = !_isModeAvailableToday(mode);
    if (!isLocked) return child;
    final strings = AppStrings.of(context);

    return AbsorbPointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Matches the card border
        child: Stack(
          children: [
            // 1. Blur the child itself (No BackdropFilter = No scrolling glitches)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: child,
            ),

            // 2. The dark smog tint and lock text on top
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.unlocksIn(_getNextUnlockDay(mode)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard({
    required BuildContext context,
    required GameMode mode,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color color,
    required bool isComingSoon,
    int attemptsRemaining = LeaderCoins.attemptsPerDay,
    required VoidCallback onTap,
  }) {
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final effectiveColor = isComingSoon ? Colors.grey : color;

    final baseCard = GestureDetector(
      onTap: isComingSoon
          ? null
          : () {
        AudioHapticHelper.playClick();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: effectiveColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: effectiveColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: effectiveColor, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock_clock_rounded,
                        color: effectiveColor,
                        size: 26,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isComingSoon)
                PositionedDirectional(
                  top: 5,
                  end: 10,
                  child: AttemptsStamp(remaining: attemptsRemaining),
                ),
            ],
          ),
        ),
      ),
    );

    if (isComingSoon) return baseCard;
    return _buildGlassLock(context, mode, baseCard);
  }
}