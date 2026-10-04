import 'package:flutter/material.dart';

class RushHudBar extends StatelessWidget {
  final int clearedCount;
  final double fillPercentage;

  const RushHudBar({
    super.key,
    required this.clearedCount,
    required this.fillPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final isDanger = fillPercentage > 0.8;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDanger ? Colors.redAccent : Colors.amber,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded,
            color: isDanger ? Colors.redAccent : Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Cleared: $clearedCount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fillPercentage.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white12,
                color: isDanger ? Colors.redAccent : Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}