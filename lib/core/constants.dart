class AppConstants {
  AppConstants._();

  static const String appName = 'Arrow Puzzle';
  static const String appFullName = 'Arrow Puzzle: Tap Maze Escape';

  static const int maxLives = 3;

  static const int bossLevelEvery = 25;
  static const int godLevelEvery  = 50;

  static const Duration arrowShakeDuration = Duration(milliseconds: 400);

  static int bossCycleCount(int level) {
    int count = 0;
    for (int l = 1; l <= level; l++) {
      if (levelTypeFor(l) == LevelType.boss) count++;
    }
    return count;
  }

  /// Returns true if this level should be a snake-style layout
  /// (few long winding arrows filling the board).
  static bool isSnakeLevel(int level) {
    if (level < 10) return false;
    return level % 5 == 3;
  }

  static int godCycleCount(int level) {
    int count = 0;
    for (int l = 1; l <= level; l++) {
      if (levelTypeFor(l) == LevelType.god) count++;
    }
    return count;
  }

  static int gridSizeForLevel(int level) {
    final type = levelTypeFor(level);

    if (type == LevelType.god) {
      final raw = 22 + ((level / 50.0) * 1.2).round();
      return raw.clamp(22, 32);
    }

    if (type == LevelType.boss) {
      final raw = 20 + ((level / 50.0) * 1.2).round();
      return raw.clamp(20, 30);
    }

    if (level <= 10) {
      return 10 + ((level - 1) * 0.44).round();
    } else if (level <= 50) {
      return 14 + ((level - 10) * 0.15).round();
    } else if (level <= 150) {
      return 20 + ((level - 50) * 0.05).round();
    } else if (level <= 300) {
      return 25 + ((level - 150) * 0.03).round();
    } else if (level <= 500) {
      return 29 + ((level - 300) * 0.01).round();
    } else {
      return 32;
    }
  }

  static LevelType levelTypeFor(int level) {
    if (level % godLevelEvery == 0) return LevelType.god;
    if (level % bossLevelEvery == 0) return LevelType.boss;
    return LevelType.normal;
  }

  static double canvasScaleForType(LevelType type) {
    switch (type) {
      case LevelType.god:  return 0.93;
      case LevelType.boss: return 0.93;
      default:             return 0.90;
    }
  }

  /// How many rocks appear on a level.
  static int rockCountForLevel(int level) {
    final type = levelTypeFor(level);

    if (type == LevelType.god) {
      if (level < 100) return 2;
      if (level < 200) return 3;
      if (level < 350) return 4;
      return 5;
    }
    if (type == LevelType.boss) {
      if (level < 100) return 1;
      if (level < 300) return 2;
      return 3;
    }

    if (level < 20) return 0;

    if (level % 10 == 0) return 2;
    if (level % 4 == 0) return 1;

    if (level >= 100 && level % 7 == 3) return 1;
    if (level >= 200 && level % 11 == 5) return 2;

    return 0;
  }

  static const int randomEasyMin = 11;
  static const int randomEasyMax = 50;
  static const int randomMediumMin = 51;
  static const int randomMediumMax = 150;
  static const int randomHardMin = 151;
  static const int randomHardMax = 300;
  static const int randomMasterMin = 301;
  static const int randomMasterMax = 500;
  static const int randomExpertMin = 501;
  static const int randomExpertMax = 700;
}

enum LevelType {
  normal,
  boss,
  god;
}