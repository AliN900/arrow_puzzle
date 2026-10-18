import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final Color cardColor;
  final List<Widget> children;

  const SettingsCard({
    super.key,
    required this.cardColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // THE FIX: Wrap the column in a Material widget
      child: Material(
        color: Colors.transparent, // Transparent so the Container's color shows
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias, // Keeps the ripple effect inside the rounded corners
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}