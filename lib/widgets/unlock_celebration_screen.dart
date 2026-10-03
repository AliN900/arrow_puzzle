import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/board_themes.dart';
import 'confetti_field.dart';

class UnlockCelebrationScreen extends StatelessWidget {
  final BoardTheme board;
  final int coinsEarned;
  final VoidCallback onResume;
  final VoidCallback onMainMenu;
  final VoidCallback onCheckInventory;

  const UnlockCelebrationScreen({
    super.key,
    required this.board,
    this.coinsEarned = 0,
    required this.onResume,
    required this.onMainMenu,
    required this.onCheckInventory,
  });

  @override
  Widget build(BuildContext context) {
    final colors = BoardThemes.get(board);
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;

    // Preview scales to fit BOTH width and height.
    // On a tall phone: preview = 220 (max)
    // On a small phone: preview shrinks to fit remaining vertical space.
    final previewByWidth = screenW - 100;
    final previewByHeight = screenH * 0.30;
    final previewSize =
    math.min(previewByWidth, previewByHeight).clamp(120.0, 220.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B9BFF), Color(0xFF2E5CB8)],
          ),
        ),
        child: Stack(
          children: [
            // Confetti
            const Positioned.fill(child: ConfettiField(count: 100)),

            // Content — scrollable for very small screens
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Title
                            const Text(
                              'Congratulations!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Color(0x55000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(
                              begin: -0.3,
                              end: 0,
                              curve: Curves.easeOut,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'New board unlocked',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.5,
                              ),
                            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                            const SizedBox(height: 24),

                            // Board card
                            _buildBoardCard(colors, previewSize),

                            const SizedBox(height: 20),

                            // Coin pill
                            if (coinsEarned > 0) _buildCoinPill(),

                            if (coinsEarned > 0) const SizedBox(height: 20),

                            // Buttons
                            _buildResumeButton(),
                            const SizedBox(height: 12),
                            _buildInventoryButton(),
                            const SizedBox(height: 8),
                            _buildMainMenuButton(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardCard(BoardColors colors, double previewSize) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview
          Container(
            width: previewSize,
            height: previewSize,
            decoration: BoxDecoration(
              gradient: colors.gradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2E5CB8).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _BoardPreviewPainter(
                    pattern: colors.pattern,
                    color: colors.patternColor,
                    seed: board.index * 9137 + 42,
                  ),
                ),
                Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colors.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Board name — safe width, ellipsis if needed
          SizedBox(
            width: previewSize,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                board.name[0].toUpperCase() + board.name.substring(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E5CB8),
                  letterSpacing: 1,
                ),
                maxLines: 1,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle — same safe width
          SizedBox(
            width: previewSize,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Added to your inventory',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 250.ms)
        .scale(
      begin: const Offset(0.6, 0.6),
      end: const Offset(1.0, 1.0),
      duration: 600.ms,
      curve: Curves.elasticOut,
    )
        .fadeIn(duration: 200.ms);
  }

  Widget _buildCoinPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD54F),
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
          const SizedBox(width: 10),
          Text(
            '+$coinsEarned COINS',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildResumeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onResume,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD54F),
          foregroundColor: const Color(0xFF5D4A1A),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Resume',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildInventoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onCheckInventory,
        icon: const Icon(Icons.inventory_2_rounded, size: 20),
        label: const Text(
          'Check Inventory',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildMainMenuButton() {
    return TextButton(
      onPressed: onMainMenu,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.85),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text(
        'Main Menu',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    )
        .animate(delay: 700.ms)
        .fadeIn(duration: 300.ms);
  }
}

// ============================================================
// BOARD PREVIEW PAINTER
// ============================================================

class _BoardPreviewPainter extends CustomPainter {
  final BoardPattern pattern;
  final Color color;
  final int seed;

  _BoardPreviewPainter({
    required this.pattern,
    required this.color,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    BoardThemes.paintPattern(
      canvas,
      Rect.fromLTWH(0, 0, size.width, size.height),
      pattern,
      color,
      seed,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPreviewPainter old) =>
      old.pattern != pattern || old.color != color || old.seed != seed;
}