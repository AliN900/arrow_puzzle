import 'dart:math' as math;

import 'game_mode.dart';

/// LeaderCoin (LC) calculation. Pure functions, no side effects.
///
/// Only Daily Challenges award LC: Arrow Rush, Blitz, Time Blitz.
/// Classic, Zen, Time Attack, and Endless-mode losses never award LC.
class LeaderCoins {
  LeaderCoins._();

  /// Attempts per mode per day. Every play consumes one, even a rage-quit.
  static const int attemptsPerDay = 10;

  /// Arrow Rush — rewards arrows cleared and survival time.
  /// Difficulty multiplier: Easy 1.0×, Hard 1.5×, Impossible 2.0×.
  static int forArrowRush({
    required int arrowsCleared,
    required int failedTaps,
    required int itemsUsed,
    required int durationSeconds,
    required double difficultyMultiplier,
  }) {
    if (arrowsCleared <= 0) return 0;
    final minutes = durationSeconds / 60.0;
    final base = arrowsCleared * 0.12 + math.sqrt(minutes) * 3.0;
    final accuracy = _accuracy(
      failedTaps: failedTaps,
      itemsUsed: itemsUsed,
      arrows: arrowsCleared,
    );
    return (base * accuracy * difficultyMultiplier).round();
  }

  /// Blitz — score already bundles stage progression and time bonuses.
  /// `arrowsCleared` is a proxy derived from score; pass `score ~/ 100`.
  static int forBlitz({
    required int blitzScore,
    required int failedTaps,
    required int itemsUsed,
    required int arrowsCleared,
  }) {
    if (blitzScore <= 0) return 0;
    final base = blitzScore / 500.0;
    final accuracy = _accuracy(
      failedTaps: failedTaps,
      itemsUsed: itemsUsed,
      arrows: arrowsCleared,
    );
    return (base * accuracy).round();
  }

  /// Time Blitz — arrows cleared under continuous pressure.
  static int forTimeBlitz({
    required int arrowsCleared,
    required int failedTaps,
    required int itemsUsed,
  }) {
    if (arrowsCleared <= 0) return 0;
    final base = arrowsCleared * 0.4;
    final accuracy = _accuracy(
      failedTaps: failedTaps,
      itemsUsed: itemsUsed,
      arrows: arrowsCleared,
    );
    return (base * accuracy).round();
  }

  /// Accuracy multiplier: 0.50× (terrible) – 1.21× (perfect).
  /// Each item use counts as 2 failed taps.
  static double _accuracy({
    required int failedTaps,
    required int itemsUsed,
    required int arrows,
  }) {
    final effectiveFails = failedTaps + itemsUsed * 2;
    final denom = arrows < 1 ? 1 : arrows;
    final ratio = effectiveFails / denom;
    final raw = 1.0 + (0.30 - ratio) * 0.7;
    return raw.clamp(0.50, 1.21);
  }

  /// Difficulty multiplier for Arrow Rush tiers.
  /// 0 = easy, 1 = hard, 2 = impossible (matches RushDifficulty.index).
  static double difficultyMultiplier(int tierIndex) {
    switch (tierIndex) {
      case 0:
        return 1.0;
      case 1:
        return 1.5;
      case 2:
        return 2.0;
      default:
        return 1.0;
    }
  }

  /// Per-run LC ceiling by mode + difficulty.
  /// Prevents grinding on Easy from out-earning Hard.
  static int applyRunCap(
      int rawLc, {
        required GameMode mode,
        required int difficultyIndex,
      }) {
    // Only endless-farmable modes need a cap. Blitz is finite (stage count),
    // so it self-limits.
    switch (mode) {
      case GameMode.endlessRush:
      case GameMode.timeBlitz:
        break;
      case GameMode.blitz:
        return rawLc;   // finite already
      default:
        return rawLc;
    }

    // Index order matches RushDifficulty.values: easy=0, medium=1, hard=2, insane=3.
    const caps = <int>[30, 60, 120, 250];
    final cap = caps[difficultyIndex.clamp(0, caps.length - 1)];
    return rawLc > cap ? cap : rawLc;
  }

  // Mode keys for the attempts tracker.
  static const String modeArrowRush = 'endlessRush';
  static const String modeBlitz = 'blitz';
  static const String modeTimeBlitz = 'timeBlitz';
}