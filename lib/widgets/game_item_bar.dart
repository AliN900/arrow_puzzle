import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/items.dart';
import '../main.dart';

class GameItemBar extends ConsumerStatefulWidget {
  final bool isTimedLevel;
  final Map<ItemType, int> usesThisLevel;
  final void Function(ItemType item) onUseItem;
  final bool hasRocks;

  const GameItemBar({
    super.key,
    required this.isTimedLevel,
    required this.hasRocks,
    required this.usesThisLevel,
    required this.onUseItem,
  });

  @override
  ConsumerState<GameItemBar> createState() => _GameItemBarState();
}

class _GameItemBarState extends ConsumerState<GameItemBar> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final coinsRepo = ref.watch(coinsRepositoryProvider);
    final accent = AppColors.accent(context);

    final owned = ItemType.values.where((item) {
      if (item.isTimedOnly && !widget.isTimedLevel) return false;
      if (item == ItemType.bomb && !widget.hasRocks) return false;
      return coinsRepo.getItemCount(item) > 0;
    }).toList();

    if (owned.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface(context).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.6),
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
            child: Icon(
              _expanded ? Icons.close_rounded : Icons.inventory_2_rounded,
              color: accent,
              size: 20,
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(width: 8),
          ...owned.map((item) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ItemButton(
              item: item,
              count: coinsRepo.getItemCount(item),
              disabled: _isDisabled(item),
              remainingUses: _remainingUses(item),
              onTap: () => widget.onUseItem(item),
            ),
          )),
        ],
      ],
    );
  }

  /// Max uses allowed per level.
  int _maxUses(ItemType item) {
    switch (item) {
      case ItemType.hint:
        return 999; // effectively unlimited
      case ItemType.undo:
        return widget.isTimedLevel ? 2 : 1;
      case ItemType.bomb:
        return 1;
      case ItemType.heartFlask:
      case ItemType.timeFreeze:
        return 1;
    }
  }

  /// How many uses remain for display.
  int _remainingUses(ItemType item) {
    final used = widget.usesThisLevel[item] ?? 0;
    return (_maxUses(item) - used).clamp(0, 999);
  }

  bool _isDisabled(ItemType item) {
    if (_remainingUses(item) <= 0) return true;

    // Timed levels: Heart Flask + Time Freeze share a single combined use
    if (widget.isTimedLevel &&
        (item == ItemType.heartFlask || item == ItemType.timeFreeze)) {
      final heartUsed = widget.usesThisLevel[ItemType.heartFlask] ?? 0;
      final timeUsed = widget.usesThisLevel[ItemType.timeFreeze] ?? 0;
      if (heartUsed + timeUsed >= 1) return true;
    }

    return false;
  }
}

class _ItemButton extends StatelessWidget {
  final ItemType item;
  final int count;
  final bool disabled;
  final int remainingUses;
  final VoidCallback onTap;

  const _ItemButton({
    required this.item,
    required this.count,
    required this.disabled,
    required this.remainingUses,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final surface = AppColors.surface(context);

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.35 : 1.0,
        child: Container(
          width: 56,
          height: 56,
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
          child: Stack(
            children: [
              Center(
                child: Icon(item.icon, color: accent, size: 26),
              ),
              // Count badge at bottom center
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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