import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/daily_rewards.dart';
import '../../core/items.dart';

class CoinsRepository extends ChangeNotifier {
  late Box _box;

  int _coins = 0;
  int _adWatchesToday = 0;
  DateTime? _lastAdWatchTime;
  DateTime? _lastResetDate;
  int _loginStreak = 0;
  DateTime? _lastLoginDate;
  // Daily streak state
  int _dailyStreak = 0;
  DateTime? _lastDailyClaimDate;
  String? _lastWeekItemType;
  int _lastWeekItemCount = 0;

// Item inventory
  final Map<String, int> _items = {};

  int get coins => _coins;
  int get adWatchesToday => _adWatchesToday;
  int get adWatchesRemaining => (5 - _adWatchesToday).clamp(0, 5);
  int get loginStreak => _loginStreak;
  int get dailyStreak => _dailyStreak;
  String? get lastWeekItemType => _lastWeekItemType;
  int get lastWeekItemCount => _lastWeekItemCount;

  /// True if today's reward hasn't been claimed yet.
  bool get canClaimDailyToday {
    if (_lastDailyClaimDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_lastDailyClaimDate!.year,
        _lastDailyClaimDate!.month, _lastDailyClaimDate!.day);
    return !today.isAtSameMomentAs(lastDay);
  }

  /// What day (1-7) the user is on right now, for display purposes.
  int get currentStreakDay {
    if (_lastDailyClaimDate == null) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_lastDailyClaimDate!.year,
        _lastDailyClaimDate!.month, _lastDailyClaimDate!.day);
    final daysSince = today.difference(lastDay).inDays;

