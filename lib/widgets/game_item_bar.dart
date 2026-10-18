import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/audio_haptic_helper.dart';
import '../core/game_mode.dart';
import '../core/items.dart';
import '../main.dart';

class GameItemBar extends ConsumerStatefulWidget {
  final bool isTimedLevel;
  final Map<ItemType, int> usesThisLevel;
  final void Function(ItemType item) onUseItem;
  final bool hasRocks;
  final GameMode gameMode;

  const GameItemBar({
    super.key,
    required this.isTimedLevel,
    required this.hasRocks,
    required this.usesThisLevel,
    required this.onUseItem,
    this.gameMode = GameMode.classic,
  });

  @override
  ConsumerState<GameItemBar> createState() => _GameItemBarState();
}

class _GameItemBarState extends ConsumerState<GameItemBar>
    with SingleTickerProviderStateMixin {
  static const double _kButtonSize = 56.0;
  static const double _kGap = 10.0;

  bool _expanded = true;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    AudioHapticHelper.playClick();
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  /// Toggle icon does a full 360° spin when opening and closing.
  Animation<double> get _rotation => Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
    parent: _animController,
    curve: Curves.easeInOutBack,
  ));

  /// Staggered fade for each item.
  Animation<double> _itemFade(int index, int total) {
    final stagger = total > 1 ? 0.35 / (total - 1) : 0.0;
    final start = (index * stagger).clamp(0.0, 0.65);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  /// Staggered pop-in: scale 0 → 1.5 → 1.0.
  /// On reverse (closing), plays back as 1.0 → 1.5 → 0.0 with fade out.
  Animation<double> _itemScale(int index, int total) {
    final stagger = total > 1 ? 0.35 / (total - 1) : 0.0;
    final start = (index * stagger).clamp(0.0, 0.65);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final accent = AppColors.accent(context);

    final owned = ItemType.values.where((item) {
      // Zen mode — no items at all.
      if (widget.gameMode == GameMode.zen) return false;

      // Time Blitz — only timeFreeze and undo make sense.
      if (widget.gameMode == GameMode.timeBlitz) {
        if (item != ItemType.timeFreeze && item != ItemType.undo) return false;
      }

      if (item.isTimedOnly && !widget.isTimedLevel) return false;
      if (item == ItemType.bomb && !widget.hasRocks) return false;
      return coinsRepo.getItemCount(item) > 0;
    }).toList();

    if (owned.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Toggle button (same size as items) ──
        GestureDetector(
          onTap: _toggle,
          child: _CircleButton(
            size: _kButtonSize,
            accent: accent,
            child: RotationTransition(
              turns: _rotation,
              child: Icon(
                Icons.inventory_2_rounded,
                color: accent,
                size: 24,
              ),
            ),
          ),
        ),

        // ── Items (staggered pop-in when opening, pop-out when closing) ──
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            if (_animController.value < 0.001) {
              return const SizedBox.shrink();
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < owned.length; i++) ...[
                  const SizedBox(width: _kGap),
                  FadeTransition(
                    opacity: _itemFade(i, owned.length),
                    child: ScaleTransition(
                      scale: _itemScale(i, owned.length),
                      child: _ItemButton(
                        item: owned[i],
                        count: coinsRepo.getItemCount(owned[i]),
                        disabled: _isDisabled(owned[i]),
                        size: _kButtonSize,
                        accent: accent,
                        onTap: () => widget.onUseItem(owned[i]),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  int _maxUses(ItemType item) {
    switch (item) {
      case ItemType.hint:
        return 999;
      case ItemType.undo:
        return widget.isTimedLevel ? 2 : 999;
      case ItemType.bomb:
        return 1;
      case ItemType.heartFlask:
      case ItemType.timeFreeze:
        return 1;
    }
  }

  int _remainingUses(ItemType item) {
    final used = widget.usesThisLevel[item] ?? 0;
    return (_maxUses(item) - used).clamp(0, 999);
  }

  bool _isDisabled(ItemType item) {
    if (_remainingUses(item) <= 0) return true;

    if (widget.isTimedLevel &&
        (item == ItemType.heartFlask || item == ItemType.timeFreeze)) {
      final heartUsed = widget.usesThisLevel[ItemType.heartFlask] ?? 0;
      final timeUsed = widget.usesThisLevel[ItemType.timeFreeze] ?? 0;
      if (heartUsed + timeUsed >= 1) return true;
    }

    return false;
  }
}

/// Shared circular button shell — used by both the toggle and item buttons
/// so they always render at the same size with the same visual style.
class _CircleButton extends StatelessWidget {
  final double size;
  final Color accent;
  final Widget child;

  const _CircleButton({
    required this.size,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        border: Border.all(
          color: accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _ItemButton extends StatelessWidget {
  final ItemType item;
  final int count;
  final bool disabled;
  final double size;
  final Color accent;
  final VoidCallback onTap;

  const _ItemButton({
    required this.item,
    required this.count,
    required this.disabled,
    required this.size,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled
          ? null
          : () {
        AudioHapticHelper.playClick();
        onTap();
      },
      child: Opacity(
        opacity: disabled ? 0.35 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _CircleButton(
              size: size,
              accent: accent,
              child: Icon(
                item.icon,
                color: accent,
                size: 24,
              ),
            ),
            // ── Count badge — top-right, blue circle (matches reference) ──
            PositionedDirectional(
              top: -4,
              end: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2979FF),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}