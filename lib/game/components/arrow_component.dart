import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../core/audio_haptic_helper.dart';
import '../../core/app_themes.dart';
import '../../core/sfx_player.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';
import '../game_state.dart';

class ArrowComponent extends PositionComponent with TapCallbacks {
  ArrowModel arrowModel;
  double cellSize;
  final GameState gameState;
  final VoidCallback? onExitCompleted;

  bool _isAnimating = false;
  bool _isBlockedAnimating = false;

  // ── Block shake state ──
  double _blockShakeTime = 0.0;
  double _blockShakeOffset = 0.0;
  static const double _kBlockShakeDuration = 0.5;   // half a second
  static const double _kBlockShakeAmplitude = 0.12; // fraction of cellSize
  static const double _kBlockShakeFrequency = 45.0; // rad/s ≈ 7 Hz

  // ── Slash steel-shine sweep ──
  // Cycle: 0 → 5.0 seconds. First 1.0s the shine is visible and sweeps
  // head → tail. Remaining 4.0s the arrow sits quiet.
  double _slashShineTime = 0.0;
  static const double _kSlashShineCycleSeconds = 3.0;
  static const double _kSlashShineSweepSeconds = 1.5;

  static const double _kLongPressThreshold = 0.30;
  double _longPressAccum = 0.0;
  bool _isTouchDown = false;
  bool _isPreviewMode = false;
  List<Offset>? _previewPath;
  double _previewPulseTime = 0.0;
  double _leavingPulseTime = 0.0;
  final double _hintPulseTime = 0.0;

  bool _isExiting = false;
  double _exitProgress = 0.0;
  double _exitDuration = 0.35;
  bool _isRestoring = false;
  double _restoreProgress = 0.0;
  double _restoreDuration = 0.5;
  bool _isEntering = false;
  double _enterProgress = 0.0;
  final double _enterDuration = 0.25;

  List<Offset>? _deflectedExtension;

  List<Offset>? _cachedPathPx;
  List<Offset>? _cachedTrack;
  List<double>? _cachedDist;
  double? _cachedHeadDist;
  double? _cachedTailDist;
  Path? _cachedBodyPath;
  Path? _cachedCaretPath;

  void _invalidateCache() {
    _cachedPathPx = null;
    _cachedTrack = null;
    _cachedDist = null;
    _cachedHeadDist = null;
    _cachedTailDist = null;
    _cachedBodyPath = null;
    _cachedCaretPath = null;
    _computeBounds();
  }

  List<Offset> _computePathPx() {
    return arrowModel.path
        .map((pt) =>
        Offset((pt[1] + 0.5) * cellSize, (pt[0] + 0.5) * cellSize))
        .toList();
  }

  static final Paint _bodyPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _glowPaintOuter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _glowPaintInner = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _trailPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _headPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _bladePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  ArrowComponent({
    required this.arrowModel,
    required this.cellSize,
    required this.gameState,
    this.onExitCompleted,
  }) : super(size: Vector2.all(cellSize * gameState.level.gridSize)) {
    _computeBounds();
  }

  void updateCellSize(double newSize) {
    cellSize = newSize;
    size = Vector2.all(newSize * gameState.level.gridSize);
    _invalidateCache();
  }

  int _minR = 0, _maxR = 0, _minC = 0, _maxC = 0;

