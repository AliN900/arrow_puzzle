/*
 * Copyright (C) 2026 ahb.Dev (Ali Hussein)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Original work: ArrowEscape by sidhant947 (https://github.com/sidhant947/ArrowEscape)
 * Licensed under GPL-3.0.
 * Modifications: Flutter fork with UI redesign, theme system, and additional features by ahb.Dev.
 */


import 'dart:async';
import 'package:arrow_puzzle/screens/onboarding/privacy_consent_screen.dart';
import 'package:arrow_puzzle/services/auth_service.dart';
import 'package:arrow_puzzle/services/cloud_sync_service.dart';
import 'package:arrow_puzzle/services/huawei_iap_service.dart';
import 'package:arrow_puzzle/services/store_detector.dart';
import 'package:arrow_puzzle/unity_rewarded_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'core/app_colors.dart';
import 'core/audio_haptic_helper.dart';
import 'core/sfx_player.dart';
import 'data/repositories/coins_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/level_repository.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_screen.dart';


const bool _kScreenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

// --- PROVIDERS ---
final progressRepositoryProvider =
ChangeNotifierProvider<ProgressRepository>((ref) {
  throw UnimplementedError('Must be overridden');
});

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  throw UnimplementedError('Must be overridden');
});

final coinsRepositoryProvider =
ChangeNotifierProvider<CoinsRepository>((ref) {
  throw UnimplementedError('Must be overridden');
});

final currentTabProvider = StateProvider<int>((ref) => 0);

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  // 🚨 CRITICAL FIX: Keeps the singleton alive forever
  ref.keepAlive();
  return AuthService.instance;
});

// ─────────────────────────────────────────────────────────────────────────
// Cloud push — debounced. Top-level so the timer survives past main().
// ─────────────────────────────────────────────────────────────────────────

Timer? _cloudPushDebounce;
ProgressRepository? _linkedProgress;
CoinsRepository? _linkedCoins;

void _scheduleCloudPush() {
  _cloudPushDebounce?.cancel();
  _cloudPushDebounce = Timer(const Duration(seconds: 3), _flushCloudPush);
}

Future<void> _flushCloudPush() async {
  _cloudPushDebounce?.cancel();
  _cloudPushDebounce = null;

  final userId = AuthService.instance.userId;
  final progress = _linkedProgress;
  final coins = _linkedCoins;
  if (userId == null || progress == null || coins == null) return;

  await CloudSyncService.instance.pushSave(
    userId: userId,
    currentLevel: progress.currentLevel,
    coins: coins.coins,
  );
}

/// Merge cloud save with local state (keep whichever side is further along)
/// and seed the cloud row if it doesn't exist yet.
Future<void> mergeCloudAndLocal(
    ProgressRepository progress,
    CoinsRepository coins,
    ) async {
  final userId = AuthService.instance.userId;
  if (userId == null) return;

  try {
    final cloud = await CloudSyncService.instance.fetchSave(userId);

    if (cloud == null) {
      await CloudSyncService.instance.pushSave(
        userId: userId,
        currentLevel: progress.currentLevel,
        coins: coins.coins,
      );
      return;
    }

    final remoteLevel = (cloud['currentLevel'] as num?)?.toInt() ?? 1;
    final remoteCoins = (cloud['coins'] as num?)?.toInt() ?? 0;

    if (remoteLevel > progress.currentLevel) {
      await progress.setCurrentLevel(remoteLevel);
    } else if (progress.currentLevel > remoteLevel) {
      _scheduleCloudPush();
    }

    if (remoteCoins > coins.coins) {
      await coins.addCoins(remoteCoins - coins.coins);
    }
  } catch (e) {
    debugPrint('Cloud merge skipped: $e');
  }
}

