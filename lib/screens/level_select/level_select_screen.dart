import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/level_details_dialog.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  static const double _crossSpacing = 12;
  static const double _mainSpacing = 12;
  static const double _hPadding = 16;
  static const double _aspectRatio = 0.82;

  final ScrollController _scrollController = ScrollController();
  bool _didAutoScroll = false;

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 900) return 6; // Large Tablets / Desktop
    if (screenWidth >= 600) return 5; // Small Tablets / Foldables
    return 4; // Phones
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleAutoScroll() {
    if (_didAutoScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoScroll());
  }

  void _tryAutoScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoScroll());
      return;
    }
    _didAutoScroll = true;
    final progress = ref.read(progressRepositoryProvider);
    final target = _offsetForLevel(progress.currentLevel);
    _scrollController.jumpTo(target);
  }

  double _offsetForLevel(int levelNumber) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(viewportWidth);
    final cellWidth = (viewportWidth - (_hPadding * 2) - (_crossSpacing * (crossAxisCount - 1))) / crossAxisCount;
    final cellHeight = cellWidth / _aspectRatio;
    final row = (levelNumber - 1) ~/ crossAxisCount;
    final rowOffset = row * (cellHeight + _mainSpacing);
    final viewportHeight = _scrollController.position.viewportDimension;
    final centered = rowOffset - viewportHeight / 2 + cellHeight / 2;
    return centered.clamp(0.0, _scrollController.position.maxScrollExtent);
  }

  void _animateToCurrent() {
    if (!_scrollController.hasClients) return;
    final progress = ref.read(progressRepositoryProvider);
    final target = _offsetForLevel(progress.currentLevel);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openLevelDetails(int levelNumber) async {
    final start = await LevelDetailsDialog.show(context, levelNumber);
    if (start == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(level: levelNumber)),
      );
    }
  }

  static int _calculateTotalVisible(int highestUnlocked) => highestUnlocked + 10;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final totalVisible = _calculateTotalVisible(progress.highestUnlockedLevel);
    final bgColor = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final accent = AppColors.accent(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    _scheduleAutoScroll();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _HeaderIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      accent: accent,
                      onTap: () {
                        AudioHapticHelper.playClick();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Text(
                    strings.levelSelectButton,
                    style: TextStyle(
                      fontSize: screenWidth >= 600 ? 28 : 22,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _HeaderIconButton(
                      icon: Icons.my_location_rounded,
                      accent: accent,
                      onTap: () {
                        AudioHapticHelper.playClick();
                        _animateToCurrent();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: _hPadding,
                  vertical: 8,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: _mainSpacing,
                  crossAxisSpacing: _crossSpacing,
                  childAspectRatio: _aspectRatio,
                ),
                itemCount: totalVisible,
                itemBuilder: (context, index) {
                  final levelNum = index + 1;
                  final isUnlocked = progress.isLevelUnlocked(levelNum);
                  final isCompleted = progress.isLevelCompleted(levelNum);
                  final isCurrentLevel = levelNum == progress.currentLevel;
                  final stars = progress.getStarsForLevel(levelNum);

                  return _LevelCell(
                    levelNumber: levelNum,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    isCurrentLevel: isCurrentLevel,
                    stars: stars,
                    onTap: isUnlocked ? () => _openLevelDetails(levelNum) : null,
                  )
                      .animate(
                    delay: Duration(milliseconds: (index % 20) * 15),
                  )
                      .fadeIn(duration: 180.ms)
                      .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: accent, size: 20),
      ),
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrentLevel;
  final int stars; // 0 to 3
  final VoidCallback? onTap;

  const _LevelCell({
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrentLevel,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeAccent = AppColors.accent(context);

    final Color cardBgColor = isUnlocked ? themeAccent : const Color(0xFF8E8E93);

    final Color strokeColor = isUnlocked
        ? HSLColor.fromColor(themeAccent)
        .withLightness((HSLColor.fromColor(themeAccent).lightness - 0.18).clamp(0.0, 1.0))
        .toColor()
        : const Color(0xFF505054);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          AudioHapticHelper.playClick();
          onTap!();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = constraints.maxWidth;
          final tileHeight = constraints.maxHeight;

          // Proportional Sizing to guarantee zero UI breakage across screen sizes
          final centerStarSize = (tileHeight * 0.22).clamp(14.0, 32.0);
          final sideStarSize = centerStarSize * 0.78;
          final maxLevelFontSize = (tileHeight * 0.38).clamp(24.0, 52.0);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(tileWidth * 0.2),
              border: Border.all(
                color: isCurrentLevel ? Colors.white : strokeColor,
                width: isCurrentLevel ? 3.0 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: strokeColor,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
                if (isCurrentLevel)
                  BoxShadow(
                    color: themeAccent.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: tileWidth * 0.04,
              vertical: tileHeight * 0.05,
            ),
            child: Center(
              child: !isUnlocked
                  ? Icon(
                Icons.lock_rounded,
                color: const Color(0xFF48484A),
                size: tileHeight * 0.32,
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── TOP: Dynamic Curved Arch Stars ─────────────────
                  _buildArchStars(
                    centerSize: centerStarSize,
                    sideSize: sideStarSize,
                    tileWidth: tileWidth,
                    tileHeight: tileHeight,
                  ),
                  SizedBox(height: tileHeight * 0.02),

                  // ── BOTTOM: Fluid Level Number ──────────────────────
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$levelNumber',
                          style: TextStyle(
                            fontSize: maxLevelFontSize,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArchStars({
    required double centerSize,
    required double sideSize,
    required double tileWidth,
    required double tileHeight,
  }) {
    final horizontalShift = (tileWidth * 0.03).clamp(2.0, 6.0);
    final verticalShift = (tileHeight * 0.03).clamp(2.0, 6.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left Star (tilted left & lowered)
        Transform.translate(
          offset: Offset(horizontalShift, verticalShift),
          child: Transform.rotate(
            angle: -0.35,
            child: _buildStarIcon(0, size: sideSize),
          ),
        ),
        // Center Star (raised arch apex)
        Transform.translate(
          offset: Offset(0, -verticalShift),
          child: _buildStarIcon(1, size: centerSize),
        ),
        // Right Star (tilted right & lowered)
        Transform.translate(
          offset: Offset(-horizontalShift, verticalShift),
          child: Transform.rotate(
            angle: 0.35,
            child: _buildStarIcon(2, size: sideSize),
          ),
        ),
      ],
    );
  }

  Widget _buildStarIcon(int index, {required double size}) {
    final bool isStarEarned = isUnlocked && (index < stars);
    return Icon(
      Icons.star_rounded,
      size: size,
      color: isStarEarned
          ? const Color(0xFFFFC107) // Vibrant Amber Gold
          : Colors.black.withValues(alpha: 0.22), // Recessed dark star outline
    );
  }
}