  void _computeBounds() {
    if (arrowModel.path.isEmpty) return;
    _minR = arrowModel.path[0][0];
    _maxR = _minR;
    _minC = arrowModel.path[0][1];
    _maxC = _minC;
    for (int i = 1; i < arrowModel.path.length; i++) {
      final r = arrowModel.path[i][0];
      final c = arrowModel.path[i][1];
      if (r < _minR) _minR = r;
      if (r > _maxR) _maxR = r;
      if (c < _minC) _minC = c;
      if (c > _maxC) _maxC = c;
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (_isExiting || _isRestoring || _isEntering) return false;
    final col = (point.x / cellSize).floor();
    final row = (point.y / cellSize).floor();
    if (row < _minR || row > _maxR || col < _minC || col > _maxC) {
      return false;
    }
    return arrowModel.path.any((pt) => pt[0] == row && pt[1] == col);
  }

  double _pressScale = 1.0;

  @override
  void onTapDown(TapDownEvent event) {
    _isTouchDown = true;
    _longPressAccum = 0.0;
    _pressScale = 0.93;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressScale = 1.0;
    final wasPreview = _isPreviewMode;
    _isTouchDown = false;
    _longPressAccum = 0.0;
    _isPreviewMode = false;
    _previewPath = null;
    if (wasPreview) return;
    if (_isAnimating) return;
    triggerMove();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressScale = 1.0;
    _isTouchDown = false;
    _longPressAccum = 0.0;
    _isPreviewMode = false;
    _previewPath = null;
  }

  void triggerMove({bool isForced = false}) {
    if (_isAnimating) return;
    _isAnimating = true;

    final result = gameState.tapArrow(arrowModel.id, isForced: isForced);
    switch (result) {
      case TapResult.exited:
        SfxPlayer.instance.playArrowClear();
        AudioHapticHelper.playSuccess(combo: gameState.comboCount);
        _startExitAnimation();
        break;
      case TapResult.blocked:
        SfxPlayer.instance.playArrowBlocked();
        AudioHapticHelper.playFailure();
        _playBlockAnimation();
        break;
      case TapResult.ignored:
        _isAnimating = false;
        break;
    }
  }

  void _startExitAnimation() {
    final double speedMultiplier;
    switch (gameState.arrowSpeed) {
      case 0:
        speedMultiplier = 1.5;
        break;
      case 2:
        speedMultiplier = 0.6;
        break;
      case 1:
      default:
        speedMultiplier = 1.0;
        break;
    }

    final rushDiv = gameState.rushSpeedMultiplier;
    _exitDuration =
        (0.4 + arrowModel.path.length * 0.08) * speedMultiplier / rushDiv;
    _deflectedExtension = _buildDeflectedExtension();

    _exitProgress = 0.0;
    _isExiting = true;
    _invalidateCache();
  }

  void startRestoreAnimation() {
    final double speedMultiplier;
    switch (gameState.arrowSpeed) {
      case 0:
        speedMultiplier = 1.5;
        break;
      case 2:
        speedMultiplier = 0.6;
        break;
      case 1:
      default:
        speedMultiplier = 1.0;
        break;
    }
    _restoreDuration =
        (0.4 + arrowModel.path.length * 0.08) * speedMultiplier /
            gameState.rushSpeedMultiplier;
    _isRestoring = true;
    _restoreProgress = 0.0;
    _isAnimating = true;
    _deflectedExtension = null;
    _invalidateCache();
  }

  void startEnterAnimation() {
    _isEntering = true;
    _enterProgress = 0.0;
    _isAnimating = true;
    _deflectedExtension = null;
    _invalidateCache();
  }

  List<Offset>? _buildDeflectedExtension() {
    final orphanDots = Map<String, OrphanDotType>.from(gameState.orphanDots);
    for (final dot in gameState.getConsumedDotsForArrow(arrowModel.id)) {
      orphanDots[dot.key] = dot.type;
    }
    if (orphanDots.isEmpty) return null;

    ArrowDirection currentDir = arrowModel.direction;
    final head = arrowModel.path[0];
    final gridSize = gameState.level.gridSize;
    final pts = <Offset>[];
    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final visited = <String>{};
    bool hasDeflection = false;

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final key = '$nr,$nc';
      if (visited.contains(key)) break;
      visited.add(key);
      pts.add(Offset((nc + 0.5) * cellSize, (nr + 0.5) * cellSize));

      if (orphanDots.containsKey(key)) {
        final dotType = orphanDots[key]!;
        if (dotType == OrphanDotType.up) {
          hasDeflection = true;
          currentDir = ArrowDirection.up;
        } else if (dotType == OrphanDotType.down) {
          hasDeflection = true;
          currentDir = ArrowDirection.down;
        } else if (dotType == OrphanDotType.left) {
          hasDeflection = true;
          currentDir = ArrowDirection.left;
        } else if (dotType == OrphanDotType.right) {
          hasDeflection = true;
          currentDir = ArrowDirection.right;
        }
      }

      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }

    if (!hasDeflection) return null;

    final int exitExtCount = gridSize + 5;
    for (int i = 0; i <= exitExtCount; i++) {
      pts.add(Offset((nc + d[1] * i + 0.5) * cellSize,
          (nr + d[0] * i + 0.5) * cellSize));
    }

    return pts.reversed.toList();
  }

