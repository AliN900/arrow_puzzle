import 'dart:math';
import 'items.dart';

class DailyRewards {
  DailyRewards._();

  static const int maxStreak = 7;
  static const int day7ItemCount = 3;

  // Coin amounts (day → coins)
  static const List<int> _baseCoins = [0, 10, 15, 20, 30, 40, 50, 75];
  static const List<int> _adCoins = [0, 20, 35, 55, 80, 110, 150, 250];

  // Items granted (day → item count). Every 2nd day + day 7.
  static const List<int> _baseItems = [0, 0, 1, 0, 1, 0, 1, 3];
  static const List<int> _adItems   = [0, 0, 2, 0, 2, 0, 2, 6];

  static int baseCoins(int day) =>
      (day < 1 || day > maxStreak) ? 0 : _baseCoins[day];

  static int adCoins(int day) =>
      (day < 1 || day > maxStreak) ? 0 : _adCoins[day];

  static int baseItems(int day) =>
      (day < 1 || day > maxStreak) ? 0 : _baseItems[day];

  static int adItems(int day) =>
      (day < 1 || day > maxStreak) ? 0 : _adItems[day];

  static bool givesItemOnDay(int day) => baseItems(day) > 0;

  static ItemType rollRandomItem() {
    final items = ItemType.values;
    return items[Random().nextInt(items.length)];
  }
}