import 'dart:async';
import 'package:flutter/material.dart';
import '../core/board_themes.dart';
import '../data/models/arrow.dart';
import '../data/models/level.dart';
import '../core/constants.dart';
import '../core/app_themes.dart';
import '../core/game_mode.dart';
import '../data/models/minesweeper_cell.dart';

class GameState extends ChangeNotifier {
  static const int kAbsoluteMaxGridSize = 15;
  late LevelModel _currentLevel;
  late List<ArrowModel> _arrows;
  late List<RockModel> _rocks;
  int _lives = AppConstants.maxLives;
  int _livesLost = 0;
  bool _isComplete = false;
  bool _isGameOver = false;
  bool _isDeadlocked = false;
  final GameTheme theme;
  final GameMode gameMode;
  final bool heartRemover;
  final bool assistMode;
  final int arrowSpeed;
  final BoardTheme boardTheme;
  final int maxLives; // Dynamic max lives for this level session
  final List<ArrowModel> _escapedHistory = [];
  String? _hintArrowId;
  bool _isBombArmed = false;


  late Map<String, OrphanDotType> _orphanDots;

  final Map<String, List<OrphanDot>> _consumedDotsByArrow = {};

  final void Function() onLevelComplete;
  final void Function() onGameOver;
  final void Function() onLifeLost;
  final void Function()? onDeadlock;
  final void Function()? onCombo;
  final void Function(Offset globalPos, Color color)? onParticleBurst;
  final void Function()? onCameraShake;

  DateTime? _lastExitTime;
  int _comboCount = 0;

  int get comboCount => _comboCount;

  GameState({
    required LevelModel level,
    required int initialLives, // Accept dynamic initial lives from GameScreen
    required this.theme,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onLifeLost,
    this.onDeadlock,
    this.gameMode = GameMode.classic,
    this.heartRemover = false,
    this.assistMode = false,
    this.onCombo,
    this.onParticleBurst,
    this.onCameraShake,
    this.arrowSpeed = 1,
    this.boardTheme = BoardTheme.minimal,
  })  : maxLives = initialLives,
        _lives = (gameMode == GameMode.zen ||
            gameMode == GameMode.timeAttack ||
            heartRemover)
            ? 999
            : initialLives {
    _currentLevel = level;
    _arrows = level.arrows.map((a) => a.copyWith()).toList();
    _rocks = level.rocks.map((r) => r.copyWith()).toList();
    _orphanDots = {for (final od in level.orphanDots) od.key: od.type};
  }

  List<ArrowModel> get arrows => _arrows;
  List<RockModel> get rocks => _rocks;
  int get lives => _lives;
  int get livesLost => _livesLost;
  bool get isComplete => _isComplete;
  bool get isGameOver => _isGameOver;
  bool get isDeadlocked => _isDeadlocked;
  LevelModel get level => _currentLevel;
  List<ArrowModel> get escapedHistory => List.unmodifiable(_escapedHistory);
  String? get hintArrowId => _hintArrowId;
  bool get isBombArmed => _isBombArmed;

  Map<String, OrphanDotType> get orphanDots => _orphanDots;

  final List<ArrowModel> telegraphArrows = [];
  /// IDs of telegraphs that were cancelled mid-blink. The blink timer in
  /// `spawnEndlessArrowWithTelegraph` checks this before landing an arrow.
  final Set<String> _cancelledTelegraphIds = {};

  /// Cancel every in-flight telegraph. The pending blink timers will see the
  /// cancellation flag and quietly abort instead of promoting to real arrows.
  void cancelAllTelegraphs() {
    if (telegraphArrows.isEmpty) return;
    for (final t in telegraphArrows) {
      _cancelledTelegraphIds.add(t.id);
    }
    telegraphArrows.clear();
    notifyListeners();
  }

  bool isTelegraphCancelled(String id) =>
      _cancelledTelegraphIds.contains(id);

  void clearTelegraphCancellation(String id) =>
      _cancelledTelegraphIds.remove(id);

  void handleArrowExitCompleted(String arrowId) {
    final idx = _arrows.indexWhere((a) => a.id == arrowId);
    if (idx != -1) {
      _escapedHistory.add(_arrows[idx]);
    }
    _arrows.removeWhere((a) => a.id == arrowId);
    _consumedDotsByArrow.remove(arrowId);

    if (gameMode == GameMode.endlessRush) {
      notifyArrowCleared();
    }

    if (_arrows.isEmpty && telegraphArrows.isEmpty) {
      _isComplete = true;
      telegraphArrows.clear();  // kill any in-flight blinks
      onLevelComplete();
    } else {
      if (checkDeadlock()) {
        _isDeadlocked = true;
        onDeadlock?.call();
      }
    }
    notifyListeners();
  }

