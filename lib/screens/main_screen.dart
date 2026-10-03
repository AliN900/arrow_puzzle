import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../main.dart';
import '../unity_banner_ad.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_pop_dialog.dart';
import 'daily/daily_screen.dart';
import 'home/home_screen.dart';
import 'inventory/inventory_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const List<Widget> _pages = [
    HomeScreen(),
    DailyScreen(),
    InventoryScreen(),
    SettingsScreen(),
  ];

  Future<bool> _confirmExit() async {
    final accent = AppColors.accent(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomPopDialog(
        title: 'Exit Game?',
        message: 'Are you sure you want to leave?',
        icon: Icon(Icons.exit_to_app_rounded, color: accent, size: 34),
        confirmText: 'Exit',
        cancelText: 'Cancel',
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    return result ?? false;
  }

  Future<void> _onBackPressed() async {
    final currentIndex = ref.read(currentTabProvider);

    // Not on Home tab → go back to Home first (no dialog)
    if (currentIndex != 0) {
      HapticFeedback.selectionClick();
      ref.read(currentTabProvider.notifier).state = 0;
      return;
    }

    // On Home tab → show exit confirmation
    HapticFeedback.lightImpact();
    final shouldExit = await _confirmExit();
    if (shouldExit) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed();
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                border: Border(
                  top: BorderSide(color: Color(0x1AFFFFFF)),
                ),
              ),
              alignment: Alignment.center,
              child: const UnityBannerAdWidget(
                placementId: 'BP_Banner_Android',
              ),
            ),
            CustomBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentTabProvider.notifier).state = index;
              },
            ),
          ],
        ),
      ),
    );
  }
}