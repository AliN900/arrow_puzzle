/*
 * Copyright (C) 2026 AHB.Dev (Ali Hussein)
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
 * Modifications: Flutter fork with UI redesign, theme system, and additional features by AHB.Dev.
 */

import 'package:arrow_puzzle/unity_rewarded_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'core/app_colors.dart';
import 'core/audio_haptic_helper.dart';
import 'data/repositories/coins_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/level_repository.dart';
import 'screens/main_screen.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioHapticHelper.init();

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

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Hive.initFlutter();

  final progressRepo = await ProgressRepository.create();
  final levelRepo = await LevelRepository.create();
  final coinsRepo = await CoinsRepository.create();

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

class ArrowPuzzle extends ConsumerWidget {
  const ArrowPuzzle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeMode = progress.themeMode;
    final accentColor = progress.accentColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
    ));

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
      home: const MainScreen(),
    );
  }
}