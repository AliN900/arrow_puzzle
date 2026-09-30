import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/level.dart';
import 'game_dialog_button.dart';

class LevelCompleteDialog extends StatelessWidget {
  final LevelModel level;
  final int stars;
  final bool isRandom;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.stars,
    this.isRandom = false,
    required this.onNextLevel,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);
    const surfaceAlt = Color(0xFF141414);

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
            const Text(
              'Level Complete!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: i < stars
                        ? accent
                        : surface.withValues(alpha: 0.6),
                    size: 38,
                  ),
                )
                    .animate(delay: Duration(milliseconds: 200 + i * 150))
                    .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (level.levelNumber == 500) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, color: accent, size: 32)
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You Finished the Game!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Congratulations! You\'ve solved all 500 challenges. Stay tuned for more levels coming soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (!isRandom) ...[
              GameDialogButton(
                label: 'Next Level',
                icon: Icons.play_arrow_rounded,
                onTap: onNextLevel,
              ),
              const SizedBox(height: 10),
            ],
            GameDialogButton(
              label: 'Home',
              icon: Icons.home_rounded,
              textColor: textPrimary,
              onTap: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}