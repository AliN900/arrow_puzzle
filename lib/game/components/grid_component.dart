import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../core/board_themes.dart';
import '../../core/game_mode.dart';
import '../../data/models/level.dart';
import '../../data/models/arrow.dart';
import '../../core/app_themes.dart';
import '../game_state.dart';
import 'arrow_component.dart';

class GridComponent extends PositionComponent with TapCallbacks {
  final GameState gameState;
  double gridPixelSize;

  final Map<String, ArrowComponent> _arrowComponents = {};
  late Set<String> _mask;
  int _lastOrphanDotsLength = -1;
  final List<({int r, int c, OrphanDotType type})> _parsedOrphanDots = [];

  static final Paint _orphanFillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _orphanStrokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _orphanLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  static final Paint _orphanArrowheadPaint = Paint()..style = PaintingStyle.fill;

  ui.Picture? _cachedDotGridPicture;
  double _entryTime = 0.0;
  bool _entryCompleted = false;


  void _invalidateDotGrid() {
    _cachedDotGridPicture?.dispose();
    _cachedDotGridPicture = null;
  }

  @override
  void onRemove() {
    _invalidateDotGrid();
    super.onRemove();
  }

  GridComponent({
    required this.gameState,
    required this.gridPixelSize,
    required Vector2 position,
  }) : super(position: position);

  double get cellSize => gridPixelSize / gameState.level.gridSize;

