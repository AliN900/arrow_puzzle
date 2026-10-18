import 'package:arrow_puzzle/widgets/status_flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../core/audio_haptic_helper.dart';
import '../core/daily_rewards.dart';
import '../main.dart';
import 'coin_icon.dart';

class DailyRewardCard extends ConsumerStatefulWidget {
  final VoidCallback? onDone;
  final bool showDismissButton;

  const DailyRewardCard({
    super.key,
    this.onDone,
    this.showDismissButton = false,
  });

  @override
  ConsumerState<DailyRewardCard> createState() => _DailyRewardCardState();
}

class _DailyRewardCardState extends ConsumerState<DailyRewardCard> {
  bool _isWatchingAd = false;

  Future<void> _claim({required bool withAd}) async {
    AudioHapticHelper.playClick();
    final strings = AppStrings.of(context);
    if (withAd) {
      if (_isWatchingAd) return;
      setState(() => _isWatchingAd = true);
      await ref.read(coinsRepositoryProvider).claimDailyReward(withAd: true);
      if (!mounted) return;
      setState(() => _isWatchingAd = false);
      widget.onDone?.call();
      _showSnack(strings.claimedSnack);
    } else {
      await ref.read(coinsRepositoryProvider).claimDailyReward();
      widget.onDone?.call();
      _showSnack(strings.claimedSnack);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    StatusFlash.success(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    final canClaim = coinsRepo.canClaimDailyToday;
    final streakDay = coinsRepo.currentStreakDay;
    final baseCoins = DailyRewards.baseCoins(streakDay);
    final adCoins = DailyRewards.adCoins(streakDay);
    final baseItems = DailyRewards.baseItems(streakDay);
    final adItems = DailyRewards.adItems(streakDay);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.dailyRewardsLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            canClaim
                ? strings.dayOfMax(streakDay, DailyRewards.maxStreak)
                : strings.comeBackTomorrow,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 7-day strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(DailyRewards.maxStreak, (i) {
              final day = i + 1;
              final isDay7 = day == DailyRewards.maxStreak;
              final isToday = day == streakDay;
              final isClaimed = day < streakDay ||
                  (day == streakDay && !canClaim);

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? accent
                          : isClaimed
                          ? accent.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isToday
                            ? accent
                            : isClaimed
                            ? accent.withValues(alpha: 0.4)
                            : textSecondary.withValues(alpha: 0.3),
                        width: isToday ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: isClaimed && !isToday
                          ? Icon(Icons.check_rounded, color: accent, size: 18)
                          : isDay7
                          ? const Text('🎁', style: TextStyle(fontSize: 15))
                          : Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isToday ? Colors.white : textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),

          if (canClaim) ...[
            // Reward summary
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CoinIcon(size: 26),
                const SizedBox(width: 8),
                Text(
                  strings.plusCoins(baseCoins),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                if (baseItems > 0) ...[
                  const SizedBox(width: 10),
                  Text(
                    strings.plusItems(baseItems),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Claim buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isWatchingAd ? null : () => _claim(withAd: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  strings.claimForFree,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isWatchingAd ? null : () => _claim(withAd: true),
                icon: _isWatchingAd
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.play_circle_outline_rounded, size: 20),
                label: Text(
                  _isWatchingAd
                      ? strings.loadingLabel
                      : strings.watchAdCoins(adCoins) +
                      (adItems > baseItems
                          ? ' ${strings.plusItems(adItems - baseItems)}'
                          : ''),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (widget.showDismissButton) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  AudioHapticHelper.playClick();
                  widget.onDone?.call();
                },
                child: Text(
                  strings.notNow,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ] else ...[
            // Already claimed
            Icon(Icons.check_circle_rounded, color: accent, size: 40),
            const SizedBox(height: 8),
            Text(
              strings.claimedToday,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.nextRewardIn(_formatTime(coinsRepo.timeUntilTomorrow)),
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            if (widget.showDismissButton) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  AudioHapticHelper.playClick();
                  widget.onDone?.call();
                },
                child: Text(
                  strings.closeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m}m';
  }
}