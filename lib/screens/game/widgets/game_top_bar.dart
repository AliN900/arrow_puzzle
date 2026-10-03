import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';
import '../../../widgets/lives_bar.dart';

class GameTopBar extends ConsumerWidget {
  final LevelModel level;
  final bool isRandom;
  final VoidCallback onPause;
  final GameMode gameMode;
  final int score;
  final int lives;
  final bool heartRemover;

  const GameTopBar({
    super.key,
    required this.level,
    this.isRandom = false,
    required this.onPause,
    required this.gameMode,
    this.score = 0,
    required this.lives,
    this.heartRemover = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Formatted title — "Lv.007" for levels, or the mode name
    String titleText;
    if (gameMode == GameMode.timeAttack) {
      titleText = 'Score: $score';
    } else if (gameMode == GameMode.zen) {
      titleText = gameMode.label;
    } else if (isRandom) {
      titleText = 'Random';
    } else {
      titleText =
      'Lv.${level.levelNumber.toString().padLeft(0, '0')}';
    }

    final showHearts = !heartRemover && gameMode != GameMode.timeAttack;

    Widget? livesWidget;
    if (showHearts) {
      if (gameMode == GameMode.zen) {
        livesWidget = const Text(
          '∞',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      } else {
        livesWidget = LivesBar(
          lives: lives,
          maxLives: AppConstants.maxLives,
        );
      }
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CENTER — title
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),

          // LEFT — hearts
          if (livesWidget != null)
            Align(
              alignment: Alignment.centerLeft,
              child: livesWidget,
            ),

          // RIGHT — pause
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onPause,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}