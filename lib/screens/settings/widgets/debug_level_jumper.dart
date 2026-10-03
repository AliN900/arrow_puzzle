import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../core/board_themes.dart';
import '../../../core/items.dart';
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

  Future<void> _showCelebrationTest(BoardTheme board) async {
    Navigator.pop(context);

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => UnlockCelebrationScreen(
          board: board,
          onResume: () => Navigator.pop(context),
          onMainMenu: () => Navigator.pop(context),
          onCheckInventory: () => Navigator.pop(context),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _showCelebrationPicker() async {
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
            child: const Text('Cancel'),
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
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Jump to level',
                labelStyle: const TextStyle(color: textSecondary),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _btn(
              label: 'Jump to Level',
              icon: Icons.play_arrow_rounded,
              color: accent,
              onTap: _jumpToLevel,
            ),
            const SizedBox(height: 8),
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
              label: '🎉 Test Celebration',
              icon: Icons.celebration_rounded,
              color: const Color(0xFFFFD54F),
              onTap: _showCelebrationPicker,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await UnityRewardedAd.show(
                  onRewarded: () {
                    debugPrint('🎉 USER EARNED REWARD');
                  },
                  onFailed: () => debugPrint('❌ Ad failed to show'),
                );
              },
              child: const Text('Test Reward Ad'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final c = ref.read(coinsRepositoryProvider);
                await c.debugAdvanceDailyStreak();
              },
              child: const Text('Advance Daily (DEV)'),
            ),
            const SizedBox(height: 8),
            _btn(
              label: '💰 Add 1000 Coins',
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFFFFD54F),
              onTap: () async {
                await ref.read(coinsRepositoryProvider).addCoins(1000);
                if (mounted) {
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
              color: const Color(0xFF7C4DFF),
              onTap: () async {
                final coinsRepo = ref.read(coinsRepositoryProvider);
                for (final item in ItemType.values) {
                  await coinsRepo.addItem(item, count: 5);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Granted 5 of each item')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _btn(
              label: 'Reset Progress',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFF5252),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: surface,
                    title: const Text(
                      'Reset everything?',
                      style: TextStyle(color: textPrimary),
                    ),
                    content: const Text(
                      'This wipes level progress, stars, and settings.',
                      style: TextStyle(color: textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Color(0xFFFF5252)),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(progressRepositoryProvider).resetProgress();
                  if (mounted) Navigator.pop(context);
                }
              },
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