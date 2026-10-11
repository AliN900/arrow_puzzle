import 'dart:async';
import '../core/game_mode.dart';
import '../data/models/arrow.dart';
import 'game_state.dart';
import 'helpers/endless_spawner.dart';

extension GameStateModes on GameState {
  /// Returns true if an arrow was successfully queued (telegraph blink has
  /// started), false if no valid spawn slot was found.
  bool spawnEndlessArrowWithTelegraph() {
    if (gameMode != GameMode.endlessRush || isGameOver || isComplete) {
      return false;
    }
    final newArrow = EndlessSpawner.trySpawnArrow(
      gridSize: level.gridSize,
      existingArrows: [...arrows, ...telegraphArrows],
      rocks: rocks,
    );
    if (newArrow == null) return false;

    failedSpawnCount = 0;
    telegraphArrows.add(newArrow);
    refresh();

    int blinkTicks = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Abort if the game ended OR the telegraph was cancelled.
      if (isGameOver ||
          isComplete ||
          isTelegraphCancelled(newArrow.id)) {
        timer.cancel();
        telegraphArrows.remove(newArrow);
        clearTelegraphCancellation(newArrow.id);
        refresh();
        return;
      }

      blinkTicks++;
      refresh();

      if (blinkTicks >= 10) {
        timer.cancel();
        telegraphArrows.remove(newArrow);
        arrows.add(newArrow.copyWith(state: ArrowState.idle));
        refresh();
      }
    });

    return true;
  }
}