import 'dart:async';
import 'dart:math' as math;
import 'package:arrow_puzzle/screens/multiplayer/providers/challenge_provider.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../data/level_generator/level_generator.dart';
import '../../data/models/level.dart';
import '../../game/arrow_puzzle_game.dart';
import '../../game/game_state.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/custom_pop_dialog.dart';
import '../../widgets/pop_dialog.dart';
import '../game/widgets/telegraph_overlay.dart';
import 'models/mp_match_config.dart';
import 'widgets/mp_diagonal_player_card.dart';

class MpGameScreen extends ConsumerStatefulWidget {
  final MpMatchConfig config;
  final LevelModel? pregeneratedLevel;
  final String p1Name;
  final String p2Name;

  const MpGameScreen({
    super.key,
    required this.config,
    this.pregeneratedLevel,
    required this.p1Name,
    required this.p2Name,
  });

  @override
  ConsumerState<MpGameScreen> createState() => _MpGameScreenState();
}

class _MpGameScreenState extends ConsumerState<MpGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late LevelModel _level;
  late ArrowPuzzleGame _game;
  GameState? _gameState;
  bool _isPaused = false;

  late int _remainingSeconds;
  Timer? _gameTimer;

  // 👈 Only use these two variables for scores
  int _myCleared = 0;
  int _opponentCleared = 0;
  int _totalArrows = 0;
  bool _isFinished = false;
  String _winnerTitle = '';

  bool get isP1 => widget.config.hostId == ref.read(authServiceProvider).userId;

  BuildContext? _retireDialogContext;

  static const double _kCellPx = 64.0;
  static const double _kBoardPadding = 24.0;
  Object? _lastFitKey;
  Size _viewportSize = Size.zero;
  bool _isInteracting = false;

  Matrix4? _fromFitMatrix;
  Matrix4? _toFitMatrix;
  late final AnimationController _fitAnimController;

  final TransformationController _transformationController = TransformationController();

  double get _cellPx => _kCellPx;
  double get _contentSize => (_level.gridSize) * _cellPx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 👈 NEW: Activate match guard as soon as the game screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengeProvider.notifier).setInMatch(true);
    });

    _transformationController.addListener(_onTransformChanged);
    _fitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(_onFitAnimTick);

    _level = widget.pregeneratedLevel ??
        LevelGenerator.generateMultiplayerLevel(
          widget.config.hostLevel,
          widget.config.matchSeed,
          difficulty: widget.config.difficulty,
        );

    _remainingSeconds = widget.config.matchTimeSeconds;
    _initFlameGame();
    _startMatchTimer();
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

  void _applyFitTransform({
    required Size viewportSize,
    required double contentSize,
    required double fitScale,
  }) {
    final tx = (viewportSize.width - contentSize * fitScale) / 2.0;
    final ty = (viewportSize.height - contentSize * fitScale) / 2.0;

    final target = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(fitScale, fitScale, 1.0, 1.0);

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
    _transformationController.value = Matrix4Tween(begin: from, end: to).lerp(t);
  }

  void _initFlameGame() {
    final progress = ref.read(progressRepositoryProvider);

    _totalArrows = _level.arrows.length;

    _gameState = GameState(
      level: _level,
      initialLives: 999,
      theme: progress.selectedTheme,
      boardTheme: progress.selectedBoard,
      arrowSpeed: progress.arrowSpeed,
      onLevelComplete: () => _finishMatch(winnerName: isP1 ? widget.p1Name : widget.p2Name),
      onGameOver: () {},
      onLifeLost: () {},
      onCameraShake: () {},
    );

    _gameState!.addListener(_onGameStateChanged);

    _game = ArrowPuzzleGame(
      level: _level,
      gameState: _gameState!,
      onLevelComplete: () => _finishMatch(winnerName: isP1 ? widget.p1Name : widget.p2Name),
      onGameOver: () {},
      onLifeLost: () {},
    );
  }

  void _onGameStateChanged() {
    if (!mounted || _isFinished || _gameState == null) return;

    final activeArrows = _gameState!.arrows.length;
    if (_totalArrows == 0 && activeArrows > 0) _totalArrows = activeArrows;

    final cleared = (_totalArrows - activeArrows).clamp(0, _totalArrows);

    if (cleared != _myCleared) {
      setState(() {
        _myCleared = cleared;
        if (_totalArrows > 0 && _myCleared >= _totalArrows) {
          _finishMatch(winnerName: isP1 ? widget.p1Name : widget.p2Name);
        }
      });
      ref.read(challengeProvider.notifier).updateMatchProgress(cleared, isP1);
    }
  }

  void _finishMatch({required String winnerName, bool isRetire = false}) {
    if (_isFinished) return;
    _gameTimer?.cancel();

    if (_retireDialogContext != null && _retireDialogContext!.mounted) {
      Navigator.pop(_retireDialogContext!);
    }

    final isDraw = winnerName == 'DRAW (Equal Cleared)';

    // Determine if the LOCAL player won
    final localPlayerWon = !isDraw && (
        (isP1 && winnerName == widget.p1Name) ||
            (!isP1 && winnerName == widget.p2Name)
    );

    String winnerId = 'draw';
    if (!isDraw) {
      winnerId = winnerName == widget.p1Name ? widget.config.hostId : widget.config.guestId;
    }

    // Sync to Appwrite
    ref.read(challengeProvider.notifier).finishMatch(winnerId, isP1);

    // if (localPlayerWon && !isRetire) {
    //   _myCleared = _totalArrows;
    //   AudioHapticHelper.playSuccess(isLast: true);
    // }

    setState(() {
      _isFinished = true;
      if (isDraw) {
        _winnerTitle = 'DRAW!';
      } else if (isRetire) {
        _winnerTitle = 'RETIRED';
      } else {
        _winnerTitle = localPlayerWon ? 'VICTORY!' : 'DEFEAT';
      }
    });

    // 👈 CALCULATE EXACT WINNER NAME AND SCORE
    final String winnerDisplayName = isDraw
        ? (isP1 ? widget.p1Name : widget.p2Name)
        : (localPlayerWon ? (isP1 ? widget.p1Name : widget.p2Name) : (isP1 ? widget.p2Name : widget.p1Name));

    // 👈 This grabs the live score accurately based on who won
    final int winnerDisplayCleared = isDraw
        ? _myCleared
        : (localPlayerWon ? _myCleared : _opponentCleared);

    final navigator = Navigator.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MpResultDialog(
        title: _winnerTitle,
        isVictory: localPlayerWon,
        isDraw: isDraw,
        isRetire: isRetire,
        winnerName: winnerDisplayName, // Passes the real winner
        winnerCleared: winnerDisplayCleared, // Passes the real score
        totalArrows: _totalArrows,
        onExit: () {
          AudioHapticHelper.playClick();

          // 👈 NEW: Lift the guard ONLY when the results card is dismissed
          ref.read(challengeProvider.notifier).setInMatch(false);

          ref.read(challengeProvider.notifier).resetChallengeState(); // Cleanup
          navigator.pop(); // Close dialog
          navigator.pop(); // Exit game screen
        },
      ),
    );
  }

  void _startMatchTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _evalTimeOutWinner();
        }
      });
    });
  }

  void _evalTimeOutWinner() {
    if (_isFinished) return;
    // 👈 USE _myCleared and _opponentCleared
    if (_myCleared > _opponentCleared) {
      _finishMatch(winnerName: isP1 ? widget.p1Name : widget.p2Name);
    } else if (_opponentCleared > _myCleared) {
      _finishMatch(winnerName: isP1 ? widget.p2Name : widget.p1Name);
    } else {
      _finishMatch(winnerName: 'DRAW (Equal Cleared)');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 👈 NEW: Fallback in case user force-exits the screen
    try {
      ref.read(challengeProvider.notifier).setInMatch(false);
    } catch (_) {}

    _transformationController.removeListener(_onTransformChanged);
    _fitAnimController.dispose();
    _transformationController.dispose();
    _gameState?.removeListener(_onGameStateChanged);
    _gameTimer?.cancel();
    super.dispose();
  }

  // 👈 NEW: Handle App Lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isFinished) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // App went to background (e.g., incoming call)
      if (!_isPaused) {
        setState(() => _isPaused = true);
        _gameTimer?.cancel(); // Pause the timer
        _showMatchOnHold();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      if (_isPaused) {
        setState(() => _isPaused = false);
        Navigator.of(context, rootNavigator: true).pop(); // Close the hold dialog
        _startMatchTimer(); // Resume the timer
      }
    } else if (state == AppLifecycleState.detached) {
      // App is being killed/closed -> Treat as Retire
      _finishMatch(
        winnerName: isP1 ? widget.p2Name : widget.p1Name,
        isRetire: true,
      );
    }
  }

  // 👈 NEW: The "Match on Hold" Overlay
  void _showMatchOnHold() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopDialog(
        child: Container(
          padding: const EdgeInsets.all(28),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: Colors.orange, size: 64),
              const SizedBox(height: 20),
              Text(
                'MATCH ON HOLD',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context)),
              ),
              const SizedBox(height: 12),
              Text(
                'Return to the game to resume.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    // 👈 LISTEN FOR OPPONENT PROGRESS
    ref.listenManual(challengeProvider.select((s) => isP1 ? s.p2Cleared : s.p1Cleared), (prev, next) {
      if (mounted && next != _opponentCleared) {
        setState(() {
          _opponentCleared = next;
          if (_totalArrows > 0 && _opponentCleared >= _totalArrows) {
            _finishMatch(winnerName: isP1 ? widget.p1Name : widget.p2Name);
          }
        });
      }
    });

    // 👈 LISTEN FOR MATCH FINISH FROM THE OTHER PLAYER
    ref.listenManual(challengeProvider.select((s) => s.winnerId), (prev, next) {
      if (next != null && next.isNotEmpty && !_isFinished && mounted) {
        final isDraw = next == 'draw';
        final isP1Win = next == widget.config.hostId;
        final winnerName = isDraw ? 'DRAW (Equal Cleared)' : (isP1Win ? widget.p1Name : widget.p2Name);

        _finishMatch(winnerName: winnerName);
      }
    });

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildProgressSide(
                      name: isP1 ? widget.p1Name : widget.p2Name,
                      cleared: _myCleared,
                      total: _totalArrows,
                      color: const Color(0xFF00C853),
                      isLeft: true,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _remainingSeconds <= 5 ? Colors.red.withValues(alpha: 0.2) : accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: _remainingSeconds <= 5 ? Colors.red : accent, width: 2),
                    ),
                    child: Text(
                      '$_remainingSeconds${strings.unitSeconds}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _remainingSeconds <= 5 ? Colors.red : textPrimary),
                    ),
                  ),
                  Expanded(
                    child: _buildProgressSide(
                      name: isP1 ? widget.p2Name : widget.p1Name,
                      cleared: _opponentCleared,
                      total: _totalArrows,
                      color: const Color(0xFFFF5252),
                      isLeft: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
                          _viewportSize = viewportSize;
                          final contentSize = _contentSize;

                          final paddedW = (viewportSize.width - _kBoardPadding).clamp(1.0, double.infinity);
                          final paddedH = (viewportSize.height - _kBoardPadding).clamp(1.0, double.infinity);

                          final fitScale = math.min(paddedW / contentSize, paddedH / contentSize);
                          final minScale = (fitScale * 0.6).clamp(0.05, 1.0);
                          final maxScale = math.max(3.0, fitScale * 4.0);

                          final fitKey = Object.hash(_level.levelNumber, _level.gridSize, viewportSize.width, viewportSize.height);

                          if (_lastFitKey != fitKey) {
                            _lastFitKey = fitKey;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              _applyFitTransform(viewportSize: viewportSize, contentSize: contentSize, fitScale: fitScale);
                            });
                          }

                          return InteractiveViewer(
                            transformationController: _transformationController,
                            constrained: false,
                            minScale: minScale,
                            maxScale: maxScale,
                            boundaryMargin: EdgeInsets.all(contentSize),
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
                                    key: ValueKey('mp_game_${_level.levelNumber}'),
                                    game: _game,
                                  ),
                                  if (_gameState != null)
                                    ListenableBuilder(
                                      listenable: _gameState!,
                                      builder: (context, _) {
                                        return TelegraphOverlay(gameState: _gameState!, boardSize: contentSize);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (!_isFinished) ...[
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    // 👈 Call the confirmation dialog instead of retiring instantly
                    onTap: _showRetireConfirmation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.30),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            color: Colors.red.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.mpRetire,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.red.shade400,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showRetireConfirmation() {
    AudioHapticHelper.playClick();

    showDialog<void>(
      context: context,
      builder: (ctx) => CustomPopDialog(
        title: 'RETIRE MATCH?', // You can replace with strings.mpRetireConfirmTitle
        message: 'Are you sure you want to retire? Your opponent will instantly be declared the winner.',
        icon: Icon(Icons.flag_rounded, color: Colors.red.shade400, size: 32),
        confirmText: 'RETIRE', // You can replace with strings.mpRetire
        cancelText: 'CANCEL',  // You can replace with strings.buttonCancel
        onConfirm: () {
          // This triggers when the player confirms
          _finishMatch(
            winnerName: isP1 ? widget.p2Name : widget.p1Name,
            isRetire: true,
          );
        },
        onCancel: () {
          // Do nothing, just close the dialog and let them keep playing
        },
      ),
    );
  }

  Widget _buildProgressSide({required String name, required int cleared, required int total, required Color color, required bool isLeft}) {
    final double ratio = total > 0 ? (cleared / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        Text('$cleared / $total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MpResultDialog extends StatelessWidget {
  final String title;
  final bool isVictory;
  final bool isDraw;
  final bool isRetire;
  final String winnerName;
  final int winnerCleared;
  final int totalArrows;
  final VoidCallback onExit;

  const _MpResultDialog({
    required this.title,
    required this.isVictory,
    required this.isDraw,
    required this.isRetire,
    required this.winnerName,
    required this.winnerCleared,
    required this.totalArrows,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    final surface = isDark ? const Color(0xFF1E1E1E) : cs.surface;
    final onSurface = cs.onSurface;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final iconData = isDraw
        ? Icons.handshake_rounded
        : isRetire
        ? Icons.flag_rounded
        : isVictory
        ? Icons.emoji_events_rounded
        : Icons.sports_esports_rounded;

    final iconColor = isDraw
        ? const Color(0xFFFFB300)
        : isRetire
        ? const Color(0xFF9E9E9E)
        : isVictory
        ? const Color(0xFFFFD700)
        : const Color(0xFFFF5252);

    final cardFillAlpha = isDark ? 0.08 : 0.12;
    final cardBorderAlpha = isDark ? 0.35 : 0.45;

    return PopDialog(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 520 : 420,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: accent.withValues(alpha: 0.5),
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
                  Container(
                    width: isTablet ? 80 : 64,
                    height: isTablet ? 80 : 64,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: isTablet ? 44 : 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.w900,
                        color: iconColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 👈 SINGLE WINNER CARD
                  Center(
                    child: SizedBox(
                      width: isTablet ? 360 : 300,
                      child: MpDiagonalPlayerCard(
                        name: winnerName,
                        subtitle: 'Cleared: $winnerCleared / $totalArrows',
                        showReadyBadge: false,
                        color: isDraw ? const Color(0xFFFFB300) : const Color(0xFF00C853),
                        avatarRadius: isTablet ? 28.0 : 22.0,
                        padH: isTablet ? 28 : 16,
                        padV: isTablet ? 20 : 16,
                        cutSize: isTablet ? 60.0 : 45.0,
                        cutCorner: MpCardCutCorner.bottomRight,
                        fillAlpha: cardFillAlpha,
                        borderAlpha: cardBorderAlpha,
                        onSurface: onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 64 : 56,
                    child: ElevatedButton(
                      onPressed: onExit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          strings.mpExitLobby,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}