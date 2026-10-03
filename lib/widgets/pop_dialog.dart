import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PopDialog extends StatelessWidget {
  final Widget child;

  const PopDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: child
          .animate()
          .scale(
        begin: const Offset(0.3, 0.3),
        end: const Offset(1.0, 1.0),
        duration: 450.ms,
        curve: Curves.elasticOut,
      )
          .fadeIn(duration: 150.ms),
    );
  }
}