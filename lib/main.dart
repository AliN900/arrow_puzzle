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
import 'dart:ui';
import 'package:arrow_puzzle/screens/onboarding/privacy_consent_screen.dart';
import 'package:arrow_puzzle/services/auth_service.dart';
import 'package:arrow_puzzle/services/cloud_sync_service.dart';
import 'package:arrow_puzzle/services/huawei_iap_service.dart';
import 'package:arrow_puzzle/services/store_detector.dart';
import 'package:arrow_puzzle/unity_rewarded_ad.dart';
import 'package:flutter/foundation.dart';
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

// ─────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────

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
  ref.keepAlive();
  return AuthService.instance;
});

// ─────────────────────────────────────────────────────────────────────
// Cloud push — debounced
// ─────────────────────────────────────────────────────────────────────

Timer? _cloudPushDebounce;
ProgressRepository? _linkedProgress;
CoinsRepository? _linkedCoins;
String? _lastMergedUserId;
bool _authListenerAttached = false;

void _scheduleCloudPush() {
  _cloudPushDebounce?.cancel();
  _cloudPushDebounce = Timer(const Duration(seconds: 3), _flushCloudPush);
}

void _attachAuthListener() {
  if (_authListenerAttached) return;
  _authListenerAttached = true;

  AuthService.instance.addListener(() {
    final userId = AuthService.instance.userId;
    if (userId == null) return;
    if (userId == _lastMergedUserId) return;
    _lastMergedUserId = userId;

    final progress = _linkedProgress;
    final coins = _linkedCoins;
    if (progress == null || coins == null) return;

    debugPrint('☁️ [Auth] userId changed → merging cloud ($userId)');
    mergeCloudAndLocal(progress, coins).then((_) {
      debugPrint('☁️ [Auth] merge complete');
    }).catchError((e) {
      debugPrint('🔴 [Auth] merge failed: $e');
    });
  });
}

Future<void> _flushCloudPush() async {
  _cloudPushDebounce?.cancel();
  _cloudPushDebounce = null;

  final userId = AuthService.instance.userId;
  final progress = _linkedProgress;
  final coins = _linkedCoins;
  if (userId == null || progress == null || coins == null) {
    debugPrint('☁️ push skipped: userId=$userId');
    return;
  }

  final blob = <String, dynamic>{
    'v': 1,
    'syncedAt': DateTime.now().toUtc().toIso8601String(),
    ...progress.exportState(),
    ...coins.exportState(),
  };

  await CloudSyncService.instance.pushFullSave(
    userId: userId,
    blob: blob,
    currentLevel: progress.currentLevel,
    coins: coins.coins,
  );
}

Future<void> mergeCloudAndLocal(
    ProgressRepository progress,
    CoinsRepository coins,
    ) async {
  final userId = AuthService.instance.userId;
  if (userId == null) {
    debugPrint('☁️ merge skipped: no userId');
    return;
  }
  debugPrint('☁️ merge start for $userId');

  try {
    final cloud = await CloudSyncService.instance.fetchFullSave(userId);

    if (cloud == null) {
      debugPrint('☁️ no cloud row — seeding from local');
      await _flushCloudPush();
      return;
    }

    debugPrint('☁️ cloud row found, importing…');
    await progress.importState(cloud);
    await coins.importState(cloud);
    debugPrint('☁️ import complete');

    final localExport = progress.exportState();
    final localSettings = localExport['settings'] as Map<String, dynamic>;
    final remoteSettings =
        cloud['settings'] as Map<String, dynamic>? ?? const {};

    final localTime = DateTime.tryParse(
      (localSettings['lastModified'] as String?) ?? '',
    );
    final remoteTime = DateTime.tryParse(
      (remoteSettings['lastModified'] as String?) ?? '',
    );

    if (localTime != null &&
        (remoteTime == null || localTime.isAfter(remoteTime))) {
      debugPrint('☁️ local settings newer — scheduling push');
      _scheduleCloudPush();
    } else {
      debugPrint('☁️ cloud settings newer or equal — no push needed');
    }
  } catch (e, st) {
    debugPrint('🔴 merge error: $e\n$st');
  }
}

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

// ─────────────────────────────────────────────────────────────────────
// main()
// ─────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: immersive mode is applied from _ArrowPuzzleState.initState,
  // not here, because the Flutter surface doesn't exist yet at this
  // point and the OS would ignore the call.

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FlutterError: ${details.exception}');
    debugPrint('🔴 STACK: ${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PlatformError: $error');
    debugPrint('🔴 STACK: $stack');
    return true;
  };

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
        testMode: kDebugMode,
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

  try {
    if (await StoreDetector.isHuaweiDevice() &&
        await StoreDetector.isHuaweiAppGallery()) {
      await HuaweiIapService.init();
    }
  } catch (e) {
    debugPrint('Huawei IAP warmup skipped: $e');
  }

  try {
    await AuthService.instance.bootstrap();
    await mergeCloudAndLocal(progressRepo, coinsRepo);
  } catch (e) {
    debugPrint('Auth/cloud boot skipped: $e');
  }

  progressRepo.addListener(_scheduleCloudPush);
  coinsRepo.addListener(_scheduleCloudPush);

  _lastMergedUserId = AuthService.instance.userId;
  _attachAuthListener();

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

// ─────────────────────────────────────────────────────────────────────
// Root widget
// ─────────────────────────────────────────────────────────────────────

class ArrowPuzzle extends ConsumerStatefulWidget {
  const ArrowPuzzle({super.key});

  @override
  ConsumerState<ArrowPuzzle> createState() => _ArrowPuzzleState();
}

class _ArrowPuzzleState extends ConsumerState<ArrowPuzzle>
    with WidgetsBindingObserver {
  bool _consentJustAccepted = false;
  Timer? _immersiveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyImmersive();
    // Re-assert every 2s. Prevents the OS from leaving the bars visible
    // after a dialog, keyboard, or notification-shade interaction.
    _immersiveTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) _applyImmersive();
    });
  }

  @override
  void dispose() {
    _immersiveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyImmersive();
    }
  }

  void _applyImmersive() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: const [],
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeMode = progress.themeMode;
    final accentColor = progress.accentColor;

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
      // Strip the top MediaQuery padding so SafeArea doesn't reserve
      // a strip where the (hidden) status bar would be.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(top: 0),
            viewPadding: mq.viewPadding.copyWith(top: 0),
          ),
          child: child!,
        );
      },
    );
  }
}