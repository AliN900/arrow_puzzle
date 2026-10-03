import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../core/app_colors.dart';

class CustomBottomNavBar extends HookWidget {
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
    final navActiveBg = isDark
        ? accent.withValues(alpha: 0.18)
        : const Color(0xFFD6E4FF);

    Widget buildIcon(IconData icon, int index) {
      final isSelected = currentIndex == index;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? navActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon),
      );
    }

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
          icon: buildIcon(Icons.home_rounded, 0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: buildIcon(Icons.calendar_today_rounded, 1),
          label: 'Daily',
        ),
        BottomNavigationBarItem(
          icon: buildIcon(Icons.inventory_2_rounded, 2),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: buildIcon(Icons.settings_rounded, 3),
          label: 'Settings',
        ),
      ],
    );
  }
}