/// Force an immediate cloud sync: merge cloud + local, then push immediately.
/// Bypasses the 3-second debounce in `_scheduleCloudPush`.
/// Used by the tap-to-sync badge in the profile header.
Future<void> forceCloudSync(
    ProgressRepository progress,
    CoinsRepository coins,
    ) async {
  final userId = AuthService.instance.userId;
  if (userId == null) {
    throw StateError('Not signed in');
  }
  await mergeCloudAndLocal(progress, coins);
  await _flushCloudPush();
}

// ─────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
  } catch (e, st) {
    debugPrint('Hive.initFlutter failed: $e\n$st');

    rethrow;
  }

  final progressRepo = await ProgressRepository.create();
  final levelRepo = await LevelRepository.create();
  final coinsRepo = await CoinsRepository.create();

  _linkedProgress = progressRepo;
  _linkedCoins = coinsRepo;

  try {
    AudioHapticHelper.init();
  } catch (e) {
    debugPrint('AudioHapticHelper.init skipped: $e');
  }

  try {
    await SfxPlayer.instance.init();
  } catch (e) {
    debugPrint('SfxPlayer.init skipped: $e');
  }

  if (!_kScreenshotMode) {
    try {
      UnityAds.init(
        gameId: '800386220',
        testMode: true,
        onComplete: () {
          debugPrint('Unity Ads initialized');
          UnityRewardedAd.preload();
        },
        onFailed: (error, message) =>
            debugPrint('Unity Ads init failed: $error $message'),
      );
    } catch (e) {
      debugPrint('UnityAds.init skipped: $e');
    }
  }

  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } catch (e) {
    debugPrint('Orientation lock skipped: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));



  // ── Huawei IAP warmup (Huawei devices + installed from AppGallery only) ──
  try {
    if (await StoreDetector.isHuaweiDevice() &&
        await StoreDetector.isHuaweiAppGallery()) {
      await HuaweiIapService.init();
    }
  } catch (e) {
    debugPrint('Huawei IAP warmup skipped: $e');
  }

  // ── Auth bootstrap ──
  // Restores the cached user from Hive, then verifies with Appwrite.
  // This MUST run before runApp so the first frame shows the correct
  // signed-in state.
  try {
    await AuthService.instance.bootstrap();
    await mergeCloudAndLocal(progressRepo, coinsRepo);
  } catch (e) {
    debugPrint('Auth/cloud boot skipped: $e');
  }

  progressRepo.addListener(_scheduleCloudPush);
  coinsRepo.addListener(_scheduleCloudPush);


  progressRepo.addListener(_scheduleCloudPush);
  coinsRepo.addListener(_scheduleCloudPush);


  AppLifecycleListener(
    onPause: () => _flushCloudPush(),
    onDetach: () => _flushCloudPush(),
  );

  runApp(
    ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWith((ref) => progressRepo),
        levelRepositoryProvider.overrideWithValue(levelRepo),
        coinsRepositoryProvider.overrideWith((ref) => coinsRepo),
      ],
      child: const ArrowPuzzle(),
    ),
  );
}

class ArrowPuzzle extends ConsumerStatefulWidget {
  const ArrowPuzzle({super.key});

  @override
  ConsumerState<ArrowPuzzle> createState() => _ArrowPuzzleState();
}

class _ArrowPuzzleState extends ConsumerState<ArrowPuzzle> {
  bool _consentJustAccepted = false;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeMode = progress.themeMode;
    final accentColor = progress.accentColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
    ));

    final showConsent = !progress.privacyAccepted && !_consentJustAccepted;

    return MaterialApp(
      title: 'Arrow Puzzle: Tap Maze Escape',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ).copyWith(primary: accentColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ).copyWith(primary: accentColor),
      ),

      // ── Locale configuration ─────────────────────────────────────
      locale: progress.languageCode == 'system'
          ? null
          : Locale(progress.languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('pt'),
        Locale('id'),
        Locale('hi'),
        Locale('ar'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('en');
      },

      home: showConsent
          ? PrivacyConsentScreen(
        onAccepted: () {
          setState(() => _consentJustAccepted = true);
        },
      )
          : const MainScreen(),
    );
  }
}