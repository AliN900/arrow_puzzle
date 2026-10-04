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
        begin: const Offset(0.5, 0.5),
        end: const Offset(1.0, 1.0),
        duration: 200.ms,
        curve: Curves.easeOutBack,
      )
          .fadeIn(duration: 100.ms),
    );
  }
}