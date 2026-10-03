import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/level.dart';
import '../../../main.dart';
import '../../../unity_rewarded_ad.dart';
import '../../../widgets/pop_dialog.dart';
import 'game_dialog_button.dart';

class LevelCompleteDialog extends ConsumerStatefulWidget {
  final LevelModel level;
  final int stars;
  final bool isRandom;
  final int baseCoins;
  final int baseItems;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.stars,
    this.isRandom = false,
    this.baseCoins = 0,
    this.baseItems = 0,
    required this.onNextLevel,
    required this.onMenu,
  });

  @override
  ConsumerState<LevelCompleteDialog> createState() =>
      _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends ConsumerState<LevelCompleteDialog> {
  bool _doubled = false;
  bool _isWatchingAd = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick every second so the cooldown timer refreshes
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _watchAd() async {
    final coinsRepo = ref.read(coinsRepositoryProvider);
    if (!coinsRepo.canWatchRewardedAd || _isWatchingAd) return;

    setState(() => _isWatchingAd = true);

    await UnityRewardedAd.show(
      onRewarded: () async {
        await ref.read(coinsRepositoryProvider).recordAdWatch(
          coinsEarned: widget.baseCoins,
          extraItems: widget.baseItems,
        );
        if (!mounted) return;
        setState(() {
          _doubled = true;
          _isWatchingAd = false;
        });
      },
      onFailed: () {
        if (!mounted) return;
        setState(() => _isWatchingAd = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not available, try again later'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onDismissed: () {
        if (!mounted) return;
        if (_isWatchingAd) {
          setState(() => _isWatchingAd = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);
    const surfaceAlt = Color(0xFF141414);
    const coinYellow = Color(0xFFFFD54F);

    final canWatch = coinsRepo.canWatchRewardedAd && !_doubled;
    final cooldown = coinsRepo.adCooldownRemaining;
    final remaining = coinsRepo.adWatchesRemaining;
    final hasAdReward = widget.baseCoins > 0 && !widget.isRandom;

    return PopDialog(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 32,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Level Complete!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < widget.stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: i < widget.stars
                          ? accent
                          : surface.withValues(alpha: 0.6),
                      size: 38,
                    ),
                  )
                      .animate(
                      delay: Duration(milliseconds: 200 + i * 150))
                      .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
                ),
              ),
              if (widget.baseItems > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      // WRAP IN FLEXIBLE TO PREVENT OVERFLOW
                      Flexible(
                        child: Text(
                          _doubled
                              ? '+${widget.baseItems * 2} RANDOM ITEMS'
                              : '+${widget.baseItems} RANDOM ITEM',
                          overflow: TextOverflow.ellipsis, // Prevents the overflow error
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: accent,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Coins earned
              if (hasAdReward) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: coinYellow.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: coinYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '¢',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF5D4A1A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _doubled
                            ? '+${widget.baseCoins * 2} COINS'
                            : '+${widget.baseCoins} COINS',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: coinYellow,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (_doubled) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.bolt_rounded,
                          color: coinYellow,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                ),
              ],

              const SizedBox(height: 16),

              // Ad button
              if (hasAdReward && !_doubled)
                _buildAdButton(
                  context: context,
                  coinYellow: coinYellow,
                  canWatch: canWatch,
                  cooldown: cooldown,
                  remaining: remaining,
                  textSecondary: textSecondary,
                ),

              const SizedBox(height: 16),

              // Level 500 easter egg
              if (widget.level.levelNumber == 500) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events, color: accent, size: 32),
                      const SizedBox(height: 10),
                      const Text(
                        'You Finished the Game!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (!widget.isRandom) ...[
                GameDialogButton(
                  label: 'Next Level',
                  icon: Icons.play_arrow_rounded,
                  onTap: widget.onNextLevel,
                ),
                const SizedBox(height: 10),
              ],
              GameDialogButton(
                label: 'Home',
                icon: Icons.home_rounded,
                textColor: textPrimary,
                onTap: widget.onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdButton({
    required BuildContext context,
    required Color coinYellow,
    required bool canWatch,
    required int cooldown,
    required int remaining,
    required Color textSecondary,
  }) {
    // Daily cap reached
    if (remaining <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Daily ad limit reached',
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Cooldown active
    if (cooldown > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, color: textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              'Next ad in ${cooldown}s',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Watch ad button
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isWatchingAd ? null : _watchAd,
        icon: _isWatchingAd
            ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: coinYellow,
          ),
        )
            : const Icon(Icons.play_circle_outline_rounded, size: 22),
        label: Text(
          _isWatchingAd
              ? 'Loading ad...'
              : widget.baseItems > 0
              ? 'Watch ad → double coins + items'
              : 'Watch ad → double coins',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: coinYellow,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: coinYellow.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}