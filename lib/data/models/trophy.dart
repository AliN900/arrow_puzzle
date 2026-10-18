import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';

enum TrophyType { benefit, monumental }
enum TrophyBenefit { extraHeart, leaderboard, none }   // ← added `leaderboard`

class TrophyModel {
  final int index;
  final String id;
  final String title;
  final String description;
  final TrophyType type;
  final TrophyBenefit benefit;
  final int unlockLevel;

  /// If non-null, this trophy is LC-gated instead of level-gated.
  /// [unlockLevel] is ignored when this is set.
  final int? requiredLc;   // ← new

  const TrophyModel({
    required this.index,
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.benefit,
    required this.unlockLevel,
    this.requiredLc,       // ← new (optional)
  });
}

class TrophyConstants {
  static final List<TrophyModel> allTrophies = [
    // ── Lv 1-50 (onboarding + early) ──────────────────────────
    const TrophyModel(
      index: 1,
      id: 'first_escape',
      title: '🌟 THE FIRST AWAKENING',
      description: 'Your very first maze escaped! You have unlocked the gateway to the Trophy System. Welcome to ahb.Dev\'s ultimate puzzle journey!',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 1,
    ),
    const TrophyModel(
      index: 2,
      id: 'point_blank',
      title: 'Point Blank',
      description: 'Successfully clear your first puzzle layout with precision.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 1,
    ),
    const TrophyModel(
      index: 4,
      id: 'quick_thinker',
      title: 'Quick Thinker',
      description: 'Complete any level swiftly under a stretched 20-second threshold.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 3,
    ),
    const TrophyModel(
      index: 7,
      id: 'spark_of_genius',
      title: 'Spark of Genius',
      description: 'Use your first hint item to find a path through a sticky situation.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 12,
    ),
    const TrophyModel(
      index: 3,
      id: 'trial_of_two',
      title: 'Trial of Two',
      description: 'Conquer the intense two-heart restriction of the early trials.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 22,
    ),
    const TrophyModel(
      index: 10,
      id: 'survivalist_badge',
      title: 'The Survivalist',
      description: 'Conquered the first 25 trials! Permanently upgrades your max hearts from 2 to 3.',
      type: TrophyType.benefit,
      benefit: TrophyBenefit.extraHeart,
      unlockLevel: 25,
    ),
    const TrophyModel(
      index: 8,
      id: 'unwind',
      title: 'Unwind',
      description: 'Use your first undo item to reverse a misstep.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 32,
    ),
    const TrophyModel(
      index: 6,
      id: 'clean_slate',
      title: 'Clean Slate',
      description: 'Finish a level without a single blocked arrow tap.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 42,
    ),
    const TrophyModel(
      index: 11,
      id: 'wayfinder',
      title: 'Wayfinder',
      description: 'Reach level 50 and prove your mastery of early mazes.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 50,
    ),

    // ── Lv 51-100 ─────────────────────────────────────────────
    const TrophyModel(
      index: 5,
      id: 'arrow_smith',
      title: 'Arrow Smith',
      description: 'Clear 10 levels without giving up or restarting.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 55,
    ),
    const TrophyModel(
      index: 24,
      id: 'golden_touch',
      title: 'Golden Touch',
      description: 'Unlock your very first custom board or arrow skin theme.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 65,
    ),
    const TrophyModel(
      index: 21,
      id: 'the_strategist',
      title: 'The Strategist',
      description: 'Utilize all available inventory items at least once during a single session.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 75,
    ),
    const TrophyModel(
      index: 9,
      id: 'rock_breaker',
      title: 'Rock Breaker',
      description: 'Successfully blast away your first rock obstacle using a tactical bomb arrow.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 85,
    ),
    const TrophyModel(
      index: 14,
      id: 'century_mark',
      title: 'Century Mark',
      description: 'Reach level 100 — one-fifth of the way to the 500 summit!',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 100,
    ),

    // ── Lv 101-150 ────────────────────────────────────────────
    const TrophyModel(
      index: 12,
      id: 'tangle_tamer',
      title: 'Tangle Tamer',
      description: 'Clear 10 levels in a row without making a single directional error.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 115,
    ),
    const TrophyModel(
      index: 20,
      id: 'halfway_to_glory',
      title: 'Halfway to Glory',
      description: 'Reach level 125, establishing your mid-game dominance.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 125,
    ),
    const TrophyModel(
      index: 19,
      id: 'master_of_angles',
      title: 'Master of Angles',
      description: 'Complete a complex puzzle heavily featuring orphan redirector dots.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 135,
    ),
    const TrophyModel(
      index: 26,
      id: 'deep_diver',
      title: 'Deep Diver',
      description: 'Reach level 150 as the labyrinth grows exponentially complex.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 150,
    ),

    // ── Lv 151-200 ────────────────────────────────────────────
    const TrophyModel(
      index: 17,
      id: 'untouchable',
      title: 'Untouchable',
      description: 'Complete 5 levels consecutively without losing a single heart.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 165,
    ),
    const TrophyModel(
      index: 22,
      id: 'quick_silver',
      title: 'Quick Silver',
      description: 'Accumulate 5 minutes of active high-speed play in Time Attack mode.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 175,
    ),
    const TrophyModel(
      index: 18,
      id: 'stargazer',
      title: 'Stargazer',
      description: 'Earn 3 stars across 30 different puzzle boards.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 185,
    ),
    const TrophyModel(
      index: 34,
      id: 'resilient_spirit',
      title: 'Resilient Spirit',
      description: 'Recover from a game-over state using an ad continuation reward.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 195,
    ),
    const TrophyModel(
      index: 31,
      id: 'milestone_master',
      title: 'Milestone Master',
      description: 'Reach level 200 — two-fifths of the way to the 500 max level.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 200,
    ),

    // ── Lv 201-250 ────────────────────────────────────────────
    const TrophyModel(
      index: 23,
      id: 'iron_will',
      title: 'Iron Will',
      description: 'Win a boss level after dropping down to your absolute final heart.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 215,
    ),
    const TrophyModel(
      index: 16,
      id: 'bomb_technician',
      title: 'Bomb Technician',
      description: 'Clear 25 rock obstacles across your campaign using tactical bombs.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 230,
    ),
    const TrophyModel(
      index: 30,
      id: 'vault_keeper',
      title: 'Vault Keeper',
      description: 'Accumulate a massive total of 500 coins from gameplay and ad rewards.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 245,
    ),
    const TrophyModel(
      index: 36,
      id: 'apex_predator',
      title: 'Apex Predator',
      description: 'Reach level 250 — the halfway summit of the current puzzle campaign.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 250,
    ),

    // ── Lv 251-300 ────────────────────────────────────────────
    const TrophyModel(
      index: 27,
      id: 'the_puzzler',
      title: 'The Puzzler',
      description: 'Complete 50 randomly generated procedural puzzle boards.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 265,
    ),
    const TrophyModel(
      index: 39,
      id: 'daily_devotee',
      title: 'Daily Devotee',
      description: 'Maintain a 7-day login streak on your daily rewards tracker.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 280,
    ),
    const TrophyModel(
      index: 13,
      id: 'time_lord',
      title: 'Time Lord',
      description: 'Survive a timed God-level trial with countdown seconds to spare.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 290,
    ),
    const TrophyModel(
      index: 41,
      id: 'high_climber',
      title: 'The High Climber',
      description: 'Reach level 300 — three-fifths of the way to the 500 summit.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 300,
    ),

    // ── Lv 301-350 ────────────────────────────────────────────
    const TrophyModel(
      index: 28,
      id: 'sharp_shooter',
      title: 'Sharp Shooter',
      description: 'Finish 20 levels using the minimum possible moves.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 310,
    ),
    const TrophyModel(
      index: 32,
      id: 'boss_slayer',
      title: 'Boss Slayer',
      description: 'Defeat 8 boss levels consecutively without a single defeat.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 325,
    ),
    const TrophyModel(
      index: 35,
      id: 'board_collector',
      title: 'Board Collector',
      description: 'Unlock 5 different custom board themes for your collection.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 340,
    ),
    const TrophyModel(
      index: 42,
      id: 'grandmaster',
      title: 'Grandmaster',
      description: 'Reach level 350, conquering the most complex grid tangles.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 350,
    ),

    // ── Lv 351-400 ────────────────────────────────────────────
    const TrophyModel(
      index: 40,
      id: 'monumental_pioneer',
      title: 'Monumental Pioneer',
      description: 'Unlock your first purely decorative, prestige monumental trophy.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 360,
    ),
    const TrophyModel(
      index: 37,
      id: 'flawless_execution',
      title: 'Flawless Execution',
      description: 'Earn 3 stars across 100 separate levels.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 375,
    ),
    const TrophyModel(
      index: 33,
      id: 'time_bender',
      title: 'Time Bender',
      description: 'Freeze time successfully 10 times on intense countdown levels.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 390,
    ),
    const TrophyModel(
      index: 44,
      id: 'ironclad',
      title: 'Ironclad',
      description: 'Reach level 400 — four-fifths of the way to the ultimate summit.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 400,
    ),

    // ── Lv 401-450 ────────────────────────────────────────────
    const TrophyModel(
      index: 43,
      id: 'eternal_flame',
      title: 'Eternal Flame',
      description: 'Maintain an incredible 14-day continuous login streak.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 415,
    ),
    const TrophyModel(
      index: 38,
      id: 'tactical_mindset',
      title: 'Tactical Mindset',
      description: 'Solve a god-tier puzzle without relying on any hints.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 430,
    ),
    const TrophyModel(
      index: 46,
      id: 'titan_of_the_maze',
      title: 'Titan of the Maze',
      description: 'Reach level 450, standing among elite puzzle solvers.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 450,
    ),

    // ── Lv 451-500 (endgame) ──────────────────────────────────
    const TrophyModel(
      index: 49,
      id: 'monument_of_time',
      title: 'Monument of Time',
      description: 'A prestige monumental artifact for dedicating over 10 active hours to escaping mazes.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 465,
    ),
    const TrophyModel(
      index: 45,
      id: 'perfectionist',
      title: 'Perfectionist',
      description: 'Earn 3 stars on every single level from 1 up to 400.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 480,
    ),
    const TrophyModel(
      index: 50,
      id: 'absolute_void',
      title: 'The Absolute Void',
      description: 'A pitch-black monumental prestige trophy awarded for maxing out key progression features.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 495,
    ),
    const TrophyModel(
      index: 47,
      id: 'the_500_club',
      title: 'The 500 Club',
      description: 'Reach level 500, hitting the current maximum summit of the puzzle grid!',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 500,
    ),
    const TrophyModel(
      index: 48,
      id: 'living_legend',
      title: 'Living Legend',
      description: 'Clear level 500 with a 3-star rating and zero mistakes.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 500,
    ),
    const TrophyModel(
      index: 51,
      id: 'infinite_horizon',
      title: 'Infinite Horizon',
      description: 'A monumental placeholder trophy acknowledging that the journey beyond level 500 never ends.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 500,
    ),
    const TrophyModel(
      index: 52,
      id: 'leaderboard_legend',
      title: '🏆 LEADERBOARD LEGEND',
      description:
      'Accumulate 1,000 LC to unlock the global leaderboard. '
          'Compete with players worldwide for the top spot!',
      type: TrophyType.benefit,
      benefit: TrophyBenefit.leaderboard,
      unlockLevel: 0,          // not level-gated
      requiredLc: 1000,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────
// Localization extension
// ─────────────────────────────────────────────────────────────────────────

extension TrophyLocalization on TrophyModel {
  String localizedTitle(BuildContext context) {
    final s = AppStrings.of(context);
    switch (id) {
      case 'first_escape':        return s.trophyFirstEscapeTitle;
      case 'point_blank':         return s.trophyPointBlankTitle;
      case 'trial_of_two':        return s.trophyTrialOfTwoTitle;
      case 'quick_thinker':       return s.trophyQuickThinkerTitle;
      case 'arrow_smith':         return s.trophyArrowSmithTitle;
      case 'clean_slate':         return s.trophyCleanSlateTitle;
      case 'spark_of_genius':     return s.trophySparkOfGeniusTitle;
      case 'unwind':              return s.trophyUnwindTitle;
      case 'rock_breaker':        return s.trophyRockBreakerTitle;
      case 'survivalist_badge':   return s.trophySurvivalistBadgeTitle;
      case 'wayfinder':           return s.trophyWayfinderTitle;
      case 'tangle_tamer':        return s.trophyTangleTamerTitle;
      case 'time_lord':           return s.trophyTimeLordTitle;
      case 'century_mark':        return s.trophyCenturyMarkTitle;
      case 'bomb_technician':     return s.trophyBombTechnicianTitle;
      case 'untouchable':         return s.trophyUntouchableTitle;
      case 'stargazer':           return s.trophyStargazerTitle;
      case 'master_of_angles':    return s.trophyMasterOfAnglesTitle;
      case 'halfway_to_glory':    return s.trophyHalfwayToGloryTitle;
      case 'the_strategist':      return s.trophyTheStrategistTitle;
      case 'quick_silver':        return s.trophyQuickSilverTitle;
      case 'iron_will':           return s.trophyIronWillTitle;
      case 'golden_touch':        return s.trophyGoldenTouchTitle;
      case 'deep_diver':          return s.trophyDeepDiverTitle;
      case 'the_puzzler':         return s.trophyThePuzzlerTitle;
      case 'sharp_shooter':       return s.trophySharpShooterTitle;
      case 'vault_keeper':        return s.trophyVaultKeeperTitle;
      case 'milestone_master':    return s.trophyMilestoneMasterTitle;
      case 'boss_slayer':         return s.trophyBossSlayerTitle;
      case 'time_bender':         return s.trophyTimeBenderTitle;
      case 'resilient_spirit':    return s.trophyResilientSpiritTitle;
      case 'board_collector':     return s.trophyBoardCollectorTitle;
      case 'apex_predator':       return s.trophyApexPredatorTitle;
      case 'flawless_execution':  return s.trophyFlawlessExecutionTitle;
      case 'tactical_mindset':    return s.trophyTacticalMindsetTitle;
      case 'daily_devotee':       return s.trophyDailyDevoteeTitle;
      case 'monumental_pioneer':  return s.trophyMonumentalPioneerTitle;
      case 'high_climber':        return s.trophyHighClimberTitle;
      case 'grandmaster':         return s.trophyGrandmasterTitle;
      case 'eternal_flame':       return s.trophyEternalFlameTitle;
      case 'ironclad':            return s.trophyIroncladTitle;
      case 'perfectionist':       return s.trophyPerfectionistTitle;
      case 'titan_of_the_maze':   return s.trophyTitanOfTheMazeTitle;
      case 'the_500_club':        return s.trophyThe500ClubTitle;
      case 'living_legend':       return s.trophyLivingLegendTitle;
      case 'monument_of_time':    return s.trophyMonumentOfTimeTitle;
      case 'absolute_void':       return s.trophyAbsoluteVoidTitle;
      case 'infinite_horizon':    return s.trophyInfiniteHorizonTitle;
      default:                    return title;
    }
  }

  String localizedDescription(BuildContext context) {
    final s = AppStrings.of(context);
    switch (id) {
      case 'first_escape':        return s.trophyFirstEscapeDesc;
      case 'point_blank':         return s.trophyPointBlankDesc;
      case 'trial_of_two':        return s.trophyTrialOfTwoDesc;
      case 'quick_thinker':       return s.trophyQuickThinkerDesc;
      case 'arrow_smith':         return s.trophyArrowSmithDesc;
      case 'clean_slate':         return s.trophyCleanSlateDesc;
      case 'spark_of_genius':     return s.trophySparkOfGeniusDesc;
      case 'unwind':              return s.trophyUnwindDesc;
      case 'rock_breaker':        return s.trophyRockBreakerDesc;
      case 'survivalist_badge':   return s.trophySurvivalistBadgeDesc;
      case 'wayfinder':           return s.trophyWayfinderDesc;
      case 'tangle_tamer':        return s.trophyTangleTamerDesc;
      case 'time_lord':           return s.trophyTimeLordDesc;
      case 'century_mark':        return s.trophyCenturyMarkDesc;
      case 'bomb_technician':     return s.trophyBombTechnicianDesc;
      case 'untouchable':         return s.trophyUntouchableDesc;
      case 'stargazer':           return s.trophyStargazerDesc;
      case 'master_of_angles':    return s.trophyMasterOfAnglesDesc;
      case 'halfway_to_glory':    return s.trophyHalfwayToGloryDesc;
      case 'the_strategist':      return s.trophyTheStrategistDesc;
      case 'quick_silver':        return s.trophyQuickSilverDesc;
      case 'iron_will':           return s.trophyIronWillDesc;
      case 'golden_touch':        return s.trophyGoldenTouchDesc;
      case 'deep_diver':          return s.trophyDeepDiverDesc;
      case 'the_puzzler':         return s.trophyThePuzzlerDesc;
      case 'sharp_shooter':       return s.trophySharpShooterDesc;
      case 'vault_keeper':        return s.trophyVaultKeeperDesc;
      case 'milestone_master':    return s.trophyMilestoneMasterDesc;
      case 'boss_slayer':         return s.trophyBossSlayerDesc;
      case 'time_bender':         return s.trophyTimeBenderDesc;
      case 'resilient_spirit':    return s.trophyResilientSpiritDesc;
      case 'board_collector':     return s.trophyBoardCollectorDesc;
      case 'apex_predator':       return s.trophyApexPredatorDesc;
      case 'flawless_execution':  return s.trophyFlawlessExecutionDesc;
      case 'tactical_mindset':    return s.trophyTacticalMindsetDesc;
      case 'daily_devotee':       return s.trophyDailyDevoteeDesc;
      case 'monumental_pioneer':  return s.trophyMonumentalPioneerDesc;
      case 'high_climber':        return s.trophyHighClimberDesc;
      case 'grandmaster':         return s.trophyGrandmasterDesc;
      case 'eternal_flame':       return s.trophyEternalFlameDesc;
      case 'ironclad':            return s.trophyIroncladDesc;
      case 'perfectionist':       return s.trophyPerfectionistDesc;
      case 'titan_of_the_maze':   return s.trophyTitanOfTheMazeDesc;
      case 'the_500_club':        return s.trophyThe500ClubDesc;
      case 'living_legend':       return s.trophyLivingLegendDesc;
      case 'monument_of_time':    return s.trophyMonumentOfTimeDesc;
      case 'absolute_void':       return s.trophyAbsoluteVoidDesc;
      case 'infinite_horizon':    return s.trophyInfiniteHorizonDesc;
      default:                    return description;
    }
  }
}