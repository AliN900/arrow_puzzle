enum TrophyType { benefit, monumental }
enum TrophyBenefit { extraHeart, none }

class TrophyModel {
  final int index;
  final String id;
  final String title;
  final String description;
  final TrophyType type;
  final TrophyBenefit benefit;
  final int unlockLevel;

  const TrophyModel({
    required this.index,
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.benefit,
    required this.unlockLevel,
  });
}

class TrophyConstants {
  static final List<TrophyModel> allTrophies = [
    // 1. Reworked Introduction Trophy (Level 1)
    const TrophyModel(
      index: 1,
      id: 'first_escape',
      title: '🌟 THE FIRST AWAKENING',
      description: 'Your very first maze escaped! You have unlocked the gateway to the Trophy System. Welcome to AHB.Dev\'s ultimate puzzle journey!',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 1,
    ),
    // 2. Point Blank
    const TrophyModel(
      index: 2,
      id: 'point_blank',
      title: 'Point Blank',
      description: 'Successfully clear your first puzzle layout with precision.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 1,
    ),
    // 3. Trial of Two
    const TrophyModel(
      index: 3,
      id: 'trial_of_two',
      title: 'Trial of Two',
      description: 'Conquer the intense two-heart restriction of the early trials.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 5,
    ),
    // 4. Quick Thinker (Stretched time window)
    const TrophyModel(
      index: 4,
      id: 'quick_thinker',
      title: 'Quick Thinker',
      description: 'Complete any level swiftly under a stretched 20-second threshold.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 3,
    ),
    // 5. Arrow Smith
    const TrophyModel(
      index: 5,
      id: 'arrow_smith',
      title: 'Arrow Smith',
      description: 'Clear 10 levels without giving up or restarting.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 10,
    ),
    // 6. Clean Slate
    const TrophyModel(
      index: 6,
      id: 'clean_slate',
      title: 'Clean Slate',
      description: 'Finish a level without a single blocked arrow tap.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 8,
    ),
    // 7. Spark of Genius
    const TrophyModel(
      index: 7,
      id: 'spark_of_genius',
      title: 'Spark of Genius',
      description: 'Use your first hint item to find a path through a sticky situation.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 4,
    ),
    // 8. Unwind
    const TrophyModel(
      index: 8,
      id: 'unwind',
      title: 'Unwind',
      description: 'Use your first undo item to reverse a misstep.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 6,
    ),
    // 9. Rock Breaker
    const TrophyModel(
      index: 9,
      id: 'rock_breaker',
      title: 'Rock Breaker',
      description: 'Successfully blast away your first rock obstacle using a tactical bomb arrow.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 25,
    ),
    // 10. The Survivalist (Benefit Trophy)
    const TrophyModel(
      index: 10,
      id: 'survivalist_badge',
      title: 'The Survivalist',
      description: 'Conquered the first 25 trials! Permanently upgrades your max hearts from 2 to 3.',
      type: TrophyType.benefit,
      benefit: TrophyBenefit.extraHeart,
      unlockLevel: 25,
    ),
    // 11. Wayfinder
    const TrophyModel(
      index: 11,
      id: 'wayfinder',
      title: 'Wayfinder',
      description: 'Reach level 50 and prove your mastery of early mazes.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 50,
    ),
    // 12. Tangle Tamer
    const TrophyModel(
      index: 12,
      id: 'tangle_tamer',
      title: 'Tangle Tamer',
      description: 'Clear 10 levels in a row without making a single directional error.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 35,
    ),
    // 13. Time Lord
    const TrophyModel(
      index: 13,
      id: 'time_lord',
      title: 'Time Lord',
      description: 'Survive a timed God-level trial with countdown seconds to spare.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 110,
    ),
    // 14. Century Mark
    const TrophyModel(
      index: 14,
      id: 'century_mark',
      title: 'Century Mark',
      description: 'Reach level 100 — one-fifth of the way to the 500 summit!',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 100,
    ),
    // 16. Bomb Technician
    const TrophyModel(
      index: 16,
      id: 'bomb_technician',
      title: 'Bomb Technician',
      description: 'Clear 25 rock obstacles across your campaign using tactical bombs.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 75,
    ),
    // 17. Untouchable
    const TrophyModel(
      index: 17,
      id: 'untouchable',
      title: 'Untouchable',
      description: 'Complete 5 levels consecutively without losing a single heart.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 45,
    ),
    // 18. Stargazer
    const TrophyModel(
      index: 18,
      id: 'stargazer',
      title: 'Stargazer',
      description: 'Earn 3 stars across 30 different puzzle boards.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 60,
    ),
    // 19. Master of Angles
    const TrophyModel(
      index: 19,
      id: 'master_of_angles',
      title: 'Master of Angles',
      description: 'Complete a complex puzzle heavily featuring orphan redirector dots.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 40,
    ),
    // 20. Halfway to Glory
    const TrophyModel(
      index: 20,
      id: 'halfway_to_glory',
      title: 'Halfway to Glory',
      description: 'Reach level 125, establishing your mid-game dominance.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 125,
    ),
    // 21. The Strategist
    const TrophyModel(
      index: 21,
      id: 'the_strategist',
      title: 'The Strategist',
      description: 'Utilize all available inventory items at least once during a single session.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 30,
    ),
    // 22. Quick Silver
    const TrophyModel(
      index: 22,
      id: 'quick_silver',
      title: 'Quick Silver',
      description: 'Accumulate 5 minutes of active high-speed play in Time Attack mode.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 55,
    ),
    // 23. Iron Will
    const TrophyModel(
      index: 23,
      id: 'iron_will',
      title: 'Iron Will',
      description: 'Win a boss level after dropping down to your absolute final heart.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 70,
    ),
    // 24. Golden Touch
    const TrophyModel(
      index: 24,
      id: 'golden_touch',
      title: 'Golden Touch',
      description: 'Unlock your very first custom board or arrow skin theme.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 20,
    ),
    // 26. Deep Diver
    const TrophyModel(
      index: 26,
      id: 'deep_diver',
      title: 'Deep Diver',
      description: 'Reach level 150 as the labyrinth grows exponentially complex.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 150,
    ),
    // 27. The Puzzler
    const TrophyModel(
      index: 27,
      id: 'the_puzzler',
      title: 'The Puzzler',
      description: 'Complete 50 randomly generated procedural puzzle boards.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 90,
    ),
    // 28. Sharp Shooter
    const TrophyModel(
      index: 28,
      id: 'sharp_shooter',
      title: 'Sharp Shooter',
      description: 'Finish 20 levels using the minimum possible moves.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 135,
    ),
    // 30. Vault Keeper
    const TrophyModel(
      index: 30,
      id: 'vault_keeper',
      title: 'Vault Keeper',
      description: 'Accumulate a massive total of 500 coins from gameplay and ad rewards.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 80,
    ),
    // 31. Milestone Master
    const TrophyModel(
      index: 31,
      id: 'milestone_master',
      title: 'Milestone Master',
      description: 'Reach level 200 — two-fifths of the way to the 500 max level.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 200,
    ),
    // 32. Boss Slayer
    const TrophyModel(
      index: 32,
      id: 'boss_slayer',
      title: 'Boss Slayer',
      description: 'Defeat 8 boss levels consecutively without a single defeat.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 175,
    ),
    // 33. Time Bender
    const TrophyModel(
      index: 33,
      id: 'time_bender',
      title: 'Time Bender',
      description: 'Freeze time successfully 10 times on intense countdown levels.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 220,
    ),
    // 34. Resilient Spirit
    const TrophyModel(
      index: 34,
      id: 'resilient_spirit',
      title: 'Resilient Spirit',
      description: 'Recover from a game-over state using an ad continuation reward.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 65,
    ),
    // 35. Board Collector
    const TrophyModel(
      index: 35,
      id: 'board_collector',
      title: 'Board Collector',
      description: 'Unlock 5 different custom board themes for your collection.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 160,
    ),
    // 36. Apex Predator
    const TrophyModel(
      index: 36,
      id: 'apex_predator',
      title: 'Apex Predator',
      description: 'Reach level 250 — the halfway summit of the current puzzle campaign.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 250,
    ),
    // 37. Flawless Execution
    const TrophyModel(
      index: 37,
      id: 'flawless_execution',
      title: 'Flawless Execution',
      description: 'Earn 3 stars across 100 separate levels.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 210,
    ),
    // 38. Tactical Mindset
    const TrophyModel(
      index: 38,
      id: 'tactical_mindset',
      title: 'Tactical Mindset',
      description: 'Solve a god-tier puzzle without relying on any hints.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 280,
    ),
    // 39. Daily Devotee
    const TrophyModel(
      index: 39,
      id: 'daily_devotee',
      title: 'Daily Devotee',
      description: 'Maintain a 7-day login streak on your daily rewards tracker.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 95,
    ),
    // 40. Monumental Pioneer
    const TrophyModel(
      index: 40,
      id: 'monumental_pioneer',
      title: 'Monumental Pioneer',
      description: 'Unlock your first purely decorative, prestige monumental trophy.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 180,
    ),
    // 41. The High Climber
    const TrophyModel(
      index: 41,
      id: 'high_climber',
      title: 'The High Climber',
      description: 'Reach level 300 — three-fifths of the way to the 500 summit.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 300,
    ),
    // 42. Grandmaster
    const TrophyModel(
      index: 42,
      id: 'grandmaster',
      title: 'Grandmaster',
      description: 'Reach level 350, conquering the most complex grid tangles.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 350,
    ),
    // 43. Eternal Flame
    const TrophyModel(
      index: 43,
      id: 'eternal_flame',
      title: 'Eternal Flame',
      description: 'Maintain an incredible 14-day continuous login streak.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 260,
    ),
    // 44. Ironclad
    const TrophyModel(
      index: 44,
      id: 'ironclad',
      title: 'Ironclad',
      description: 'Reach level 400 — four-fifths of the way to the ultimate summit.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 400,
    ),
    // 45. Perfectionist
    const TrophyModel(
      index: 45,
      id: 'perfectionist',
      title: 'Perfectionist',
      description: 'Earn 3 stars on every single level from 1 up to 400.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 420,
    ),
    // 46. Titan of the Maze
    const TrophyModel(
      index: 46,
      id: 'titan_of_the_maze',
      title: 'Titan of the Maze',
      description: 'Reach level 450, standing among elite puzzle solvers.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 450,
    ),
    // 47. The 500 Club
    const TrophyModel(
      index: 47,
      id: 'the_500_club',
      title: 'The 500 Club',
      description: 'Reach level 500, hitting the current maximum summit of the puzzle grid!',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 500,
    ),
    // 48. Living Legend
    const TrophyModel(
      index: 48,
      id: 'living_legend',
      title: 'Living Legend',
      description: 'Clear level 500 with a 3-star rating and zero mistakes.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 500,
    ),
    // 49. Monument of Time
    const TrophyModel(
      index: 49,
      id: 'monument_of_time',
      title: 'Monument of Time',
      description: 'A prestige monumental artifact for dedicating over 10 active hours to escaping mazes.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 320,
    ),
    // 50. The Absolute Void
    const TrophyModel(
      index: 50,
      id: 'absolute_void',
      title: 'The Absolute Void',
      description: 'A pitch-black monumental prestige trophy awarded for maxing out key progression features.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 480,
    ),
    // 51. Infinite Horizon
    const TrophyModel(
      index: 51,
      id: 'infinite_horizon',
      title: 'Infinite Horizon',
      description: 'A monumental placeholder trophy acknowledging that the journey beyond level 500 never ends.',
      type: TrophyType.monumental,
      benefit: TrophyBenefit.none,
      unlockLevel: 500,
    ),
  ];
}