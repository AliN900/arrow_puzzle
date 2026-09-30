import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textSecondary = AppColors.textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Nav active pill: light purple-ish in light mode, tinted accent in dark
    final navActiveBg = isDark
        ? accent.withValues(alpha: 0.18)
        : const Color(0xFFD6E4FF);

    return BottomNavigationBar(
      backgroundColor: cardColor,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      selectedLabelStyle:
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle:
      const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: currentIndex == 0 ? navActiveBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home_rounded),
          ),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_rounded),
          label: 'Daily',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_rounded),
          label: 'Inventory',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}