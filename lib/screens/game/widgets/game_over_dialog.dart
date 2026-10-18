import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../../core/app_colors.dart';
import '../../../core/audio_haptic_helper.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';
import '../../../unity_rewarded_ad.dart';
import '../../../widgets/status_flash.dart';
import 'game_dialog_button.dart';

class GameOverDialog extends ConsumerStatefulWidget {
  final LevelModel level;
  final bool isTimeout;
  final int continueTime;
  final int heartReward;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onMenu;
  final GameMode gameMode;
  final int score;
  final bool adRewardAvailable;

  const GameOverDialog({
    super.key,
    required this.level,
    this.isTimeout = false,
    this.continueTime = 0,
    this.heartReward = 1,
    required this.onContinue,
    required this.onRestart,
    required this.onMenu,
    this.gameMode = GameMode.classic,
    this.score = 0,
    this.adRewardAvailable = true,
  });

  @override
  ConsumerState<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends ConsumerState<GameOverDialog> {
  bool _isWatchingAd = false;
  bool _adRewardClaimed = false;

  Future<void> _watchAd(AppStrings strings) async {
    if (_isWatchingAd || _adRewardClaimed) return;
    setState(() => _isWatchingAd = true);

    await UnityRewardedAd.show(
      onRewarded: () {
        if (!mounted) return;
        setState(() {
          _isWatchingAd = false;
          _adRewardClaimed = true;
        });
        widget.onContinue();
      },
      onFailed: () {
        if (!mounted) return;
        setState(() => _isWatchingAd = false);
        StatusFlash.fail(context, strings.adNotAvailable);
      },
      onDismissed: () {
        if (!mounted) return;
        if (_isWatchingAd) setState(() => _isWatchingAd = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isTimeAttack = widget.gameMode == GameMode.timeAttack;
    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);

    final String title;
    final IconData icon;
    final Color iconColor;
    if (isTimeAttack) {
      title = strings.gameOverTimeUp;
      icon = Icons.timer_off_rounded;
      iconColor = Colors.orangeAccent;
    } else if (widget.isTimeout) {
      title = strings.gameOverOutOfTime;
      icon = Icons.hourglass_top;
      iconColor = accent;
    } else {
      title = strings.gameOverOutOfLives;
      icon = Icons.heart_broken;
      iconColor = accent;
    }

    final String rewardLabel = widget.isTimeout
        ? strings.gameOverRewardTime(widget.continueTime)
        : strings.gameOverRewardHearts(widget.heartReward);

    final showAdOption =
        !isTimeAttack && !_adRewardClaimed && widget.adRewardAvailable;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 32,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 52)
                  .animate()
                  .shake(duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              if (isTimeAttack) ...[
                const SizedBox(height: 8),
                Text(
                  strings.gameOverTimeAttackStats(
                    widget.score,
                    widget.level.levelNumber,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              if (showAdOption) ...[
                GestureDetector(
                  onTap: () {
                    AudioHapticHelper.playClick();
                    if (!_isWatchingAd) _watchAd(strings);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 14, 28, 14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accent, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isWatchingAd
                                ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                                : Icon(
                              Icons.play_circle_outline_rounded,
                              color: accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _isWatchingAd
                                      ? strings.loadingLabel
                                      : strings.gameOverWatchAdReward(rewardLabel),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: accent,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: accent, width: 1),
                          ),
                          child: Text(
                            strings.adBadge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              GameDialogButton(
                label: isTimeAttack
                    ? strings.gameOverStartNewRun
                    : strings.gameOverRestartLevel,
                icon: Icons.refresh_rounded,
                textColor: textPrimary,
                iconColor: accent,
                onTap: widget.onRestart,
              ),
              const SizedBox(height: 10),

              GameDialogButton(
                label: strings.homeButton,
                icon: Icons.home_rounded,
                textColor: textSecondary,
                iconColor: accent,
                onTap: widget.onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}