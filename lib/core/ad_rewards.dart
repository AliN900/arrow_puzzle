class AdRewards {
  AdRewards._();

  /// Hearts granted when the player runs out of lives.
  /// One heart per level — the ad can only be used once per attempt.
  static int heartsForLevel(int level) {
    return 3;
  }

  /// Seconds granted when the player runs out of time.
  static int secondsForRemainingArrows(int remainingArrows) {
    return (remainingArrows * 3).clamp(30, 90);
  }
}