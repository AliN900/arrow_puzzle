import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/audio_haptic_helper.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../unity_banner_ad.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_pop_dialog.dart';
import 'daily/daily_screen.dart';
import 'home/home_screen.dart';
import 'inventory/inventory_screen.dart';
import 'settings/settings_screen.dart';

const bool _kScreenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const _exitChannel = MethodChannel('ahb.dev.arrow_puzzle/exit');

  static const List<Widget> _pages = [
    HomeScreen(),
    DailyScreen(),
    InventoryScreen(),
    SettingsScreen(),
  ];

  /// When true, the Unity banner widget is removed from the tree. Set right
  /// before a hard kill so the plugin starts releasing its native WebView.
  bool _disposingBanner = false;

  Future<bool> _confirmExit() async {
    final strings = AppStrings.of(context);
    final accent = AppColors.accent(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomPopDialog(
        title: strings.dialogExitTitle,
        message: strings.dialogExitMessage,
        icon: Icon(Icons.exit_to_app_rounded, color: accent, size: 34),
        confirmText: strings.buttonExit,
        onConfirm: () {},
        onCancel: () {},
      ),
    );
    return result ?? false;
  }

  Future<void> _onBackPressed() async {
    debugPrint('🔵 [exit] _onBackPressed fired');
    final currentIndex = ref.read(currentTabProvider);

    if (currentIndex != 0) {
      debugPrint('🔵 [exit] not on home tab → switching to home');
      AudioHapticHelper.playClick();
      ref.read(currentTabProvider.notifier).state = 0;
      return;
    }

    debugPrint('🔵 [exit] on home tab → showing confirm dialog');
    AudioHapticHelper.playClick();
    final shouldExit = await _confirmExit();
    debugPrint('🔵 [exit] user chose: $shouldExit');
    if (!shouldExit || !mounted) {
      debugPrint('🔵 [exit] aborting (user cancelled or unmounted)');
      return;
    }

    debugPrint('🔵 [exit] removing banner from tree');
    setState(() => _disposingBanner = true);

    debugPrint('🔵 [exit] waiting 250ms for native teardown');
    await Future.delayed(const Duration(milliseconds: 250));

    debugPrint('🔵 [exit] invoking killApp channel');
    try {
      await _exitChannel.invokeMethod('killApp');
      debugPrint('🔵 [exit] killApp returned — process should be dead');
    } on MissingPluginException catch (e) {
      debugPrint('🔴 [exit] MissingPluginException — channel not wired: $e');
      if (mounted) await SystemNavigator.pop();
    } on PlatformException catch (e) {
      debugPrint('🔴 [exit] PlatformException — Kotlin error: $e');
      if (mounted) await SystemNavigator.pop();
    } catch (e) {
      debugPrint('🔴 [exit] Unknown error: $e');
      if (mounted) await SystemNavigator.pop();
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
            if (!_disposingBanner && !_kScreenshotMode)
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