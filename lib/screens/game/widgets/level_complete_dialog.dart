import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../core/audio_haptic_helper.dart';
import '../../../data/models/level.dart';
import '../../../data/models/trophy.dart';
import '../../../main.dart';
import '../../../unity_rewarded_ad.dart';
import '../../../widgets/coin_icon.dart';
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

  Future<void> _watchAd() async {
    if (_isWatchingAd || _doubled) return;

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
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);
    const shinyGold = Color(0xFFFFD700);

    final hasAdReward = widget.baseCoins > 0 && !widget.isRandom;

    final hasNewTrophy = !widget.isRandom &&
        TrophyConstants.allTrophies
            .any((t) => t.unlockLevel == widget.level.levelNumber);

    return PopScope(
      canPop: false,
      child: PopDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── STARS IN A RAINBOW ARC WITH TRUE STAR-SHAPED OUTLINE BADGES ──
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(3, (i) {
                  final isCenter = i == 1;
                  final badgeSize = isCenter ? 82.0 : 68.0;
                  final verticalOffset = isCenter ? -14.0 : 14.0;
                  final isEarned = i < widget.stars;

                  return Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: badgeSize,
                        height: badgeSize,
                        child: CustomPaint(
                          painter: StarBadgePainter(
                            isEarned: isEarned,
                            shinyGold: shinyGold,
                            surfaceColor: Colors.yellow.shade500,
                          ),
                          child: Center(
                            child: Icon(
                              isEarned
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: isEarned ? shinyGold : Colors.white24,
                              size: badgeSize * 0.52,
                            ),
                          ),
                        ),
                      )
                          .animate(
                          delay: Duration(milliseconds: 150 + i * 120))
                          .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // ── MAIN POPUP CARD ──
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),

                    // ── COINS GAINED UNDER LEVEL COMPLETE TEXT ──
                    if (hasAdReward) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CoinIcon(size: 22),
                          const SizedBox(width: 8),
                          Text(
                            _doubled
                                ? '+${widget.baseCoins * 2}'
                                : '+${widget.baseCoins}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: accent,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (_doubled) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.bolt_rounded,
                              color: accent,
                              size: 16,
                            ),
                          ],
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                    ],

                    // ── NEW TROPHY NOTIFICATION ──
                    if (hasNewTrophy) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_rounded,
                              color: accent, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'NEW TROPHY',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: accent,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    ],

                    // ── RANDOM ITEMS INFO ──
                    if (widget.baseItems > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _doubled
                                  ? '+${widget.baseItems * 2} RANDOM ITEMS'
                                  : '+${widget.baseItems} RANDOM ITEM',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: accent,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Double Coins Ad Button
                    if (hasAdReward) ...[
                      _buildAdButton(
                        context: context,
                        accent: accent,
                        textSecondary: textSecondary,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Level 500 easter egg
                    if (widget.level.levelNumber == 500) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accent, width: 1.5),
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
                      const SizedBox(height: 12),
                    ] else if (!widget.isRandom) ...[
                      GameDialogButton(
                        label: 'Next Level',
                        icon: Icons.play_arrow_rounded,
                        onTap: widget.onNextLevel,
                      ),
                      const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAdButton({
    required BuildContext context,
    required Color accent,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (_doubled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Text(
            'Coins Doubled!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        if (!_isWatchingAd) _watchAd();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isWatchingAd
                    ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                )
                    : Icon(
                  Icons.play_circle_outline_rounded,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isWatchingAd ? 'Loading...' : 'Double Coins',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 4,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: accent, width: 1),
              ),
              child: Text(
                'AD',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarBadgePainter extends CustomPainter {
  final bool isEarned;
  final Color shinyGold;
  final Color surfaceColor;

  StarBadgePainter({
    required this.isEarned,
    required this.shinyGold,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createRoundedStarPath(size.width, size.height);

    final fillPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = isEarned ? shinyGold : Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = isEarned ? 3.0 : 1.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  Path _createRoundedStarPath(double width, double height) {
    final path = Path();
    final cx = width / 2;
    final cy = height / 2;
    final outerRadius = width / 2 - 6;
    final innerRadius = outerRadius * 0.42;
    const numPoints = 5;

    final pts = <Offset>[];
    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / numPoints) - (math.pi / 2);
      pts.add(
          Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle)));
    }

    const cornerRadius = 5.0;
    final len = pts.length;
    for (int i = 0; i < len; i++) {
      final p1 = pts[(i - 1 + len) % len];
      final p2 = pts[i];
      final p3 = pts[(i + 1) % len];

      final v1 = (p1 - p2);
      final v1Len = v1.distance;
      final d1 = v1 / v1Len;

      final v2 = (p3 - p2);
      final v2Len = v2.distance;
      final d2 = v2 / v2Len;

      final effectiveR = math.min(cornerRadius, math.min(v1Len, v2Len) / 2);

      final start = p2 + d1 * effectiveR;
      final end = p2 + d2 * effectiveR;

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(p2.dx, p2.dy, end.dx, end.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant StarBadgePainter oldDelegate) {
    return oldDelegate.isEarned != isEarned ||
        oldDelegate.shinyGold != shinyGold ||
        oldDelegate.surfaceColor != surfaceColor;
  }
}