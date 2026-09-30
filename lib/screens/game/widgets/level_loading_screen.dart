import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import 'loader_animation.dart';

class LevelLoadingScreen extends StatelessWidget {
  const LevelLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoaderAnimation(color: AppColors.accent(context)),
            const SizedBox(height: 24),
            Text(
              'LOADING LEVEL...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}