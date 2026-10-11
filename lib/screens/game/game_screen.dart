import 'dart:async';
import 'dart:math';
import 'package:arrow_puzzle/screens/game/widgets/game_dialog_button.dart';
import 'package:arrow_puzzle/screens/game/widgets/leaving_arrow_counter.dart';
import 'package:arrow_puzzle/screens/game/widgets/telegraph_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ad_rewards.dart';
import '../../core/app_colors.dart';
import '../../core/board_themes.dart';
import '../../core/coin_rewards.dart';
import '../../core/constants.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/game_mode.dart';
import '../../core/items.dart';
import '../../core/rush_difficulty.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';
import '../../data/models/level_result.dart';
import '../../data/repositories/progress_repository.dart';
import '../../game/arrow_puzzle_game.dart';
import '../../game/game_state.dart';
import '../../game/game_state_modes_extension.dart';
import '../../game/helpers/endless_spawner.dart';
import '../../game_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/game_item_bar.dart';
import '../../widgets/pop_dialog.dart';
import '../../widgets/unlock_celebration_screen.dart';
import 'widgets/game_top_bar.dart';
import 'widgets/game_bottom_bar.dart';
import 'widgets/timer_display.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/level_complete_dialog.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/level_loading_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int level;
  final bool isRandom;
  final GameMode gameMode;
  final RushDifficulty rushDifficulty;


  const GameScreen({
    super.key,
    required this.level,
    this.isRandom = false,
    this.gameMode = GameMode.classic,
    this.rushDifficulty = RushDifficulty.easy,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late LevelModel _level;
  late ArrowPuzzleGame _game;
  GameState? _gameState;
  bool _showingGameOver = false;
  bool _showingComplete = false;
  int _lives = AppConstants.maxLives;
  int? _loadedLevelNum;
  bool _isLoadingLevel = false;
  bool _isPaused = false;

  Timer? _levelTimer;
  int _timeRemaining = 0;
  int _totalTime = 0;
  bool _isTimeoutState = false;
  bool _isAppBackgrounded = false;

  int _timeAttackScore = 0;

// ── Time Blitz state ──
  int _timeBlitzScore = 0;
  bool _timeBlitzStarted = false;
  int _lastTimeBlitzArrowCount = -1;

// ── Timer pulse animation state (up to 3 visible simultaneously) ──
  final List<_TimerPulse> _timerPulses = [];
  int _nextPulseId = 0;
  int _nextPulseSlot = 0;

  // ── Blitz mode state ──
  int _blitzStage = 0;              // 0-indexed
  int _blitzScore = 0;
  int _blitzStageCount = 5;
  int _blitzRunStartHearts = 3;     // captured at stage 0
  bool _blitzShowingSplash = false;
  int _blitzSplashStage = 1;
  late int _blitzRunSeed;
  bool _showBonusAnimation = false;
  String _bonusText = '';
  bool _usedAdRewardThisLevel = false;
  final Map<ItemType, int> _itemUsesThisLevel = {};
  int _pendingMilestoneItems = 0;
  int _rocksBeforeBomb = 0;

  // ---------------------------------------------------------------------------
  // Board sizing / zoom
  // ---------------------------------------------------------------------------
  /// Preferred cell size at scale 1.0. Grows the board's intrinsic size
  /// proportionally with `gridSize`, so large levels don't cram tiny cells.
  static const double _kCellPx = 64.0;
  static const double _kBoardPadding = 24.0;
  Object? _lastFitKey;

  Matrix4? _fromFitMatrix;
  Matrix4? _toFitMatrix;
  late final AnimationController _fitAnimController;

  final TransformationController _transformationController =
  TransformationController();

  /// Cell size for the current board. Endless Rush boards start huge
  /// (16×16+), so we compress cells slightly as the grid grows to keep the
  /// canvas from ballooning past the viewport.
  double get _cellPx {
    if (widget.gameMode == GameMode.endlessRush) {
      final g = _gameState?.level.gridSize ?? _level.gridSize;
      return (64 - (g - 16) * 2).clamp(48, 64).toDouble();
    }
    return _kCellPx;
  }

  double get _contentSize =>
      (_gameState?.level.gridSize ?? _level.gridSize) * _cellPx;
  // -------------------------------------------------------------------------
// Endless Rush level scaling
// -------------------------------------------------------------------------

  static int _startingGridForLevel(int level, RushDifficulty d) =>
      ((6 + level ~/ 60).clamp(6, 12) + d.gridBonus).clamp(6, 15);

  static int _maxGridForLevel(int level, RushDifficulty d) =>
      (_startingGridForLevel(level, d) + 3).clamp(5, 17);

  static int _initialArrowCountForLevel(int level, int startGrid, RushDifficulty d) {
    final fill = (0.35 + level / 600).clamp(0.35, 0.50);
    final count = (startGrid * startGrid * fill / 2.5 * d.arrowMult).round();
    return count.clamp(3, 120);
  }

  static int _minSpawnDelayForLevel(int level, RushDifficulty d) =>
      ((700 - level * 0.5) * d.delayMult).round().clamp(200, 900);

  static int _maxSpawnDelayForLevel(int level, RushDifficulty d) =>
      ((3500 - level * 2.5) * d.delayMult).round().clamp(1200, 4000);

  static double _lossFillForLevel(int level, RushDifficulty d) =>
      ((0.85 - level / 12000) + d.lossOffset).clamp(0.70, 0.88);

  static double _rushSpeedMultiplierForLevel(int level, RushDifficulty d) =>
      (1.0 + (level / 1200).clamp(0.0, 0.25)) * d.speedMult;

  static int _lastStandCountForLevel(int level) =>
      1 + (level ~/ 200).clamp(0, 1);

  // ── Blitz scaling ─────────────────────────────────────────────────────
// Stage count grows with the player's campaign level: 5 stages baseline,
// +5 stages for every 100 levels reached. Capped at 40.
  static int _blitzStageCountForLevel(int playerLevel) =>
      ((playerLevel ~/ 100 + 1) * 5).clamp(5, 40);

  /// Campaign level played on a given stage. Climbs linearly from 1 up to
  /// the player's current level across the whole run.
  static int _blitzLevelForStage({
    required int stageIndex,
    required int stageCount,
    required int playerLevel,
  }) {
    if (stageIndex <= 0) return 1;
    final denom = stageCount > 1 ? stageCount - 1 : 1;
    return (1 + (playerLevel - 1) * stageIndex / denom).round();
  }

  /// Time limit for a stage. Ramps from 35s down to 18s across the run —
  /// gentler than a linear 30→9, and the floor is 18s so late stages are
  /// still tense but fair.
  static int _blitzTimerForStage({
    required int stageIndex,
    required int stageCount,
  }) {
    if (stageCount <= 1) return 35;
    final t = stageIndex / (stageCount - 1);
    final seconds = 35 - (t * 17); // 35 .. 18
    return seconds.round().clamp(18, 35);
  }

  /// Classic: leaving arrows start at level 20.
  ///   20-49 → 1
  ///   50-79 → 2
  ///   80-109 → 3
  ///   110-139 → 4
  ///   140+ → 5 (cap)
  int _leavingArrowsForLevel(int levelNum) {
    if (levelNum < 20) return 0;
    return ((levelNum - 20) ~/ 30 + 1).clamp(1, 5);
  }

  /// Time Blitz: scales faster since it's the survival mode.
  ///   Stage 0-4  → 0
  ///   Stage 5-9  → 1
  ///   Stage 10-14 → 2
  ///   Stage 15-19 → 3
  ///   Stage 20-24 → 4
  ///   Stage 25+   → 5 (cap)
  int _leavingArrowsForStage(int stage) {
    if (stage < 5) return 0;
    return (stage ~/ 5).clamp(1, 5);
  }


  /// Applies a scale + translation matrix that centres [contentSize] inside a
  /// viewport of [viewportSize] at the given [fitScale].
  void _applyFitTransform({
    required Size viewportSize,
    required double contentSize,
    required double fitScale,
  }) {
    final tx = (viewportSize.width - contentSize * fitScale) / 2;
    final ty = (viewportSize.height - contentSize * fitScale) / 2;

    final target = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(fitScale, fitScale, fitScale, 1.0);

    // First application (boot): snap directly, don't animate from identity.
    if (_toFitMatrix == null) {
      _toFitMatrix = target;
      _transformationController.value = target;
      return;
    }

    // Subsequent applications (grid growth, rotation): animate from
    // whatever the current rendered transform is.
    _fitAnimController.stop();
    _fromFitMatrix = _transformationController.value;
    _toFitMatrix = target;
    _fitAnimController.forward(from: 0);
  }

  void _onFitAnimTick() {
    final from = _fromFitMatrix;
    final to = _toFitMatrix;
    if (from == null || to == null) return;

    final t = Curves.easeOutCubic.transform(_fitAnimController.value);
    _transformationController.value =
        Matrix4Tween(begin: from, end: to).lerp(t);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.gameMode == GameMode.blitz ||
        widget.gameMode == GameMode.timeBlitz) {
      _blitzRunSeed = DateTime.now().microsecondsSinceEpoch;
    }
    _fitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(_onFitAnimTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final levelNum = widget.level;
    if (_loadedLevelNum != levelNum) {
      _loadedLevelNum = levelNum;
      _loadLevelAsync(levelNum);
    }
  }



  Future<void> _loadLevelAsync(int levelNum) async {
    // ── Blitz ──
    if (widget.gameMode == GameMode.blitz ||
        widget.gameMode == GameMode.timeBlitz) {
      final progress = ref.read(progressRepositoryProvider);
      final playerLevel = progress.currentLevel;

      final stageCount = _blitzStageCountForLevel(playerLevel);
      // Blitz caps at final stage; Time Blitz is endless.
      final stageIndex = widget.gameMode == GameMode.blitz
          ? _blitzStage.clamp(0, stageCount - 1)
          : _blitzStage;
      final targetLevel = _blitzLevelForStage(
        stageIndex: stageIndex,
        stageCount: stageCount,
        playerLevel: playerLevel,
      );

      _blitzStageCount = stageCount;

      final levelRepo = ref.read(levelRepositoryProvider);

      _level = await levelRepo.getBlitzLevelAsync(
        targetLevel,
        seed: _blitzRunSeed + _blitzStage * 997,
      );
      if (!mounted) return;

      _initGame();
      if (mounted) setState(() => _isLoadingLevel = false);
      return;
    }


    if (widget.gameMode == GameMode.endlessRush) {
      // Use the player's actual campaign level, not widget.level (which is
      // usually just 1 when the mode is launched from the menu).
      final progress = ref.read(progressRepositoryProvider);
      final effectiveLevel = _kDebugRushLevel > 0
          ? _kDebugRushLevel
          : progress.currentLevel;

      final startGrid = _startingGridForLevel(
        effectiveLevel,
        widget.rushDifficulty,
      );
      final maxGrid = _maxGridForLevel(
        effectiveLevel,
        widget.rushDifficulty,
      );
      final targetArrows = _initialArrowCountForLevel(
        effectiveLevel,
        startGrid,
        widget.rushDifficulty,
      );

      final initialMask = <String>{
        for (int r = 0; r < startGrid; r++)
          for (int c = 0; c < startGrid; c++) '$r,$c'
      };

      final generated = <ArrowModel>[];
      for (int i = 0; i < targetArrows; i++) {
        final arrow = EndlessSpawner.trySpawnArrow(
          gridSize: startGrid,
          existingArrows: generated,
          rocks: const [],
        );
        if (arrow == null) break;
        generated.add(arrow);
      }

      // Cache every per-level parameter that _tickEndlessRush / _endlessAttemptSpawn
      // will read. Recomputing these every tick is wasteful and would let a
      // mid-run `widget.level` change desync the pacing.
      _endlessMaxGrid = maxGrid;
      _endlessMinDelayMs =
          _minSpawnDelayForLevel(effectiveLevel, widget.rushDifficulty);
      _endlessMaxDelayMs =
          _maxSpawnDelayForLevel(effectiveLevel, widget.rushDifficulty);
      _endlessLossFill =
          _lossFillForLevel(effectiveLevel, widget.rushDifficulty);
      _endlessLastStandCount = _lastStandCountForLevel(effectiveLevel);
      _lastSeenArrowCount = -1;

      _level = LevelModel(
        levelNumber: 999,
        gridSize: startGrid,
        arrows: generated,
        rocks: [],
        maskShape: MaskShape.square,
        mask: initialMask,
        orphanDots: [],
      );
      _initGame();
      if (mounted) setState(() => _isLoadingLevel = false);
      return;
    }

    final levelRepo = ref.read(levelRepositoryProvider);
    final progress = ref.read(progressRepositoryProvider);

    final useCache = !widget.isRandom || !progress.complexPaths;
    if (useCache && levelRepo.isCached(levelNum)) {
      _level = levelRepo.getLevel(levelNum);
      _initGame();
      if (!widget.isRandom) {
        levelRepo.preGenerateRangeAsync(levelNum + 1, 5);
      }
      return;
    }

    if (mounted) setState(() => _isLoadingLevel = true);

    try {
      final level = widget.isRandom
          ? await levelRepo.getRandomLevelAsync(levelNum,
          complexPaths: progress.complexPaths)
          : await levelRepo.getLevelAsync(levelNum, preGenerateNext: true);
      if (!mounted) return;
      _level = level;
      _initGame();
      setState(() => _isLoadingLevel = false);
      if (!widget.isRandom) {
        levelRepo.preGenerateRangeAsync(levelNum + 1, 5);
      }
    } catch (_) {
      if (!mounted) return;
      _level = levelRepo.getLevel(levelNum);
      _initGame();
      if (mounted) setState(() => _isLoadingLevel = false);
    }
  }

  double _shakeOffset = 0.0;
  Timer? _shakeTimer;

  void _triggerShake() {
    _shakeTimer?.cancel();
    int count = 0;
    _shakeTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      count++;
      if (count > 6) {
        timer.cancel();
        if (mounted) setState(() => _shakeOffset = 0.0);
      } else {
        if (mounted) {
          setState(() => _shakeOffset = (count % 2 == 0 ? 8.0 : -8.0));
        }
      }
    });
  }

  void _triggerTimeAttackBonusAnimation() {
    setState(() {
      _bonusText = AppStrings.of(context).timeBonusAmount(15);
      _showBonusAnimation = true;
    });
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showBonusAnimation = false);
    });
  }


  Timer? _endlessSpawnTimer;
  int _endlessInitialArrowCount = 0;
  int _endlessMaxGrid = 8;
  int _endlessMinDelayMs = 700;
  int _endlessMaxDelayMs = 3500;
  double _endlessLossFill = 0.95;
  int _endlessLastStandCount = 1;
  int _lastSeenArrowCount = -1;

  /// Boots the endless-rush pressure loop. Call from _initGame.
  ///
  /// Gives the player a fixed 5-second survey window before pressure begins,
  /// then hands off to the recursive `_tickEndlessRush` scheduler.
  void _startEndlessRush() {
    _endlessSpawnTimer?.cancel();
    final gs = _gameState;
    if (gs == null) return;
    _endlessInitialArrowCount = gs.arrows.length;
    _endlessSpawnTimer = Timer(const Duration(seconds: 5), _tickEndlessRush);
  }

  /// Ad-reward continue for Endless Rush: drops board density to ~50 % so
  /// the next spawn attempt doesn't instantly re-trigger game-over.
  void _clearArrowsForAdContinue() {
    final gs = _gameState;
    if (gs == null) return;

    final gridSize = gs.level.gridSize;
    final targetOccupied = ((gridSize * gridSize) * 0.40).round();

    final occupied = <String>{};
    for (final a in gs.arrows) {
      for (final p in a.path) {
        occupied.add('${p[0]},${p[1]}');
      }
    }
    if (occupied.length <= targetOccupied) {
      gs.cancelAllTelegraphs();
      gs.refresh();
      return;
    }

    // Remove the biggest arrows first — frees the most cells per removal.
    final sorted = List<ArrowModel>.from(gs.arrows)
      ..sort((a, b) => b.path.length.compareTo(a.path.length));

    for (final a in sorted) {
      if (occupied.length <= targetOccupied) break;
      gs.arrows.removeWhere((x) => x.id == a.id);
      for (final p in a.path) {
        occupied.remove('${p[0]},${p[1]}');
      }
    }

    gs.cancelAllTelegraphs();
    gs.refresh();
  }

  /// Recursive scheduler. Every tick:
  ///   1. win if board is empty
  ///   2. gate spawns until 50% of the initial arrow count is cleared
  ///   3. otherwise schedule a spawn whose delay shrinks as clearing progresses
  ///      OR as elapsed time increases (slow background pressure).
  void _tickEndlessRush() {
    _endlessSpawnTimer?.cancel();

    if (!mounted || _gameState == null) return;

    if (_isPaused || _isAppBackgrounded || _showingGameOver || _showingComplete) {
      _endlessSpawnTimer =
          Timer(const Duration(milliseconds: 500), _tickEndlessRush);
      return;
    }



    final gs = _gameState!;
    final realArrows = gs.arrows.length;
    final telegraphs = gs.telegraphArrows.length;

    if (realArrows == 0 && telegraphs == 0) {
      unawaited(_onLevelComplete());
      return;
    }

    // Last stand (count scales with player level).
    if (realArrows <= _endlessLastStandCount) {
      if (telegraphs > 0) {
        gs.cancelAllTelegraphs();
        if (gs.arrows.isEmpty) {
          unawaited(_onLevelComplete());
          return;
        }
      }
      _endlessSpawnTimer =
          Timer(const Duration(milliseconds: 150), _tickEndlessRush);
      return;
    }

    // NEW: early loss check — if the board is at max grid and densely packed,
// end the run immediately instead of waiting for the next spawn attempt.
    final gridSize = gs.level.gridSize;
    if (gridSize >= _endlessMaxGrid) {
      final occupiedCells = <String>{};
      for (final a in gs.arrows) {
        for (final p in a.path) {
          occupiedCells.add('${p[0]},${p[1]}');
        }
      }
      final currentFill = occupiedCells.length / (gridSize * gridSize);
      if (currentFill > _endlessLossFill) {
        _onGameOver();
        return;
      }
    }

    final initial = _endlessInitialArrowCount;
    if (initial == 0) {
      _endlessSpawnTimer =
          Timer(const Duration(milliseconds: 300), _tickEndlessRush);
      return;
    }

    // NEW: cumulative arrows cleared this run — drives the pressure ramp.
    final clearedTotal = gs.clearedRushArrows;

    // Pacing: base delay scales with current board fill, then a pressure
    // term accelerates everything as the player clears more cumulative arrows.
    final remaining = realArrows + telegraphs;
    final remainingRatio = (remaining / initial).clamp(0.0, 1.0);

    // Pressure: 0 clears → 1.0 scale. Every `initial` arrows cleared adds
    // 0.20 to the denominator, capped so the floor is exactly 50 %.
    final pressure = (clearedTotal / initial).clamp(0.0, 5.0);
    final paceScale = 1.0 / (1.0 + 0.20 * pressure);

    final adjMin = (_endlessMinDelayMs * paceScale).round();
    final adjMax = (_endlessMaxDelayMs * paceScale).round();
    final delayMs = (adjMin + ((adjMax - adjMin) * remainingRatio)).round();

    _endlessSpawnTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted || _gameState == null) return;
      final nowReal = _gameState!.arrows.length;
      final nowTel = _gameState!.telegraphArrows.length;
      if (nowReal > _endlessLastStandCount) {
        _endlessAttemptSpawn();
      } else if (nowTel > 0) {
        _gameState!.cancelAllTelegraphs();
      }
      _tickEndlessRush();
    });
  }




  /// One spawn attempt. Grows the grid when the board is getting cramped,
  /// declares loss when the grid is maxed and still packed, otherwise spawns.
  void _endlessAttemptSpawn() {
    final gs = _gameState!;
    final gridSize = gs.level.gridSize;
    final maxGrid = _endlessMaxGrid;

    final occupied = <String>{};
    for (final a in gs.arrows) {
      for (final p in a.path) {
        occupied.add('${p[0]},${p[1]}');
      }
    }
    for (final r in gs.rocks) {
      occupied.add('${r.row},${r.col}');
    }

    final fillRatio = occupied.length / (gridSize * gridSize);

    if (gridSize >= maxGrid && fillRatio > _endlessLossFill) {
      _onGameOver();
      return;
    }

    if (fillRatio > 0.75 && gridSize < maxGrid) {
      gs.growGrid(maxGridSize: maxGrid);
      return;
    }

    final spawned = gs.spawnEndlessArrowWithTelegraph();
    if (!spawned) {
      if (gridSize < maxGrid) {
        gs.growGrid(maxGridSize: maxGrid);
        return;
      }
      _onGameOver();
      return;
    }
  }


  void _goToNextLevelInPlace() {

    if (widget.gameMode == GameMode.blitz) return;   // Blitz advances internally


    final nextLevel = _level.levelNumber + 1;
    setState(() {
      _showingComplete = false;
      _showingGameOver = false;
      _loadedLevelNum = nextLevel;
      _lastFitKey = null; // force re-fit for the new level
    });
    _loadLevelAsync(nextLevel);
  }

  static const int _kDebugRushLevel = 0;

  void _initGame() {
    final progress = ref.read(progressRepositoryProvider);
    final selectedTheme = progress.selectedTheme;
    final isLifeFree = widget.gameMode == GameMode.zen ||
        widget.gameMode == GameMode.timeAttack ||
        widget.gameMode == GameMode.timeBlitz ||
        progress.heartRemover;

    // Endless Rush and Blitz both scale with the player's real campaign level,
    // not the widget's default (usually 1).
    final effectiveLevel =
    (widget.gameMode == GameMode.endlessRush ||
        widget.gameMode == GameMode.blitz)
        ? progress.currentLevel
        : widget.level;

    final levelMaxLives = progress.getMaxLivesForLevel(effectiveLevel);
    _lives = isLifeFree ? 999 : levelMaxLives;


    if (widget.gameMode == GameMode.blitz && _blitzStage == 0) {
      _blitzRunStartHearts = _lives;
    }

    _showingGameOver = false;
    _usedAdRewardThisLevel = false;
    _pendingMilestoneItems = 0;
    _itemUsesThisLevel.clear();
    _rocksBeforeBomb = 0;
    _gameState?.removeListener(_onGameStateChanged);

    _gameState = GameState(
      level: _level,
      initialLives: _lives,
      theme: selectedTheme,
      heartRemover: progress.heartRemover,
      boardTheme: progress.selectedBoard,
      assistMode: progress.assistMode,
      arrowSpeed: progress.arrowSpeed,
        rushSpeedMultiplier: widget.gameMode == GameMode.endlessRush
            ? _rushSpeedMultiplierForLevel(
          _kDebugRushLevel > 0
              ? _kDebugRushLevel
              : progress.currentLevel,
          widget.rushDifficulty,
        )
            : 1.0,
      onLevelComplete: _onLevelComplete,
      onGameOver: _onGameOver,
      // Time Blitz still wants the callback — blocked taps cost time.
      onLifeLost: (isLifeFree && widget.gameMode != GameMode.timeBlitz)
          ? () {}
          : _onLifeLost,
      gameMode: widget.gameMode,
      onCameraShake: _triggerShake,
    );
    _gameState!.addListener(_onGameStateChanged);


    // ── Seed leaving arrows (Classic + Time Blitz only) ──
    if (widget.gameMode == GameMode.classic) {
      final count = _leavingArrowsForLevel(_level.levelNumber);
      if (count > 0) {
        _gameState!.seedLeavingArrows(count: count);
      }
    } else if (widget.gameMode == GameMode.timeBlitz) {
      final count = _leavingArrowsForStage(_blitzStage);
      if (count > 0) {
        _gameState!.seedLeavingArrows(count: count);
      }
    }


    _game = ArrowPuzzleGame(
      level: _level,
      gameState: _gameState!,
      onLevelComplete: _onLevelComplete,
      onGameOver: _onGameOver,
      onLifeLost: isLifeFree ? () {} : _onLifeLost,
    );

    _resetTimerForLevel();

    // Brief heads-up when a timed Classic level starts.
    if (_totalTime > 0 && widget.gameMode == GameMode.classic) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏱ TIMED LEVEL · ${_totalTime}s'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orangeAccent.shade700,
          ),
        );
      });
    }

    // Blitz overrides the timer — its own per-stage duration.
    if (widget.gameMode == GameMode.blitz) {
      _levelTimer?.cancel();
      _totalTime = _blitzTimerForStage(
        stageIndex: _blitzStage,
        stageCount: _blitzStageCount,
      );
      _timeRemaining = _totalTime;
      _startLevelTimer();
    }

    // New game ⇒ new board ⇒ reset zoom fit next frame.
    _lastFitKey = null;
    _lastSeenArrowCount = -1;
    _lastTimeBlitzArrowCount = -1;   // ← add
    _toFitMatrix = null;
    _transformationController.value = Matrix4.identity();
    if (widget.gameMode == GameMode.endlessRush) {
      _startEndlessRush();
    }
  }

  void _onGameStateChanged() {
    if (!mounted) return;

    if (_rocksBeforeBomb > 0 &&
        _gameState!.rocks.length < _rocksBeforeBomb) {
      final bombsUsed = _itemUsesThisLevel[ItemType.bomb] ?? 0;
      _rocksBeforeBomb = 0;
      setState(() {
        _itemUsesThisLevel[ItemType.bomb] = bombsUsed + 1;
      });
      ref.read(coinsRepositoryProvider).spendItem(ItemType.bomb);
    }

    setState(() => _lives = _gameState!.lives);

    // Endless Rush: react *immediately* whenever the real-arrow count
    // drops. Telegraph blinks notify 10×/sec, so we only act on change.
    if (widget.gameMode == GameMode.endlessRush) {
      final realArrows = _gameState!.arrows.length;
      if (realArrows != _lastSeenArrowCount) {
        _lastSeenArrowCount = realArrows;
        _onEndlessArrowCountChanged(realArrows);
      }
    }
    if (widget.gameMode == GameMode.timeBlitz) {
      _tickTimeBlitz();
    }
  }

  /// Shows a floating "+Ns" / "-Ns" text below the timer.
  ///
  /// Up to 3 pulses are visible at once, distributed across three slots
  /// (left, center, right). A 4th pulse replaces the oldest (left slot).
  void _showTimerPulse(int deltaSeconds) {
    if (deltaSeconds == 0) return;
    if (!mounted) return;

    final isGain = deltaSeconds > 0;
    final id = _nextPulseId++;
    final slot = _nextPulseSlot;
    _nextPulseSlot = (_nextPulseSlot + 1) % 3;

    setState(() {
      // Clear any existing pulse occupying this slot.
      _timerPulses.removeWhere((p) => p.slot == slot);

      // Add the new pulse.
      _timerPulses.add(_TimerPulse(
        id: id,
        text: isGain ? '+${deltaSeconds}s' : '${deltaSeconds}s',
        color: isGain ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
        slot: slot,
      ));
    });

    // Auto-remove after the animation completes.
    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _timerPulses.removeWhere((p) => p.id == id);
      });
    });
  }


  Widget _buildPulseAnimated(_TimerPulse pulse) {
    // Horizontal drift: left slot → left, center stays, right → right.
    final dx = switch (pulse.slot) {
      0 => -36.0,
      1 => 0.0,
      2 => 36.0,
      _ => 0.0,
    };

    return Text(
      pulse.text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: pulse.color,
        letterSpacing: 0.5,
        shadows: const [
          Shadow(
            color: Colors.black87,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
    )
        .animate(key: ValueKey(pulse.id))
        .fadeIn(duration: 150.ms, curve: Curves.easeOut)
        .custom(
      duration: 750.ms,
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(dx * value, 42 * value),
        child: child,
      ),
    )
        .fadeOut(delay: 400.ms, duration: 300.ms);
  }

  /// Time penalty for a blocked tap in Time Blitz.
  /// Grows with each stage cleared, capped at 20 seconds.
  ///   Stage 0   → -3s
  ///   Stage 5   → -5s
  ///   Stage 10  → -8s
  ///   Stage 15  → -10s
  ///   Stage 25  → -15s
  ///   Stage 34+ → -20s
  int _timePenaltyForStage() {
    return (3 + (_blitzStage * 0.5)).round().clamp(3, 20);
  }

  /// Time Blitz — tracks arrow clears and adds time per arrow.
  /// Ignores mass-clears (level transitions) via a delta threshold.
  void _tickTimeBlitz() {
    final gs = _gameState;
    if (gs == null) return;
    if (_showingComplete || _showingGameOver) return;

    final currentArrows = gs.arrows.length;

    // First observation on a new level — record the baseline, no time gain.
    if (_lastTimeBlitzArrowCount < 0) {
      _lastTimeBlitzArrowCount = currentArrows;
      return;
    }

    if (currentArrows < _lastTimeBlitzArrowCount) {
      final delta = _lastTimeBlitzArrowCount - currentArrows;
      // delta > 5 = level just cleared → don't award time.
      if (delta <= 5) {
        _timeBlitzScore += delta;
        setState(() {
          _timeRemaining += delta * 2; // +2s per arrow cleared
        });
        _showTimerPulse(delta * 2); // ← add this
      }
    }

    _lastTimeBlitzArrowCount = currentArrows;
  }

  /// Fires the instant the count of *real* arrows (not telegraphs) drops.
  /// If we've reached last-stand, cancel any blinking telegraph and
  /// drop straight into the polling loop.
  void _onEndlessArrowCountChanged(int realArrows) {
    final gs = _gameState;
    if (gs == null) return;

    if (realArrows <= _endlessLastStandCount &&
        gs.telegraphArrows.isNotEmpty) {
      gs.cancelAllTelegraphs();
    }

    if (realArrows <= _endlessLastStandCount) {
      _endlessSpawnTimer?.cancel();
      _tickEndlessRush();
    }
  }


  void _onLifeLost() {
    if (!mounted) return;

    if (widget.gameMode == GameMode.timeBlitz) {
      final penalty = _timePenaltyForStage();
      final newTime = (_timeRemaining - penalty).clamp(0, 999);
      setState(() => _timeRemaining = newTime);
      _showTimerPulse(-penalty);
      if (newTime <= 0) {
        _levelTimer?.cancel();
        _onTimeOut();
      }
      return;
    }

    setState(() => _lives = _gameState!.lives);
  }

  Future<void> _onLevelComplete() async {
    if (!mounted || _showingComplete) return;

    if (widget.gameMode == GameMode.blitz) {
      await _handleBlitzStageComplete();
      return;
    }

    if (widget.gameMode == GameMode.timeBlitz) {
      _handleTimeBlitzStageComplete();
      return;
    }

    _levelTimer?.cancel();
    _endlessSpawnTimer?.cancel();
    AudioHapticHelper.playSuccess(isLast: true);
    setState(() => _showingComplete = true);

    final progress = ref.read(progressRepositoryProvider);
    final coinsRepo = ref.read(coinsRepositoryProvider);
    final stars = ProgressRepository.calculateStars(_gameState!.livesLost);

    int coinsEarned = 0;
    int itemsEarned = 0;

    if (!widget.isRandom && widget.gameMode == GameMode.classic) {
      final levelNum = _level.levelNumber;
      final wasAlreadyBeaten = progress.isLevelCompleted(levelNum);

      if (!wasAlreadyBeaten) {
        coinsEarned = CoinRewards.firstClearCoins(levelNum) +
            CoinRewards.starBonus(stars) +
            CoinRewards.milestoneCoins(levelNum);

        if (Random().nextDouble() < 0.05) {
          await coinsRepo.addRandomItems(1);
        }
      } else {
        coinsEarned = CoinRewards.replayCoins(
          level: levelNum,
          stars: stars,
          currentLevel: progress.currentLevel,
        );
      }

      await progress.recordLevelComplete(LevelResult(
        levelNumber: levelNum,
        stars: stars,
        livesLost: _gameState!.livesLost,
        completed: true,
        completedAt: DateTime.now(),
      ));

      final packsEarned = await progress.consumePendingItemMilestones();
      if (packsEarned > 0) {
        itemsEarned = packsEarned;
        _pendingMilestoneItems = packsEarned;
        await coinsRepo.addRandomItems(itemsEarned);
      } else {
        _pendingMilestoneItems = 0;
      }

      if (coinsEarned > 0) {
        await coinsRepo.addCoins(coinsEarned);
      }
    }

    if (widget.gameMode == GameMode.timeAttack) {
      setState(() {
        _timeRemaining = (_timeRemaining + 15).clamp(0, 99);
        _timeAttackScore++;
      });
      _triggerTimeAttackBonusAnimation();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _goToNextLevelInPlace();
      });
    } else if (widget.gameMode == GameMode.zen) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _goToNextLevelInPlace();
      });
    } else if (widget.gameMode == GameMode.timeBlitz) {
      // No dialog — just advance. Score is already tracked per arrow.
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _goToNextLevelInPlace();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showLevelCompleteDialog(stars, coinsEarned);
      });
    }
  }

  Future<void> _handleBlitzStageComplete() async {
    if (!mounted) return;

    // Score: base × progression multiplier + time bonus.
    final multiplier = 1.0 + (_blitzStage * 0.15);
    final base = (1000 * multiplier).round();
    final timeBonus = _timeRemaining * 25;
    _blitzScore += base + timeBonus;

    // Last stage cleared → done.
    if (_blitzStage >= _blitzStageCount - 1) {
      _levelTimer?.cancel();
      await _showBlitzResult(completed: true);
      return;
    }

    // Show splash for ~1.1s, then advance.
    setState(() {
      _blitzStage++;
      _blitzSplashStage = _blitzStage + 1;
      _blitzShowingSplash = true;
    });

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    setState(() => _blitzShowingSplash = false);
    await _loadLevelAsync(0); // argument ignored for Blitz
  }

  void _handleTimeBlitzStageComplete() {
    if (!mounted) return;

    AudioHapticHelper.playSuccess(isLast: true);
    setState(() => _showingComplete = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _showingComplete = false;
        _blitzStage++;
        _lastFitKey = null;
        _lastTimeBlitzArrowCount = -1;
      });
      _loadLevelAsync(0);
    });
  }

  Future<void> _showBlitzResult({required bool completed}) async {
    if (!mounted || _showingComplete) return;

    final strings = AppStrings.of(context);

    setState(() {
      _showingComplete = true;
      _levelTimer?.cancel();
    });

    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: PopDialog(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completed ? Icons.emoji_events_rounded : Icons.bolt_rounded,
                  color: accent,
                  size: 52,
                ),
                const SizedBox(height: 12),
                Text(
                  completed ? strings.blitzCompleteTitle : strings.blitzOverTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  completed
                      ? strings.blitzSurvivedAll(_blitzStageCount)
                      : strings.blitzClearedOf(_blitzStage, _blitzStageCount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Score panel ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        strings.blitzFinalScore,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_blitzScore',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Home button ──
                GameDialogButton(
                  label: strings.homeButton,
                  icon: Icons.home_rounded,
                  textColor: textPrimary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTimeBlitzResult() async {
    if (!mounted || _showingGameOver) return;

    final strings = AppStrings.of(context);
    setState(() => _showingGameOver = true);

    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);
    final reachedLevel = _level.levelNumber;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: PopDialog(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Color(0xFFFF5722),
                  size: 52,
                ),
                const SizedBox(height: 12),
                Text(
                  strings.timeBlitzOverTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        strings.timeBlitzScoreLabel,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_timeBlitzScore',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${strings.timeBlitzLevelsLabel}: $reachedLevel',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GameDialogButton(
                  label: strings.homeButton,
                  icon: Icons.home_rounded,
                  textColor: textPrimary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.popUntil(context, (r) => r.isFirst);
                    ref.read(currentTabProvider.notifier).state = 1;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _checkForUnlocks({required VoidCallback after}) async {
    final progress = ref.read(progressRepositoryProvider);
    final pending = progress.getPendingCelebration();

    if (pending.isEmpty) {
      after();
      return;
    }

    for (final board in pending) {
      if (!mounted) return;
      await progress.markCelebrationShown(board);
      if (!mounted) return;

      bool shouldContinue = false;
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => UnlockCelebrationScreen(
            board: board,
            coinsEarned: 0,
            onResume: () {
              Navigator.pop(context);
              shouldContinue = true;
            },
            onMainMenu: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
              ref.read(currentTabProvider.notifier).state = 0;
            },
            onCheckInventory: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
              ref.read(currentTabProvider.notifier).state = 2;
            },
          ),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );

      if (!shouldContinue) return;
    }

    after();
  }

  void _onGameOver() {
    if (!mounted || _showingGameOver) return;

    if (widget.gameMode == GameMode.blitz) {
      _levelTimer?.cancel();
      _showBlitzResult(completed: false);
      return;
    }

    setState(() => _showingGameOver = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showGameOverDialog();
    });
  }

  Future<void> _handleRestart() async {

    if (widget.gameMode == GameMode.blitz) {
      setState(() {
        _showingGameOver = false;
        _showingComplete = false;
        _blitzStage = 0;
        _blitzScore = 0;
        _loadedLevelNum = 1;
        _lastFitKey = null;
        _blitzRunSeed = DateTime.now().microsecondsSinceEpoch;
        _transformationController.value = Matrix4.identity();
      });
      await _loadLevelAsync(0);
      return;
    }


    if (!mounted) return;

    // Endless rush must fully rebuild — gridSize can grow, so resetLevel()
    // alone would leave the board expanded.
    if (widget.gameMode == GameMode.endlessRush) {
      _endlessSpawnTimer?.cancel();
      setState(() {
        _showingGameOver = false;
        _showingComplete = false;
        _usedAdRewardThisLevel = false;
        _itemUsesThisLevel.clear();
        _lastFitKey = null;
        _toFitMatrix = null;
        _transformationController.value = Matrix4.identity();
      });
      await _loadLevelAsync(widget.level);
      return;
    }

    // Classic / zen / time-attack: resetLevel is enough.
    final isLifeFree = widget.gameMode == GameMode.zen ||
        widget.gameMode == GameMode.timeAttack ||
        ref.read(progressRepositoryProvider).heartRemover;

    setState(() {
      _showingGameOver = false;
      _showingComplete = false;
      _usedAdRewardThisLevel = false;
      _game.resetLevel();
      _lives = isLifeFree ? 999 : AppConstants.maxLives;
      _resetTimerForLevel();
      _itemUsesThisLevel.clear();
      _lastFitKey = null;
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _useItem(ItemType item) async {
    final strings = AppStrings.of(context);
    final coinsRepo = ref.read(coinsRepositoryProvider);
    if (coinsRepo.getItemCount(item) <= 0) return;
    if (_gameState == null) return;

    final isTimed = _totalTime > 0 ||
        widget.gameMode == GameMode.timeAttack ||
        widget.gameMode == GameMode.timeBlitz;

    int maxUses;
    switch (item) {
      case ItemType.hint:
        maxUses = 999;
        break;
      case ItemType.undo:
        maxUses = isTimed ? 2 : 1;
        break;
      case ItemType.bomb:
        maxUses = 1;
        break;
      case ItemType.heartFlask:
      case ItemType.timeFreeze:
        maxUses = 1;
        break;
    }

    final currentUses = _itemUsesThisLevel[item] ?? 0;
    if (currentUses >= maxUses) return;

    if (isTimed &&
        (item == ItemType.heartFlask || item == ItemType.timeFreeze)) {
      final heartUsed = _itemUsesThisLevel[ItemType.heartFlask] ?? 0;
      final timeUsed = _itemUsesThisLevel[ItemType.timeFreeze] ?? 0;
      if (heartUsed + timeUsed >= 1) return;
    }

    switch (item) {
      case ItemType.heartFlask:
        if (_gameState!.lives >= AppConstants.maxLives) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.heartsAlreadyFull),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _gameState!.restoreLife();
        setState(() => _lives = _gameState!.lives);
        break;

      case ItemType.timeFreeze:
        if (widget.gameMode == GameMode.classic && _totalTime > 0) {
          final elapsed = _totalTime - _timeRemaining;
          if (elapsed < 30) {
            final wait = 30 - elapsed;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.timeFreezeWait(wait)),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
        }
        setState(() => _timeRemaining += 30);
        break;

      case ItemType.bomb:
        _rocksBeforeBomb = _gameState!.rocks.length;
        _gameState!.setBombArmed(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.tapRockToDestroy),
            duration: const Duration(seconds: 3),
          ),
        );
        return;

      case ItemType.hint:
        final arrowId = _gameState!.findNextSolvableArrowId();
        if (arrowId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.noSolvableArrowFound),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _gameState!.setHintArrow(arrowId);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _gameState?.setHintArrow(null);
        });
        break;

      case ItemType.undo:
        final ok = _gameState!.undoLastExit();
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.nothingToUndo),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        break;
    }

    await coinsRepo.spendItem(item);
    if (!mounted) return;
    setState(() {
      _itemUsesThisLevel[item] = currentUses + 1;
    });
  }

  void _togglePause() {
    if (_showingComplete || _showingGameOver || !_isLevelReady) return;
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _game.pauseEngine();
    } else {
      _game.resumeEngine();
    }
  }

  void _handleResume() {
    setState(() => _isPaused = false);
    _game.resumeEngine();
  }

  void _handlePauseRestart() {
    setState(() => _isPaused = false);
    _game.resumeEngine();
    _handleRestart();
  }

  void _handlePauseMainMenu() {
    setState(() => _isPaused = false);
    _game.resumeEngine();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handleNextLevel() {
    Navigator.pop(context);
    _checkForUnlocks(after: _goToNextLevelInPlace);
  }

  void _handleMenu() {
    Navigator.pop(context);
    _checkForUnlocks(after: () {
      Navigator.popUntil(context, (r) => r.isFirst);
      ref.read(currentTabProvider.notifier).state = 0;
    });
  }

  Future<void> _showLevelCompleteDialog(int stars, int coinsEarned) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteDialog(
        level: _gameState?.level ?? _level,
        stars: stars,
        isRandom: widget.isRandom,
        gameMode: widget.gameMode,          // ← new
        baseCoins: coinsEarned,
        baseItems: _pendingMilestoneItems,
        onNextLevel: _handleNextLevel,
        onMenu: _handleMenu,
      ),
    );
  }

  Future<void> _handleTimeAttackRestart() async {
    setState(() {
      _showingGameOver = false;
      _showingComplete = false;
      _timeRemaining = 60;
      _timeAttackScore = 0;
      _loadedLevelNum = 1;
      _lastFitKey = null;
    });
    _loadLevelAsync(1);
  }

  Future<void> _showGameOverDialog() async {
    int continueTime = 0;
    int heartReward = 0;

    if (_isTimeoutState) {
      final remainingArrows =
          _gameState!.arrows.where((a) => a.state != ArrowState.sliding).length;
      continueTime = AdRewards.secondsForRemainingArrows(remainingArrows);
    } else {
      final progress = ref.read(progressRepositoryProvider);
      final effectiveLevel = widget.gameMode == GameMode.endlessRush
          ? progress.currentLevel
          : _level.levelNumber;

      // Refill to the level's actual max — 2 for early levels, 3 once the
      // Survivalist trophy is unlocked. Same source of truth as the top
      // bar's LivesBar, so the ad reward can never exceed the cap.
      heartReward = progress.getMaxLivesForLevel(effectiveLevel);
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        level: _level,
        isTimeout: _isTimeoutState,
        continueTime: continueTime,
        heartReward: heartReward,
        adRewardAvailable: !_usedAdRewardThisLevel,
        gameMode: widget.gameMode,
        score: _timeAttackScore,
        onContinue: () {
          Navigator.pop(context);
          setState(() {
            _showingGameOver = false;
            _usedAdRewardThisLevel = true;
            if (_isTimeoutState) {
              _timeRemaining = continueTime;
              _isTimeoutState = false;
              _gameState!.resumeFromTimeout();
              _startLevelTimer();
            } else {
              for (int i = 0; i < heartReward; i++) {
                _gameState!.restoreLife();
              }
              _lives = _gameState!.lives;
            }
          });

          if (widget.gameMode == GameMode.endlessRush) {
            // The ad likely left the app in a backgrounded state; reset it so
            // the scheduler doesn't hit the soft-pause guard.
            _isAppBackgrounded = false;

            _gameState!.resumeFromTimeout();
            _clearArrowsForAdContinue();
            _lastSeenArrowCount = -1;

            _tickEndlessRush();
          }
        },
        onRestart: () {
          Navigator.pop(context);
          if (widget.gameMode == GameMode.timeAttack) {
            _handleTimeAttackRestart();
          } else {
            _handleRestart();
          }
        },
        onMenu: () {
          Navigator.pop(context);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _levelTimer?.cancel();
    _endlessSpawnTimer?.cancel();
    _shakeTimer?.cancel();
    _gameState?.removeListener(_onGameStateChanged);
    _fitAnimController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isAppBackgrounded = true;
    } else if (state == AppLifecycleState.resumed) {
      _isAppBackgrounded = false;
    }
  }

  /// Duration for a recurring timed Classic level.
  ///
  /// Formula scales with both level and board size, staying fair at all tiers:
  ///
  ///   Level 30  (progress ~0.06):  ~85s base + ~3.4s per arrow
  ///   Level 60  (progress ~0.12):  ~82s base + ~3.3s per arrow
  ///   Level 100 (progress ~0.20):  ~78s base + ~3.1s per arrow
  ///   Level 250 (progress ~0.50):  ~65s base + ~2.6s per arrow
  ///   Level 500 (progress ~1.00):  ~50s base + ~2.0s per arrow
  ///
  /// A competent player should finish with ~15-25% of the clock remaining on
  /// the first try. Using a Time Freeze adds +30s, which is 30-40% more time
  /// on early-mid timed levels — meaningful enough to justify the item.
  int _calculateTimedLevelDuration(int levelNum, int totalArrows) {
    // Progress from 0.0 (level 1) to 1.0 (level 500+).
    final progress = (levelNum / 500.0).clamp(0.0, 1.0);

    // Base buffer: 18s at low levels → 8s at high levels.
    final baseSeconds = 18.0 - progress * 10.0;

    // Per-arrow budget: 3.5s at low levels → 2.0s at high levels.
    final perArrow = 3.5 - progress * 1.5;

    return (baseSeconds + perArrow * totalArrows).round();
  }

  void _resetTimerForLevel() {
    if (widget.gameMode == GameMode.blitz) return;

    // ── Time Blitz: survival timer keeps running across levels ──
    if (widget.gameMode == GameMode.timeBlitz) {
      if (!_timeBlitzStarted) {
        _timeBlitzStarted = true;
        _timeBlitzScore = 0;
        _timeRemaining = 30;
        _totalTime = 0;
        _startLevelTimer();
      }
      return;
    }

    _levelTimer?.cancel();
    _isTimeoutState = false;

    if (widget.gameMode == GameMode.timeAttack) {
      if (_timeRemaining <= 0) {
        _timeRemaining = 60;
      }
      _totalTime = 99;
      _startLevelTimer();
    } else if (widget.gameMode == GameMode.classic) {
      final hasTimer = _isTimedClassicLevel(_level.levelNumber);

      if (hasTimer) {
        _totalTime = _calculateTimedLevelDuration(
            _level.levelNumber, _level.arrows.length);
        _timeRemaining = _totalTime;
        _startLevelTimer();
      } else {
        _totalTime = 0;
        _timeRemaining = 0;
      }
    } else {
      _totalTime = 0;
      _timeRemaining = 0;
    }
  }

  /// Timed Classic levels:
  ///   - Start at level 30 (players learn the base game first)
  ///   - Repeat every 5 levels: 30, 35, 40, 45, 50, ...
  ///
  /// Gives a predictable rhythm — every 5th level is a "checkpoint challenge"
  /// and rewards using the Time Freeze item (~20% of levels have a timer).
  bool _isTimedClassicLevel(int levelNum) {
    if (levelNum < 30) return false;
    return levelNum % 5 == 0;
  }

  void _startLevelTimer() {
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_showingComplete ||
          _showingGameOver ||
          _isLoadingLevel ||
          !_isLevelReady ||
          _isAppBackgrounded ||
          _isPaused) {
        return;
      }
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          if (_timeRemaining == 0) {
            timer.cancel();
            _onTimeOut();
          }
        }
      });
    });
  }

  void _onTimeOut() {
    if (!mounted || _showingGameOver) return;

    if (widget.gameMode == GameMode.blitz) {
      _levelTimer?.cancel();
      _showBlitzResult(completed: false);
      return;
    }

    if (widget.gameMode == GameMode.timeBlitz) {
      _levelTimer?.cancel();
      _showTimeBlitzResult();
      return;
    }

    if (widget.gameMode == GameMode.timeBlitz) {
      _levelTimer?.cancel();
      _showTimeBlitzResult();
      return;
    }

    setState(() => _isTimeoutState = true);
    _gameState?.forceGameOver();
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressRepositoryProvider);

    if (_isLoadingLevel || !_isLevelReady) {
      return const LevelLoadingScreen();
    }

    final totalArrows = _level.arrows.length;
    final activeArrows =
        _gameState?.arrows.where((a) => a.state != ArrowState.sliding).length ??
            totalArrows;
    final clearedArrows = totalArrows - activeArrows;
    final progressVal =
    totalArrows > 0 ? (clearedArrows / totalArrows).clamp(0.0, 1.0) : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!_isPaused && !_showingComplete && !_showingGameOver) {
          _togglePause();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: BoardThemes.get(progressState.selectedBoard).gradient,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    GameTopBar(
                      level: _gameState?.level ?? _level,
                      isRandom: widget.isRandom,
                      onPause: _togglePause,
                      gameMode: widget.gameMode,
                      score: widget.gameMode == GameMode.timeBlitz
                          ? _timeBlitzScore
                          : _timeAttackScore,
                      lives: _lives,
                      heartRemover: progressState.heartRemover,
                    ),
                    if (_totalTime > 0 ||
                        widget.gameMode == GameMode.timeAttack ||
                        widget.gameMode == GameMode.timeBlitz)
                      RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              TimerDisplay(
                                timeRemaining: _timeRemaining,
                                totalTime: widget.gameMode == GameMode.timeAttack
                                    ? 99
                                    : widget.gameMode == GameMode.timeBlitz
                                    ? 90
                                    : _totalTime,
                              ),

                              // ── Floating +Ns / -Ns pulses, all anchored at center ──
                              Positioned(
                                top: 44,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 60,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      for (final pulse in _timerPulses) _buildPulseAnimated(pulse),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: Stack(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final viewportSize = Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                final contentSize = _contentSize;

                            // Fit scale: how much we need to shrink the board
                            // so it (plus padding) fits inside the viewport.
                            final paddedW =
                            (viewportSize.width - _kBoardPadding * 2)
                                .clamp(1.0, double.infinity);
                            final paddedH =
                            (viewportSize.height - _kBoardPadding * 2)
                                .clamp(1.0, double.infinity);
                            final fitScale = min(
                              paddedW / contentSize,
                              paddedH / contentSize,
                            );

                            // Zoom range: allow zooming slightly further out
                            // than the auto-fit, and in for detail.
                            final minScale = (fitScale * 0.6).clamp(0.05, 1.0);
                            final maxScale = max(3.0, fitScale * 4.0);

                            final liveGridSize = _gameState?.level.gridSize ?? _level.gridSize;
                            final fitKey = Object.hash(
                              _gameState?.level.levelNumber ?? _level.levelNumber,
                              liveGridSize,
                              viewportSize.width,
                              viewportSize.height,
                            );
                            if (_lastFitKey != fitKey) {
                              _lastFitKey = fitKey;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                _applyFitTransform(
                                  viewportSize: viewportSize,
                                  contentSize: contentSize,
                                  fitScale: fitScale,
                                );
                              });
                            }

                            return Transform.translate(
                              offset: Offset(_shakeOffset, 0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  RepaintBoundary(
                                    child: InteractiveViewer(
                                      transformationController:
                                      _transformationController,
                                      // Allow the board to be larger than the
                                      // viewport; users can pan / zoom.
                                      constrained: false,
                                      minScale: minScale,
                                      maxScale: maxScale,
                                      boundaryMargin:
                                      EdgeInsets.all(contentSize * 0.5),
                                      clipBehavior: Clip.hardEdge,
                                      onInteractionStart: (_) => _fitAnimController.stop(),
                                      child: SizedBox(
                                        width: contentSize,
                                        height: contentSize,
                                        child: Stack(
                                          children: [
                                            GameWidget(
                                              key: ValueKey(
                                                'game_widget_${_gameState?.level.levelNumber ?? _level.levelNumber}',
                                              ),
                                              game: _game,
                                            ),
                                            if (_gameState != null)
                                              ListenableBuilder(
                                                listenable: _gameState!,
                                                builder: (context, _) {
                                                  return TelegraphOverlay(
                                                    gameState: _gameState!,
                                                    boardSize: contentSize,
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_showBonusAnimation)
                                    Positioned(
                                      top: 60,
                                      child: Text(
                                        _bonusText,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.orangeAccent,
                                          letterSpacing: 1.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black87,
                                              blurRadius: 12,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      )
                                          .animate()
                                          .fadeIn(duration: 200.ms)
                                          .slideY(
                                        begin: 0.5,
                                        end: -0.2,
                                        duration: 600.ms,
                                        curve: Curves.easeOut,
                                      )
                                          .fadeOut(
                                        delay: 500.ms,
                                        duration: 300.ms,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),Positioned(
                              left: 12,
                              bottom: 12,
                              child: GameItemBar(
                                isTimedLevel: _totalTime > 0 ||
                                    widget.gameMode == GameMode.timeAttack ||
                                    widget.gameMode == GameMode.timeBlitz,
                                hasRocks: (_gameState?.rocks.isNotEmpty) ?? false,
                                usesThisLevel: _itemUsesThisLevel,
                                onUseItem: _useItem,
                                gameMode: widget.gameMode,   // ← add this
                              ),
                            ),
                          ],
                      ),
                    ),
                    GameBottomBar(
                      lives: _lives,
                      progress: progressVal,
                      gameMode: widget.gameMode,
                      heartRemover: progressState.heartRemover,
                    ),
                    // Leaving-arrow counter — top-left corner
                    if (_gameState?.hasActiveLeavingArrow == true)
                      Positioned(
                        top: 8,
                        left: 12,
                        child: LeavingArrowCounter(
                          count: _gameState!.leavingArrowTapCount,
                          max: GameState.kLeavingArrowTapLimit,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    const GameBanner(),
                  ],
                ),
              ),
            ),
            if (_isPaused)
              PauseOverlay(
                onResume: _handleResume,
                onRestart: (widget.gameMode == GameMode.blitz ||
                    widget.gameMode == GameMode.timeBlitz)
                    ? null // no restart — would reset the survival timer
                    : _handlePauseRestart,
                onMainMenu: _handlePauseMainMenu,
              ),
            if (_blitzShowingSplash)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.of(context).blitzSplashStage,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_blitzSplashStage',
                        style: const TextStyle(
                          color: Color(0xFF00BCD4),
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.of(context).blitzPoints(_blitzScore),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _blitzRunStartHearts,
                              (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              i < _lives
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: i < _lives
                                  ? Colors.redAccent
                                  : Colors.white24,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 180.ms),
              ),
          ],
        ),
      ),
    );
  }

  bool get _isLevelReady => _gameState != null;
}

/// One floating time pulse (e.g. "+2s" or "-3s") tied to a specific
/// horizontal slot under the timer.
class _TimerPulse {
  final int id;
  final String text;
  final Color color;
  final int slot; // 0 = left, 1 = center, 2 = right

  const _TimerPulse({
    required this.id,
    required this.text,
    required this.color,
    required this.slot,
  });
}