    if (daysSince == 0) return _dailyStreak;
    if (daysSince == 1) {
      final next = _dailyStreak + 1;
      return next > DailyRewards.maxStreak ? 1 : next;
    }
    return 1;
  }

  Duration get timeUntilTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// True if the player can watch another reward ad right now.
  bool get canWatchRewardedAd {
    if (adWatchesRemaining <= 0) return false;
    if (_lastAdWatchTime == null) return true;
    final secondsSince = DateTime.now().difference(_lastAdWatchTime!).inSeconds;
    return secondsSince >= 60;
  }

  /// Seconds remaining before another ad can be watched. 0 if ready.
  int get adCooldownRemaining {
    if (_lastAdWatchTime == null) return 0;
    final seconds = 60 - DateTime.now().difference(_lastAdWatchTime!).inSeconds;
    return seconds.clamp(0, 60);
  }

  CoinsRepository._();

  static Future<CoinsRepository> create() async {
    final repo = CoinsRepository._();
    await repo._init();
    return repo;
  }

  Future<void> _init() async {
    _box = await Hive.openBox('coins');
    _load();
    _checkDailyReset();
  }

  Future<int> claimDailyReward({bool withAd = false}) async {
    if (!canClaimDailyToday) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int newStreak = 1;

    if (_lastDailyClaimDate != null) {
      final lastDay = DateTime(_lastDailyClaimDate!.year,
          _lastDailyClaimDate!.month, _lastDailyClaimDate!.day);
      final daysSince = today.difference(lastDay).inDays;
      if (daysSince == 1) {
        newStreak = _dailyStreak + 1;
        if (newStreak > DailyRewards.maxStreak) newStreak = 1;
      }
    }

    _dailyStreak = newStreak;
    _lastDailyClaimDate = now;

    // Coins
    final coins = withAd
        ? DailyRewards.adCoins(newStreak)
        : DailyRewards.baseCoins(newStreak);
    _coins += coins;

    // Items
    final itemCount = withAd
        ? DailyRewards.adItems(newStreak)
        : DailyRewards.baseItems(newStreak);
    if (itemCount > 0) {
      for (int i = 0; i < itemCount; i++) {
        final item = DailyRewards.rollRandomItem();
        _items[item.name] = (_items[item.name] ?? 0) + 1;
        _lastWeekItemType = item.name;
      }
      _lastWeekItemCount = itemCount;
    }

    await _save();
    notifyListeners();
    return coins;
  }

  /// DEV ONLY — force-advances the daily streak by one day so you can test
  /// the full 7-day path without waiting. Awards the base reward each time.
  Future<int> debugAdvanceDailyStreak() async {
    final nextDay =
    _dailyStreak >= DailyRewards.maxStreak ? 1 : _dailyStreak + 1;
    _dailyStreak = nextDay;
    _lastDailyClaimDate = DateTime.now();

    final coins = DailyRewards.baseCoins(nextDay);
    _coins += coins;

    final itemCount = DailyRewards.baseItems(nextDay);
    for (int i = 0; i < itemCount; i++) {
      final item = DailyRewards.rollRandomItem();
      _items[item.name] = (_items[item.name] ?? 0) + 1;
      _lastWeekItemType = item.name;
    }
    if (itemCount > 0) _lastWeekItemCount = itemCount;

    await _save();
    notifyListeners();
    debugPrint('🎁 DEV: Day $nextDay, +$coins coins, +$itemCount items, total ${_coins}');
    return coins;
  }

  void _load() {
    _coins = _box.get('coins', defaultValue: 0);
    _adWatchesToday = _box.get('adWatchesToday', defaultValue: 0);
    _loginStreak = _box.get('loginStreak', defaultValue: 0);

    final lastAdStr = _box.get('lastAdWatchTime');
    if (lastAdStr != null) {
      _lastAdWatchTime = DateTime.tryParse(lastAdStr);
    }
    final lastResetStr = _box.get('lastResetDate');
    if (lastResetStr != null) {
      _lastResetDate = DateTime.tryParse(lastResetStr);
    }
    final lastLoginStr = _box.get('lastLoginDate');
    if (lastLoginStr != null) {
      _lastLoginDate = DateTime.tryParse(lastLoginStr);
    }
    _dailyStreak = _box.get('dailyStreak', defaultValue: 0);
    final lastClaimStr = _box.get('lastDailyClaimDate');
    if (lastClaimStr != null) {
      _lastDailyClaimDate = DateTime.tryParse(lastClaimStr);
    }
    _lastWeekItemType = _box.get('lastWeekItemType');
    _lastWeekItemCount = _box.get('lastWeekItemCount', defaultValue: 0);

    _items.clear();
    final itemsMap = _box.get('items', defaultValue: <String, int>{});
    (itemsMap as Map).forEach((k, v) {
      _items[k.toString()] = (v as num).toInt();
    });
  }

  Future<void> _save() async {
    await _box.putAll({
      'coins': _coins,
      'adWatchesToday': _adWatchesToday,
      'loginStreak': _loginStreak,
      'lastAdWatchTime': _lastAdWatchTime?.toIso8601String(),
      'lastResetDate': _lastResetDate?.toIso8601String(),
      'lastLoginDate': _lastLoginDate?.toIso8601String(),
      'dailyStreak': _dailyStreak,
      'lastDailyClaimDate': _lastDailyClaimDate?.toIso8601String(),
      'lastWeekItemType': _lastWeekItemType,
      'lastWeekItemCount': _lastWeekItemCount,
      'items': _items,
    });
  }

  /// Add [count] of [item] to the player's inventory.
  Future<void> addItem(ItemType item, {int count = 1}) async {
    if (count <= 0) return;
    _items[item.name] = (_items[item.name] ?? 0) + count;
    await _save();
    notifyListeners();
  }

  /// Add N random items (for daily rewards / milestones).
  /// Returns the list of items granted (for UI display).
  Future<List<ItemType>> addRandomItems(int count) async {
    final granted = <ItemType>[];
    for (int i = 0; i < count; i++) {
      final item = DailyRewards.rollRandomItem();
      _items[item.name] = (_items[item.name] ?? 0) + 1;
      granted.add(item);
    }
    await _save();
    notifyListeners();
    return granted;
  }

  /// Consume one of [item]. Returns true if successful.
  Future<bool> spendItem(ItemType item) async {
    final current = _items[item.name] ?? 0;
    if (current <= 0) return false;
    if (current == 1) {
      _items.remove(item.name);
    } else {
      _items[item.name] = current - 1;
    }
    await _save();
    notifyListeners();
    return true;
  }

  int getItemCount(ItemType item) => _items[item.name] ?? 0;

  /// Called on app launch. Resets the daily ad counter if the day rolled over.
  void _checkDailyReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null ||
        DateTime(_lastResetDate!.year, _lastResetDate!.month, _lastResetDate!.day)
            .isBefore(today)) {
      _adWatchesToday = 0;
      _lastResetDate = today;
      _save();
    }
  }

  /// Public — call on resume/app start.
  Future<void> checkDailyReset() async {
    _checkDailyReset();
    notifyListeners();
  }

  /// Award coins from any source.
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    _coins += amount;
    await _save();
    notifyListeners();
  }

  /// Try to spend coins. Returns true if successful.
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    if (_coins < amount) return false;
    _coins -= amount;
    await _save();
    notifyListeners();
    return true;
  }

  /// Record a reward ad watch. Returns the coin amount earned, or 0 if
  /// the player wasn't allowed to watch (daily cap or cooldown).
  Future<int> recordAdWatch({
    required int coinsEarned,
    int extraItems = 0,
  }) async {
    if (!canWatchRewardedAd) return 0;

    _adWatchesToday++;
    _lastAdWatchTime = DateTime.now();
    _coins += coinsEarned;

    // Bonus items (e.g. milestone doubling)
    for (int i = 0; i < extraItems; i++) {
      final item = DailyRewards.rollRandomItem();
      _items[item.name] = (_items[item.name] ?? 0) + 1;
    }

    await _save();
    notifyListeners();
    return coinsEarned;
  }

  /// Record a login for the daily streak. Returns the coins earned
  /// (0 if already logged in today).
  Future<int> recordDailyLogin() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastLoginDate != null) {
      final lastLoginDay = DateTime(
        _lastLoginDate!.year,
        _lastLoginDate!.month,
        _lastLoginDate!.day,
      );
      if (lastLoginDay.isAtSameMomentAs(today)) {
        return 0; // already logged in today
      }

      // Check if streak is broken (more than 1 day gap)
      final daysSince = today.difference(lastLoginDay).inDays;
      if (daysSince > 1) {
        _loginStreak = 0; // reset
      }
    }

    _loginStreak++;
    _lastLoginDate = now;

    // Reward: 10 / 20 / 30 (day 1 / 2 / 3+)
    final int reward;
    if (_loginStreak <= 1) {
      reward = 10;
    } else if (_loginStreak == 2) {
      reward = 20;
    } else {
      reward = 30;
    }

    _coins += reward;
    await _save();
    notifyListeners();
    return reward;
  }

  /// DEV ONLY — wipes coin state.
  Future<void> resetAll() async {
    _coins = 0;
    _adWatchesToday = 0;
    _loginStreak = 0;
    _lastAdWatchTime = null;
    _lastResetDate = null;
    _lastLoginDate = null;
    await _save();
    notifyListeners();
  }
}