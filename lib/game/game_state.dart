import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/board_themes.dart';
import '../data/models/arrow.dart';
import '../data/models/level.dart';
import '../core/constants.dart';
import '../core/app_themes.dart';
import '../core/game_mode.dart';
import '../data/models/minesweeper_cell.dart';
import 'helpers/leaving_arrow_solver.dart';

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
  final double rushSpeedMultiplier;
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
    this.rushSpeedMultiplier = 1.0,
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
  bool _isSearchingForLeavingArrow = false;

  void refresh() => notifyListeners();

  Map<String, OrphanDotType> get orphanDots => _orphanDots;



  final List<ArrowModel> telegraphArrows = [];
  /// IDs of telegraphs that were cancelled mid-blink. The blink timer in
  /// `spawnEndlessArrowWithTelegraph` checks this before landing an arrow.
  final Set<String> _cancelledTelegraphIds = {};


  /// True if [arrowId] is the currently active leaving arrow.
  /// Component-side renderers should call this instead of reading
  /// `arrowModel.isLeavingArrow` — the model may be a stale snapshot.
  bool isArrowLeaving(String arrowId) => _activeLeavingArrowId == arrowId;

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
    final wasActiveLeaving = arrowId == _activeLeavingArrowId;

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
      telegraphArrows.clear();
      onLevelComplete();
    } else {
      if (checkDeadlock()) {
        _isDeadlocked = true;
        onDeadlock?.call();
      }
    }

    if (wasActiveLeaving) {
      onLeavingArrowResolved(arrowId);
    }

    // ── THE FIX: Trigger the search ONLY after an arrow clears ──
    if (!_isComplete && !_isGameOver && _leavingArrowsRemaining > 0 && _activeLeavingArrowId == null) {
      _startAsyncLeavingArrowSearch();
    }

    notifyListeners();
  }

  int failedSpawnCount = 0;

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

  TapResult tapArrow(String arrowId, {bool isForced = false}) {
    if (_isComplete || _isGameOver) return TapResult.ignored;

    final index = _arrows.indexWhere((a) => a.id == arrowId);
    if (index == -1) return TapResult.ignored;

    final arrow = _arrows[index];
    if (arrow.state != ArrowState.idle) {
      return TapResult.ignored;
    }

    // Decrement on EVERY user tap (correct or wrong).
    // Forced launches skip this so the counter doesn't go negative.
    if (!isForced) {
      decrementLeavingArrowCounter();
    }

    final exitInfo = _computeExitInfo(arrow);

    // ── THE FIX: Remove the bypass. If it's blocked, it's blocked. ──
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

    if (exitInfo.rocksToDestroy.isNotEmpty) {
      final toRemove = exitInfo.rocksToDestroy.toSet();
      _rocks.removeWhere((r) => toRemove.contains(r.id));
    }

    notifyListeners();

    return TapResult.exited;
  }

  /// No longer used — slash arrows destroy mines inside [tapArrow].
  @Deprecated('Slash arrows handle mine clearing in tapArrow.')
  void removeRockOnImpact(String arrowId) {
    // Intentionally empty.
  }

  TapResult _handleBlocked(int index, ArrowModel arrow, String arrowId) {
    _arrows[index] = arrow.copyWith(state: ArrowState.blocked);

    final isHeartFree = gameMode == GameMode.zen ||
        gameMode == GameMode.timeAttack ||
        heartRemover;

    final isTimeBlitz = gameMode == GameMode.timeBlitz;

    // Classic / Endless Rush: deduct a life
    if (!isHeartFree && !isTimeBlitz) {
      _lives--;
      _livesLost++;
      onLifeLost();
    }

    // Time Blitz: fire onLifeLost for the time penalty (screen handles the
    // actual -Ns). Hearts aren't tracked.
    if (isTimeBlitz) {
      onLifeLost();
    }

    Future.delayed(AppConstants.arrowShakeDuration, () {
      final idx = _arrows.indexWhere((a) => a.id == arrowId);
      if (idx != -1) {
        _arrows[idx] = _arrows[idx].copyWith(state: ArrowState.idle);
        notifyListeners();
      }
    });

    // Classic game-over on life depletion
    if (!isHeartFree && !isTimeBlitz && _lives <= 0) {
      _isGameOver = true;
      onGameOver();
      notifyListeners();
      return TapResult.blocked;
    }

    notifyListeners();
    return TapResult.blocked;
  }

  _ExitInfo _computeExitInfo(ArrowModel arrow) =>
      _computeExitInfoFor(arrow, _arrows, _rocks, _orphanDots);

  _ExitInfo _computeExitInfoFor(
      ArrowModel arrow,
      List<ArrowModel> arrows,
      List<RockModel> rocks,
      Map<String, OrphanDotType> orphanDots,
      ) {
    ArrowDirection currentDir = arrow.direction;
    final head = arrow.path[0];
    final gridSize = _currentLevel.gridSize;
    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final consumed = <String>[];
    final rocksToDestroy = <String>[];
    final visited = <String>{};

    final isSlash = arrow.type == ArrowType.slash;

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final key = '$nr,$nc';
      if (visited.contains(key)) return const _ExitInfo(true);
      visited.add(key);

      RockModel? hitRock;
      for (final rock in rocks) {
        if (rock.row == nr && rock.col == nc) {
          hitRock = rock;
          break;
        }
      }

      if (hitRock != null) {
        // Slash arrows pass through mines; normal arrows are blocked.
        if (isSlash) {
          rocksToDestroy.add(hitRock.id);
        } else {
          return const _ExitInfo(true);
        }
      } else {
        if (orphanDots.containsKey(key)) {
          consumed.add(key);
          switch (orphanDots[key]!) {
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
          for (final other in arrows) {
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
      }

      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }
    return _ExitInfo(false, consumed, rocksToDestroy);
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

    // Restored arrows always come back as plain normal arrows — never as
    // leaving arrows. A leaving arrow that already escaped shouldn't be
    // able to re-enter the leaving sequence, and its orange glow would be
    // misleading since it's no longer counted against the tap limit.
    _arrows.add(arrow.copyWith(
      state: ArrowState.idle,
      isLeavingArrow: false,
    ));

    // If the restored arrow was the active leaving arrow's ID (edge case:
    // the player undid within one frame of promotion), make sure the
    // counter doesn't keep pointing at a now-normal arrow.
    if (_activeLeavingArrowId == arrow.id) {
      _pendingForceLaunch.remove(arrow.id);
      _activeLeavingArrowId = null;
    }

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

  // ── Leaving Arrows (Classic + Time Blitz only) ──

  /// The dynamic per-arrow limit. Computed at promotion time from the
  /// number of arrows that must clear before the target becomes solvable,
  /// plus a difficulty-based buffer.
  int _leavingArrowTapLimit = 10;
  int _leavingArrowTapCount = 10;
  String? _activeLeavingArrowId;
  int _leavingArrowsRemaining = 0;
  final Set<String> _pendingForceLaunch = {};

  int get leavingArrowTapCount => _leavingArrowTapCount;
  int get leavingArrowTapLimit => _leavingArrowTapLimit;
  String? get activeLeavingArrowId => _activeLeavingArrowId;
  Set<String> get pendingForceLaunch => _pendingForceLaunch;
  bool get hasActiveLeavingArrow => _activeLeavingArrowId != null;


  void seedLeavingArrows({required int count}) {
    _leavingArrowsRemaining = count;
    _leavingArrowTapCount = 10;
    _leavingArrowTapLimit = 10;
    _activeLeavingArrowId = null;
    _pendingForceLaunch.clear();
    _isSearchingForLeavingArrow = false;
  }

  Future<void> _startAsyncLeavingArrowSearch() async {
    if (_leavingArrowsRemaining <= 0) return;
    if (_isComplete || _isGameOver || _activeLeavingArrowId != null) return;
    if (_isSearchingForLeavingArrow) return;

    _isSearchingForLeavingArrow = true;

    final args = {
      'arrows': _arrows.map((a) => a.toJson()).toList(),
      'rocks': _rocks.map((r) => r.toJson()).toList(),
      'orphanDots': _orphanDots.entries.map((e) {
        final parts = e.key.split(',');
        return OrphanDot(row: int.parse(parts[0]), col: int.parse(parts[1]), type: e.value).toJson();
      }).toList(),
      'gridSize': _currentLevel.gridSize,
    };

    try {
      final result = await compute(LeavingArrowSolver.findBestLeavingArrow, args);

      if (_isComplete || _isGameOver || _activeLeavingArrowId != null) {
        _isSearchingForLeavingArrow = false;
        return;
      }

      if (result != null) {
        final id = result['id'] as String;
        final required = result['required'] as int;

        final idx = _arrows.indexWhere((a) => a.id == id);

        if (idx == -1 || _arrows[idx].state != ArrowState.idle) {
          debugPrint('🏹 Arrow $id is gone or sliding. Retrying search...');
          _isSearchingForLeavingArrow = false;
          _startAsyncLeavingArrowSearch();
          return;
        }

        // ── THE MARGIN LOGIC ──
        final lvl = _currentLevel.levelNumber;
        int margin;

        if (lvl <= 50) {
          margin = 3; // Early levels: 3 extra tries
        } else if (lvl <= 150) {
          margin = 2; // Mid levels: 2 extra tries
        } else {
          // High levels (151+): 50% chance for 1, 50% chance for 2
          margin = Random().nextBool() ? 1 : 2;
        }

        _arrows[idx] = _arrows[idx].copyWith(isLeavingArrow: true);
        _activeLeavingArrowId = id;

        // ── THE PERFECT MATH ──
        // required = absolute minimum moves to clear blockers
        // + 1 = tap the target
        // + margin = extra tries based on player level
        final limit = (required + 1 + margin).clamp(4, 15);

        _leavingArrowTapLimit = limit;
        _leavingArrowTapCount = limit;
        _leavingArrowsRemaining--;

        debugPrint('🏹 Leaving arrow promoted: id=$id required=$required margin=$margin limit=$limit');
        notifyListeners();
      } else {
        debugPrint('🏹 No fair leaving arrow found async. Skipping.');
        _leavingArrowsRemaining = 0;
        _activeLeavingArrowId = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('🏹 Leaving arrow async search failed: $e');
    } finally {
      _isSearchingForLeavingArrow = false;
    }
  }

  void onLeavingArrowResolved(String arrowId) {
    if (_activeLeavingArrowId != arrowId) return;
    _pendingForceLaunch.remove(arrowId);
    _activeLeavingArrowId = null;

    // Spin up the search for the NEXT leaving arrow in the background
    _startAsyncLeavingArrowSearch();
  }


  /// Decrement the leaving-arrow counter on every user tap.
  void decrementLeavingArrowCounter() {
    final activeId = _activeLeavingArrowId;
    if (activeId == null) return;

    final stillAlive = _arrows
        .any((a) => a.id == activeId && a.state == ArrowState.idle);
    if (!stillAlive) return;

    _leavingArrowTapCount--;
    if (_leavingArrowTapCount <= 0) {
      _pendingForceLaunch.add(activeId);
      _leavingArrowTapCount = _leavingArrowTapLimit; // Reset to prevent negative
    }
    notifyListeners();
  }

  /// Called by ArrowComponent after a forced launch has been initiated.
  void acknowledgeForceLaunch(String arrowId) {
    _pendingForceLaunch.remove(arrowId);
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
  /// Mines this arrow will destroy on its way out. Non-empty only for
  /// slash arrows.
  final List<String> rocksToDestroy;

  const _ExitInfo(
      this.blocked, [
        this.consumed = const [],
        this.rocksToDestroy = const [],
      ]);
}