  // ─────────────────────────────────────────────────────────────────
  // Blocked animation — shake in place, red tint for 0.5 s.
  // ─────────────────────────────────────────────────────────────────

  void _playBlockAnimation() {
    _invalidateCache();
    _isBlockedAnimating = true;
    _blockShakeTime = 0.0;
    _blockShakeOffset = 0.0;
  }

  /// Perpendicular shake axis. Vertical arrows shake horizontally,
  /// horizontal arrows shake vertically — so it reads as bouncing off a
  /// wall rather than sliding along it.
  Offset _blockShakeAxis(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
      case ArrowDirection.down:
        return const Offset(1, 0);
      case ArrowDirection.left:
      case ArrowDirection.right:
        return const Offset(0, 1);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.pendingForceLaunch.contains(arrowModel.id) &&
        !_isAnimating &&
        !_isExiting &&
        !_isRestoring &&
        !_isEntering) {
      gameState.acknowledgeForceLaunch(arrowModel.id);
      triggerMove(isForced: true);
    }

    if (gameState.isArrowLeaving(arrowModel.id) && !_isAnimating) {
      _leavingPulseTime += dt * 4.0;
    }
    if (arrowModel.type == ArrowType.slash &&
        !_isAnimating &&
        !_isExiting &&
        !_isRestoring) {
      _slashShineTime += dt;
      if (_slashShineTime >= _kSlashShineCycleSeconds) {
        _slashShineTime -= _kSlashShineCycleSeconds;
      }
    }

    if (_isEntering) {
      _enterProgress += dt / _enterDuration;
      if (_enterProgress >= 1.0) {
        _isEntering = false;
        _enterProgress = 0.0;
        _isAnimating = false;
        _invalidateCache();
      }
      return;
    }

    if (_isRestoring) {
      _restoreProgress += dt / _restoreDuration;
      if (_restoreProgress >= 1.0) {
        _isRestoring = false;
        _isAnimating = false;
        _invalidateCache();
      }
      return;
    }

    if (_isTouchDown && !_isAnimating && !_isExiting) {
      _longPressAccum += dt;
      if (!_isPreviewMode && _longPressAccum >= _kLongPressThreshold) {
        _isPreviewMode = true;
        _previewPath = _buildPreviewPath();
        AudioHapticHelper.playClick();
      }
      if (_isPreviewMode) {
        _previewPulseTime += dt * 4.0;
      }
    } else {
      _previewPulseTime = 0.0;
    }

    if (_isExiting) {
      _exitProgress += dt / _exitDuration;
      if (_exitProgress >= 1.0) {
        removeFromParent();
        gameState.handleArrowExitCompleted(arrowModel.id);
        onExitCompleted?.call();
        return;
      }
    }

