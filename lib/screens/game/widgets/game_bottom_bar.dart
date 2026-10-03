import 'package:flutter/material.dart';

class GameBottomBar extends StatelessWidget {
  final int lives;
  final double progress;
  final dynamic gameMode;
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
    return const SizedBox(height: 12);
  }
}