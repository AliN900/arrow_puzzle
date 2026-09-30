import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../widgets/bottom_nav_bar.dart';
import 'daily/daily_screen.dart';
import 'home/home_screen.dart';
import 'inventory/inventory_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    DailyScreen(),
    InventoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
      ),
    );
  }
}