import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';
import 'game_dialog_button.dart';

class GameOverDialog extends StatelessWidget {
  final LevelModel level;
  final bool isTimeout;
  final int continueTime;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onMenu;
  final GameMode gameMode;
  final int score;

  const GameOverDialog({
    super.key,
    required this.level,
    this.isTimeout = false,
    this.continueTime = 0,
    required this.onContinue,
    required this.onRestart,
    required this.onMenu,
    this.gameMode = GameMode.classic,
    this.score = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isTimeAttack = gameMode == GameMode.timeAttack;
    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTimeAttack
                  ? Icons.timer_off_rounded
                  : (isTimeout ? Icons.hourglass_top : Icons.heart_broken),
              color: isTimeAttack ? Colors.orangeAccent : accent,
              size: 52,
            ).animate().shake(duration: 500.ms),
            const SizedBox(height: 12),
            Text(
              isTimeAttack
                  ? "Time's Up!"
                  : (isTimeout ? 'Out of Time!' : 'Out of Lives!'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            if (isTimeAttack) ...[
              const SizedBox(height: 8),
              Text(
                'Puzzles Cleared: $score\nFinal Level: ${level.levelNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            GameDialogButton(
              label: isTimeAttack ? 'Start New Run' : 'Restart Level',
              icon: Icons.refresh_rounded,
              textColor: textPrimary,
              onTap: onRestart,
            ),
            const SizedBox(height: 10),
            GameDialogButton(
              label: 'Home',
              icon: Icons.home_rounded,
              textColor: textSecondary,
              onTap: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}