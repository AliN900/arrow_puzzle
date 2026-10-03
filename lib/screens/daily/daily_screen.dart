import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/daily_rewards.dart';
import '../../main.dart';
import '../../unity_rewarded_ad.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  bool _isWatchingAd = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _claim({required bool withAd}) async {
    if (withAd) {
      if (_isWatchingAd) return;
      setState(() => _isWatchingAd = true);

      await UnityRewardedAd.show(
        onRewarded: () async {
          await ref.read(coinsRepositoryProvider).claimDailyReward(withAd: true);
          if (mounted) {
            setState(() => _isWatchingAd = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reward claimed!')),
            );
          }
        },
        onFailed: () {
          if (mounted) setState(() => _isWatchingAd = false);
        },
        onDismissed: () {
          if (mounted && _isWatchingAd) {
            setState(() => _isWatchingAd = false);
          }
        },
      );
    } else {
      await ref.read(coinsRepositoryProvider).claimDailyReward();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claimed!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final bg = AppColors.background(context);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    const coinYellow = Color(0xFFFFD54F);

    final canClaim = coinsRepo.canClaimDailyToday;
    final streakDay = coinsRepo.currentStreakDay;
    final baseCoins = DailyRewards.baseCoins(streakDay);
    final adCoins = DailyRewards.adCoins(streakDay);
    final isDay7 = streakDay == DailyRewards.maxStreak;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Daily Rewards',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                canClaim
                    ? 'Day $streakDay of ${DailyRewards.maxStreak} · Claim your reward'
                    : 'Day $streakDay of ${DailyRewards.maxStreak} · Come back tomorrow',
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),

              const SizedBox(height: 20),

              // Streak strip
              _buildStreakStrip(
                context: context,
                card: card,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accent: accent,
                streakDay: streakDay,
                canClaim: canClaim,
              ),

              const SizedBox(height: 20),

              // Today's reward card
              if (canClaim)
                _buildClaimCard(
                  context: context,
                  card: card,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accent: accent,
                  coinYellow: coinYellow,
                  baseCoins: baseCoins,
                  adCoins: adCoins,
                  isDay7: isDay7,
                )
              else
                _buildClaimedCard(
                  context: context,
                  card: card,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accent: accent,
                  coinYellow: coinYellow,
                  timeUntil: coinsRepo.timeUntilTomorrow,
                  lastItemType: coinsRepo.lastWeekItemType,
                  lastItemCount: coinsRepo.lastWeekItemCount,
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakStrip({
    required BuildContext context,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required int streakDay,
    required bool canClaim,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
                width: 36,
                height: 36,
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
                    width: isToday ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: isClaimed && !isToday
                      ? Icon(Icons.check_rounded, color: accent, size: 20)
                      : isDay7
                      ? const Text('🎁', style: TextStyle(fontSize: 18))
                      : Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isToday ? Colors.white : textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isToday ? 'Today' : 'D$day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday ? accent : textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildClaimCard({
    required BuildContext context,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required Color coinYellow,
    required int baseCoins,
    required int adCoins,
    required bool isDay7,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            "TODAY'S REWARD",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: coinYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '¢',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D4A1A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '+$baseCoins coins',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          if (isDay7) ...[
            const SizedBox(height: 8),
            Text(
              '+ 3 random items 🎁',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
          const SizedBox(height: 20),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isWatchingAd ? null : () => _claim(withAd: true),
              icon: _isWatchingAd
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.play_circle_outline_rounded, size: 22),
              label: Text(
                _isWatchingAd
                    ? 'Loading...'
                    : 'Watch ad → +$adCoins coins',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedCard({
    required BuildContext context,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required Color coinYellow,
    required Duration timeUntil,
    required String? lastItemType,
    required int lastItemCount,
  }) {
    final h = timeUntil.inHours;
    final m = timeUntil.inMinutes % 60;
    final s = timeUntil.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, color: accent, size: 48),
          const SizedBox(height: 12),
          Text(
            'Claimed today!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Next reward in ${h}h ${m}m ${s}s',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          if (lastItemType != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Last week: $lastItemCount× ${lastItemType[0].toUpperCase()}${lastItemType.substring(1)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}