  int _failedSpawnCount = 0;
  int get failedSpawnCount => _failedSpawnCount;
  set failedSpawnCount(int val) => _failedSpawnCount = val;

  void setLevel(LevelModel updatedLevel) {
    _currentLevel = updatedLevel;
    notifyListeners();
  }

  bool checkDeadlock() {
    if (_arrows.isEmpty) return false;

    for (final arrow in _arrows) {
      final exit = _computeExitInfo(arrow);
      if (!exit.blocked) {
        return false;
      }
    }
    return true;
  }

  // Inside GameState class:
  int _clearedRushArrows = 0;
  int get clearedRushArrows => _clearedRushArrows;

  void notifyArrowCleared() {
    _clearedRushArrows++;
    notifyListeners();
  }

  /// Grows the grid by one cell in both directions.
  /// [maxGridSize] caps growth (caller supplies the level-specific limit).
  bool growGrid({int? maxGridSize}) {
    final limit = maxGridSize ?? kAbsoluteMaxGridSize;
    if (_currentLevel.gridSize >= limit) return false;
    final newSize = _currentLevel.gridSize + 1;

    final newMask = <String>{..._currentLevel.mask};
    for (int i = 0; i < newSize; i++) {
      newMask.add('${newSize - 1},$i');
      newMask.add('$i,${newSize - 1}');
    }

    _currentLevel = LevelModel(
      levelNumber: _currentLevel.levelNumber,
      gridSize: newSize,
      arrows: _currentLevel.arrows,
      rocks: _currentLevel.rocks,
      maskShape: _currentLevel.maskShape,
      mask: newMask,
      orphanDots: _currentLevel.orphanDots,
    );

    notifyListeners();
    return true;
  }

  bool isArrowBlocked(String arrowId) {
    final index = _arrows.indexWhere((a) => a.id == arrowId);
    if (index == -1) return true;
    final arrow = _arrows[index];
    return _computeExitInfo(arrow).blocked;
  }

  List<OrphanDot> getConsumedDotsForArrow(String arrowId) {
    return _consumedDotsByArrow[arrowId] ?? [];
  }

  void _recordConsumedDots(String arrowId, List<String> consumedKeys) {
    final dots = <OrphanDot>[];
    for (final key in consumedKeys) {
      final match = _currentLevel.orphanDots.firstWhere(
            (od) => od.key == key,
        orElse: () {
          final parts = key.split(',');
          return OrphanDot(
            row: int.parse(parts[0]),
            col: int.parse(parts[1]),
            type: OrphanDotType.neutral,
          );
        },
      );
      dots.add(match);
    }
    _consumedDotsByArrow[arrowId] = dots;
  }

  TapResult tapArrow(String arrowId) {
    if (_isComplete || _isGameOver) return TapResult.ignored;

    final index = _arrows.indexWhere((a) => a.id == arrowId);
    if (index == -1) return TapResult.ignored;

    final arrow = _arrows[index];
    if (arrow.state != ArrowState.idle) {
      return TapResult.ignored;
    }

    final exitInfo = _computeExitInfo(arrow);
    if (exitInfo.blocked) {
      _comboCount = 0;
      onCameraShake?.call();
      return _handleBlocked(index, arrow, arrowId);
    }

    final now = DateTime.now();
    if (_lastExitTime != null &&
        now.difference(_lastExitTime!).inMilliseconds < 1500) {
      _comboCount++;
      if (_comboCount >= 2) {
        onCombo?.call();
      }
    } else {
      _comboCount = 1;
    }
    _lastExitTime = now;

    _arrows[index] = arrow.copyWith(state: ArrowState.sliding);
    _recordConsumedDots(arrowId, exitInfo.consumed);

    for (final k in exitInfo.consumed) {
      _orphanDots.remove(k);
    }
    notifyListeners();

    return TapResult.exited;
  }

  void removeRockOnImpact(String arrowId) {
    final idx = _arrows.indexWhere((a) => a.id == arrowId);
    if (idx == -1) return;
    final arrow = _arrows[idx];
    if (arrow.targetRockId == null) return;
    _rocks.removeWhere((r) => r.id == arrow.targetRockId);
    notifyListeners();
  }

  TapResult _handleBlocked(int index, ArrowModel arrow, String arrowId) {
    _arrows[index] = arrow.copyWith(state: ArrowState.blocked);
    if (gameMode != GameMode.zen &&
        gameMode != GameMode.timeAttack &&
        !heartRemover) {
      _lives--;
      _livesLost++;
      onLifeLost();
    }

    Future.delayed(AppConstants.arrowShakeDuration, () {
      final idx = _arrows.indexWhere((a) => a.id == arrowId);
      if (idx != -1) {
        _arrows[idx] = _arrows[idx].copyWith(state: ArrowState.idle);
        notifyListeners();
      }
    });

    if (gameMode != GameMode.zen &&
        gameMode != GameMode.timeAttack &&
        !heartRemover &&
        _lives <= 0) {
      _isGameOver = true;
      onGameOver();
      notifyListeners();
      return TapResult.blocked;
    }

    notifyListeners();
    return TapResult.blocked;
  }

