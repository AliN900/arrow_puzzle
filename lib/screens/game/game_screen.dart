import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../core/constants.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/game_mode.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';
import '../../data/models/level_result.dart';
import '../../data/repositories/progress_repository.dart';
import '../../game/arrow_puzzle_game.dart';
import '../../game/game_state.dart';
import '../../main.dart';

import 'widgets/game_top_bar.dart';
import 'widgets/game_bottom_bar.dart';
import 'widgets/timer_display.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/level_complete_dialog.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/game_dialog_button.dart';
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
    with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  String? _comboText;
  Timer? _comboTimer;

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

  void _triggerCombo() {
    if (_gameState == null) return;
    final combo = _gameState!.comboCount;
    _comboTimer?.cancel();
    setState(() => _comboText = '$combo x COMBO');
    _comboTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _comboText = null);
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

  void _goToNextLevelInPlace() {
    final nextLevel = _level.levelNumber + 1;
    setState(() {
      _showingComplete = false;
      _showingGameOver = false;
      _loadedLevelNum = nextLevel;
    });
    _loadLevelAsync(nextLevel);
  }

  void _initGame() {
    final progress = ref.read(progressRepositoryProvider);
    final isLifeFree = widget.gameMode == GameMode.zen ||
        widget.gameMode == GameMode.timeAttack ||
        progress.heartRemover;
    _lives = isLifeFree ? 999 : AppConstants.maxLives;
    _showingGameOver = false;
    _gameState?.removeListener(_onGameStateChanged);
    _gameState = GameState(
      level: _level,
      theme: progress.selectedTheme,
      heartRemover: progress.heartRemover,
      assistMode: progress.assistMode,
      arrowSpeed: progress.arrowSpeed,
      onLevelComplete: _onLevelComplete,
      onGameOver: _onGameOver,
      onLifeLost: isLifeFree ? () {} : _onLifeLost,
      gameMode: widget.gameMode,
      onCombo: _triggerCombo,
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
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() => _lives = _gameState!.lives);
  }

  void _onLifeLost() {
    if (!mounted) return;
    setState(() => _lives = _gameState!.lives);
  }

  void _onLevelComplete() {
    if (!mounted || _showingComplete) return;
    _levelTimer?.cancel();
    AudioHapticHelper.playSuccess(isLast: true);
    setState(() => _showingComplete = true);

    final progress = ref.read(progressRepositoryProvider);
    final stars = ProgressRepository.calculateStars(_gameState!.livesLost);

    if (!widget.isRandom && widget.gameMode == GameMode.classic) {
      progress.recordLevelComplete(LevelResult(
        levelNumber: _level.levelNumber,
        stars: stars,
        livesLost: _gameState!.livesLost,
        completed: true,
        completedAt: DateTime.now(),
      ));
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
        if (mounted) _showLevelCompleteDialog(stars);
      });
    }
  }

  void _onGameOver() {
    if (!mounted || _showingGameOver) return;
    setState(() => _showingGameOver = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showGameOverDialog();
    });
  }

  Future<void> _handleRestart() async {
    if (mounted) {
      final isLifeFree = widget.gameMode == GameMode.zen ||
          widget.gameMode == GameMode.timeAttack ||
          ref.read(progressRepositoryProvider).heartRemover;
      setState(() {
        _showingGameOver = false;
        _showingComplete = false;
        _game.resetLevel();
        _lives = isLifeFree ? 999 : AppConstants.maxLives;
        _resetTimerForLevel();
      });
    }
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

  Future<bool> _confirmLeaveLevel() async {
    if (_showingComplete || _showingGameOver) return true;
    final progress = ref.read(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: themeColors.accentColor.withValues(alpha: 0.35),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: themeColors.accentColor.withValues(alpha: 0.18),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app_rounded,
                color: themeColors.accentColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Leave Level?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your current level progress will be lost.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              GameDialogButton(
                label: 'Resume',
                icon: Icons.play_arrow_rounded,
                textColor: textPrimary,
                iconColor: themeColors.accentColor,
                onTap: () => Navigator.pop(ctx, false),
              ),
              const SizedBox(height: 10),
              GameDialogButton(
                label: 'Leave',
                icon: Icons.close_rounded,
                textColor: textSecondary,
                iconColor: themeColors.accentColor,
                onTap: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    final shouldLeave = await _confirmLeaveLevel();
    if (!shouldLeave || !mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handleNextLevel() {
    Navigator.pop(context);
    _goToNextLevelInPlace();
  }

  void _handleMenu() {
    Navigator.pop(context);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _showLevelCompleteDialog(int stars) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteDialog(
        level: _level,
        stars: stars,
        isRandom: widget.isRandom,
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
    });
    _loadLevelAsync(1);
  }

  Future<void> _showGameOverDialog() async {
    final levelType = AppConstants.levelTypeFor(_level.levelNumber);
    final hasTimer = (levelType == LevelType.god && _level.levelNumber > 100) ||
        (levelType == LevelType.boss && _level.levelNumber > 200);

    int continueTime = 0;
    if (hasTimer && _gameState != null) {
      final remainingArrows =
          _gameState!.arrows.where((a) => a.state != ArrowState.sliding).length;
      continueTime =
          _calculateContinueDuration(_level.levelNumber, remainingArrows);
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        level: _level,
        isTimeout: _isTimeoutState,
        continueTime: continueTime,
        gameMode: widget.gameMode,
        score: _timeAttackScore,
        onContinue: () {
          Navigator.pop(context);
          setState(() {
            _showingGameOver = false;
            if (_isTimeoutState) {
              _timeRemaining = continueTime;
              _isTimeoutState = false;
              _gameState!.resumeFromTimeout();
              _startLevelTimer();
            } else {
              _gameState!.restoreLife();
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
    WidgetsBinding.instance.removeObserver(this);
    _levelTimer?.cancel();
    _gameState?.removeListener(_onGameStateChanged);
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

  int _calculateContinueDuration(int levelNum, int remainingArrows) {
    final type = AppConstants.levelTypeFor(levelNum);
    if (type == LevelType.god) {
      final secondsPerArrow =
      (2.2 - (levelNum - 100) * (0.7 / 400.0)).clamp(1.5, 2.2);
      return (20.0 + secondsPerArrow * remainingArrows).round();
    } else if (type == LevelType.boss) {
      final secondsPerArrow =
      (2.0 - (levelNum - 200) * (0.6 / 300.0)).clamp(1.4, 2.0);
      return (15.0 + secondsPerArrow * remainingArrows).round();
    }
    return 45;
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
      final hasTimer = (levelType == LevelType.god && _level.levelNumber > 100) ||
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
    final themeColors = AppThemes.getThemeColors(progressState.selectedTheme);

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
        // Android back gesture → open pause menu
        if (!_isPaused && !_showingComplete && !_showingGameOver) {
          _togglePause();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: themeColors.bgGradient),
              child: SafeArea(
                child: Column(
                  children: [
                    GameTopBar(
                      level: _level,
                      isRandom: widget.isRandom,
                      onPause: _togglePause,
                      gameMode: widget.gameMode,
                      score: _timeAttackScore,
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
                          final boardSize = min(
                              constraints.maxWidth, constraints.maxHeight - 16);
                          return Transform.translate(
                            offset: Offset(_shakeOffset, 0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                RepaintBoundary(
                                  child: InteractiveViewer(
                                    minScale: 0.8,
                                    maxScale: 4.0,
                                    boundaryMargin: const EdgeInsets.all(60),
                                    clipBehavior: Clip.hardEdge,
                                    child: Center(
                                      child: SizedBox(
                                        width: boardSize,
                                        height: boardSize,
                                        child: GameWidget(game: _game),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_comboText != null)
                                  Positioned(
                                    top: 20,
                                    child: RepaintBoundary(
                                      child: Text(
                                        _comboText!,
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.accent(context),
                                          letterSpacing: 1.5,
                                          shadows: [
                                            const Shadow(
                                              color: Colors.black87,
                                              blurRadius: 12,
                                              offset: Offset(0, 2),
                                            ),
                                            Shadow(
                                              color: AppColors.accent(context),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                      )
                                          .animate()
                                          .scale(
                                        begin: const Offset(0.5, 0.5),
                                        end: const Offset(1.15, 1.15),
                                        duration: 200.ms,
                                        curve: Curves.elasticOut,
                                      )
                                          .then()
                                          .scale(
                                        begin: const Offset(1.15, 1.15),
                                        end: const Offset(1.0, 1.0),
                                        duration: 100.ms,
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