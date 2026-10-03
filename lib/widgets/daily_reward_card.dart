import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/daily_rewards.dart';
import '../main.dart';

class DailyRewardCard extends ConsumerStatefulWidget {
  /// Called when the user finishes claiming (or skips) — used by the popup
  /// to close the dialog. Ignored in Profile screen usage.
  final VoidCallback? onDone;

  /// If true, adds a subtle "Dismiss" text button (popup mode).
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
    if (withAd) {
      if (_isWatchingAd) return;
      setState(() => _isWatchingAd = true);
      // NOTE: Ad logic will be added later. For now just claim.
      await ref.read(coinsRepositoryProvider).claimDailyReward(withAd: true);
      if (!mounted) return;
      setState(() => _isWatchingAd = false);
      widget.onDone?.call();
      _showSnack('Claimed!');
    } else {
      await ref.read(coinsRepositoryProvider).claimDailyReward();
      widget.onDone?.call();
      _showSnack('Claimed!');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    const coinYellow = Color(0xFFFFD54F);

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
            'DAILY REWARDS',
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
                ? 'Day $streakDay of ${DailyRewards.maxStreak}'
                : 'Come back tomorrow',
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
                          color:
                          isToday ? Colors.white : textPrimary,
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
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: coinYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '¢',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF5D4A1A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+$baseCoins coins',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                if (baseItems > 0) ...[
                  const SizedBox(width: 10),
                  Text(
                    '+ $baseItems 🎁',
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
                child: const Text(
                  'Claim for free',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
                      ? 'Loading...'
                      : 'Watch ad → +$adCoins coins'
                      '${adItems > baseItems ? " +${adItems}🎁" : ""}',
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
                onPressed: widget.onDone,
                child: Text(
                  'Not now',
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
              'Claimed today!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Next reward in ${_formatTime(coinsRepo.timeUntilTomorrow)}',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            if (widget.showDismissButton) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onDone,
                child: Text(
                  'Close',
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