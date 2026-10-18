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
  static const int _crossAxisCount = 4;
  static const double _crossSpacing = 10;
  static const double _mainSpacing = 10;
  static const double _hPadding = 16;
  static const double _aspectRatio = 0.85;

  final ScrollController _scrollController = ScrollController();
  bool _didAutoScroll = false;

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
    final cellWidth =
        (viewportWidth - _hPadding * 2 - _crossSpacing * (_crossAxisCount - 1)) /
            _crossAxisCount;
    final cellHeight = cellWidth / _aspectRatio;
    final row = (levelNumber - 1) ~/ _crossAxisCount;
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

  static int _calculateTotalVisible(int highestUnlocked) =>
      highestUnlocked + 10;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final totalVisible = _calculateTotalVisible(progress.highestUnlockedLevel);
    final bgColor = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final accent = AppColors.accent(context);

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
                      fontSize: 22,
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
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount,
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

                  return _LevelCell(
                    levelNumber: levelNum,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    isCurrentLevel: isCurrentLevel,
                    onTap: isUnlocked
                        ? () => _openLevelDetails(levelNum)
                        : null,
                  )
                      .animate(
                    delay: Duration(milliseconds: (index % 20) * 20),
                  )
                      .fadeIn(duration: 200.ms)
                      .scale(
                    begin: const Offset(0.7, 0.7),
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
  final VoidCallback? onTap;

  const _LevelCell({
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrentLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);
    final surface = AppColors.surface(context);

    Color bgColor;
    Color borderColor;
    Color shadowColor;
    Color textColor;

    if (isCurrentLevel) {
      bgColor = surface;
      borderColor = accent;
      shadowColor = accent.withValues(alpha: 0.45);
      textColor = accent;
    } else if (isCompleted) {
      bgColor = accent;
      borderColor = accent;
      shadowColor = accent.withValues(alpha: 0.45);
      textColor = Colors.white;
    } else if (isUnlocked) {
      bgColor = surface;
      borderColor = accent.withValues(alpha: 0.25);
      shadowColor = surface.withValues(alpha: 0.8);
      textColor = textPrimary;
    } else {
      bgColor = surface.withValues(alpha: 0.4);
      borderColor = Colors.transparent;
      shadowColor = Colors.transparent;
      textColor = textMuted;
    }

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          AudioHapticHelper.playClick();
          onTap!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border:
          isUnlocked ? Border.all(color: borderColor, width: 1.5) : null,
          boxShadow: isUnlocked
              ? [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock_outline_rounded, color: textMuted, size: 20)
            else
              Text(
                '$levelNumber',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}