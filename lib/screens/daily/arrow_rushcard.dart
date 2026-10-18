import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/audio_haptic_helper.dart';
import '../../core/game_mode.dart';
import '../../core/leader_coins.dart';
import '../../core/rush_difficulty.dart';
import '../../data/repositories/progress_repository.dart';
import '../../main.dart';
import '../../widgets/attempts_stamp.dart';
import '../game/game_screen.dart';

String _tierLabel(AppStrings strings, RushDifficulty d) {
  switch (d) {
    case RushDifficulty.easy:
      return strings.rushDifficultyEasy;
    case RushDifficulty.hard:
      return strings.rushDifficultyHard;
    case RushDifficulty.impossible:
      return strings.rushDifficultyImpossible;
  }
}

class ArrowRushCard extends ConsumerWidget {
  const ArrowRushCard({
    super.key,
    required this.progress,
    required this.selected,
    required this.accent,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
  });

  final ProgressRepository progress;
  final RushDifficulty selected;
  final Color accent;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final coinsRepo = ref.watch(coinsRepositoryProvider);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.amber,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.arrowRushTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    // Space for the attempts stamp so the title
                    // doesn't run under it.
                    const SizedBox(width: 46),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Tier chips row ──
                Row(
                  children: [
                    for (int i = 0; i < RushDifficulty.values.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: _TierChip(
                          difficulty: RushDifficulty.values[i],
                          label: _tierLabel(
                              strings, RushDifficulty.values[i]),
                          unlocked: progress.isRushDifficultyUnlocked(
                              RushDifficulty.values[i]),
                          selected:
                          selected == RushDifficulty.values[i],
                          accent: accent,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          strings: strings,
                          onTap: () async {
                            AudioHapticHelper.playClick();
                            final d = RushDifficulty.values[i];
                            if (!progress.isRushDifficultyUnlocked(d)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    strings.reachLevelToUnlock(
                                      d.unlockLevel,
                                      _tierLabel(strings, d),
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            await ref
                                .read(progressRepositoryProvider)
                                .setRushDifficulty(d);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // ── Start button ──
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AudioHapticHelper.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            level: 1,
                            gameMode: GameMode.endlessRush,
                            rushDifficulty: progress.rushDifficulty,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: Text(
                      strings.startTier(
                          _tierLabel(strings, selected)),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Attempts stamp (top-end: right in LTR, left in RTL) ──
          PositionedDirectional(
            top: 12,
            end: 12,
            child: AttemptsStamp(
              remaining: coinsRepo
                  .lcAttemptsRemaining(LeaderCoins.modeArrowRush),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.difficulty,
    required this.label,
    required this.unlocked,
    required this.selected,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.strings,
    required this.onTap,
  });

  final RushDifficulty difficulty;
  final String label;
  final bool unlocked;
  final bool selected;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final AppStrings strings;
  final VoidCallback onTap;

  Color get _tierColor {
    switch (difficulty) {
      case RushDifficulty.easy:
        return const Color(0xFF4CAF50);
      case RushDifficulty.hard:
        return const Color(0xFFFF9800);
      case RushDifficulty.impossible:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? _tierColor : Colors.grey;
    final showSelected = selected && unlocked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: showSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: showSelected
                ? color
                : color.withValues(alpha: 0.35),
            width: showSelected ? 2 : 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unlocked
                  ? (showSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked)
                  : Icons.lock_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: unlocked ? color : textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              strings.lvLabel(difficulty.unlockLevel),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? Colors.transparent
                    : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}