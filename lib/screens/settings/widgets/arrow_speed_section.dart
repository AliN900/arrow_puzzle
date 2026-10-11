import 'package:flutter/material.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

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

  String _speedLabel(AppStrings strings, int value) {
    switch (value) {
      case 0:
        return strings.arrowSpeedSlow;
      case 1:
        return strings.arrowSpeedNormal;
      case 2:
        return strings.arrowSpeedFast;
      default:
        return strings.arrowSpeedSlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final label = _speedLabel(strings, speed);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.speed_outlined, color: textSecondary, size: 24),
              const SizedBox(width: 16),
              Text(
                strings.arrowSpeedEscapeSpeed,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                label,
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
            label: label,
            onChanged: (value) => onSpeedChanged(value.round()),
          ),
        ],
      ),
    );
  }
}