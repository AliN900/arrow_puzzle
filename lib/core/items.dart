import 'package:flutter/material.dart';

enum ItemType {
  bomb,
  hint,
  undo,
  heartFlask,
  timeFreeze;

  String get displayName {
    switch (this) {
      case ItemType.bomb:
        return 'Bomb';
      case ItemType.hint:
        return 'Hint';
      case ItemType.undo:
        return 'Undo';
      case ItemType.heartFlask:
        return 'Heart Flask';
      case ItemType.timeFreeze:
        return 'Time Freeze';
    }
  }

  String get description {
    switch (this) {
      case ItemType.bomb:
        return 'Destroy one rock';
      case ItemType.hint:
        return 'Reveal the next solvable arrow';
      case ItemType.undo:
        return 'Bring back the last escaped arrow';
      case ItemType.heartFlask:
        return 'Restore one heart';
      case ItemType.timeFreeze:
        return 'Add 30 seconds to the timer';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemType.bomb:
        return Icons.local_fire_department_rounded;
      case ItemType.hint:
        return Icons.lightbulb_rounded;
      case ItemType.undo:
        return Icons.undo_rounded;
      case ItemType.heartFlask:
        return Icons.favorite_rounded;
      case ItemType.timeFreeze:
        return Icons.timer_rounded;
    }
  }

  /// Only used on timed levels — hidden otherwise.
  bool get isTimedOnly => this == ItemType.timeFreeze;

  /// Only enabled during play after an arrow has escaped.
  bool get needsEscapedArrow => this == ItemType.undo;
}

class ItemBundle {
  final int count;
  final int price;
  const ItemBundle({required this.count, required this.price});
}

class ItemPricing {
  ItemPricing._();

  /// Bundle options per item. First entry is the single-purchase price.
  /// Some items have volume discounts, e.g. Heart Flask ×2 / ×3.
  static const Map<ItemType, List<ItemBundle>> bundles = {
    ItemType.hint: [
      ItemBundle(count: 1, price: 50),
      ItemBundle(count: 5, price: 220), // 12% off
    ],
    ItemType.bomb: [
      ItemBundle(count: 1, price: 100),
      ItemBundle(count: 5, price: 450), // 10% off
    ],
    ItemType.timeFreeze: [
      ItemBundle(count: 1, price: 100),
      ItemBundle(count: 3, price: 280), // 7% off
    ],
    ItemType.heartFlask: [
      ItemBundle(count: 1, price: 150),
      ItemBundle(count: 2, price: 280), // 7% off
      ItemBundle(count: 3, price: 400), // 11% off
    ],
    ItemType.undo: [
      ItemBundle(count: 1, price: 200),
      ItemBundle(count: 3, price: 550), // 8% off
    ],
  };

  static List<ItemBundle> bundlesFor(ItemType item) =>
      bundles[item] ?? const [ItemBundle(count: 1, price: 100)];

  static int minPrice(ItemType item) =>
      bundlesFor(item).first.price;
}

