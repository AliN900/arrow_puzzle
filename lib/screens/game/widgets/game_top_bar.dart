import 'package:flutter/material.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';

class GameTopBar extends StatelessWidget {
  final LevelModel level;
  final bool isRandom;
  final VoidCallback onPause;
  final GameMode gameMode;
  final int score;

  const GameTopBar({
    super.key,
    required this.level,
    this.isRandom = false,
    required this.onPause,
    required this.gameMode,
    this.score = 0,
  });

  @override
  Widget build(BuildContext context) {
    String titleText;
    if (gameMode == GameMode.timeAttack) {
      titleText = 'Score: $score';
    } else if (gameMode == GameMode.zen) {
      titleText = gameMode.label;
    } else if (isRandom) {
      titleText = 'Random Mode';
    } else {
      titleText = 'Level ${level.levelNumber}';
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Center(
            child: Text(
              titleText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onPause,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child:
                Icon(Icons.pause_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}