import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:arrow_puzzle/screens/game/widgets/game_dialog_button.dart';
import 'package:arrow_puzzle/screens/game/widgets/leaving_arrow_counter.dart';
import 'package:arrow_puzzle/screens/game/widgets/telegraph_overlay.dart';
import 'package:flutter/foundation.dart';
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
import '../../core/leader_coins.dart';
import '../../core/music_player.dart';
import '../../core/rush_difficulty.dart';
import '../../data/level_generator/level_generator.dart';
import '../../data/level_generator/mask_generator.dart';
import '../../data/level_generator/solver.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';
import '../../data/models/level_result.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../data/repositories/level_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../game/arrow_puzzle_game.dart';
import '../../game/game_state.dart';
import '../../game/game_state_modes_extension.dart';
import '../../game/helpers/endless_spawner.dart';
import '../../game_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_item_bar.dart';
import '../../widgets/pop_dialog.dart';
import '../../widgets/status_flash.dart';
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
  final LevelModel? prebuiltLevel;

  const GameScreen({
    super.key,
    required this.level,
    this.isRandom = false,
    this.gameMode = GameMode.classic,
    this.rushDifficulty = RushDifficulty.easy,
    this.prebuiltLevel,
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
  Size _viewportSize = Size.zero;

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
  int _missesThisLevel = 0;

  // ── Timer pulse animation state ──
  final List<_TimerPulse> _timerPulses = [];
  int _nextPulseId = 0;
  int _nextPulseSlot = 0;

  // ── LC / run tracking ──
  bool _runInitialized = false;
  bool _consumedAttemptThisRun = false;
  bool _currentRunEarnsLc = false;
  DateTime? _runStartTime;
  int _runFailedTaps = 0;
  int _runTotalItemsUsed = 0;
  bool _isInteracting = false;

  // ── Blitz mode state ──
  int _blitzStage = 0;
  int _blitzScore = 0;
  int _blitzArrowsCleared = 0;
  int _blitzStageCount = 5;
  int _blitzRunStartHearts = 3;
  bool _blitzShowingSplash = false;
  int _blitzSplashStage = 1;
  late int _blitzRunSeed;
  bool _showBonusAnimation = false;
  String _bonusText = '';
  bool _usedAdRewardThisLevel = false;
  final Map<ItemType, int> _itemUsesThisLevel = {};
  int _pendingMilestoneItems = 0;
  int _rocksBeforeBomb = 0;

  // ── Board sizing / zoom ──
  static const double _kCellPx = 64.0;
  static const double _kBoardPadding = 24.0;
  Object? _lastFitKey;

  Matrix4? _fromFitMatrix;
  Matrix4? _toFitMatrix;
  late final AnimationController _fitAnimController;

  final TransformationController _transformationController =
  TransformationController();

  double get _cellPx {
    if (widget.gameMode == GameMode.endlessRush) {
      final g = _gameState?.level.gridSize ?? _level.gridSize;
      return (64.0 - (g - 16) * 2.0).clamp(48.0, 64.0);
    }
    return _kCellPx;
  }

  double get _contentSize =>
      (_gameState?.level.gridSize ?? _level.gridSize) * _cellPx;

  // ── Endless Rush level scaling ──
  static int _startingGridForLevel(int level, RushDifficulty d) =>
      ((6 + level ~/ 60).clamp(6, 12) + d.gridBonus).clamp(6, 15);

  static int _maxGridForLevel(int level, RushDifficulty d) =>
      (_startingGridForLevel(level, d) + 3).clamp(5, 17);

  static int _initialArrowCountForLevel(
      int level, int startGrid, RushDifficulty d) {
    final fill = (0.35 + level / 600.0).clamp(0.35, 0.50);
    final count =
    (startGrid * startGrid * fill / 2.5 * d.arrowMult).round();
    return count.clamp(3, 120);
  }

  static int _minSpawnDelayForLevel(int level, RushDifficulty d) =>
      ((700.0 - level * 0.5) * d.delayMult).round().clamp(200, 900);

  static int _maxSpawnDelayForLevel(int level, RushDifficulty d) =>
      ((3500.0 - level * 2.5) * d.delayMult).round().clamp(1200, 4000);

  static double _lossFillForLevel(int level, RushDifficulty d) =>
      ((0.85 - level / 12000.0) + d.lossOffset).clamp(0.70, 0.88);

  static double _rushSpeedMultiplierForLevel(
      int level, RushDifficulty d) =>
      (1.0 + (level / 1200.0).clamp(0.0, 0.25)) * d.speedMult;

  static int _lastStandCountForLevel(int level) =>
      1 + (level ~/ 200).clamp(0, 1);

  bool get _isLcMode =>
      widget.gameMode == GameMode.endlessRush ||
          widget.gameMode == GameMode.blitz ||
          widget.gameMode == GameMode.timeBlitz;

  String? get _lcModeKey {
    switch (widget.gameMode) {
      case GameMode.endlessRush:
        return LeaderCoins.modeArrowRush;
      case GameMode.blitz:
        return LeaderCoins.modeBlitz;
      case GameMode.timeBlitz:
        return LeaderCoins.modeTimeBlitz;
      default:
        return null;
    }
  }

  void _resetRunTracking() {
    _runInitialized = false;
    _consumedAttemptThisRun = false;
    _currentRunEarnsLc = false;
    _runStartTime = null;
    _runFailedTaps = 0;
    _runTotalItemsUsed = 0;
  }

  static int _blitzStageCountForLevel(int playerLevel) =>
      ((playerLevel ~/ 100 + 1) * 5).clamp(5, 40);

  static MaskShape _blitzShapeForStage(int stage, int runSeed) {
    if (stage < 3) return MaskShape.square;
    const shapes = <MaskShape>[
      MaskShape.pyramid,
      MaskShape.rectangleHorizontal,
      MaskShape.diamond,
      MaskShape.rectangleVertical,
      MaskShape.hexagon,
      MaskShape.circle,
      MaskShape.star,
    ];
    return shapes[(stage - 3 + runSeed.abs()) % shapes.length];
  }

  static int _blitzTimerForStage({
    required int stageIndex,
    required int stageCount,
    required int arrowCount,
  }) {
    final t = stageCount > 1 ? stageIndex / (stageCount - 1) : 0.0;
    final base = 15.0 - t * 5.0;
    final perArrow = 2.5 - t * 0.7;
    final seconds = (base + perArrow * arrowCount).round();
    return seconds.clamp(10, 300);
  }

  int _leavingArrowsForLevel(int levelNum) {
    if (levelNum < 20) return 0;
    return ((levelNum - 20) ~/ 20 + 1).clamp(1, 25);
  }

  int _leavingArrowsForStage(int stage, int playerLevel) {
    final levelCount = ((playerLevel - 20) / 38.0).clamp(0.0, 10.0).round();
    final stageCount = (stage ~/ 2).clamp(0, 10);
    return (levelCount + stageCount).clamp(1, 20);
  }

  void _applyFitTransform({
    required Size viewportSize,
    required double contentSize,
    required double fitScale,
  }) {
    final tx = (viewportSize.width - contentSize * fitScale) / 2.0;
    final ty = (viewportSize.height - contentSize * fitScale) / 2.0;

    final target = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(fitScale, fitScale, fitScale, 1.0);

    if (_toFitMatrix == null) {
      _toFitMatrix = target;
      _transformationController.value = target;
      return;
    }

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

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
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

  void _onTransformChanged() {
    if (_isInteracting) return;
    if (_fitAnimController.isAnimating) return;
    _clampBoardPosition();
  }

  void _clampBoardPosition() {
    if (_viewportSize == Size.zero) return;
    if (_fitAnimController.isAnimating) return;
    if (_isInteracting) return;

    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final contentW = _contentSize * scale;
    final contentH = _contentSize * scale;

    final tx = matrix.getTranslation().x;
    final ty = matrix.getTranslation().y;

    const double overlapRatio = 0.5;
    final double minOverlapX = overlapRatio * math.min(contentW, _viewportSize.width);
    final double minOverlapY = overlapRatio * math.min(contentH, _viewportSize.height);

    final double minTx = minOverlapX - contentW;
    final double maxTx = _viewportSize.width - minOverlapX;
    final double minTy = minOverlapY - contentH;
    final double maxTy = _viewportSize.height - minOverlapY;

    final double clampedTx = tx.clamp(minTx, maxTx);
    final double clampedTy = ty.clamp(minTy, maxTy);

    if (clampedTx != tx || clampedTy != ty) {
      _transformationController.value = matrix.clone()
        ..setTranslationRaw(clampedTx, clampedTy, 0.0);
    }
  }

  Future<void> _loadLevelAsync(int levelNum) async {
    if (widget.prebuiltLevel != null) {
      _level = widget.prebuiltLevel!;
      _initGame();
      if (mounted) setState(() => _isLoadingLevel = false);
      return;
    }

    if (widget.gameMode == GameMode.zen) {
      final randomLevel = _getRandomZenLevel();
      final levelRepo = ref.read(levelRepositoryProvider);

      if (mounted) setState(() => _isLoadingLevel = true);
      try {
        final level = await levelRepo.getLevelAsync(
          randomLevel,
          preGenerateNext: false,
        );
        if (!mounted) return;
        _level = level;
        _initGame();
        setState(() => _isLoadingLevel = false);
      } catch (_) {
        if (!mounted) return;
        _level = levelRepo.getLevel(randomLevel);
        _initGame();
        setState(() => _isLoadingLevel = false);
      }
      return;
    }

    if (widget.gameMode == GameMode.blitz ||
        widget.gameMode == GameMode.timeBlitz) {
      final progress = ref.read(progressRepositoryProvider);
      final playerLevel = progress.currentLevel;
      final stageIndex = _blitzStage;
      _blitzStageCount = _blitzStageCountForLevel(playerLevel);

      final double t = ((playerLevel - 50) / 350.0).clamp(0.0, 1.0);
      final int stageMultiplier = (5 + (t * 17)).round();
      final targetLevel = (playerLevel + (stageIndex * stageMultiplier)).clamp(1, 800);

      final double levelScale = ((playerLevel - 20) / 380.0).clamp(0.0, 1.0);
      final int baseSize = (14 + (levelScale * 10)).round();
      final gridSize = (baseSize + (stageIndex * 0.5)).round();

      final shape = _blitzShapeForStage(stageIndex, _blitzRunSeed);
      final stageSeed = _blitzRunSeed + stageIndex * 997;

      LevelModel? generated;
      try {
        generated = await compute(generateBlitzLevelIsolate, {
          'levelNumber': targetLevel,
          'gridSize': gridSize,
          'shapeName': shape.name,
          'seed': stageSeed,
        });
      } catch (e) {
        debugPrint('❌ Blitz isolate failed: $e');
      }
      if (!mounted) return;

      if (generated == null || generated.gridSize != gridSize) {
        _level = LevelGenerator.generateFromMask(
          levelNumber: targetLevel,
          mask: MaskGenerator.shapeByName(
            'square',
            gridSize,
            Random(stageSeed),
          ),
          gridSize: gridSize,
          maskShape: MaskShape.square,
          seed: stageSeed,
        );
      } else {
        _level = generated;
      }

      _level = _level.copyWith(levelNumber: stageIndex + 1);
      _initGame();
      if (mounted) setState(() => _isLoadingLevel = false);
      return;
    }

    if (widget.gameMode == GameMode.endlessRush) {
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
  bool _endlessLastStandLocked = false;

  void _startEndlessRush() {
    _endlessSpawnTimer?.cancel();
    final gs = _gameState;
    if (gs == null) return;
    _endlessInitialArrowCount = gs.arrows.length;
    _endlessSpawnTimer = Timer(const Duration(seconds: 5), _tickEndlessRush);
  }

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

    if (realArrows <= _endlessLastStandCount) {
      _endlessLastStandLocked = true;

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

    final clearedTotal = gs.clearedRushArrows;
    final remaining = realArrows + telegraphs;
    final remainingRatio = (remaining / initial).clamp(0.0, 1.0);

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

  int? _lastZenLevel;

  int _getRandomZenLevel() {
    final progress = ref.read(progressRepositoryProvider);
    final playerLevel = progress.currentLevel;
    final maxLevel = math.min(playerLevel + 100, 400).clamp(20, 400);

    int randomLevel = 1 + Random().nextInt(maxLevel);
    int attempts = 0;
    while (randomLevel == _lastZenLevel && attempts < 10) {
      randomLevel = 1 + Random().nextInt(maxLevel);
      attempts++;
    }

    _lastZenLevel = randomLevel;
    return randomLevel;
  }

  void _goToNextLevelInPlace() {
    if (widget.gameMode == GameMode.blitz) return;

    if (widget.gameMode == GameMode.zen) {
      setState(() {
        _showingComplete = false;
        _showingGameOver = false;
        _lastFitKey = null;
      });
      _loadLevelAsync(0);
      return;
    }

    final nextLevel = _level.levelNumber + 1;
    setState(() {
      _showingComplete = false;
      _showingGameOver = false;
      _loadedLevelNum = nextLevel;
      _lastFitKey = null;
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

    final effectiveLevel =
    (widget.gameMode == GameMode.endlessRush ||
        widget.gameMode == GameMode.blitz)
        ? progress.currentLevel
        : widget.level;

    final levelMaxLives = progress.getMaxLivesForLevel(effectiveLevel);
    _lives = isLifeFree ? 999 : levelMaxLives;

    final int effectiveArrowSpeed = widget.gameMode == GameMode.zen
        ? math.min(progress.arrowSpeed, 1)
        : progress.arrowSpeed;

    if (widget.gameMode == GameMode.blitz && _blitzStage == 0) {
      _blitzRunStartHearts = _lives;
      _blitzArrowsCleared = 0;
    }

    _showingGameOver = false;
    _usedAdRewardThisLevel = false;
    _pendingMilestoneItems = 0;
    _itemUsesThisLevel.clear();

    if (!_runInitialized) {
      _runInitialized = true;
      _runStartTime = DateTime.now();
      _runFailedTaps = 0;
      _runTotalItemsUsed = 0;
      _currentRunEarnsLc = false;
    }

    if (_isLcMode && !_consumedAttemptThisRun) {
      _consumedAttemptThisRun = true;
      final coinsRepo = ref.read(coinsRepositoryProvider);
      final modeKey = _lcModeKey;
      if (modeKey != null) {
        _currentRunEarnsLc = coinsRepo.canEarnLc(modeKey);
        if (_currentRunEarnsLc) {
          unawaited(coinsRepo.consumeLcAttempt(modeKey));
        }
      }
    }

    _gameState = GameState(
      level: _level,
      initialLives: _lives,
      theme: selectedTheme,
      heartRemover: progress.heartRemover,
      boardTheme: progress.selectedBoard,
      assistMode: progress.assistMode,
      arrowSpeed: effectiveArrowSpeed,
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
      onLifeLost: (isLifeFree && widget.gameMode != GameMode.timeBlitz)
          ? () {}
          : _onLifeLost,
      gameMode: widget.gameMode,
      onCameraShake: _triggerShake,
      onBombMissed: () {
        if (mounted) StatusFlash.fail(context, "", true);
      },
    );
    _gameState!.addListener(_onGameStateChanged);

    if (widget.gameMode == GameMode.classic) {
      final count = _leavingArrowsForLevel(_level.levelNumber);
      if (count > 0) {
        _gameState!.seedLeavingArrows(count: count);
      }
    } else if (widget.gameMode == GameMode.timeBlitz) {
      final count = _leavingArrowsForStage(_blitzStage, progress.currentLevel);
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

    if (widget.gameMode == GameMode.endlessRush ||
        widget.gameMode == GameMode.blitz ||
        widget.gameMode == GameMode.timeBlitz) {
      MusicPlayer.instance.play(MusicPlayer.trackRush);
    } else {
      MusicPlayer.instance.play(MusicPlayer.trackClassic);
    }

    _resetTimerForLevel();

    // if (_totalTime > 0 && widget.gameMode == GameMode.classic) {
    //   Future.delayed(const Duration(milliseconds: 400), () {
    //     if (!mounted) return;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(AppStrings.of(context).gameTimedLevel(_totalTime.toString())),
    //         duration: const Duration(seconds: 2),
    //         backgroundColor: Colors.orangeAccent.shade700,
    //       ),
    //     );
    //   });
    // }

    if (widget.gameMode == GameMode.blitz) {
      _levelTimer?.cancel();
      _totalTime = _blitzTimerForStage(
        stageIndex: _blitzStage,
        stageCount: _blitzStageCount,
        arrowCount: _level.arrows.length,
      );
      _timeRemaining = _totalTime;
      _startLevelTimer();
    }

    if (widget.gameMode == GameMode.timeBlitz) {
      _missesThisLevel = 0;
    }

    _lastFitKey = null;
    _lastSeenArrowCount = -1;
    _lastTimeBlitzArrowCount = -1;
    _endlessLastStandLocked = false;
    _toFitMatrix = null;
    _transformationController.value = Matrix4.identity();
    if (widget.gameMode == GameMode.endlessRush) {
      _startEndlessRush();
    }
  }

  void _centerOnLeavingArrow() {
    final gs = _gameState;
    if (gs == null || gs.activeLeavingArrowId == null) return;

    final idx = gs.arrows.indexWhere((a) => a.id == gs.activeLeavingArrowId);
    if (idx == -1) return;
    final arrow = gs.arrows[idx];

    final head = arrow.path[0];
    final cs = _cellPx;
    final px = (head[1] + 0.5) * cs;
    final py = (head[0] + 0.5) * cs;

    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    final targetTx = _viewportSize.width / 2.0 - px * scale;
    final targetTy = _viewportSize.height / 2.0 - py * scale;

    final target = Matrix4.identity()
      ..translateByDouble(targetTx, targetTy, 0.0, 1.0)
      ..scaleByDouble(scale, scale, scale, 1.0);

    _fitAnimController.stop();
    _fromFitMatrix = _transformationController.value;
    _toFitMatrix = target;
    _fitAnimController.forward(from: 0);
  }

  void _onGameStateChanged() {
    if (!mounted) return;

    if (!_gameState!.isBombArmed && _rocksBeforeBomb > 0) {
      _rocksBeforeBomb = 0;
      setState(() {});
    }

    if (_rocksBeforeBomb > 0 &&
        _gameState!.rocks.length < _rocksBeforeBomb) {
      final bombsUsed = _itemUsesThisLevel[ItemType.bomb] ?? 0;
      _rocksBeforeBomb = 0;
      setState(() {
        _itemUsesThisLevel[ItemType.bomb] = bombsUsed + 1;
      });
      _runTotalItemsUsed++;
      ref.read(coinsRepositoryProvider).spendItem(ItemType.bomb);
    }

    setState(() => _lives = _gameState!.lives);

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

  Future<void> _awardLc({
    required int lc,
    required int arrowsCleared,
    required int failedTaps,
    required int itemsUsed,
    required int durationSeconds,
  }) async {
    if (!mounted) return;
    if (lc <= 0) {
      debugPrint('🏆 [Debug] Stopped: lc is 0 or less');
      return;
    }
    if (!_currentRunEarnsLc) {
      debugPrint('🏆 [Debug] Stopped: _currentRunEarnsLc is false');
      return;
    }
    if (AuthService.instance.isGuest) {
      debugPrint('🏆 [Debug] Stopped: User is a guest');
      return;
    }

    final progress = ref.read(progressRepositoryProvider);
    await progress.addLbPoints(lc);
    if (!mounted) return;
    StatusFlash.success(context, '+$lc LC');

    // if (!progress.leaderboardOptIn) {
    //   debugPrint('🏆 [Debug] Stopped: User is not opted in to leaderboard');
    //   return;
    // }
    // if (!progress.isLeaderboardUnlocked) {
    //   debugPrint('🏆 [Debug] Stopped: Leaderboard is not unlocked');
    //   return;
    // }

    try {
      debugPrint('🏆 [Debug] Sending to Appwrite...');
      final result = await LeaderboardRepository.instance.awardLcRun(
        mode: widget.gameMode.name,
        difficulty: widget.rushDifficulty.index,
        lcDelta: lc,
        arrowsCleared: arrowsCleared,
        failedTaps: failedTaps,
        itemsUsed: itemsUsed,
        durationSeconds: durationSeconds,
        level: progress.currentLevel,
        totalStars: progress.totalStars,
        trophies: progress.unlockedTrophies.length,
      );

      if (result != null) {
        debugPrint('🏆 [Debug] Appwrite Success! Awarded: ${result.lcAwarded}');
        await progress.setLbScores(
          weekly: result.weeklyScore,
          monthly: result.monthlyScore,
          allTime: result.allTimeScore,
        );
        await progress.markLbClean();
      } else {
        debugPrint('🏆 [Debug] Appwrite returned null (Rejected by server)');
      }
    } catch (e) {
      debugPrint('🏆 [Debug] LC push error: $e');
    }
  }

  void _showTimerPulse(int deltaSeconds) {
    if (deltaSeconds == 0) return;
    if (!mounted) return;

    final isGain = deltaSeconds > 0;
    final id = _nextPulseId++;
    final slot = _nextPulseSlot;
    _nextPulseSlot = (_nextPulseSlot + 1) % 3;

    setState(() {
      _timerPulses.removeWhere((p) => p.slot == slot);
      _timerPulses.add(_TimerPulse(
        id: id,
        text: isGain ? '+$deltaSeconds' : '$deltaSeconds',
        color: isGain ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
        slot: slot,
      ));
    });

    Future.delayed(const Duration(milliseconds: 855), () {
      if (!mounted) return;
      setState(() {
        _timerPulses.removeWhere((p) => p.id == id);
      });
    });
  }

  Widget _buildPulseAnimated(_TimerPulse pulse) {
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
        offset: Offset(dx * value, -42.0 * value),
        child: child,
      ),
    )
        .fadeOut(delay: 400.ms, duration: 300.ms);
  }

  int _timePenaltyForStage() {
    return (3.0 + (_blitzStage * 0.5)).round().clamp(3, 20);
  }

  void _tickTimeBlitz() {
    final gs = _gameState;
    if (gs == null) return;
    if (_showingComplete || _showingGameOver) return;

    final currentArrows = gs.arrows.length;

    if (_lastTimeBlitzArrowCount < 0) {
      _lastTimeBlitzArrowCount = currentArrows;
      return;
    }

    if (currentArrows < _lastTimeBlitzArrowCount) {
      final delta = _lastTimeBlitzArrowCount - currentArrows;
      if (delta <= 5) {
        _timeBlitzScore += delta;
        setState(() {
          _timeRemaining += delta * 2;
        });
        _showTimerPulse(delta * 2);
      }
    }

    _lastTimeBlitzArrowCount = currentArrows;
  }

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
    _runFailedTaps++;

    if (widget.gameMode == GameMode.timeBlitz) {
      _missesThisLevel++;

      final progress = ref.read(progressRepositoryProvider);
      final playerLevel = progress.currentLevel;

      final basePenalty = _timePenaltyForStage();
      final int levelScaling = 1 + (playerLevel ~/ 100);
      final rawPenalty = basePenalty + ((_missesThisLevel - 1) * levelScaling);
      final finalPenalty = rawPenalty.clamp(3, 30);

      final newTime = (_timeRemaining - finalPenalty).clamp(0, 999);
      setState(() => _timeRemaining = newTime);
      _showTimerPulse(-finalPenalty);

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
        if (mounted) _showZenResultDialog();
      });
    } else if (widget.gameMode == GameMode.endlessRush) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showDailyRunResult(
            completed: true,
            modeName: AppStrings.of(context).arrowRushTitle,
          );
        }
      });
    } else if (widget.gameMode == GameMode.timeBlitz) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _goToNextLevelInPlace();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showLevelCompleteDialog(stars, coinsEarned);
      });
    }
  }

  Future<void> _showZenResultDialog() async {
    if (!mounted) return;

    final durationSec = _runStartTime != null
        ? DateTime.now().difference(_runStartTime!).inSeconds
        : 0;
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final strings = AppStrings.of(context);
    final accent = AppColors.accent(context);
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
              border: Border.all(color: accent.withValues(alpha: 0.35), width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.self_improvement_rounded, color: accent, size: 52),
                const SizedBox(height: 12),
                Text(
                  strings.zenModeTitle,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(strings.zenTimePlayed, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(timeStr, style: TextStyle(color: accent, fontSize: 44, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GameDialogButton(
                  label: strings.levelCompleteNextLevel,
                  icon: Icons.skip_next_rounded,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    _goToNextLevelInPlace();
                  },
                ),
                const SizedBox(height: 12),
                GameDialogButton(
                  label: strings.homeButton,
                  icon: Icons.home_rounded,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.popUntil(context, (r) => r.isFirst);
                    ref.read(currentTabProvider.notifier).state = 0;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBlitzStageComplete() async {
    if (!mounted) return;

    _levelTimer?.cancel();
    final frozenTime = _timeRemaining;

    final int arrowsInLevel = _level.arrows.length;
    final int arrowPoints = arrowsInLevel * 5;
    final int stageBonus = 50 + (_blitzStage * 25);
    final int timeBonus = frozenTime * 50;

    _blitzScore += arrowPoints + stageBonus + timeBonus;
    _blitzArrowsCleared += arrowsInLevel;

    if (_blitzStage >= _blitzStageCount - 1) {
      _levelTimer?.cancel();
      await _showDailyRunResult(
        completed: true,
        modeName: AppStrings.of(context).blitzTitle,
      );
      return;
    }

    setState(() {
      _blitzStage++;
      _blitzSplashStage = _blitzStage + 1;
      _blitzShowingSplash = true;
    });

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    setState(() => _blitzShowingSplash = false);
    await _loadLevelAsync(0);
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

  Future<void> _showDailyRunResult({
    required bool completed,
    required String modeName,
  }) async {
    if (!mounted) return;

    if (completed) {
      setState(() => _showingComplete = true);
    } else {
      setState(() => _showingGameOver = true);
    }

    final durationSec = _runStartTime != null
        ? DateTime.now().difference(_runStartTime!).inSeconds
        : 0;
    final cleared = _gameState?.clearedRushArrows ?? 0;

    final progressRepo = ref.read(progressRepositoryProvider);
    final playerLevel = progressRepo.currentLevel;
    final double progressionMultiplier = (1.0 + (playerLevel / 200.0)).clamp(1.0, 3.0);

    final int arrows;
    final int lcRaw;
    switch (widget.gameMode) {
      case GameMode.endlessRush:
        arrows = cleared;
        lcRaw = LeaderCoins.forArrowRush(
          arrowsCleared: cleared,
          failedTaps: _runFailedTaps,
          itemsUsed: _runTotalItemsUsed,
          durationSeconds: durationSec,
          difficultyMultiplier:
          LeaderCoins.difficultyMultiplier(widget.rushDifficulty.index),
        );
        break;
      case GameMode.blitz:
        arrows = _blitzArrowsCleared;
        lcRaw = LeaderCoins.forBlitz(
          blitzScore: _blitzScore,
          failedTaps: _runFailedTaps,
          itemsUsed: _runTotalItemsUsed,
          arrowsCleared: arrows,
        );
        break;
      case GameMode.timeBlitz:
        arrows = _timeBlitzScore;
        lcRaw = LeaderCoins.forTimeBlitz(
          arrowsCleared: _timeBlitzScore,
          failedTaps: _runFailedTaps,
          itemsUsed: _runTotalItemsUsed,
        );
        break;
      default:
        arrows = 0;
        lcRaw = 0;
    }

    final int scaledLcRaw = (lcRaw * progressionMultiplier).round();
    final lc = LeaderCoins.applyRunCap(
      scaledLcRaw,
      mode: widget.gameMode,
      difficultyIndex: widget.rushDifficulty.index,
    );
    final wasCapped = lc < scaledLcRaw;

    _awardLc(
      lc: lc,
      arrowsCleared: arrows,
      failedTaps: _runFailedTaps,
      itemsUsed: _runTotalItemsUsed,
      durationSeconds: durationSec,
    );

    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final strings = AppStrings.of(context);
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
                  modeName,
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
                        'LC',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+$lc',
                        style: const TextStyle(
                          color: Color(0xFF58A6FF),
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      if (wasCapped) ...[
                        const SizedBox(height: 6),
                        Text(
                          strings.gameCapped(_difficultyLabel()),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        label: 'Time',
                        value: timeStr,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCell(
                        label: strings.inventoryTabArrows,
                        value: '$arrows',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
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

  Widget _statCell({
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textSecondary,
              fontSize: 10,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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

      final int remaining = _gameState?.arrows.length ?? 0;
      final int clearedInStage = _level.arrows.length - remaining;

      _blitzScore += clearedInStage * 5;
      _blitzArrowsCleared += clearedInStage;

      if (_blitzStage == 0 && remaining == 1) {
        _blitzScore += 50;
      }

      _showDailyRunResult(
        completed: false,
        modeName: AppStrings.of(context).blitzTitle,
      );
      return;
    }

    if (widget.gameMode == GameMode.endlessRush) {
      _showDailyRunResult(
        completed: false,
        modeName: AppStrings.of(context).arrowRushTitle,
      );
      return;
    }

    setState(() => _showingGameOver = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showGameOverDialog();
    });
  }

  Future<void> _handleRestart() async {
    _endlessLastStandLocked = false;
    _resetRunTracking();

    if (widget.gameMode == GameMode.blitz) {
      setState(() {
        _showingGameOver = false;
        _showingComplete = false;
        _blitzStage = 0;
        _blitzScore = 0;
        _blitzArrowsCleared = 0;
        _loadedLevelNum = 1;
        _lastFitKey = null;
        _blitzRunSeed = DateTime.now().microsecondsSinceEpoch;
        _transformationController.value = Matrix4.identity();
      });
      await _loadLevelAsync(0);
      return;
    }

    if (!mounted) return;

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

    // ── ADD THIS ──
    // Re-seed the leaving arrows for Classic mode after a restart
    if (widget.gameMode == GameMode.classic) {
      final count = _leavingArrowsForLevel(_level.levelNumber);
      if (count > 0) {
        _gameState!.seedLeavingArrows(count: count);
      }
    }
    // ──────────────
  }

  Future<void> _useItem(ItemType item) async {
    if (widget.gameMode == GameMode.zen ||
        widget.gameMode == GameMode.timeBlitz) {
      return;
    }

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
      case ItemType.undo:
        maxUses = 999;
        break;
      case ItemType.bomb:
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
          StatusFlash.fail(context, strings.heartsAlreadyFull);
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
            StatusFlash.fail(context, strings.timeFreezeWait(wait));
            return;
          }
        }
        setState(() => _timeRemaining += 30);
        break;

      case ItemType.bomb:
        if (_gameState!.isBombArmed) {
          _gameState!.setBombArmed(false);
          _rocksBeforeBomb = 0;
          StatusFlash.fail(context, strings.bombDeselected, true);
          return;
        }
        if (_gameState!.rocks.isEmpty) {
          StatusFlash.fail(context, strings.noMinesToDestroy, true);
          return;
        }
        _rocksBeforeBomb = _gameState!.rocks.length;
        _gameState!.setBombArmed(true);
        return;

      case ItemType.hint:
        final arrowId = _gameState!.findNextSolvableArrowId();
        if (arrowId == null) {
          StatusFlash.fail(context, strings.noSolvableArrowFound);
          return;
        }
        _gameState!.setHintArrow(arrowId);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _gameState?.setHintArrow(null);
        });
        break;

      case ItemType.undo when widget.gameMode == GameMode.endlessRush && _endlessLastStandLocked:
        StatusFlash.fail(context, strings.nothingToUndo);
        return;

      case ItemType.undo:
        final ok = _gameState!.undoLastExit();
        if (!ok) {
          StatusFlash.fail(context, strings.nothingToUndo);
          return;
        }
        break;
    }

    await coinsRepo.spendItem(item);
    if (!mounted) return;
    setState(() {
      _itemUsesThisLevel[item] = currentUses + 1;
    });
    _runTotalItemsUsed++;
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

  Future<void> _debugSolveLevel() async {
    if (!mounted || _showingComplete || _showingGameOver) return;

    final gs = _gameState;
    if (gs == null) return;

    AudioHapticHelper.playClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).gameSolverCalculating)),
    );

    final solution = LevelSolver.solve(gs.level, 200000);

    if (solution == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF5252),
          content: Text(AppStrings.of(context).gameSolverUnsolvable),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    for (final arrowId in solution) {
      if (!mounted) return;

      final arrowIndex = gs.arrows.indexWhere((a) => a.id == arrowId);
      if (arrowIndex == -1) continue;

      gs.arrows.removeAt(arrowIndex);
      gs.refresh();

      await Future.delayed(const Duration(milliseconds: 30));
    }

    _onLevelComplete();
  }

  void _debugWinLevel() {
    if (!mounted) return;
    if (_showingComplete || _showingGameOver) return;

    AudioHapticHelper.playClick();

    if (widget.gameMode == GameMode.classic ||
        widget.gameMode == GameMode.zen ||
        widget.gameMode == GameMode.timeAttack) {
      final gs = _gameState;
      if (gs != null) {
        while (gs.arrows.isNotEmpty) {
          final id = gs.arrows.first.id;
          gs.arrows.removeWhere((a) => a.id == id);
        }
        gs.cancelAllTelegraphs();
        gs.refresh();
      }
    }

    _onLevelComplete();
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

    if (_isLcMode) {
      _levelTimer?.cancel();
      _endlessSpawnTimer?.cancel();

      _showDailyRunResult(
        completed: false,
        modeName: _getLcModeName(),
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  String _getLcModeName() {
    switch (widget.gameMode) {
      case GameMode.endlessRush:
        return AppStrings.of(context).arrowRushTitle;
      case GameMode.blitz:
        return AppStrings.of(context).blitzTitle;
      case GameMode.timeBlitz:
        return AppStrings.of(context).gameModeTimeBlitz;
      default:
        return '';
    }
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
        gameMode: widget.gameMode,
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
    _transformationController.removeListener(_onTransformChanged);
    MusicPlayer.instance.play(MusicPlayer.trackMenu);
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

  int _calculateTimedLevelDuration(int levelNum, int totalArrows) {
    final progress = (levelNum / 500.0).clamp(0.0, 1.0);
    final baseSeconds = 12.0 - progress * 6.0;
    final perArrow = 2.2 - progress * 0.9;
    return (baseSeconds + perArrow * totalArrows).round();
  }

  void _resetTimerForLevel() {
    if (widget.gameMode == GameMode.blitz) return;

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

    if (widget.gameMode == GameMode.timeBlitz) {
      _levelTimer?.cancel();
      _showDailyRunResult(
        completed: false,
        modeName: AppStrings.of(context).gameModeTimeBlitz,
      );
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
    final strings = AppStrings.of(context);

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
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        // Semi-transparent background so the board shows through slightly
                        color: AppColors.surface(context).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        // Subtle border to separate it from the board
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        // Drop shadow to make it float above the board
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GameTopBar(
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
                              if (widget.gameMode == GameMode.timeBlitz)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _timeRemaining <= 10
                                          ? Colors.redAccent
                                          : Colors.orangeAccent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_timeRemaining <= 10
                                            ? Colors.redAccent
                                            : Colors.orangeAccent)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_rounded,
                                        color: _timeRemaining <= 10
                                            ? Colors.redAccent
                                            : Colors.orangeAccent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_timeRemaining',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        strings.unitSeconds,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                TimerDisplay(
                                  timeRemaining: _timeRemaining,
                                  totalTime: widget.gameMode == GameMode.timeAttack
                                      ? 99
                                      : _totalTime,
                                ),
                              Positioned(
                                top: 50,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 60,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      for (final pulse in _timerPulses)
                                        _buildPulseAnimated(pulse),
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
                              _viewportSize = viewportSize;
                              final contentSize = _contentSize;

                              final paddedW =
                              (viewportSize.width - _kBoardPadding * 2.0)
                                  .clamp(1.0, double.infinity);
                              final paddedH =
                              (viewportSize.height - _kBoardPadding * 2.0)
                                  .clamp(1.0, double.infinity);
                              final fitScale = min(
                                paddedW / contentSize,
                                paddedH / contentSize,
                              );

                              final minScale =
                              (fitScale * 0.6).clamp(0.05, 1.0);
                              final maxScale = max(3.0, fitScale * 4.0);

                              final liveGridSize =
                                  _gameState?.level.gridSize ?? _level.gridSize;
                              final fitKey = Object.hash(
                                _gameState?.level.levelNumber ??
                                    _level.levelNumber,
                                liveGridSize,
                                viewportSize.width,
                                viewportSize.height,
                              );
                              if (_lastFitKey != fitKey) {
                                _lastFitKey = fitKey;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
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
                                        constrained: false,
                                        minScale: minScale,
                                        maxScale: maxScale,
                                        boundaryMargin:
                                        EdgeInsets.all(contentSize),
                                        clipBehavior: Clip.hardEdge,
                                        onInteractionStart: (_) {
                                          _fitAnimController.stop();
                                          _isInteracting = true;
                                        },
                                        onInteractionEnd: (_) {
                                          _isInteracting = false;
                                        },
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
                          if (widget.gameMode != GameMode.zen &&
                              widget.gameMode != GameMode.timeBlitz)
                            PositionedDirectional(
                              start: 12,
                              bottom: 12,
                              child: GameItemBar(
                                isTimedLevel: _totalTime > 0 ||
                                    widget.gameMode == GameMode.timeAttack,
                                hasRocks:
                                (_gameState?.rocks.isNotEmpty) ?? false,
                                usesThisLevel: _itemUsesThisLevel,
                                isBombArmed: _gameState?.isBombArmed ?? false,
                                onUseItem: _useItem,
                              ),
                            ),
                          if (kDebugMode) ...[
                            PositionedDirectional(
                              end: 12,
                              bottom: 52,
                              child: GestureDetector(
                                onTap: _debugSolveLevel,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C853)
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        strings.gameBtnSolve,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              end: 12,
                              bottom: 12,
                              child: GestureDetector(
                                onTap: _debugWinLevel,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935)
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.bolt_rounded,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        strings.gameBtnWin,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_gameState?.hasActiveLeavingArrow == true)
                            PositionedDirectional(
                              top: 8,
                              start: 12,
                              child: LeavingArrowCounter(
                                count: _gameState!.leavingArrowTapCount,
                                max: _gameState!.leavingArrowTapLimit,
                                color: const Color(0xFFFF9800),
                                onTap: _centerOnLeavingArrow,
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
                    ? null
                    : _handlePauseRestart,
                onMainMenu: _handlePauseMainMenu,
                mainMenuLabel: _isLcMode
                    ? 'Retire'
                    : AppStrings.of(context).homeButton,
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
                        AppStrings.of(context).blitzTimeLeftLabel,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_timeRemaining',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          height: 1,
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

  String _difficultyLabel() {
    final strings = AppStrings.of(context);
    switch (widget.rushDifficulty) {
      case RushDifficulty.easy:
        return strings.difficultyEasy;
      case RushDifficulty.hard:
        return strings.difficultyHard;
      case RushDifficulty.impossible:
        return strings.difficultyImpossible;
    }
  }

  bool get _isLevelReady => _gameState != null;
}

class _TimerPulse {
  final int id;
  final String text;
  final Color color;
  final int slot;

  const _TimerPulse({
    required this.id,
    required this.text,
    required this.color,
    required this.slot,
  });
}