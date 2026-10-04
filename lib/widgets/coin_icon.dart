import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  final double? size; // Optional: auto-scales responsively if omitted
  final Color? backgroundColor;
  final Color? textColor;

  const CoinIcon({
    super.key,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0xFFFFD54F);
    final fg = textColor ?? const Color(0xFF5D4A1A);

    // Responsive scaling based on screen width
    final screenWidth = MediaQuery.sizeOf(context).width;
    final iconSize = size ?? (screenWidth < 360 ? 20.0 : (screenWidth > 600 ? 28.0 : 22.0));

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -0.5), // Micro-adjustment for absolute optical centering
          child: Text(
            '¢',
            style: TextStyle(
              fontSize: iconSize * 0.64,
              fontWeight: FontWeight.w900,
              color: fg,
              height: 1.0, // Proper line height prevents baseline offset
            ),
          ),
        ),
      ),
    );
  }
}