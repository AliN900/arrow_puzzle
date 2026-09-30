import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/audio_haptic_helper.dart';

class GameDialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color textColor;
  final Color? iconColor;

  const GameDialogButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.textColor = Colors.white,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final surface = const Color(0xFF1E1E1E);

    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent, width: 1.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor ?? accent, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}