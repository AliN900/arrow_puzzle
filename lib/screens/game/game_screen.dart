import 'dart:async';
import 'dart:math';
import 'package:arrow_puzzle/screens/game/widgets/telegraph_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ad_rewards.dart';
import '../../core/board_themes.dart';
import '../../core/coin_rewards.dart';
import '../../core/constants.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/game_mode.dart';
import '../../core/items.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';
import '../../data/models/level_result.dart';
import '../../data/repositories/progress_repository.dart';
import '../../game/arrow_puzzle_game.dart';
import '../../game/game_state.dart';
import '../../game/game_state_modes_extension.dart';
import '../../game/helpers/endless_spawner.dart';
import '../../main.dart';
import '../../widgets/game_item_bar.dart';
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

  const GameScreen({
    super.key,
    required this.level,
    this.isRandom = false,
    this.gameMode = GameMode.classic,
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

  static int _startingGridForLevel(int level) =>
      (5 + level ~/ 45).clamp(5, 13);

  static int _maxGridForLevel(int level) =>
      (_startingGridForLevel(level) + 4).clamp(5, 17);

  static int _initialArrowCountForLevel(int level, int startGrid) {
    final fill = (0.35 + level / 450).clamp(0.35, 0.65);
    final count = (startGrid * startGrid * fill / 2.5).round();
    return count.clamp(3, 80);
  }

  static int _minSpawnDelayForLevel(int level) =>
      (700 - (level * 0.8).round()).clamp(300, 700);

  static int _maxSpawnDelayForLevel(int level) =>
      (3500 - (level * 5.0).round()).clamp(1500, 3500);

  static double _lossFillForLevel(int level) =>
      (0.95 - level / 6000).clamp(0.85, 0.95);

  static int _lastStandCountForLevel(int level) =>
      1 + (level ~/ 200).clamp(0, 1);

  static double _rushSpeedMultiplierForLevel(int level) =>
      1.0 + (level / 1200).clamp(0.0, 0.25);

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
      ..translate(tx, ty)
      ..scale(fitScale);

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
    if (widget.gameMode == GameMode.endlessRush) {
      // Use the player's actual campaign level, not widget.level (which is
      // usually just 1 when the mode is launched from the menu).
      final progress = ref.read(progressRepositoryProvider);
      final effectiveLevel = _kDebugRushLevel > 0
          ? _kDebugRushLevel
          : progress.currentLevel;

      final startGrid = _startingGridForLevel(effectiveLevel);
      final maxGrid = _maxGridForLevel(effectiveLevel);
      final targetArrows =
      _initialArrowCountForLevel(effectiveLevel, startGrid);

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
      _endlessMinDelayMs = _minSpawnDelayForLevel(effectiveLevel);
      _endlessMaxDelayMs = _maxSpawnDelayForLevel(effectiveLevel);
      _endlessLossFill = _lossFillForLevel(effectiveLevel);
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
      _bonusText = '+15s';
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

  /// Recursive scheduler. Every tick:
  ///   1. win if board is empty
  ///   2. gate spawns until 50% of the initial arrow count is cleared
  ///   3. otherwise schedule a spawn whose delay shrinks as clearing progresses
  ///      OR as elapsed time increases (slow background pressure).
  void _tickEndlessRush() {
    _endlessSpawnTimer?.cancel();
    if (!mounted ||
        _gameState == null ||
        _isPaused ||
        _isAppBackgrounded ||
        _showingGameOver ||
        _showingComplete) {
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
      for (final p in a.path) occupied.add('${p[0]},${p[1]}');
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
      } else {
        _onGameOver();
      }
    }
  }


  void _goToNextLevelInPlace() {
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
        progress.heartRemover;

// Endless Rush should scale hearts with the player's real campaign level,
// not the widget's default (usually 1).
    final effectiveLevel = widget.gameMode == GameMode.endlessRush
        ? progress.currentLevel
        : widget.level;

    final levelMaxLives = progress.getMaxLivesForLevel(effectiveLevel);
    _lives = isLifeFree ? 999 : levelMaxLives;

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
              : progress.currentLevel)
          : 1.0,
      onLevelComplete: _onLevelComplete,
      onGameOver: _onGameOver,
      onLifeLost: isLifeFree ? () {} : _onLifeLost,
      gameMode: widget.gameMode,
      onCameraShake: _triggerShake,
    );
    _gameState!.addListener(_onGameStateChanged);

    _game = ArrowPuzzleGame(
      level: _level,
      gameState: _gameState!,
      onLevelComplete: _onLevelComplete,
      onGameOver: _onGameOver,
      onLifeLost: isLifeFree ? () {} : _onLifeLost,
    );

    _resetTimerForLevel();

    // New game ⇒ new board ⇒ reset zoom fit next frame.
    _lastFitKey = null;
    _lastSeenArrowCount = -1;
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
    setState(() => _lives = _gameState!.lives);
  }

  Future<void> _onLevelComplete() async {
    if (!mounted || _showingComplete) return;
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
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showLevelCompleteDialog(stars, coinsEarned);
      });
    }
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

      bool shouldContinue = false;
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => UnlockCelebrationScreen(
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
          transitionsBuilder: (_, animation, __, child) {
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
    setState(() => _showingGameOver = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showGameOverDialog();
    });
  }

  Future<void> _handleRestart() async {
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
    final coinsRepo = ref.read(coinsRepositoryProvider);
    if (coinsRepo.getItemCount(item) <= 0) return;
    if (_gameState == null) return;

    final isTimed =
        _totalTime > 0 || widget.gameMode == GameMode.timeAttack;

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
            const SnackBar(
              content: Text('Hearts are already full'),
              duration: Duration(seconds: 2),
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
                content: Text('Wait ${wait}s more before using Time Freeze'),
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
          const SnackBar(
            content: Text('Tap a rock to destroy it'),
            duration: Duration(seconds: 3),
          ),
        );
        return;

      case ItemType.hint:
        final arrowId = _gameState!.findNextSolvableArrowId();
        if (arrowId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No solvable arrow found'),
              duration: Duration(seconds: 2),
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
            const SnackBar(
              content: Text('Nothing to undo'),
              duration: Duration(seconds: 2),
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

    final progress = ref.read(progressRepositoryProvider);
    final effectiveLevel = widget.gameMode == GameMode.endlessRush
        ? progress.currentLevel
        : _level.levelNumber;
    final maxLives = progress.getMaxLivesForLevel(effectiveLevel);

    if (_isTimeoutState) {
      final remainingArrows =
          _gameState!.arrows.where((a) => a.state != ArrowState.sliding).length;
      continueTime = AdRewards.secondsForRemainingArrows(remainingArrows);
    } else {
      // Reward can never exceed the player's heart ceiling for this level.
      // Levels ≤ 25 → 2 hearts, higher levels → 3 (or 3 with survivalist).
      heartReward = min(
        AdRewards.heartsForLevel(effectiveLevel),
        maxLives,
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        level: _gameState?.level ?? _level,
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

  int _calculateLevelTimerDuration(int levelNum, int totalArrows) {
    final type = AppConstants.levelTypeFor(levelNum);
    if (type == LevelType.god && levelNum > 100) {
      final baseSeconds =
      (45.0 - (levelNum - 100) * (20.0 / 400.0)).clamp(25.0, 45.0);
      final secondsPerArrow =
      (2.5 - (levelNum - 100) * (1.0 / 400.0)).clamp(1.5, 2.5);
      return (baseSeconds + secondsPerArrow * totalArrows).round();
    } else if (type == LevelType.boss && levelNum > 200) {
      final baseSeconds =
      (40.0 - (levelNum - 200) * (20.0 / 300.0)).clamp(20.0, 40.0);
      final secondsPerArrow =
      (2.2 - (levelNum - 200) * (0.8 / 300.0)).clamp(1.4, 2.2);
      return (baseSeconds + secondsPerArrow * totalArrows).round();
    }
    return 0;
  }

  void _resetTimerForLevel() {
    _levelTimer?.cancel();
    _isTimeoutState = false;

    if (widget.gameMode == GameMode.timeAttack) {
      if (_timeRemaining <= 0) {
        _timeRemaining = 60;
      }
      _totalTime = 99;
      _startLevelTimer();
    } else if (widget.gameMode == GameMode.classic) {
      final levelType = AppConstants.levelTypeFor(_level.levelNumber);
      final hasTimer =
          (levelType == LevelType.god && _level.levelNumber > 100) ||
              (levelType == LevelType.boss && _level.levelNumber > 200);

      if (hasTimer) {
        _totalTime = _calculateLevelTimerDuration(
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
                      score: _timeAttackScore,
                      lives: _lives,
                      heartRemover: progressState.heartRemover,
                    ),
                    if (_totalTime > 0 ||
                        widget.gameMode == GameMode.timeAttack)
                      RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TimerDisplay(
                            timeRemaining: _timeRemaining,
                            totalTime: widget.gameMode == GameMode.timeAttack
                                ? 99
                                : _totalTime,
                          ),
                        ),
                      ),
                    Expanded(
                      child: LayoutBuilder(
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
                      ),
                    ),
                    GameBottomBar(
                      lives: _lives,
                      progress: progressVal,
                      gameMode: widget.gameMode,
                      heartRemover: progressState.heartRemover,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: GameItemBar(
                isTimedLevel: _totalTime > 0 ||
                    widget.gameMode == GameMode.timeAttack,
                hasRocks: (_gameState?.rocks.isNotEmpty) ?? false,
                usesThisLevel: _itemUsesThisLevel,
                onUseItem: _useItem,
              ),
            ),
            if (_isPaused)
              PauseOverlay(
                onResume: _handleResume,
                onRestart: _handlePauseRestart,
                onMainMenu: _handlePauseMainMenu,
              ),
          ],
        ),
      ),
    );
  }

  bool get _isLevelReady => _gameState != null;
}