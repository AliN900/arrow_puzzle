/*
 * Copyright (C) 2026 Ali Hussein (AliN900)
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
 * Modifications: Native Flutter rewrite, UI redesign, theme system, and additional features by AliN900.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_colors.dart';
import 'core/audio_haptic_helper.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/level_repository.dart';
import 'screens/main_screen.dart';

// --- PROVIDERS ---
final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  throw UnimplementedError('Must be overridden');
});

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  throw UnimplementedError('Must be overridden');
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final accentColorProvider = StateProvider<Color>((ref) => const Color(0xFF6C4CF1));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioHapticHelper.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Hive.initFlutter();

  final progressRepo = await ProgressRepository.create();
  final levelRepo = await LevelRepository.create();

  runApp(
    ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWith((ref) => progressRepo),
        levelRepositoryProvider.overrideWithValue(levelRepo),
      ],
      child: const ArrowPuzzle(),
    ),
  );
}

class ArrowPuzzle extends ConsumerWidget {
  const ArrowPuzzle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Arrow Puzzle: Tap Maze Escape',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
      ),

      home: const MainScreen(),
    );
  }
}