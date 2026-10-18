import 'package:flutter/material.dart';

/// Small badge showing remaining LC-earning attempts for a daily challenge.
/// Place in the top-right corner of each challenge card.
class AttemptsStamp extends StatelessWidget {
  final int remaining;

  const AttemptsStamp({super.key, required this.remaining});

  Color _color() {
    if (remaining <= 0) return const Color(0xFFE53935); // red
    if (remaining <= 4) return const Color(0xFFFF9800); // orange
    return const Color(0xFF4CAF50); // green
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final spent = remaining <= 0;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Center(
        child: spent
            ? Icon(Icons.lock_rounded, size: 18, color: color)
            : Text(
          '$remaining',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }
}