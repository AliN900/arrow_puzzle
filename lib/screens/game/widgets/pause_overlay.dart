import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import 'game_dialog_button.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accent.withValues(alpha: 0.5),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_outline_rounded,
                  color: accent,
                  size: 52,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Paused',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                GameDialogButton(
                  label: 'Resume',
                  icon: Icons.play_arrow_rounded,
                  textColor: Colors.white,
                  onTap: onResume,
                ),
                const SizedBox(height: 10),
                GameDialogButton(
                  label: 'Restart',
                  icon: Icons.refresh_rounded,
                  textColor: Colors.white,
                  onTap: onRestart,
                ),
                const SizedBox(height: 10),
                GameDialogButton(
                  label: 'Main Menu',
                  icon: Icons.home_rounded,
                  textColor: Colors.white70,
                  onTap: onMainMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}