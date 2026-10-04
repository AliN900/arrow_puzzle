import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../data/models/level.dart';
import 'components/grid_component.dart';
import 'game_state.dart';

/// Render-only Flame game.
///
/// Invariant: this game is mounted inside a **square `SizedBox`** whose side
/// equals `level.gridSize * cellPx` (see `GameScreen._kCellPx`). Therefore:
///
///   * `game.size.x == game.size.y == level.gridSize * cellPx`
///   * One world unit == one logical pixel of the board.
///   * The grid fills the canvas exactly — no internal scaling, no centring.
///
/// Zooming / panning / fitting to the device viewport is handled entirely by
/// the widget layer (`InteractiveViewer` in `GameScreen`). Do **not** add a
/// `CameraComponent.withFixedResolution`, `FixedResolutionViewport`, or
/// `canvasScaleForType` here — those would fight the outer transform.
class ArrowPuzzleGame extends FlameGame {
  final LevelModel level;
  final GameState gameState;
  GridComponent? gridComponent;

  final void Function() onLevelComplete;
  final void Function() onGameOver;
  final void Function() onLifeLost;

  ArrowPuzzleGame({
    required this.level,
    required this.gameState,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onLifeLost,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  /// Board is square; guard against non-square sizes just in case.
  double get _boardPixels => size.x < size.y ? size.x : size.y;

  /// Build the grid on first layout, or reposition / resize it afterwards.
  void _syncGridLayout() {
    // Flame sometimes calls onGameResize with size (0,0) before the first
    // real layout pass. Bail out until we have a usable size.
    if (size.x <= 0 || size.y <= 0) return;

    final boardPixels = _boardPixels;

    if (gridComponent == null) {
      gridComponent = GridComponent(
        gameState: gameState,
        gridPixelSize: boardPixels,
        position: Vector2(boardPixels / 2, boardPixels / 2),
      )..anchor = Anchor.center;
      add(gridComponent!);
    } else {
      gridComponent!
        ..position = Vector2(boardPixels / 2, boardPixels / 2)
        ..resize(boardPixels);
    }
  }

  @override
  Future<void> onLoad() async {
    _syncGridLayout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _syncGridLayout();
  }

  /// Called by `GameScreen._handleRestart()`.
  void resetLevel() {
    gameState.resetLevel();
    gridComponent?.rebuild();
  }
}