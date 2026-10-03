import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiField extends StatefulWidget {
  final int count;
  const ConfettiField({super.key, this.count = 80});

  @override
  State<ConfettiField> createState() => _ConfettiFieldState();
}

class _ConfettiFieldState extends State<ConfettiField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _ConfettiPainter(
            progress: _controller.value,
            count: widget.count,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int count;

  _ConfettiPainter({required this.progress, required this.count});

  static const _colors = [
    Color(0xFFFFD54F), // yellow
    Color(0xFFFF5252), // red
    Color(0xFF69F0AE), // green
    Color(0xFF40C4FF), // blue
    Color(0xFFFF4081), // pink
    Color(0xFF7C4DFF), // purple
    Color(0xFFFF9800), // orange
    Color(0xFF18FFFF), // cyan
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(12345);

    for (int i = 0; i < count; i++) {
      final startX = rng.nextDouble();
      final startY = rng.nextDouble();
      final speed = 0.4 + rng.nextDouble() * 1.2;
      final rotationSpeed = (rng.nextDouble() - 0.5) * 6;
      final sizeVar = 4.0 + rng.nextDouble() * 6.0;
      final color = _colors[rng.nextInt(_colors.length)];
      final isStar = rng.nextDouble() < 0.3;
      final initialRotation = rng.nextDouble() * math.pi * 2;
      final swayAmp = 0.02 + rng.nextDouble() * 0.04;

      // Vertical fall
      final y = (startY + progress * speed) % 1.0;

      // Horizontal sway
      final x = (startX + math.sin((progress * 4 + i) * math.pi * 2) * swayAmp) % 1.0;

      // Fade at top and bottom
      final fade = math.min(1.0, math.min(y * 4, (1 - y) * 4));

      final px = x * size.width;
      final py = y * size.height;
      final rot = initialRotation + progress * rotationSpeed * math.pi * 2;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = color.withValues(alpha: fade);

      if (isStar) {
        _drawStar(canvas, sizeVar * 0.9, paint);
      } else {
        // Rectangular piece
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: sizeVar * 1.2,
              height: sizeVar * 0.6,
            ),
            const Radius.circular(1),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2 - math.pi / 2;
      final outerX = math.cos(angle) * r;
      final outerY = math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      final innerAngle = angle + math.pi / 5;
      final innerX = math.cos(innerAngle) * r * 0.45;
      final innerY = math.sin(innerAngle) * r * 0.45;
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}