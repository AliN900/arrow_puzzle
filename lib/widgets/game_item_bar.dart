import 'dart:math' as math;

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
  final bool isBombArmed;
  final VoidCallback? onDeselectBomb;

  const GameItemBar({
    super.key,
    required this.isTimedLevel,
    required this.hasRocks,
    required this.usesThisLevel,
    required this.onUseItem,
    this.gameMode = GameMode.classic,
    this.isBombArmed = false,
    this.onDeselectBomb,
  });

  @override
  ConsumerState<GameItemBar> createState() => _GameItemBarState();
}

class _GameItemBarState extends ConsumerState<GameItemBar>
    with SingleTickerProviderStateMixin {
  static const double _kButtonSize = 56.0;
  static const double _kGap = 10.0;


  bool _expanded = false;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: 0.0,
    );
  }



  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    AudioHapticHelper.playClick();

    final wasExpanded = _expanded;

    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });

    // If we just collapsed and the bomb is armed, deselect it.
    if (wasExpanded && widget.isBombArmed) {
      if (widget.onDeselectBomb != null) {
        widget.onDeselectBomb!();
      } else {
        widget.onUseItem(ItemType.bomb); // fallback: toggle
      }
    }
  }

  Animation<double> _itemFade(int index, int total) {
    final stagger = total > 1 ? 0.35 / (total - 1) : 0.0;
    final start = (index * stagger).clamp(0.0, 0.65);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

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
      if (widget.gameMode == GameMode.zen) return false;
      if (widget.gameMode == GameMode.timeBlitz) {
        if (item != ItemType.timeFreeze && item != ItemType.undo) return false;
      }
      if (item.isTimedOnly && !widget.isTimedLevel) return false;
      if (item == ItemType.bomb && !widget.hasRocks && !widget.isBombArmed) {
        return false;
      }
      return coinsRepo.getItemCount(item) > 0;
    }).toList();

    if (owned.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 24;

        return AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            final v = _animController.value;

            return SizedBox(
              height: _kButtonSize + 32, // 88
              width: w,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // ── Items (grow into the space the bag vacates) ──
                  if (v > 0.001)
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(left: _kButtonSize * (1 - v)),
                        child: ClipRect(
                          child: SingleChildScrollView(
                            key: const PageStorageKey('item_bar_scroll'),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                                left: _kGap, right: 10, top: 16, bottom: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < owned.length; i++) ...[
                                  if (i > 0) const SizedBox(width: _kGap),
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
                                        isSelected: owned[i] == ItemType.bomb &&
                                            widget.isBombArmed,
                                        onTap: () => widget.onUseItem(owned[i]),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Bag ↔ X (top layer, morphs + glides up) ──
                  Positioned(
                    left: 0,
                    top: 16 - 28 * v,
                    child: Transform.scale(
                      scale: 1.0 - 0.40 * v,
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _toggle,
                        child: _CircleButton(
                          size: _kButtonSize,
                          accent: accent,
                          child: _BagToXIcon(
                            progress: _animController,
                            accent: accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

class _CircleButton extends StatelessWidget {
  final double size;
  final Color accent;
  final Widget child;
  final bool isSelected;

  const _CircleButton({
    required this.size,
    required this.accent,
    required this.child,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(context);
    final activeColor = isSelected ? Colors.redAccent : accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.redAccent : accent.withValues(alpha: 0.5),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.redAccent.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
            offset: isSelected ? Offset.zero : const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(color: activeColor),
          child: child,
        ),
      ),
    );
  }
}

class _ItemButton extends StatefulWidget {
  final ItemType item;
  final int count;
  final bool disabled;
  final double size;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemButton({
    required this.item,
    required this.count,
    required this.disabled,
    required this.size,
    required this.accent,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<_ItemButton> createState() => _ItemButtonState();
}

class _ItemButtonState extends State<_ItemButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _ItemButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSelected && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled
          ? null
          : () {
        AudioHapticHelper.playClick();
        widget.onTap();
      },
      child: Opacity(
        opacity: widget.disabled ? 0.35 : 1.0,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _CircleButton(
                size: widget.size,
                accent: widget.accent,
                isSelected: widget.isSelected,
                child: Icon(
                  widget.item.icon,
                  color: widget.isSelected ? Colors.redAccent : widget.accent,
                  size: 24,
                ),
              ),
              PositionedDirectional(
                top: -4,
                end: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.count}',
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
      ),
    );
  }
}

class _BagToXIcon extends StatelessWidget {
  final Animation<double> progress;
  final Color accent;
  const _BagToXIcon({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final v = progress.value.clamp(0.0, 1.0);
        return SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -v * math.pi / 2,
                child: Opacity(
                  opacity: (1.0 - v).clamp(0.0, 1.0),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: accent,
                    size: 24,
                  ),
                ),
              ),
              Transform.rotate(
                angle: (1 - v) * math.pi / 2,
                child: Opacity(
                  opacity: v,
                  child: Icon(
                    Icons.close_rounded,
                    color: accent,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}