  @override
  bool containsLocalPoint(Vector2 point) {
    if (gameState.isBombArmed || gameState.assistMode) {
      return point.x >= -cellSize &&
          point.x <= size.x + cellSize &&
          point.y >= -cellSize &&
          point.y <= size.y + cellSize;
    }
    return super.containsLocalPoint(point);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (gameState.isBombArmed) {
      // ... existing bomb logic ...
      return;
    }

    if (!gameState.assistMode) return;

    final localPos = event.localPosition;
    final c = (localPos.x / cellSize).floor();
    final r = (localPos.y / cellSize).floor();
    final gridSize = gameState.level.gridSize;

    // ── FIX: Instant exact tap check ──
    if (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
      for (final arrow in gameState.arrows) {
        if (arrow.path.any((pt) => pt[0] == r && pt[1] == c)) {
          final arrowComp = _arrowComponents[arrow.id];
          arrowComp?.triggerMove();
          return; // Exit immediately if we hit an exact arrow
        }
      }
    }

    // If they tapped an empty space, fallback to the nearest neighbor
    if (r < -1 || r > gridSize || c < -1 || c > gridSize) return;

    const neighbors = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1],
    ];

    final maxDistSq = cellSize * cellSize;
    String? closestArrowId;
    double minDistanceSq = double.infinity;

    for (final n in neighbors) {
      final nr = r + n[0];
      final nc = c + n[1];
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) continue;

      for (final arrow in gameState.arrows) {
        for (final pt in arrow.path) {
          if (pt[0] == nr && pt[1] == nc) {
            final minX = nc * cellSize;
            final maxX = minX + cellSize;
            final minY = nr * cellSize;
            final maxY = minY + cellSize;

            final dx = localPos.x < minX ? minX - localPos.x : (localPos.x > maxX ? localPos.x - maxX : 0.0);
            final dy = localPos.y < minY ? minY - localPos.y : (localPos.y > maxY ? localPos.y - maxY : 0.0);
            final distSq = dx * dx + dy * dy;

            if (distSq <= maxDistSq && distSq < minDistanceSq) {
              minDistanceSq = distSq;
              closestArrowId = arrow.id;
            }
          }
        }
      }
    }

    if (closestArrowId != null) {
      final arrowComp = _arrowComponents[closestArrowId];
      arrowComp?.triggerMove();
    }
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(gridPixelSize);
    scale = Vector2.all(0.0);
    _refreshMask();
    _buildArrows();
  }

  void _refreshMask() {
    _mask = gameState.level.mask;
  }

  void _speedUpIntersectingArrows(ArrowComponent newArrow) {
    final newPath = newArrow.arrowModel.path;
    final newDir = newArrow.arrowModel.direction;

    for (final comp in _arrowComponents.values) {
      if (comp.isExiting && comp != newArrow) {
        final oldPath = comp.arrowModel.path;
        final oldDir = comp.arrowModel.direction;

        // 1. Check if they are in the same lane and moving the same way
        bool sameLane = false;
        if (newDir == ArrowDirection.up || newDir == ArrowDirection.down) {
          if (oldDir == newDir && newPath[0][1] == oldPath[0][1]) {
            sameLane = true;
          }
        } else if (newDir == ArrowDirection.left || newDir == ArrowDirection.right) {
          if (oldDir == newDir && newPath[0][0] == oldPath[0][0]) {
            sameLane = true;
          }
        }

        // 2. Check if their bodies directly intersect
        final intersects = newPath.any((p1) =>
            oldPath.any((p2) => p1[0] == p2[0] && p1[1] == p2[1]));

        if (sameLane || intersects) {
          comp.speedUpExit();
        }
      }
    }
  }

  void _buildArrows() {
    removeAll(children.whereType<ArrowComponent>());
    _arrowComponents.clear();

    for (final arrow in gameState.arrows) {
      final comp = ArrowComponent(
        arrowModel: arrow,
        cellSize: cellSize,
        gameState: gameState,
        onExitCompleted: () => _arrowComponents.remove(arrow.id),
        speedUpIntersectingArrows: _speedUpIntersectingArrows,
      )..position = Vector2(0, 0);
      _arrowComponents[arrow.id] = comp;
      add(comp);
    }
  }

  void rebuild() {
    _refreshMask();
    _buildArrows();
    _lastOrphanDotsLength = -1;
    _invalidateDotGrid();
  }

  void resize(double newGridPixelSize) {
    gridPixelSize = newGridPixelSize;
    size = Vector2.all(gridPixelSize);
    for (final child in children) {
      if (child is ArrowComponent) child.updateCellSize(cellSize);
    }
    _invalidateDotGrid();
  }

  void _recacheDotGrid() {
    _cachedDotGridPicture?.dispose();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final gridSize = gameState.level.gridSize;
    final cs = cellSize;
    final baseDot = (cs * 0.045).clamp(0.6, 1.6);
    final inR = baseDot;
    final outR = inR * 0.55;

    final boardColors = BoardThemes.get(gameState.boardTheme);
    final dotColor = boardColors.dotColor;

    // Draw the board's signature pattern first
    BoardThemes.paintPattern(
      canvas,
      Rect.fromLTWH(0, 0, gridSize * cs, gridSize * cs),
      boardColors.pattern,
      boardColors.patternColor,
      gameState.boardTheme.index * 9137 + 42,
    );

    final isShaped = gameState.level.maskShape != MaskShape.square;
    if (isShaped) {
      final tilePaint = Paint()
        ..color = dotColor.withValues(alpha: 0.04)
        ..style = PaintingStyle.fill;
      for (final cellKey in _mask) {
        final parts = cellKey.split(',');
        final r = int.parse(parts[0]);
        final c = int.parse(parts[1]);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                c * cs + cs * 0.04, r * cs + cs * 0.04, cs * 0.92, cs * 0.92),
            Radius.circular(cs * 0.16),
          ),
          tilePaint,
        );
      }
    }

    final inPaint = Paint()
      ..color = dotColor.withValues(alpha: isShaped ? 0.28 : 0.24)
      ..style = PaintingStyle.fill;
    final outPaint = Paint()
      ..color = dotColor.withValues(alpha: isShaped ? 0.04 : 0.07)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final inMask = _mask.contains('$r,$c');
        canvas.drawCircle(
          Offset((c + 0.5) * cs, (r + 0.5) * cs),
          inMask ? inR : outR,
          inMask ? inPaint : outPaint,
        );
      }
    }

    _cachedDotGridPicture = recorder.endRecording();
  }

  final List<_Shockwave> _shockwaves = [];

  void addShockwave(Offset center, Color color) {
    _shockwaves.add(_Shockwave(center: center, color: color));
  }

  @override
  void render(Canvas canvas) {
    final cs = cellSize;

    if (_cachedDotGridPicture == null) {
      _recacheDotGrid();
    }
    canvas.drawPicture(_cachedDotGridPicture!);

    for (final sw in _shockwaves) {
      sw.render(canvas, cs);
    }

    final themeColors = AppThemes.getThemeColors(gameState.theme);
    _updateParsedOrphanDots();
    for (final dot in _parsedOrphanDots) {
      _drawOrphanDot(
        canvas,
        Offset((dot.c + 0.5) * cs, (dot.r + 0.5) * cs),
        dot.type,
        cs,
        themeColors,
      );
    }

    // Draw rocks
    for (final rock in gameState.rocks) {
      _drawRock(
        canvas,
        Offset((rock.col + 0.5) * cs, (rock.row + 0.5) * cs),
        cs,
        themeColors,
      );
    }

    super.render(canvas);
  }

  void _updateParsedOrphanDots() {
    final orphanDots = gameState.orphanDots;
    if (_lastOrphanDotsLength == orphanDots.length) return;
    _lastOrphanDotsLength = orphanDots.length;
    _parsedOrphanDots.clear();
    for (final entry in orphanDots.entries) {
      final parts = entry.key.split(',');
      _parsedOrphanDots.add((
        r: int.parse(parts[0]),
        c: int.parse(parts[1]),
        type: entry.value,
      ));
    }
  }

  static void _drawOrphanDot(
      Canvas canvas, Offset center, OrphanDotType type, double cs, ThemeColors themeColors) {
    if (type == OrphanDotType.neutral) return;

    _orphanFillPaint.color = const Color(0xFF2A2A2A);
    canvas.drawCircle(center, cs * 0.38, _orphanFillPaint);

    _orphanStrokePaint
      ..color = themeColors.arrowColor.withValues(alpha: 0.4)
      ..strokeWidth = cs * 0.04;
    canvas.drawCircle(center, cs * 0.38, _orphanStrokePaint);

    final ArrowDirection dir;
    switch (type) {
      case OrphanDotType.up:    dir = ArrowDirection.up;    break;
      case OrphanDotType.down:  dir = ArrowDirection.down;  break;
      case OrphanDotType.left:  dir = ArrowDirection.left;  break;
      case OrphanDotType.right: dir = ArrowDirection.right; break;
      default: return;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(dir.rotationRadians);

    _orphanLinePaint
      ..color = themeColors.arrowColor
      ..strokeWidth = cs * 0.06;
    canvas.drawLine(Offset(-cs * 0.18, 0), Offset(cs * 0.08, 0), _orphanLinePaint);

    final arrowheadPath = Path()
      ..moveTo(cs * 0.24, 0)
      ..lineTo(cs * 0.02, -cs * 0.14)
      ..lineTo(cs * 0.08, 0)
      ..lineTo(cs * 0.02, cs * 0.14)
      ..close();

    _orphanArrowheadPaint.color = themeColors.arrowColor;
    canvas.drawPath(arrowheadPath, _orphanArrowheadPaint);

    canvas.restore();
  }


  void _drawRock(Canvas canvas, Offset center, double cs, ThemeColors themeColors) {
    final bodyRadius = cs * 0.30;        // ball radius
    final spikeLength = cs * 0.11;       // spike sticks out this far

    // ── Soft outer glow — reads as "targetable" on any board ──
    canvas.drawCircle(
      center,
      bodyRadius + spikeLength + cs * 0.10,
      Paint()
        ..color = themeColors.arrowColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── Ground shadow (depth) ──
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, cs * 0.16),
        width: cs * 0.70,
        height: cs * 0.20,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── Spikes (8 around the perimeter) ──
    const spikeCount = 8;
    final spikePaint = Paint()
      ..color = themeColors.arrowColor.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < spikeCount; i++) {
      final angle = (i / spikeCount) * 2 * math.pi - math.pi / 2;

      // Base of the spike sits on the ball's surface, tip sticks out.
      final baseCX = center.dx + math.cos(angle) * bodyRadius * 0.95;
      final baseCY = center.dy + math.sin(angle) * bodyRadius * 0.95;
      final tipX   = center.dx + math.cos(angle) * (bodyRadius + spikeLength);
      final tipY   = center.dy + math.sin(angle) * (bodyRadius + spikeLength);

      // Perpendicular half-width for the spike triangle base.
      final perpX = math.cos(angle + math.pi / 2) * cs * 0.055;
      final perpY = math.sin(angle + math.pi / 2) * cs * 0.055;

      final spike = Path()
        ..moveTo(tipX, tipY)
        ..lineTo(baseCX + perpX, baseCY + perpY)
        ..lineTo(baseCX - perpX, baseCY - perpY)
        ..close();

      canvas.drawPath(spike, spikePaint);
    }

    // ── Ball body ──
    // Radial gradient so light appears to come from the top-left.
    final bodyRect = Rect.fromCircle(center: center, radius: bodyRadius);
    canvas.drawCircle(
      center,
      bodyRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: const [
            Color(0xFF6E6E6E),   // bright spot
            Color(0xFF2E2E2E),   // mid
            Color(0xFF121212),   // deep shadow edge
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bodyRect),
    );

    // ── Rim outline — same colour family as arrows, always visible ──
    canvas.drawCircle(
      center,
      bodyRadius,
      Paint()
        ..color = themeColors.arrowColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cs * 0.045,
    );

    // ── Specular highlight (small bright dot, top-left) ──
    canvas.drawCircle(
      center + Offset(-bodyRadius * 0.38, -bodyRadius * 0.42),
      bodyRadius * 0.22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // ── Secondary soft highlight (adds roundness) ──
    canvas.drawCircle(
      center + Offset(-bodyRadius * 0.30, -bodyRadius * 0.35),
      bodyRadius * 0.42,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (int i = _shockwaves.length - 1; i >= 0; i--) {
      _shockwaves[i].update(dt);
      if (_shockwaves[i].isFinished) {
        _shockwaves.removeAt(i);
      }
    }

    if (!_entryCompleted) {
      _entryTime += dt;
      if (_entryTime >= 0.5) {
        scale = Vector2.all(1.0);
        _entryCompleted = true;
      } else {
        final t = _entryTime / 0.5;
        final double bounce = Curves.easeOutBack.transform(t);
        scale = Vector2.all(bounce);
      }
    }

    // ── Rebuild component map to match gameState.arrows ──
    final currentIds = gameState.arrows.map((a) => a.id).toSet();

    for (final arrow in gameState.arrows) {
      if (!_arrowComponents.containsKey(arrow.id)) {
        final comp = ArrowComponent(
          arrowModel: arrow,
          cellSize: cellSize,
          gameState: gameState,
          onExitCompleted: () => _arrowComponents.remove(arrow.id),
          speedUpIntersectingArrows: _speedUpIntersectingArrows,
        )..position = Vector2(0, 0);

        if (gameState.gameMode == GameMode.endlessRush) {
          comp.startEnterAnimation();
        } else {
          comp.startRestoreAnimation();
        }

        _arrowComponents[arrow.id] = comp;
        add(comp);
      }
    }

    // 2. Remove arrows that escaped
    final gone =
    _arrowComponents.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in gone) {
      _arrowComponents[id]?.removeFromParent();
      _arrowComponents.remove(id);
    }
  }
}

class _Shockwave {
  final Offset center;
  final Color color;
  double progress = 0.0;
  final double duration = 0.35;

  _Shockwave({required this.center, required this.color});

  bool get isFinished => progress >= 1.0;

  void update(double dt) {
    progress += dt / duration;
  }

  void render(Canvas canvas, double cs) {
    final t = progress.clamp(0.0, 1.0);
    final radius = cs * (0.3 + 1.2 * t);
    final alpha = (1.0 - t).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cs * 0.08 * (1.0 - t * 0.5);

    canvas.drawCircle(center, radius, paint);
  }
}