    if (_isBlockedAnimating) {
      _blockShakeTime += dt;

      if (_blockShakeTime >= _kBlockShakeDuration) {
        _isBlockedAnimating = false;
        _isAnimating = false;
        _blockShakeOffset = 0.0;
        _invalidateCache();
      } else {
        // Sinusoidal shake with gentle decay toward the end.
        final t = _blockShakeTime / _kBlockShakeDuration;
        final decay = 1.0 - t * 0.35;
        _blockShakeOffset =
            math.sin(_blockShakeTime * _kBlockShakeFrequency) *
                cellSize *
                _kBlockShakeAmplitude *
                decay;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (arrowModel.path.isEmpty) return;

    final bool isSlashArrow = arrowModel.type == ArrowType.slash;
    final bool hasPressScale = _pressScale != 1.0;
    final bool needsTransform = hasPressScale || _isBlockedAnimating;

    if (needsTransform) {
      canvas.save();

      if (hasPressScale) {
        final head = arrowModel.path[0];
        final center =
        Offset((head[1] + 0.5) * cellSize, (head[0] + 0.5) * cellSize);
        canvas.translate(center.dx, center.dy);
        canvas.scale(_pressScale, _pressScale);
        canvas.translate(-center.dx, -center.dy);
      }

      if (_isBlockedAnimating) {
        final axis = _blockShakeAxis(arrowModel.direction);
        canvas.translate(
          axis.dx * _blockShakeOffset,
          axis.dy * _blockShakeOffset,
        );
      }
    }

    _cachedPathPx ??= _computePathPx();
    final pathPx = _cachedPathPx!;

    final List<Offset> pts;
    final bool isAnimatingNow = _isExiting ||
        _isBlockedAnimating ||
        _isRestoring ||
        _isEntering;

    if (_isRestoring && _cachedTrack == null) {
      final delta = arrowModel.direction.delta;
      final headPx = pathPx.first;
      final track = <Offset>[];
      final int extCount;
      if (_deflectedExtension != null) {
        track.addAll(_deflectedExtension!);
        extCount = _deflectedExtension!.length;
      } else {
        extCount = gameState.level.gridSize + 2;
        for (int i = extCount; i >= 1; i--) {
          track.add(headPx +
              Offset(delta[1] * i * cellSize, delta[0] * i * cellSize));
        }
      }
      track.addAll(pathPx);
      _cachedTrack = track;

      final dist = <double>[0.0];
      for (int i = 1; i < track.length; i++) {
        dist.add(dist[i - 1] + (track[i] - track[i - 1]).distance);
      }
      _cachedDist = dist;
      _cachedHeadDist = dist[extCount];
      _cachedTailDist = dist[extCount + pathPx.length - 1];
    }

    if (_isBlockedAnimating) {
      // No travel — the shake is applied via the canvas transform above.
      pts = pathPx;
    } else if (_isRestoring) {
      final track = _cachedTrack!;
      final dist = _cachedDist!;
      final headDist = _cachedHeadDist!;
      final tailDist = _cachedTailDist!;

      final traveled =
      ((1.0 - _restoreProgress) * tailDist).clamp(0.0, tailDist);
      final animHead = (headDist - traveled).clamp(0.0, headDist);
      final animTail = (tailDist - traveled).clamp(0.0, tailDist);

      pts = _slice(track, dist, animHead, animTail);
    } else if (_isEntering) {
      final track = pathPx;
      final dist = <double>[0.0];
      for (int i = 1; i < track.length; i++) {
        dist.add(dist[i - 1] + (track[i] - track[i - 1]).distance);
      }
      final totalLen = dist.last;
      final p = Curves.easeOutCubic.transform(_enterProgress.clamp(0.0, 1.0));
      pts = _slice(track, dist, 0.0, p * totalLen);
    } else if (isAnimatingNow) {
      if (_cachedTrack == null) {
        final delta = arrowModel.direction.delta;
        final headPx = pathPx.first;

        final track = <Offset>[];
        final int extCount;
        if (_deflectedExtension != null) {
          track.addAll(_deflectedExtension!);
          extCount = _deflectedExtension!.length;
        } else {
          extCount = gameState.level.gridSize + 2;
          for (int i = extCount; i >= 1; i--) {
            track.add(headPx +
                Offset(delta[1] * i * cellSize, delta[0] * i * cellSize));
          }
        }
        track.addAll(pathPx);
        _cachedTrack = track;

        final dist = <double>[0.0];
        for (int i = 1; i < track.length; i++) {
          dist.add(dist[i - 1] + (track[i] - track[i - 1]).distance);
        }
        _cachedDist = dist;
        _cachedHeadDist = dist[extCount];
        _cachedTailDist = dist[extCount + pathPx.length - 1];
      }

      final track = _cachedTrack!;
      final dist = _cachedDist!;
      final headDist = _cachedHeadDist!;
      final tailDist = _cachedTailDist!;

      final double animHead, animTail;
      if (_isExiting) {
        final traveled = (_exitProgress * tailDist).clamp(0.0, tailDist);
        animHead = (headDist - traveled).clamp(0.0, headDist);
        animTail = (tailDist - traveled).clamp(0.0, tailDist);
      } else {
        animHead = headDist;
        animTail = tailDist;
      }

      pts = _slice(track, dist, animHead, animTail);

      if (_isExiting) {
        final consumedDots = gameState.getConsumedDotsForArrow(arrowModel.id);
        for (final dot in consumedDots) {
          final dotPx =
          Offset((dot.col + 0.5) * cellSize, (dot.row + 0.5) * cellSize);
          double? dotDist;
          for (int i = 0; i < track.length; i++) {
            if ((track[i] - dotPx).distanceSquared < 0.01) {
              dotDist = dist[i];
              break;
            }
          }
          if (dotDist != null && animHead > dotDist) {
            _drawOrphanDot(canvas, dotPx, dot.type, cellSize);
          }
        }
      }
    } else {
      pts = pathPx;
    }

    if (pts.isEmpty) {
      if (needsTransform) canvas.restore();
      return;
    }

    final mainColor = _color();
    final sw = cellSize * (isSlashArrow ? 0.18 : 0.13);

    final Path bodyPath;
    if (isAnimatingNow) {
      bodyPath = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        bodyPath.lineTo(pts[i].dx, pts[i].dy);
      }
    } else {
      if (_cachedBodyPath == null) {
        final path = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (int i = 1; i < pts.length; i++) {
          path.lineTo(pts[i].dx, pts[i].dy);
        }
        _cachedBodyPath = path;
      }
      bodyPath = _cachedBodyPath!;
    }

    final themeColors = AppThemes.getThemeColors(gameState.theme);


    if (themeColors.hasGlow && !_isBlockedAnimating) {
      _glowPaintOuter
        ..color = mainColor.withValues(alpha: 0.15)
        ..strokeWidth = sw * 2.2;
      canvas.drawPath(bodyPath, _glowPaintOuter);

      _glowPaintInner
        ..color = mainColor.withValues(alpha: 0.25)
        ..strokeWidth = sw * 1.5;
      canvas.drawPath(bodyPath, _glowPaintInner);
    }

    if (_isExiting || _isBlockedAnimating || _isRestoring) {
      _trailPaint
        ..color = mainColor.withValues(alpha: 0.15)
        ..strokeWidth = sw * 2.0;
      canvas.drawPath(bodyPath, _trailPaint);
    }

    _bodyPaint
      ..color = mainColor
      ..strokeWidth = sw;
    canvas.drawPath(bodyPath, _bodyPaint);

    // ── Slash arrow: white "blade" down the centre ──
    if (isSlashArrow && !_isBlockedAnimating) {
      _bladePaint
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = sw * 0.28;
      canvas.drawPath(bodyPath, _bladePaint);
    }

    // ── Slash arrow: periodic steel shine sweep ──
    if (isSlashArrow && !_isBlockedAnimating && !isAnimatingNow) {
      _drawSlashShine(canvas, bodyPath, sw);
    }

    _drawHead(canvas, pts, mainColor, sw);

    if (gameState.isArrowLeaving(arrowModel.id) &&
        arrowModel.state == ArrowState.idle) {
      final pulse = 0.5 + 0.5 * math.sin(_leavingPulseTime);
      canvas.drawPath(
        bodyPath,
        Paint()
          ..color = const Color(0xFFFF9800)
              .withValues(alpha: 0.35 + pulse * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * 4.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    if (_isPreviewMode) {
      final preview = _previewPath;
      if (preview != null && preview.length >= 2) {
        final isBlocked = gameState.isArrowBlocked(arrowModel.id);
        _drawPreviewPath(canvas, preview, isBlocked);
      }
    }

    if (gameState.hintArrowId == arrowModel.id) {
      final pulse = 0.5 + 0.5 * math.sin(_hintPulseTime * 6);
      canvas.drawPath(
        bodyPath,
        Paint()
          ..color =
          const Color(0xFFFFEB3B).withValues(alpha: 0.5 + pulse * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    if (needsTransform) canvas.restore();
  }

  /// Draws a bright highlight that travels from the arrow's head toward
  /// its tail once every [_kSlashShineCycleSeconds]. The shine starts
  /// loud (thick, bright, with a flare at the head), then tapers off as
  /// it reaches the tail — so the player's eye is caught immediately.
  void _drawSlashShine(Canvas canvas, Path bodyPath, double sw) {
    // Quiet phase — no shine on screen.
    if (_slashShineTime > _kSlashShineSweepSeconds) return;

    final sweepT =
    (_slashShineTime / _kSlashShineSweepSeconds).clamp(0.0, 1.0);

    // Intensity: starts at 1.0, still ~0.65 mid-sweep, ~0.3 at the end.
    // This makes the shine "punch" as soon as it appears.
    final intensity = (1.0 - sweepT * 0.7).clamp(0.0, 1.0);
    if (intensity <= 0.01) return;

    // Streak gets narrower as it travels tail-ward, so the shine reads
    // as a wave cresting away from the head.
    final streakScale = 1.0 - sweepT * 0.55;

    final metrics = bodyPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    // Highlight length along the path — bigger at the start.
    final tailLength = sw * 3.5 * streakScale;

    for (final m in metrics) {
      final total = m.length;
      if (total <= 0) continue;

      final center = sweepT * total;
      final from = (center - tailLength).clamp(0.0, total);
      final to = (center + tailLength).clamp(0.0, total);
      if (to <= from) continue;

      final shine = m.extractPath(from, to);

      // Outer bloom — noticeably bigger and brighter at the start.
      canvas.drawPath(
        shine,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.65 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * 2.6 * streakScale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            sw * 1.4 * streakScale,
          ),
      );

      // Bright core streak.
      canvas.drawPath(
        shine,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.98 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * 0.7 * streakScale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Extra flare at the head during the first 35 % of the sweep.
    // Reads as the shine "igniting" from the arrow's tip.
    if (sweepT < 0.35) {
      final flareT = sweepT / 0.35; // 0 → 1 across the first 35 %
      final flareIntensity = (1.0 - flareT) * (1.0 - flareT);
      if (flareIntensity > 0.01) {
        final head = arrowModel.path[0];
        final headCenter = Offset(
          (head[1] + 0.5) * cellSize,
          (head[0] + 0.5) * cellSize,
        );
        final radius = cellSize * 0.55 * (0.6 + flareT * 0.6);
        canvas.drawCircle(
          headCenter,
          radius,
          Paint()
            ..color =
            Colors.white.withValues(alpha: 0.6 * flareIntensity)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              radius * 0.6,
            ),
        );
      }
    }
  }

  void _drawHead(Canvas canvas, List<Offset> pts, Color mainColor, double sw) {
    final Path caretPath;
    final bool isAnimatingNow = _isExiting ||
        _isBlockedAnimating ||
        _isRestoring ||
        _isEntering;

    if (isAnimatingNow) {
      caretPath = _buildCaretPath(pts, sw);
    } else {
      _cachedCaretPath ??= _buildCaretPath(pts, sw);
      caretPath = _cachedCaretPath!;
    }

    _headPaint
      ..color = mainColor
      ..strokeWidth = sw;
    canvas.drawPath(caretPath, _headPaint);
  }

  Path _buildCaretPath(List<Offset> pts, double sw) {
    final prev = pts.length > 1 ? pts[1] : pts.first;
    final dv = pts.first - prev;
    final len = dv.distance;

    final d = arrowModel.direction.delta;
    final dx = len > 0.01 ? dv.dx / len : d[1].toDouble();
    final dy = len > 0.01 ? dv.dy / len : d[0].toDouble();

    final tip = pts.first + Offset(dx * cellSize * 0.3, dy * cellSize * 0.3);

    final hd = cellSize * 0.25;
    final hw = cellSize * 0.18;

    final base = tip - Offset(dx * hd, dy * hd);
    final px = -dy, py = dx;

    return Path()
      ..moveTo(base.dx + px * hw, base.dy + py * hw)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(base.dx - px * hw, base.dy - py * hw);
  }

  List<Offset>? _buildPreviewPath() {
    final orphanDots = gameState.orphanDots;
    ArrowDirection currentDir = arrowModel.direction;
    final head = arrowModel.path[0];
    final gridSize = gameState.level.gridSize;
    final pts = <Offset>[];

    final headPx =
    Offset((head[1] + 0.5) * cellSize, (head[0] + 0.5) * cellSize);
    pts.add(headPx);

    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final visited = <String>{};

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final key = '$nr,$nc';
      if (visited.contains(key)) break;
      visited.add(key);
      pts.add(Offset((nc + 0.5) * cellSize, (nr + 0.5) * cellSize));

      if (orphanDots.containsKey(key)) {
        final dotType = orphanDots[key]!;
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
          default:
            break;
        }
      }

      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }

    for (int i = 1; i <= 2; i++) {
      pts.add(Offset((nc + d[1] * i + 0.5) * cellSize,
          (nr + d[0] * i + 0.5) * cellSize));
    }

    return pts.isEmpty ? null : pts;
  }

  void _drawPreviewPath(Canvas canvas, List<Offset> preview, bool isBlocked) {
    if (preview.length < 2) return;

    final rawPath = Path()..moveTo(preview.first.dx, preview.first.dy);
    for (int i = 1; i < preview.length; i++) {
      rawPath.lineTo(preview[i].dx, preview[i].dy);
    }

    final Color shadowColor =
    isBlocked ? const Color(0xFF808080) : Colors.white;
    final Color coreColor =
    isBlocked ? const Color(0xFF606060) : Colors.white;

    final double pulse = 0.85 + 0.15 * (1.0 + (0.5 * _previewPulseTime).abs());

    canvas.drawPath(
      rawPath,
      Paint()
        ..color =
        shadowColor.withValues(alpha: (0.25 * pulse).clamp(0.05, 0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.45 * pulse
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      rawPath,
      Paint()
        ..color = coreColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Color _color() {
    // Block animation: red for 0.5 s, then back to normal.
    if (_isBlockedAnimating) {
      return const Color(0xFFE53935);
    }

    if (gameState.isArrowLeaving(arrowModel.id) &&
        arrowModel.state == ArrowState.idle) {
      return const Color(0xFFFF9800);
    }

    if (arrowModel.type == ArrowType.slash) {
      // Brushed gunmetal / steel blue.
      return const Color(0xFFA8B8C4);
    }

    final themeColors = AppThemes.getThemeColors(gameState.theme);
    final palette = themeColors.arrowPalette;
    if (palette != null && palette.isNotEmpty) {
      final idx = arrowModel.id.hashCode.abs() % palette.length;
      return palette[idx];
    }
    return themeColors.arrowColor;
  }

  List<Offset> _slice(
      List<Offset> track, List<double> dist, double from, double to) {
    if (from >= to) {
      if (from == to && track.isNotEmpty) {
        return [_lerp(track, dist, from)];
      }
      return [];
    }
    final pts = <Offset>[_lerp(track, dist, from)];
    for (int i = 0; i < dist.length; i++) {
      if (dist[i] > from && dist[i] < to) pts.add(track[i]);
    }
    pts.add(_lerp(track, dist, to));
    return pts;
  }

  Offset _lerp(List<Offset> track, List<double> dist, double s) {
    if (s <= dist.first) return track.first;
    if (s >= dist.last) return track.last;
    for (int i = 0; i < dist.length - 1; i++) {
      if (s >= dist[i] && s <= dist[i + 1]) {
        final t = (s - dist[i]) / (dist[i + 1] - dist[i]);
        return Offset.lerp(track[i], track[i + 1], t)!;
      }
    }
    return track.last;
  }

  static void _drawOrphanDot(
      Canvas canvas, Offset center, OrphanDotType type, double cs) {
    if (type == OrphanDotType.neutral) return;

    canvas.drawCircle(
      center,
      cs * 0.38,
      Paint()
        ..color = const Color(0xFF2A2A2A)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      cs * 0.38,
      Paint()
        ..color = const Color(0xFF666666)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cs * 0.04,
    );

    final ArrowDirection dir;
    switch (type) {
      case OrphanDotType.up:
        dir = ArrowDirection.up;
        break;
      case OrphanDotType.down:
        dir = ArrowDirection.down;
        break;
      case OrphanDotType.left:
        dir = ArrowDirection.left;
        break;
      case OrphanDotType.right:
        dir = ArrowDirection.right;
        break;
      default:
        return;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(dir.rotationRadians);

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = cs * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(-cs * 0.18, 0), Offset(cs * 0.08, 0), linePaint);

    final arrowheadPath = Path()
      ..moveTo(cs * 0.24, 0)
      ..lineTo(cs * 0.02, -cs * 0.14)
      ..lineTo(cs * 0.08, 0)
      ..lineTo(cs * 0.02, cs * 0.14)
      ..close();

    canvas.drawPath(
      arrowheadPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }
}