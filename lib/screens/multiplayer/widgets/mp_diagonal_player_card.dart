import 'package:flutter/material.dart';

enum MpCardCutCorner { topLeft, bottomRight }

// ─────────────────────────────────────────────────────────────
// Shape helpers — diagonal card with one corner sliced at 45°
// ─────────────────────────────────────────────────────────────

class MpDiagonalCardClipper extends CustomClipper<Path> {
  final double cutSize;
  final MpCardCutCorner cutCorner;
  final double radius;

  MpDiagonalCardClipper({
    required this.cutSize,
    required this.cutCorner,
    this.radius = 18,
  });

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final c = cutSize;
    final path = Path();

    if (cutCorner == MpCardCutCorner.bottomRight) {
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - c);
      path.lineTo(w - c, h);
      path.lineTo(r, h);
      path.quadraticBezierTo(0, h, 0, h - r);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      path.moveTo(c, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - r);
      path.quadraticBezierTo(w, h, w - r, h);
      path.lineTo(r, h);
      path.quadraticBezierTo(0, h, 0, h - r);
      path.lineTo(0, c);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant MpDiagonalCardClipper old) =>
      cutSize != old.cutSize ||
          cutCorner != old.cutCorner ||
          radius != old.radius;
}

class MpCardShapePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double cutSize;
  final MpCardCutCorner cutCorner;
  final double radius;

  MpCardShapePainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.cutSize,
    required this.cutCorner,
    this.radius = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = MpDiagonalCardClipper(
      cutSize: cutSize,
      cutCorner: cutCorner,
      radius: radius,
    ).getClip(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 2, // Fixed broken operator
    );
  }

  @override
  bool shouldRepaint(covariant MpCardShapePainter old) =>
      fillColor != old.fillColor ||
          borderColor != old.borderColor ||
          borderWidth != old.borderWidth ||
          cutSize != old.cutSize ||
          cutCorner != old.cutCorner ||
          radius != old.radius;
}

// ─────────────────────────────────────────────────────────────
// The Single Unified Player Card
// ─────────────────────────────────────────────────────────────

class MpDiagonalPlayerCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isReady;
  final bool showReadyBadge;
  final Color color;
  final double avatarRadius;
  final double padH;
  final double padV;
  final double cutSize;
  final MpCardCutCorner cutCorner;
  final double fillAlpha;
  final double borderAlpha;
  final Color onSurface;

  const MpDiagonalPlayerCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.isReady = false,
    this.showReadyBadge = true,
    required this.color,
    required this.avatarRadius,
    required this.padH,
    required this.padV,
    required this.cutSize,
    required this.cutCorner,
    required this.fillAlpha,
    required this.borderAlpha,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MpDiagonalCardClipper(
        cutSize: cutSize,
        cutCorner: cutCorner,
      ),
      child: CustomPaint(
        painter: MpCardShapePainter(
          fillColor: color.withValues(alpha: fillAlpha),
          borderColor: color.withValues(alpha: borderAlpha),
          borderWidth: 1.5,
          cutSize: cutSize,
          cutCorner: cutCorner,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: avatarRadius * 0.8, // Fixed broken operator
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onSurface.withValues(alpha: 0.54),
                ),
              ),
              if (showReadyBadge) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isReady ? color : onSurface.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isReady ? 'READY' : 'WAITING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isReady ? Colors.white : onSurface,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}