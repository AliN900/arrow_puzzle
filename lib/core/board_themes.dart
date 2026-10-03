import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Which category tab the board appears under.
enum BoardCategory { dark, light }

enum BoardTheme {
  // ---- DARK ----
  minimal,
  nebula,
  blueprint,
  forest,
  ocean,
  ember,
  cosmic,
  geometric,
  gold,
  hacker,
  // ---- LIGHT ----
  paper,
  ice,
  sand,
  cloud,
  mint,
  rose,
  lavender,
  sky,
  pearl,
  honey,
}

enum BoardPattern {
  none,
  stars,
  blueprint,
  leaves,
  waves,
  embers,
  cosmic,
  geometric,
  sparkles,
  matrix,
  paper,
  frost,
  sand,
  clouds,
  grass,
  petals,
  bubbles,
  sky,
  pearl,
  honeycomb,
}

class BoardColors {
  final LinearGradient gradient;
  final Color dotColor;
  final Color patternColor;
  final BoardPattern pattern;
  final BoardCategory category;
  final int unlockLevel;

  const BoardColors({
    required this.gradient,
    required this.dotColor,
    required this.patternColor,
    required this.pattern,
    required this.category,
    required this.unlockLevel,
  });
}

class BoardThemes {
  BoardThemes._();

  static BoardColors get(BoardTheme theme) {
    switch (theme) {
    // ============================================================
    // DARK BOARDS
    // ============================================================

      case BoardTheme.minimal:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1D21), Color(0xFF121315)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF6E727A),
          patternColor: Color(0xFF6E727A),
          pattern: BoardPattern.none,
          category: BoardCategory.dark,
          unlockLevel: 0,
        );

      case BoardTheme.nebula:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF2A1254), Color(0xFF0A0518)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFFB39DFF),
          patternColor: Color(0xFFE0C7FF),
          pattern: BoardPattern.stars,
          category: BoardCategory.dark,
          unlockLevel: 10,
        );

      case BoardTheme.blueprint:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2540), Color(0xFF05172E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF63B3ED),
          patternColor: Color(0xFF7FC7FF),
          pattern: BoardPattern.blueprint,
          category: BoardCategory.dark,
          unlockLevel: 25,
        );

      case BoardTheme.forest:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF15331A), Color(0xFF071208)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF8FBC8F),
          patternColor: Color(0xFF9CD89C),
          pattern: BoardPattern.leaves,
          category: BoardCategory.dark,
          unlockLevel: 50,
        );

      case BoardTheme.ocean:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF063E5C), Color(0xFF02121F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF4DD0E1),
          patternColor: Color(0xFF7FE7F5),
          pattern: BoardPattern.waves,
          category: BoardCategory.dark,
          unlockLevel: 75,
        );

      case BoardTheme.ember:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF3B1508), Color(0xFF140604)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFFFF7043),
          patternColor: Color(0xFFFFB74D),
          pattern: BoardPattern.embers,
          category: BoardCategory.dark,
          unlockLevel: 100,
        );

      case BoardTheme.cosmic:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF10002B), Color(0xFF1A0033)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFFCE93D8),
          patternColor: Color(0xFFFFFFFF),
          pattern: BoardPattern.cosmic,
          category: BoardCategory.dark,
          unlockLevel: 150,
        );

      case BoardTheme.geometric:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2E), Color(0xFF0D0D17)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF9C7CFF),
          patternColor: Color(0xFF7C4DFF),
          pattern: BoardPattern.geometric,
          category: BoardCategory.dark,
          unlockLevel: 200,
        );

      case BoardTheme.gold:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF3A2C10), Color(0xFF171008)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFFFFD54F),
          patternColor: Color(0xFFFFEB3B),
          pattern: BoardPattern.sparkles,
          category: BoardCategory.dark,
          unlockLevel: 300,
        );

      case BoardTheme.hacker:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFF020A02), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF39FF14),
          patternColor: Color(0xFF39FF14),
          pattern: BoardPattern.matrix,
          category: BoardCategory.dark,
          unlockLevel: 400,
        );

    // ============================================================
    // LIGHT BOARDS
    // ============================================================

      case BoardTheme.paper:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F1E8), Color(0xFFE8E2D5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF8B7355),
          patternColor: Color(0xFFA89070),
          pattern: BoardPattern.paper,
          category: BoardCategory.light,
          unlockLevel: 20,
        );

      case BoardTheme.ice:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F4F8), Color(0xFFA8CCD6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF2E4A5A),
          patternColor: Color(0xFFFFFFFF),
          pattern: BoardPattern.frost,
          category: BoardCategory.light,
          unlockLevel: 40,
        );

      case BoardTheme.sand:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFF0E0C0), Color(0xFFD9C29B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF6B5438),
          patternColor: Color(0xFF8B6F44),
          pattern: BoardPattern.sand,
          category: BoardCategory.light,
          unlockLevel: 60,
        );

      case BoardTheme.cloud:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFF0F6FF), Color(0xFFD5E4F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF5A7BA6),
          patternColor: Color(0xFFFFFFFF),
          pattern: BoardPattern.clouds,
          category: BoardCategory.light,
          unlockLevel: 90,
        );

      case BoardTheme.mint:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFE5F5EC), Color(0xFFBFE0CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF3B7A55),
          patternColor: Color(0xFF6BB88A),
          pattern: BoardPattern.grass,
          category: BoardCategory.light,
          unlockLevel: 120,
        );

      case BoardTheme.rose:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFFCE8EE), Color(0xFFEDC5D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF9C4A63),
          patternColor: Color(0xFFD67A93),
          pattern: BoardPattern.petals,
          category: BoardCategory.light,
          unlockLevel: 160,
        );

      case BoardTheme.lavender:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE6F8), Color(0xFFCFC0E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF6C4CB3),
          patternColor: Color(0xFF9D7CD6),
          pattern: BoardPattern.bubbles,
          category: BoardCategory.light,
          unlockLevel: 220,
        );

      case BoardTheme.sky:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFDCEEFF), Color(0xFFA8CDEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF3B5F8F),
          patternColor: Color(0xFFFFFFFF),
          pattern: BoardPattern.sky,
          category: BoardCategory.light,
          unlockLevel: 280,
        );

      case BoardTheme.pearl:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFFAFAF5), Color(0xFFE2E0D0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF7A7A6E),
          patternColor: Color(0xFFB8B5A0),
          pattern: BoardPattern.pearl,
          category: BoardCategory.light,
          unlockLevel: 350,
        );

      case BoardTheme.honey:
        return const BoardColors(
          gradient: LinearGradient(
            colors: [Color(0xFFFBF0D5), Color(0xFFE8CB86)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotColor: Color(0xFF8A5A1E),
          patternColor: Color(0xFFB07A2E),
          pattern: BoardPattern.honeycomb,
          category: BoardCategory.light,
          unlockLevel: 450,
        );
    }
  }

  static List<BoardTheme> get all => BoardTheme.values;

  static List<BoardTheme> byCategory(BoardCategory category) {
    return BoardTheme.values.where((t) => get(t).category == category).toList();
  }

  static void paintPattern(
      Canvas canvas,
      Rect rect,
      BoardPattern pattern,
      Color color,
      int seed,
      ) {
    if (pattern == BoardPattern.none) return;
    final rng = math.Random(seed);
    final w = rect.width;
    final h = rect.height;

    switch (pattern) {
      case BoardPattern.none:
        return;

      case BoardPattern.stars:
        for (int i = 0; i < 40; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.003,
            Paint()..color = color.withValues(alpha: 0.55),
          );
        }
        for (int i = 0; i < 6; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.018,
            Paint()
              ..color = color.withValues(alpha: 0.2)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          );
          canvas.drawCircle(Offset(dx, dy), w * 0.006, Paint()..color = color);
        }

      case BoardPattern.blueprint:
        final step = w / 20;
        final linePaint = Paint()
          ..color = color.withValues(alpha: 0.1)
          ..strokeWidth = w * 0.0015;
        for (double x = rect.left; x <= rect.right; x += step) {
          canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), linePaint);
        }
        for (double y = rect.top; y <= rect.bottom; y += step) {
          canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), linePaint);
        }
        final crossPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = w * 0.002
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 20; i++) {
          final gx = rect.left + (rng.nextInt(20) + 0.5) * step;
          final gy = rect.top + (rng.nextInt(20) + 0.5) * step;
          final s = step * 0.2;
          canvas.drawLine(Offset(gx - s, gy), Offset(gx + s, gy), crossPaint);
          canvas.drawLine(Offset(gx, gy - s), Offset(gx, gy + s), crossPaint);
        }

      case BoardPattern.leaves:
        for (int i = 0; i < 30; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final size = w * 0.008 + rng.nextDouble() * w * 0.01;
          final rot = rng.nextDouble() * math.pi * 2;
          canvas.save();
          canvas.translate(dx, dy);
          canvas.rotate(rot);
          final path = Path()
            ..moveTo(0, -size)
            ..quadraticBezierTo(size, 0, 0, size)
            ..quadraticBezierTo(-size, 0, 0, -size);
          canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.18));
          canvas.restore();
        }

      case BoardPattern.waves:
        final wavePaint = Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.0025
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 8; i++) {
          final y = rect.top + (h / 8) * (i + 0.5);
          final path = Path();
          for (double x = rect.left; x <= rect.right; x += 3) {
            final py = y + math.sin((x / (w / 3)) * 2 * math.pi) * h * 0.015;
            if (x == rect.left) {
              path.moveTo(x, py);
            } else {
              path.lineTo(x, py);
            }
          }
          canvas.drawPath(path, wavePaint);
        }
        for (int i = 0; i < 25; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final r = w * 0.004 + rng.nextDouble() * w * 0.006;
          canvas.drawCircle(
            Offset(dx, dy),
            r,
            Paint()
              ..color = color.withValues(alpha: 0.2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.0015,
          );
        }

      case BoardPattern.embers:
        for (int i = 0; i < 25; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final r = w * 0.003 + rng.nextDouble() * w * 0.005;
          canvas.drawCircle(
            Offset(dx, dy),
            r * 4,
            Paint()
              ..color = color.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          );
          canvas.drawCircle(
            Offset(dx, dy),
            r,
            Paint()..color = color.withValues(alpha: 0.75),
          );
        }

      case BoardPattern.cosmic:
        for (int i = 0; i < 120; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.001,
            Paint()..color = color.withValues(alpha: 0.5),
          );
        }
        for (int i = 0; i < 8; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.02,
            Paint()
              ..color = color.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          );
          canvas.drawCircle(Offset(dx, dy), w * 0.005, Paint()..color = color);
        }

      case BoardPattern.geometric:
        final linePaint = Paint()
          ..color = color.withValues(alpha: 0.12)
          ..strokeWidth = w * 0.002;
        final step = w / 12;
        for (double d = -h; d < w + h; d += step) {
          canvas.drawLine(
            Offset(rect.left + d, rect.top),
            Offset(rect.left + d - h, rect.bottom),
            linePaint,
          );
          canvas.drawLine(
            Offset(rect.left + d, rect.top),
            Offset(rect.left + d + h, rect.bottom),
            linePaint,
          );
        }
        for (int i = 0; i < 12; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final s = w * 0.012;
          final path = Path()
            ..moveTo(dx, dy - s)
            ..lineTo(dx + s, dy)
            ..lineTo(dx, dy + s)
            ..lineTo(dx - s, dy)
            ..close();
          canvas.drawPath(
            path,
            Paint()
              ..color = color.withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.002,
          );
        }

      case BoardPattern.sparkles:
        for (int i = 0; i < 20; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final s = w * 0.008 + rng.nextDouble() * w * 0.008;
          canvas.drawCircle(
            Offset(dx, dy),
            s * 1.8,
            Paint()
              ..color = color.withValues(alpha: 0.2)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
          final path = Path()
            ..moveTo(dx, dy - s)
            ..lineTo(dx + s * 0.25, dy)
            ..lineTo(dx, dy + s)
            ..lineTo(dx - s * 0.25, dy)
            ..close();
          canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.6));
          final path2 = Path()
            ..moveTo(dx - s, dy)
            ..lineTo(dx, dy + s * 0.25)
            ..lineTo(dx + s, dy)
            ..lineTo(dx, dy - s * 0.25)
            ..close();
          canvas.drawPath(path2, Paint()..color = color.withValues(alpha: 0.45));
        }

      case BoardPattern.matrix:
      // Vertical streams of small dots
        final colCount = 15;
        final colWidth = w / colCount;
        for (int c = 0; c < colCount; c++) {
          final x = rect.left + c * colWidth + colWidth / 2;
          final count = 8 + rng.nextInt(15);
          for (int j = 0; j < count; j++) {
            final y = rect.top + rng.nextDouble() * h;
            final alpha = 0.15 + rng.nextDouble() * 0.5;
            canvas.drawCircle(
              Offset(x, y),
              w * 0.003,
              Paint()..color = color.withValues(alpha: alpha),
            );
          }
        }

      case BoardPattern.paper:
      // Subtle grain lines
        final grainPaint = Paint()
          ..color = color.withValues(alpha: 0.06)
          ..strokeWidth = w * 0.001;
        for (int i = 0; i < 40; i++) {
          final y = rect.top + rng.nextDouble() * h;
          final x1 = rect.left + rng.nextDouble() * w * 0.3;
          final x2 = x1 + w * 0.15 + rng.nextDouble() * w * 0.4;
          canvas.drawLine(Offset(x1, y), Offset(x2, y), grainPaint);
        }
        for (int i = 0; i < 30; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.0015,
            Paint()..color = color.withValues(alpha: 0.25),
          );
        }

      case BoardPattern.frost:
        for (int i = 0; i < 60; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.0015,
            Paint()..color = color.withValues(alpha: 0.7),
          );
        }
        final crackPaint = Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.002
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 6; i++) {
          final startX = rect.left + rng.nextDouble() * w;
          final startY = rect.top + rng.nextDouble() * h;
          final path = Path()..moveTo(startX, startY);
          double cx = startX;
          double cy = startY;
          for (int s = 0; s < 4; s++) {
            cx += (rng.nextDouble() - 0.5) * w * 0.1;
            cy += (rng.nextDouble() - 0.5) * h * 0.1;
            path.lineTo(cx, cy);
          }
          canvas.drawPath(path, crackPaint);
        }

      case BoardPattern.sand:
      // Horizontal ripple lines
        final ripplePaint = Paint()
          ..color = color.withValues(alpha: 0.15)
          ..strokeWidth = w * 0.0015;
        for (int i = 0; i < 12; i++) {
          final y = rect.top + (h / 12) * (i + 0.5);
          final path = Path();
          for (double x = rect.left; x <= rect.right; x += 4) {
            final py =
                y + math.sin((x / (w / 4)) * 2 * math.pi) * h * 0.008;
            if (x == rect.left) {
              path.moveTo(x, py);
            } else {
              path.lineTo(x, py);
            }
          }
          canvas.drawPath(path, ripplePaint);
        }
        // Sand grains
        for (int i = 0; i < 80; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.0008,
            Paint()..color = color.withValues(alpha: 0.35),
          );
        }

      case BoardPattern.clouds:
      // Soft white cloud blobs
        for (int i = 0; i < 8; i++) {
          final cx = rect.left + rng.nextDouble() * w;
          final cy = rect.top + rng.nextDouble() * h;
          final blobCount = 4 + rng.nextInt(3);
          for (int j = 0; j < blobCount; j++) {
            final dx = cx + (rng.nextDouble() - 0.5) * w * 0.15;
            final dy = cy + (rng.nextDouble() - 0.5) * h * 0.06;
            canvas.drawCircle(
              Offset(dx, dy),
              w * 0.03 + rng.nextDouble() * w * 0.02,
              Paint()
                ..color = color.withValues(alpha: 0.35)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
            );
          }
        }

      case BoardPattern.grass:
      // Small vertical grass blades
        for (int i = 0; i < 50; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final len = h * 0.015 + rng.nextDouble() * h * 0.02;
          final tilt = (rng.nextDouble() - 0.5) * w * 0.01;
          canvas.drawLine(
            Offset(dx, dy),
            Offset(dx + tilt, dy - len),
            Paint()
              ..color = color.withValues(alpha: 0.35)
              ..strokeWidth = w * 0.002
              ..strokeCap = StrokeCap.round,
          );
        }

      case BoardPattern.petals:
      // Small flower petals
        for (int i = 0; i < 20; i++) {
          final cx = rect.left + rng.nextDouble() * w;
          final cy = rect.top + rng.nextDouble() * h;
          final r = w * 0.012;
          for (int p = 0; p < 5; p++) {
            final angle = (p / 5) * 2 * math.pi;
            final dx = cx + math.cos(angle) * r;
            final dy = cy + math.sin(angle) * r;
            canvas.drawCircle(
              Offset(dx, dy),
              r * 0.7,
              Paint()..color = color.withValues(alpha: 0.2),
            );
          }
          canvas.drawCircle(
            Offset(cx, cy),
            r * 0.5,
            Paint()..color = color.withValues(alpha: 0.35),
          );
        }

      case BoardPattern.bubbles:
        for (int i = 0; i < 30; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          final r = w * 0.008 + rng.nextDouble() * w * 0.015;
          // Ring
          canvas.drawCircle(
            Offset(dx, dy),
            r,
            Paint()
              ..color = color.withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.002,
          );
          // Highlight
          canvas.drawCircle(
            Offset(dx - r * 0.3, dy - r * 0.3),
            r * 0.15,
            Paint()..color = color.withValues(alpha: 0.5),
          );
        }

      case BoardPattern.sky:
      // Soft horizontal gradient wisps
        final wisps = [
          (0.2, 0.15),
          (0.45, 0.1),
          (0.7, 0.18),
          (0.9, 0.12),
        ];
        for (final (yFrac, alpha) in wisps) {
          final y = rect.top + h * yFrac;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(rect.center.dx, y),
              width: w * 0.9,
              height: h * 0.08,
            ),
            Paint()
              ..color = color.withValues(alpha: alpha)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
          );
        }

      case BoardPattern.pearl:
      // Iridescent shimmer lines
        final shimmer = Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = w * 0.0015
          ..style = PaintingStyle.stroke;
        for (int i = 0; i < 15; i++) {
          final y = rect.top + (h / 15) * (i + 0.5);
          final path = Path();
          for (double x = rect.left; x <= rect.right; x += 5) {
            final py = y + math.sin(x / w * math.pi * 2) * h * 0.004;
            if (x == rect.left) {
              path.moveTo(x, py);
            } else {
              path.lineTo(x, py);
            }
          }
          canvas.drawPath(path, shimmer);
        }
        // Fine dots
        for (int i = 0; i < 40; i++) {
          final dx = rect.left + rng.nextDouble() * w;
          final dy = rect.top + rng.nextDouble() * h;
          canvas.drawCircle(
            Offset(dx, dy),
            w * 0.0012,
            Paint()..color = color.withValues(alpha: 0.5),
          );
        }

      case BoardPattern.honeycomb:
      // Hexagonal pattern
        final hexRadius = w / 18;
        final hexHeight = hexRadius * math.sqrt(3);
        final linePaint = Paint()
          ..color = color.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.0018;
        for (double cy = rect.top;
        cy <= rect.bottom + hexHeight;
        cy += hexHeight) {
          for (double cx = rect.left;
          cx <= rect.right + hexRadius * 2;
          cx += hexRadius * 3) {
            final isOffset = ((cy - rect.top) / hexHeight).round().isOdd;
            final xOff = isOffset ? hexRadius * 1.5 : 0;
            final path = Path();
            for (int i = 0; i < 6; i++) {
              final angle = (i / 6) * 2 * math.pi - math.pi / 2;
              final px = cx + xOff + math.cos(angle) * hexRadius;
              final py = cy + math.sin(angle) * hexRadius;
              if (i == 0) {
                path.moveTo(px, py);
              } else {
                path.lineTo(px, py);
              }
            }
            path.close();
            canvas.drawPath(path, linePaint);
          }
        }
    }
  }
}