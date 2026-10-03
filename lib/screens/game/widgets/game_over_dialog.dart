import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';
import '../../../main.dart';
import '../../../unity_rewarded_ad.dart';
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
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _watchAd() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not available, try again later'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onDismissed: () {
        if (!mounted) return;
        if (_isWatchingAd) setState(() => _isWatchingAd = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTimeAttack = widget.gameMode == GameMode.timeAttack;
    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);
    const rewardGreen = Color(0xFF4CAF50);

    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final canWatch = coinsRepo.canWatchRewardedAd;

    // Title + subtitle based on state
    final String title;
    final IconData icon;
    final Color iconColor;
    if (isTimeAttack) {
      title = "Time's Up!";
      icon = Icons.timer_off_rounded;
      iconColor = Colors.orangeAccent;
    } else if (widget.isTimeout) {
      title = 'Out of Time!';
      icon = Icons.hourglass_top;
      iconColor = accent;
    } else {
      title = 'Out of Lives!';
      icon = Icons.heart_broken;
      iconColor = accent;
    }

    // Reward description
    final String rewardLabel = widget.isTimeout
        ? '+${widget.continueTime}s'
        : '+${widget.heartReward} ${widget.heartReward == 1 ? "heart" : "hearts"}';

    // Show ad button only if available and not already claimed in this dialog
    final showAdOption =
        !isTimeAttack && !_adRewardClaimed && widget.adRewardAvailable;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
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
                  'Puzzles Cleared: ${widget.score}\nFinal Level: ${widget.level.levelNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Ad reward button
              if (showAdOption)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isWatchingAd || !canWatch ? null : _watchAd,
                    icon: _isWatchingAd
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: rewardGreen,
                      ),
                    )
                        : const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 22,
                    ),
                    label: Text(
                      _isWatchingAd
                          ? 'Loading ad...'
                          : canWatch
                          ? 'Watch ad → $rewardLabel'
                          : 'Daily ad limit reached',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: rewardGreen,
                      disabledForegroundColor:
                      textSecondary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: canWatch
                            ? rewardGreen.withValues(alpha: 0.5)
                            : textSecondary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

              if (showAdOption) const SizedBox(height: 12),

              // Restart
              GameDialogButton(
                label: isTimeAttack ? 'Start New Run' : 'Restart Level',
                icon: Icons.refresh_rounded,
                textColor: textPrimary,
                iconColor: accent,
                onTap: widget.onRestart,
              ),
              const SizedBox(height: 10),

              // Home
              GameDialogButton(
                label: 'Home',
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