import 'package:flutter/material.dart';

class AnimatedCoinCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Color? color;
  final Duration duration;

  const AnimatedCoinCounter({
    super.key,
    required this.value,
    this.style,
    this.color,
    this.duration = const Duration(milliseconds: 1200), // 1.2 seconds
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic, // Starts fast, slows down nicely
      builder: (context, val, child) {
        // Format number with commas (e.g., 75000 -> 75,000)
        final formatted = val.round().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
        );
        return Text(
          formatted,
          style: (style ?? const TextStyle()).copyWith(color: color),
        );
      },
    );
  }
}