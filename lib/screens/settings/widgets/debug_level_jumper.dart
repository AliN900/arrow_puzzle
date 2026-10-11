import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../core/board_themes.dart';
import '../../../core/game_mode.dart';
import '../../../core/items.dart';
import '../../../data/models/level_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../unity_rewarded_ad.dart';
import '../../../widgets/unlock_celebration_screen.dart';
import '../../game/game_screen.dart';

class DebugLevelJumper extends ConsumerStatefulWidget {
  const DebugLevelJumper({super.key});

  @override
  ConsumerState<DebugLevelJumper> createState() => _DebugLevelJumperState();
}

class _DebugLevelJumperState extends ConsumerState<DebugLevelJumper> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpToLevel() {
    final level = int.tryParse(_controller.text.trim());
    if (level == null || level < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid level number')),
      );
      return;
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(level: level)),
    );
  }

  int? _parsedInput() {
    final level = int.tryParse(_controller.text.trim());
    if (level == null || level < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid level number')),
      );
      return null;
    }
    return level;
  }

  Future<void> _unlockUpTo() async {
    final level = _parsedInput();
    if (level == null) return;
    await ref.read(progressRepositoryProvider).unlockUpToLevel(level);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unlocked through level $level')),
    );
    setState(() {}); // refresh the "current/highest" banner
  }

  Future<void> _setCurrentLevel() async {
    final level = _parsedInput();
    if (level == null) return;
    await ref.read(progressRepositoryProvider).setCurrentLevel(level);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Current level set to $level')),
    );
    setState(() {});
  }

  /// Debug: fills levels 1..currentLevel with random stars (1-3), weighted
  /// toward 3 so the total looks like a real player's progress.
  ///
  /// As a side effect, this also triggers trophy unlocks (many trophies
  /// check `highestUnlockedLevel`), which is exactly what we want for
  /// clean store screenshots.
  Future<void> _fillRandomStars() async {
    final progress = ref.read(progressRepositoryProvider);
    final targetLevel = progress.currentLevel;

    if (targetLevel <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set a current level above 1 first'),
        ),
      );
      return;
    }

    final rng = Random();
    int totalStars = 0;
    int levelsFilled = 0;

    for (int lv = 1; lv <= targetLevel; lv++) {
      // Weighted random star roll:
      //   55% chance → 3 stars
      //   35% chance → 2 stars
      //   10% chance → 1 star
      // Mirrors how a decent player would actually clear levels.
      final roll = rng.nextDouble();
      final stars = roll < 0.55 ? 3 : (roll < 0.90 ? 2 : 1);

      // Corresponding livesLost value (matches how the real game computes it):
      final livesLost = stars == 3 ? 0 : (stars == 2 ? 1 : 2);

      await progress.recordLevelComplete(LevelResult(
        levelNumber: lv,
        stars: stars,
        livesLost: livesLost,
        completed: true,
        completedAt: DateTime.now(),
      ));

      totalStars += stars;
      levelsFilled++;
    }

    // Restore the current level in case recordLevelComplete altered it.
    await progress.setCurrentLevel(targetLevel);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Filled $totalStars stars across $levelsFilled levels',
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _launchEndlessRush() async {
    final level = int.tryParse(_controller.text.trim());
    if (level != null && level >= 1) {
      await ref.read(progressRepositoryProvider).setCurrentLevel(level);
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GameScreen(
          level: 1,                     // ignored by endless rush
          gameMode: GameMode.endlessRush,
        ),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final strings = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Reset everything?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This wipes level progress, stars, and settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFFF5252))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(progressRepositoryProvider).resetProgress();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _showCelebrationTest(BoardTheme board) async {
    Navigator.pop(context);

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => UnlockCelebrationScreen(
          board: board,
          onResume: () => Navigator.pop(context),
          onMainMenu: () => Navigator.pop(context),
          onCheckInventory: () => Navigator.pop(context),
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _showCelebrationPicker() async {
    final strings = AppStrings.of(context);
    final boards = BoardTheme.values;
    final selected = await showDialog<BoardTheme>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Pick a board to preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: boards.length,
            itemBuilder: (_, i) {
              final b = boards[i];
              return ListTile(
                title: Text(
                  b.name[0].toUpperCase() + b.name.substring(1),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  BoardThemes.get(b).category == BoardCategory.dark
                      ? 'Dark'
                      : 'Light',
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () => Navigator.pop(ctx, b),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.buttonCancel),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      await _showCelebrationTest(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressRepositoryProvider);

    final accent = AppColors.accent(context);
    const surface = Color(0xFF1E1E1E);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;

    return AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1.5),
      ),
      title: const Text(
        '🛠 DEV MENU',
        style: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current level: ${progress.currentLevel}  ·  '
                  'Highest unlocked: ${progress.highestUnlockedLevel}',
              style: const TextStyle(color: textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // ── Input ──
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Level number',
                labelStyle: const TextStyle(color: textSecondary),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── LEVEL NAVIGATION ──
            _sectionLabel('LEVEL NAVIGATION'),
            const SizedBox(height: 6),
            _btn(
              label: '🔓 Unlock Up To Level',
              icon: Icons.lock_open_rounded,
              color: accent,
              onTap: _unlockUpTo,
            ),
            const SizedBox(height: 8),
            _btn(
              label: '🎯 Set Current Level',
              icon: Icons.flag_rounded,
              color: accent,
              onTap: _setCurrentLevel,
            ),
            const SizedBox(height: 8),
            _btn(
              label: '▶️ Play Classic at Level',
              icon: Icons.play_arrow_rounded,
              color: accent,
              onTap: _jumpToLevel,
            ),
            const SizedBox(height: 8),
            _btn(
              label: '🌀 Play Endless Rush at Current',
              icon: Icons.all_inclusive_rounded,
              color: accent,
              onTap: _launchEndlessRush,
            ),
            const SizedBox(height: 16),

            // ── Quick test chips ──
            const Text(
              'Quick test levels',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [1, 60, 120, 240, 300, 500, 800].map((lv) {
                return ActionChip(
                  label: Text(
                    '$lv',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: accent.withValues(alpha: 0.25),
                  side: BorderSide(color: accent.withValues(alpha: 0.6)),
                  onPressed: () {
                    _controller.text = '$lv';
                    _setCurrentLevel();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── PROGRESS ──
            _sectionLabel('PROGRESS'),
            const SizedBox(height: 6),
            _btn(
              label: 'Unlock All Levels',
              icon: Icons.lock_open_rounded,
              color: accent,
              onTap: () async {
                await ref.read(progressRepositoryProvider).unlockAllLevels();
                if (mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _btn(
              label: '⭐ Fill Random Stars',
              icon: Icons.star_rounded,
              color: accent,
              onTap: _fillRandomStars,
            ),
            const SizedBox(height: 20),

            // ── TESTING ──
            _sectionLabel('TESTING'),
            const SizedBox(height: 6),
            _btn(
              label: '🎉 Test Celebration',
              icon: Icons.celebration_rounded,
              color: accent,
              onTap: _showCelebrationPicker,
            ),
            const SizedBox(height: 8),
            _btn(
              label: '📺 Test Reward Ad',
              icon: Icons.play_circle_outline_rounded,
              color: accent,
              onTap: () async {
                await UnityRewardedAd.show(
                  onRewarded: () => debugPrint('🎉 USER EARNED REWARD'),
                  onFailed: () => debugPrint('❌ Ad failed to show'),
                );
              },
            ),
            const SizedBox(height: 8),
            _btn(
              label: '📅 Advance Daily (DEV)',
              icon: Icons.calendar_today_rounded,
              color: accent,
              onTap: () async {
                final c = ref.read(coinsRepositoryProvider);
                await c.debugAdvanceDailyStreak();
              },
            ),
            const SizedBox(height: 20),

            // ── ECONOMY ──
            _sectionLabel('ECONOMY'),
            const SizedBox(height: 6),
            _btn(
              label: '💰 Add 1000 Coins',
              icon: Icons.monetization_on_rounded,
              color: accent,
              onTap: () async {
                await ref.read(coinsRepositoryProvider).addCoins(1000);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('+1000 coins added')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _btn(
              label: '🎁 Grant All Items ×5',
              icon: Icons.inventory_2_rounded,
              color: accent,
              onTap: () async {
                final coinsRepo = ref.read(coinsRepositoryProvider);
                for (final item in ItemType.values) {
                  await coinsRepo.addItem(item, count: 5);
                }
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Granted 5 of each item')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // ── DANGER ZONE ──
            _sectionLabel('DANGER ZONE'),
            const SizedBox(height: 6),
            _btn(
              label: 'Reset Progress',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFF5252),
              onTap: _confirmReset,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _btn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }
}

Widget _sectionLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: Colors.white38,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  );
}