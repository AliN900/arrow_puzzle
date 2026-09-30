import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;

  const TimerDisplay({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
  });

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (timeRemaining / totalTime).clamp(0.0, 1.0);
    final isLowTime = timeRemaining <= 15 || timeRemaining <= totalTime * 0.15;
    final color =
    isLowTime ? const Color(0xFFFF5252) : AppColors.accent(context);

    Widget content = Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isLowTime ? 0.3 : 0.1),
            blurRadius: isLowTime ? 8 : 4,
            spreadRadius: isLowTime ? 1 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                _formatTime(timeRemaining),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );

    if (isLowTime) {
      content = content
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
        begin: 0.96,
        end: 1.04,
        duration: 400.ms,
        curve: Curves.easeInOut,
      );
    }

    return content;
  }
}