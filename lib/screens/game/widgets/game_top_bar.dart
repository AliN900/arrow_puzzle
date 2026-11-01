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
    if (gameMode == GameMode.timeAttack || gameMode == GameMode.timeBlitz) {
      titleText = strings.gameTopBarScore(score);
    } else if (gameMode == GameMode.zen) {
      titleText = gameMode.localizedLabel(context);
    } else if (gameMode == GameMode.endlessRush) {
      titleText = strings.arrowRushTitle;
    } else if (isRandom) {
      titleText = strings.gameTopBarRandom;
    } else {
      titleText = strings.levelDetailsTitle(level.levelNumber);
    }

    final progress = ref.watch(progressRepositoryProvider);
    final showHearts = !heartRemover &&
        gameMode != GameMode.timeAttack &&
        gameMode != GameMode.timeBlitz;

    Widget? livesWidget;
    if (showHearts) {
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
              const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
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
        final effectiveLevel = gameMode == GameMode.endlessRush
            ? progress.currentLevel
            : level.levelNumber;

        livesWidget = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: LivesBar(
            lives: lives,
            maxLives: progress.getMaxLivesForLevel(effectiveLevel),
          ),
        );
      }
    }

    const double sideSlotWidth = 95.0; // Keeps center title symmetrically balanced

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 1. LEFT SLOT: Hearts / Infinite Indicator ─────────────────
          SizedBox(
            width: sideSlotWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: livesWidget ?? const SizedBox.shrink(),
            ),
          ),

          // ── 2. CENTER SLOT: Bounded Responsive Title (Stroke + Shader) ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer stroke border + drop shadow
                      Text(
                        titleText,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4.0
                            ..color = const Color(0x59000000),
                          shadows: const [
                            Shadow(
                              color: Color(0x4D000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      // Gradient fill
                      ShaderMask(
                        shaderCallback: _heartGradient,
                        child: Text(
                          titleText,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. RIGHT SLOT: Pause Button ───────────────────────────────
          SizedBox(
            width: sideSlotWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onPause,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.pause_rounded,
                        color: Color(0x59000000),
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Color(0x4D000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      ShaderMask(
                        shaderCallback: _heartGradient,
                        child: Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Shader _heartGradient(Rect bounds) => const LinearGradient(
  colors: [Colors.white, Color(0xFFB0B0B0)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
).createShader(bounds);