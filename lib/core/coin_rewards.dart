class CoinRewards {
  CoinRewards._();

  /// Coins awarded the FIRST time a level is completed.
  static int firstClearCoins(int level) {
    if (level <= 10) return 5;
    if (level <= 50) return 8;
    if (level <= 150) return 12;
    if (level <= 300) return 18;
    if (level <= 500) return 25;
    return 30;
  }

  /// Star bonus for a first clear: 0 / 3 / 8.
  static int starBonus(int stars) {
    switch (stars) {
      case 3:
        return 8;
      case 2:
        return 3;
      default:
        return 0;
    }
  }

  /// Tier = which 25-level bracket you're in. Capped at 5.
  static int tierFor(int level) {
    if (level <= 25) return 1;
    if (level <= 50) return 2;
    if (level <= 75) return 3;
    if (level <= 100) return 4;
    return 5;
  }

  /// Replay reward for an already-beaten level.
  /// Only valid if [level] is within the player's current tier.
  static int replayCoins({
    required int level,
    required int stars,
    required int currentLevel,
  }) {
    final playerTier = tierFor(currentLevel);
    final levelTier = tierFor(level);

    // Outside current tier → no coins
    if (levelTier != playerTier) return 0;

    return stars * levelTier;
  }

  /// Coins earned from a reward ad, based on the level being played.
  static int rewardAdCoins(int level) {
    if (level <= 50) return 10;
    if (level <= 125) return 20;
    if (level <= 250) return 30;
    return 40;
  }

  /// Milestone rewards. Returns 0 if [level] isn't a milestone.
  static int milestoneCoins(int level) {
    if (level % 100 == 0) return 200;
    if (level % 25 == 0) return 50;
    return 0;
  }

  /// Daily puzzle reward.
  static int dailyPuzzleCoins(int stars) {
    int base = 25;
    if (stars == 3) base += 15;
    return base;
  }
}