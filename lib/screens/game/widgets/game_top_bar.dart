import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
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
    final strings = AppStrings.of(context);

    String titleText;
    if (gameMode == GameMode.timeAttack ||
        gameMode == GameMode.timeBlitz) {
      titleText = strings.gameTopBarScore(score);
    } else if (gameMode == GameMode.zen) {
      titleText = gameMode.localizedLabel(context);
    } else if (gameMode == GameMode.endlessRush) {
      titleText = strings.arrowRushTitle;
    } else if (isRandom) {
      titleText = strings.gameTopBarRandom;
    } else {
      titleText = strings.gameTopBarLevelNumber(level.levelNumber.toString());
    }

    final progress = ref.watch(progressRepositoryProvider);
    final showHearts = !heartRemover &&
        gameMode != GameMode.timeAttack &&
        gameMode != GameMode.timeBlitz;

    Widget? livesWidget;
    if (showHearts) {
      // Only Zen has truly infinite hearts. Endless Rush now uses the
      // player's real campaign hearts.
      final isInfiniteMode = gameMode == GameMode.zen;

      if (isInfiniteMode || lives > 5) {
        livesWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_rounded,
                  color: Colors.redAccent, size: 18),
              const SizedBox(width: 4),
              Text(
                isInfiniteMode ? '∞' : '$lives',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else {
        // Endless Rush reports level 999, which would always give the wrong
        // heart cap. Use the player's real campaign level for the ratio.
        final effectiveLevel = gameMode == GameMode.endlessRush
            ? progress.currentLevel
            : level.levelNumber;

        livesWidget = LivesBar(
          lives: lives,
          maxLives: progress.getMaxLivesForLevel(effectiveLevel),
        );
      }
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          if (livesWidget != null)
            Align(
              alignment: Alignment.centerLeft,
              child: livesWidget,
            ),
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