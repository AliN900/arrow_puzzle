import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../../core/app_colors.dart';
import '../../../core/audio_haptic_helper.dart';
import '../../../core/game_mode.dart';
import '../../../data/models/level.dart';
import '../../../data/models/trophy.dart';
import '../../../main.dart';
import '../../../unity_rewarded_ad.dart';
import '../../../widgets/coin_icon.dart';
import '../../../widgets/pop_dialog.dart';
import '../../../widgets/status_flash.dart';
import 'game_dialog_button.dart';

class LevelCompleteDialog extends ConsumerStatefulWidget {
  final LevelModel level;
  final int stars;
  final bool isRandom;
  final int baseCoins;
  final int baseItems;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;
  final GameMode gameMode;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.stars,
    this.isRandom = false,
    this.baseCoins = 0,
    this.baseItems = 0,
    required this.onNextLevel,
    this.gameMode = GameMode.classic,
    required this.onMenu,
  });

  @override
  ConsumerState<LevelCompleteDialog> createState() =>
      _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends ConsumerState<LevelCompleteDialog> {
  bool _doubled = false;
  bool _isWatchingAd = false;

  Future<void> _watchAd(AppStrings strings) async {
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
        StatusFlash.fail(context, strings.adNotAvailable);
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
    final strings = AppStrings.of(context);
    final accent = AppColors.accent(context);
    const textPrimary = Colors.white;
    const textSecondary = Colors.white70;
    const surface = Color(0xFF1E1E1E);


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
            _buildStars(),
            const SizedBox(height: 14),

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
                    Text(
                      strings.levelCompleteTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),

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
                              strings.levelCompleteNewTrophy,
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

                    if (widget.baseItems > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              strings.levelCompleteRandomItems(
                                _doubled
                                    ? widget.baseItems * 2
                                    : widget.baseItems,
                              ),
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

                    if (hasAdReward) ...[
                      _buildAdButton(
                        context: context,
                        strings: strings,
                        accent: accent,
                        textSecondary: textSecondary,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (widget.level.levelNumber == 500 &&
                        widget.gameMode != GameMode.endlessRush) ...[
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
                            Text(
                              strings.levelCompleteFinishedGame,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else if (!widget.isRandom &&
                        widget.gameMode != GameMode.endlessRush) ...[
                      GameDialogButton(
                        label: strings.levelCompleteNextLevel,
                        icon: Icons.play_arrow_rounded,
                        onTap: widget.onNextLevel,
                      ),
                      const SizedBox(height: 12),
                    ],
                    GameDialogButton(
                      label: strings.homeButton,
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

  Widget _buildStars() {
    const shinyGold = Color(0xFFFFD700);
    final count = widget.stars.clamp(1, 3);

    // 1 star: single large centred
    if (count == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _starBadge(index: 0, size: 82, offsetY: 0, shinyGold: shinyGold),
          ],
        ),
      );
    }

    // 2 stars: side by side, equal size
    if (count == 2) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _starBadge(index: 0, size: 78, offsetY: 0, shinyGold: shinyGold),
            const SizedBox(width: 14),
            _starBadge(index: 1, size: 78, offsetY: 0, shinyGold: shinyGold),
          ],
        ),
      );
    }

    // 3 stars: middle raised and larger — matches the reference image
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _starBadge(index: 0, size: 68, offsetY: 14, shinyGold: shinyGold),
          const SizedBox(width: 14),
          _starBadge(index: 1, size: 82, offsetY: -14, shinyGold: shinyGold),
          const SizedBox(width: 14),
          _starBadge(index: 2, size: 68, offsetY: 14, shinyGold: shinyGold),
        ],
      ),
    );
  }

  Widget _starBadge({
    required int index,
    required double size,
    required double offsetY,
    required Color shinyGold,
  }) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: StarBadgePainter(
            isEarned: true,
            shinyGold: shinyGold,
            surfaceColor: Colors.yellow.shade500,
          ),
          child: Center(
            child: Icon(
              Icons.star_rounded,
              color: shinyGold,
              size: size * 0.52,
            ),
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: 150 + index * 120))
          .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        duration: 500.ms,
        curve: Curves.elasticOut,
      ),
    );
  }

  Widget _buildAdButton({
    required BuildContext context,
    required AppStrings strings,
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
            strings.levelCompleteCoinsDoubled,
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
        if (!_isWatchingAd) _watchAd(strings);
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
                  _isWatchingAd
                      ? strings.loadingLabel
                      : strings.levelCompleteDoubleCoins,
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
                strings.adBadge,
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

