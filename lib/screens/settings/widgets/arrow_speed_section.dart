import 'package:flutter/material.dart';

class ArrowSpeedSection extends StatelessWidget {
  final int speed;
  final ValueChanged<int> onSpeedChanged;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  const ArrowSpeedSection({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  String _speedLabel(int value) {
    switch (value) {
      case 0:
        return 'Slow';
      case 1:
        return 'Normal';
      case 2:
        return 'Fast';
      default:
        return 'Slow';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.speed_outlined, color: textSecondary, size: 24),
              const SizedBox(width: 16),
              Text(
                'Escape speed',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                _speedLabel(speed),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: speed.toDouble().clamp(0, 2),
            min: 0,
            max: 2,
            divisions: 2,
            activeColor: accentColor,
            inactiveColor: accentColor.withValues(alpha: 0.2),
            label: _speedLabel(speed),
            onChanged: (value) => onSpeedChanged(value.round()),
          ),
        ],
      ),
    );
  }
}