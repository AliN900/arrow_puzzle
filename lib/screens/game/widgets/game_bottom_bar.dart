import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/game_mode.dart';
import '../../../widgets/lives_bar.dart';

class GameBottomBar extends StatelessWidget {
  final int lives;
  final double progress;
  final GameMode gameMode;
  final bool heartRemover;

  const GameBottomBar({
    super.key,
    required this.lives,
    required this.progress,
    required this.gameMode,
    this.heartRemover = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 130,
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          if (heartRemover || gameMode == GameMode.timeAttack)
            const SizedBox()
          else if (gameMode == GameMode.zen)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFB0B0B0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '∞',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          else
            LivesBar(lives: lives, maxLives: AppConstants.maxLives),
        ],
      ),
    );
  }
}