  _ExitInfo _computeExitInfo(ArrowModel arrow) {
    ArrowDirection currentDir = arrow.direction;
    final head = arrow.path[0];
    final gridSize = _currentLevel.gridSize;
    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final consumed = <String>[];
    final visited = <String>{};

    final isBomb =
        arrow.type == ArrowType.bomb && arrow.targetRockId != null;

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final key = '$nr,$nc';
      if (visited.contains(key)) return const _ExitInfo(true);
      visited.add(key);

      RockModel? hitRock;
      for (final rock in _rocks) {
        if (rock.row == nr && rock.col == nc) {
          hitRock = rock;
          break;
        }
      }
      if (hitRock != null) {
        if (isBomb && hitRock.id == arrow.targetRockId) {
          return _ExitInfo(false, consumed, hitRock.id);
        }
        return const _ExitInfo(true);
      }

      if (_orphanDots.containsKey(key)) {
        consumed.add(key);
        final dotType = _orphanDots[key]!;
        switch (dotType) {
          case OrphanDotType.up:
            currentDir = ArrowDirection.up;
            break;
          case OrphanDotType.down:
            currentDir = ArrowDirection.down;
            break;
          case OrphanDotType.left:
            currentDir = ArrowDirection.left;
            break;
          case OrphanDotType.right:
            currentDir = ArrowDirection.right;
            break;
          case OrphanDotType.neutral:
            break;
        }
      } else {
        bool hit = false;
        for (final other in _arrows) {
          if (other.id == arrow.id) continue;
          if (other.state == ArrowState.sliding) continue;
          for (final pt in other.path) {
            if (pt[0] == nr && pt[1] == nc) {
              hit = true;
              break;
            }
          }
          if (hit) break;
        }
        if (hit) return const _ExitInfo(true);
      }

      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }
    return _ExitInfo(false, consumed);
  }

  Map<String, MinesweeperCell> minesweeperCells = {};

  void triggerMineExplosion(int row, int col) {
    if (gameMode != GameMode.zen && !heartRemover) {
      _lives--;
      _livesLost++;
      onLifeLost();
      onCameraShake?.call();
      if (_lives <= 0) {
        _isGameOver = true;
        onGameOver();
      }
      notifyListeners();
    }
  }

  void setBombArmed(bool armed) {
    _isBombArmed = armed;
    notifyListeners();
  }

  void setHintArrow(String? id) {
    _hintArrowId = id;
    notifyListeners();
  }

  bool undoLastExit() {
    if (_escapedHistory.isEmpty) return false;
    final arrow = _escapedHistory.removeLast();
    _arrows.add(arrow.copyWith(state: ArrowState.idle));
    notifyListeners();
    return true;
  }

  bool destroyRock(String rockId) {
    final before = _rocks.length;
    _rocks.removeWhere((r) => r.id == rockId);
    if (_rocks.length == before) return false;
    notifyListeners();
    return true;
  }

  String? findNextSolvableArrowId() {
    for (final arrow in _arrows) {
      if (arrow.state != ArrowState.idle) continue;
      final exit = _computeExitInfo(arrow);
      if (!exit.blocked) return arrow.id;
    }
    return null;
  }

  void resetLevel() {
    _escapedHistory.clear();
    _hintArrowId = null;
    _isBombArmed = false;
    _arrows = _currentLevel.arrows
        .map((a) => a.copyWith(state: ArrowState.idle))
        .toList();
    _rocks = _currentLevel.rocks.map((r) => r.copyWith()).toList();
    _orphanDots = {
      for (final od in _currentLevel.orphanDots) od.key: od.type
    };
    _consumedDotsByArrow.clear();
    _lives = (gameMode == GameMode.zen ||
        gameMode == GameMode.timeAttack ||
        heartRemover)
        ? 999
        : maxLives;
    _livesLost = 0;
    _isComplete = false;
    _isGameOver = false;
    _isDeadlocked = false;
    notifyListeners();
  }

  void restoreLife() {
    if (_lives < maxLives) {
      _lives++;
      if (_isGameOver && _lives > 0) {
        _isGameOver = false;
      }
      notifyListeners();
    }
  }

  void forceGameOver() {
    _isGameOver = true;
    onGameOver();
    notifyListeners();
  }

  void resumeFromTimeout() {
    _isGameOver = false;
    notifyListeners();
  }
}

enum TapResult { exited, blocked, ignored }

class _ExitInfo {
  final bool blocked;
  final List<String> consumed;
  final String? rockToDestroy;
  const _ExitInfo(this.blocked, [this.consumed = const [], this.rockToDestroy]);
}