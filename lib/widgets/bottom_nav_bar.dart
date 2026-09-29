import 'package:flutter/material.dart';

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
    // Hardcoded light theme colors
    const Color cardColor = Colors.white;
    const Color primaryPurple = Color(0xFF6C4CF1);
    const Color textSecondary = Color(0xFF8A8D93);
    const Color navActiveBg = Color(0xFFD6E4FF);

    return BottomNavigationBar(
      backgroundColor: cardColor,
      selectedItemColor: primaryPurple,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Only show the active pill on the selected tab
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
          label: 'Setting',
        ),
      ],
    );
  }
}