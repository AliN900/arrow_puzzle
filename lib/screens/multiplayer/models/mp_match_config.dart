import 'dart:math';

enum MpDifficulty { easy, hard, extreme }

class MpMatchConfig {
  final String hostId;
  final String guestId;
  final int hostLevel;
  final int guestLevel;
  final MpDifficulty difficulty;
  final int matchSeed;
  final int totalArrows;

  const MpMatchConfig({
    required this.hostId,
    required this.guestId,
    required this.hostLevel,
    required this.guestLevel,
    this.difficulty = MpDifficulty.hard,
    required this.matchSeed,
    this.totalArrows = 20,
  });

  /// Level formula scaled dynamically by selected difficulty multiplier
  int get effectiveLevel {
    final baseLevel = (hostLevel + guestLevel) / 2.0;
    double multiplier;

    switch (difficulty) {
      case MpDifficulty.easy:
        multiplier = 1.5;
        break;
      case MpDifficulty.hard:
        multiplier = 3.0;
        break;
      case MpDifficulty.extreme:
        multiplier = 4.5;
        break;
    }

    return max(1, (baseLevel * multiplier).round());
  }

  /// Calculates strict time limit per arrow based on selected difficulty
  int get matchTimeSeconds {
    double secondsPerArrow;
    switch (difficulty) {
      case MpDifficulty.easy:
        secondsPerArrow = 2.5;
        break;
      case MpDifficulty.hard:
        secondsPerArrow = 1.8;
        break;
      case MpDifficulty.extreme:
        secondsPerArrow = 1.2;
        break;
    }
    return max(10, (totalArrows * secondsPerArrow).round());
  }
}