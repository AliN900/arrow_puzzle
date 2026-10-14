// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppStringsEn extends AppStrings {
  AppStringsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Arrow Puzzle';

  @override
  String get menuHome => 'Home';

  @override
  String get menuDaily => 'Daily';

  @override
  String get menuInventory => 'Inventory';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuTrophies => 'Trophies';

  @override
  String get menuLeaderboard => 'Leaderboard';

  @override
  String get menuContinue => 'Continue';

  @override
  String menuLevel(int level) {
    return 'Level $level';
  }

  @override
  String get buttonPlay => 'Play';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonBuy => 'Buy';

  @override
  String get buttonRestart => 'Restart';

  @override
  String get buttonResume => 'Resume';

  @override
  String get buttonExit => 'Exit';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonNext => 'Next Level';

  @override
  String get buttonSignIn => 'Sign In';

  @override
  String get buttonSignUp => 'Create Account';

  @override
  String get buttonSignOut => 'Sign out';

  @override
  String get buttonDeleteAccount => 'Delete Account';

  @override
  String get buttonClaim => 'Claim for free';

  @override
  String get buttonWatchAd => 'Watch ad';

  @override
  String get buttonAccept => 'Accept & Continue';

  @override
  String get buttonShare => 'Share with friends';

  @override
  String get buttonStartBlitz => 'Start Blitz';

  @override
  String buttonStartRush(String tier) {
    return 'Start $tier';
  }

  @override
  String get gameModeClassic => 'Classic';

  @override
  String get gameModeZen => 'Zen Mode';

  @override
  String get gameModeTimeAttack => 'Time Attack';

  @override
  String get gameModeArrowRush => 'Arrow Rush';

  @override
  String get gameModeBlitz => 'Blitz';

  @override
  String get gameModeMineArrows => 'Mine Arrows';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyImpossible => 'Impossible';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsAccentColor => 'Accent Color';

  @override
  String get settingsAudioHaptics => 'AUDIO & HAPTICS';

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsArrowSpeed => 'ARROW SPEED';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms & Conditions';

  @override
  String get settingsLanguage => 'Language';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsSharingComingSoon => 'Sharing coming soon';

  @override
  String get consentTitle => 'Welcome to Arrow Puzzle';

  @override
  String get consentSubtitle =>
      'Before we begin, please review and accept our terms.';

  @override
  String get consentLocalProgress =>
      'Your progress is saved locally on your device.';

  @override
  String get consentCloudSync =>
      'Optional accounts sync progress to the cloud.';

  @override
  String get consentAds => 'The game shows ads to keep it free.';

  @override
  String get consentAgreement =>
      'By tapping above you agree to our Terms & Conditions.';

  @override
  String get dialogExitTitle => 'Exit Game?';

  @override
  String get dialogExitMessage => 'Are you sure you want to leave?';

  @override
  String get dialogSignOutTitle => 'Sign out?';

  @override
  String get dialogSignOutMessage =>
      'Your cloud save stays. This device will reset to a fresh guest account and start from level 1.';

  @override
  String get dialogDeleteTitle => 'Delete Account?';

  @override
  String get dialogDeleteMessage =>
      'This will permanently delete your cloud save and account. This action cannot be undone.';

  @override
  String get profileGuest => 'Playing as guest';

  @override
  String get profileSaveToCloud => 'Save to Cloud';

  @override
  String get profileSynced => 'Synced';

  @override
  String get profileSignedIn => 'Signed in';

  @override
  String get profileStatsLevel => 'Level';

  @override
  String get profileStatsStars => 'Stars';

  @override
  String get profileStatsTrophies => 'Trophies';

  @override
  String get dailyRewardsTitle => 'DAILY REWARDS';

  @override
  String dailyRewardsDay(int day, int max) {
    return 'Day $day of $max';
  }

  @override
  String get dailyRewardsComeBack => 'Come back tomorrow';

  @override
  String get dailyRewardsClaimed => 'Claimed today!';

  @override
  String get levelComplete => 'Level Complete!';

  @override
  String get levelFailed => 'Out of Lives!';

  @override
  String get levelTimeUp => 'Out of Time!';

  @override
  String get gameOverRestart => 'Restart Level';

  @override
  String get gameOverHome => 'Home';

  @override
  String get blitzTitle => 'Blitz';

  @override
  String get blitzStage => 'STAGE';

  @override
  String get blitzComplete => 'Blitz Complete!';

  @override
  String get blitzOver => 'Blitz Over';

  @override
  String get blitzFinalScore => 'FINAL SCORE';

  @override
  String blitzSurvivedAll(int count) {
    return 'You survived all $count stages.';
  }

  @override
  String blitzClearedOf(int cleared, int total) {
    return 'Cleared $cleared of $total stages.';
  }

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong. Please try again.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get dailyRewardsClaimFree => 'Claim for free';

  @override
  String get dailyRewardsWatchAd => 'Watch ad';

  @override
  String get dailyRewardsSnackClaimed => 'Claimed!';

  @override
  String get dailyRewardsClaimedToday => 'Claimed today!';

  @override
  String dailyRewardsNextIn(String time) {
    return 'Next reward in $time';
  }

  @override
  String get unlockTitle => 'Congratulations!';

  @override
  String get unlockSubtitle => 'New board unlocked';

  @override
  String get unlockAddedToInventory => 'Added to your inventory';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count COINS';
  }

  @override
  String get buttonCheckInventory => 'Check Inventory';

  @override
  String get buttonMainMenu => 'Main Menu';

  @override
  String get dailyChallengesTitle => 'Daily Challenges';

  @override
  String get dailyChallengesSubtitle =>
      'Complete special modes to earn bonus rewards.';

  @override
  String get dailyRewardsSubtitle => 'Claim your streak reward';

  @override
  String get activeChallengesTitle => 'Active Challenges';

  @override
  String get blitzSubtitle =>
      'Clear a gauntlet of stages. Timers tighten. Hearts carry.';

  @override
  String get badgeNew => 'NEW';

  @override
  String get mineArrowsTitle => 'Mine Arrows';

  @override
  String get mineArrowsSubtitle =>
      'Clear arrows while dodging hidden grid mines!';

  @override
  String get badgeComingSoon => 'COMING SOON';

  @override
  String get mineArrowsComingSoonSnack =>
      'Mine Arrows challenge is coming soon!';

  @override
  String get dailyRewardsLabel => 'DAILY REWARDS';

  @override
  String dayOfMax(int day, int max) {
    return 'Day $day of $max';
  }

  @override
  String get comeBackTomorrow => 'Come back tomorrow';

  @override
  String plusCoins(int count) {
    return '+$count coins';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'Claim for free';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String watchAdCoins(int coins) {
    return 'Watch ad → +$coins coins';
  }

  @override
  String get notNow => 'Not now';

  @override
  String get claimedToday => 'Claimed today!';

  @override
  String nextRewardIn(String time) {
    return 'Next reward in $time';
  }

  @override
  String get closeLabel => 'Close';

  @override
  String get claimedSnack => 'Claimed!';

  @override
  String get arrowRushTitle => 'Arrow Rush';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return 'Reach level $level to unlock $tier';
  }

  @override
  String startTier(String tier) {
    return 'Start $tier';
  }

  @override
  String lvLabel(int level) {
    return 'Lv $level';
  }

  @override
  String get adNotAvailable => 'Ad not available, try again later';

  @override
  String get adBadge => 'AD';

  @override
  String get homeButton => 'Home';

  @override
  String get gameOverTimeUp => 'Time\'s Up!';

  @override
  String get gameOverOutOfTime => 'Out of Time!';

  @override
  String get gameOverOutOfLives => 'Out of Lives!';

  @override
  String gameOverRewardTime(int seconds) {
    return '+${seconds}s';
  }

  @override
  String gameOverRewardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count hearts',
      one: '+$count heart',
    );
    return '$_temp0';
  }

  @override
  String gameOverTimeAttackStats(int cleared, int level) {
    return 'Puzzles Cleared: $cleared\nFinal Level: $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'Watch ad → $reward';
  }

  @override
  String get gameOverStartNewRun => 'Start New Run';

  @override
  String get gameOverRestartLevel => 'Restart Level';

  @override
  String get levelCompleteTitle => 'Level Complete!';

  @override
  String get levelCompleteNewTrophy => 'NEW TROPHY';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count RANDOM ITEMS',
      one: '+$count RANDOM ITEM',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => 'You Finished the Game!';

  @override
  String get levelCompleteNextLevel => 'Next Level';

  @override
  String get levelCompleteCoinsDoubled => 'Coins Doubled!';

  @override
  String get levelCompleteDoubleCoins => 'Double Coins';

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseResume => 'Resume';

  @override
  String get pauseRestart => 'Restart';

  @override
  String get pauseMainMenu => 'Main Menu';

  @override
  String get itemBombName => 'Bomb';

  @override
  String get itemBombDesc => 'Destroy one rock';

  @override
  String get itemHintName => 'Hint';

  @override
  String get itemHintDesc => 'Reveal the next solvable arrow';

  @override
  String get itemUndoName => 'Undo';

  @override
  String get itemUndoDesc => 'Bring back the last escaped arrow';

  @override
  String get itemHeartFlaskName => 'Heart Flask';

  @override
  String get itemHeartFlaskDesc => 'Restore one heart';

  @override
  String get itemTimeFreezeName => 'Time Freeze';

  @override
  String get itemTimeFreezeDesc => 'Add 30 seconds to the timer';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeClassic => 'Classic';

  @override
  String get themeRetro => 'Retro';

  @override
  String get themeCyber => 'Cyber';

  @override
  String get themeHacker => 'Hacker';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeBlueprint => 'Blueprint';

  @override
  String get themeForest => 'Forest';

  @override
  String get themePastel => 'Pastel';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeRainbow => 'Rainbow';

  @override
  String get boardMinimal => 'Minimal';

  @override
  String get boardNebula => 'Nebula';

  @override
  String get boardBlueprint => 'Blueprint';

  @override
  String get boardForest => 'Forest';

  @override
  String get boardOcean => 'Ocean';

  @override
  String get boardEmber => 'Ember';

  @override
  String get boardCosmic => 'Cosmic';

  @override
  String get boardGeometric => 'Geometric';

  @override
  String get boardGold => 'Gold';

  @override
  String get boardHacker => 'Hacker';

  @override
  String get boardPaper => 'Paper';

  @override
  String get boardIce => 'Ice';

  @override
  String get boardSand => 'Sand';

  @override
  String get boardCloud => 'Cloud';

  @override
  String get boardMint => 'Mint';

  @override
  String get boardRose => 'Rose';

  @override
  String get boardLavender => 'Lavender';

  @override
  String get boardSky => 'Sky';

  @override
  String get boardPearl => 'Pearl';

  @override
  String get boardHoney => 'Honey';

  @override
  String get trophyFirstEscapeTitle => '🌟 THE FIRST AWAKENING';

  @override
  String get trophyFirstEscapeDesc =>
      'Your very first maze escaped! You have unlocked the gateway to the Trophy System. Welcome to AHB.Dev\'s ultimate puzzle journey!';

  @override
  String get trophyPointBlankTitle => 'Point Blank';

  @override
  String get trophyPointBlankDesc =>
      'Successfully clear your first puzzle layout with precision.';

  @override
  String get trophyTrialOfTwoTitle => 'Trial of Two';

  @override
  String get trophyTrialOfTwoDesc =>
      'Conquer the intense two-heart restriction of the early trials.';

  @override
  String get trophyQuickThinkerTitle => 'Quick Thinker';

  @override
  String get trophyQuickThinkerDesc =>
      'Complete any level swiftly under a stretched 20-second threshold.';

  @override
  String get trophyArrowSmithTitle => 'Arrow Smith';

  @override
  String get trophyArrowSmithDesc =>
      'Clear 10 levels without giving up or restarting.';

  @override
  String get trophyCleanSlateTitle => 'Clean Slate';

  @override
  String get trophyCleanSlateDesc =>
      'Finish a level without a single blocked arrow tap.';

  @override
  String get trophySparkOfGeniusTitle => 'Spark of Genius';

  @override
  String get trophySparkOfGeniusDesc =>
      'Use your first hint item to find a path through a sticky situation.';

  @override
  String get trophyUnwindTitle => 'Unwind';

  @override
  String get trophyUnwindDesc =>
      'Use your first undo item to reverse a misstep.';

  @override
  String get trophyRockBreakerTitle => 'Rock Breaker';

  @override
  String get trophyRockBreakerDesc =>
      'Successfully blast away your first rock obstacle using a tactical bomb arrow.';

  @override
  String get trophySurvivalistBadgeTitle => 'The Survivalist';

  @override
  String get trophySurvivalistBadgeDesc =>
      'Conquered the first 25 trials! Permanently upgrades your max hearts from 2 to 3.';

  @override
  String get trophyWayfinderTitle => 'Wayfinder';

  @override
  String get trophyWayfinderDesc =>
      'Reach level 50 and prove your mastery of early mazes.';

  @override
  String get trophyTangleTamerTitle => 'Tangle Tamer';

  @override
  String get trophyTangleTamerDesc =>
      'Clear 10 levels in a row without making a single directional error.';

  @override
  String get trophyTimeLordTitle => 'Time Lord';

  @override
  String get trophyTimeLordDesc =>
      'Survive a timed God-level trial with countdown seconds to spare.';

  @override
  String get trophyCenturyMarkTitle => 'Century Mark';

  @override
  String get trophyCenturyMarkDesc =>
      'Reach level 100 — one-fifth of the way to the 500 summit!';

  @override
  String get trophyBombTechnicianTitle => 'Bomb Technician';

  @override
  String get trophyBombTechnicianDesc =>
      'Clear 25 rock obstacles across your campaign using tactical bombs.';

  @override
  String get trophyUntouchableTitle => 'Untouchable';

  @override
  String get trophyUntouchableDesc =>
      'Complete 5 levels consecutively without losing a single heart.';

  @override
  String get trophyStargazerTitle => 'Stargazer';

  @override
  String get trophyStargazerDesc =>
      'Earn 3 stars across 30 different puzzle boards.';

  @override
  String get trophyMasterOfAnglesTitle => 'Master of Angles';

  @override
  String get trophyMasterOfAnglesDesc =>
      'Complete a complex puzzle heavily featuring orphan redirector dots.';

  @override
  String get trophyHalfwayToGloryTitle => 'Halfway to Glory';

  @override
  String get trophyHalfwayToGloryDesc =>
      'Reach level 125, establishing your mid-game dominance.';

  @override
  String get trophyTheStrategistTitle => 'The Strategist';

  @override
  String get trophyTheStrategistDesc =>
      'Utilize all available inventory items at least once during a single session.';

  @override
  String get trophyQuickSilverTitle => 'Quick Silver';

  @override
  String get trophyQuickSilverDesc =>
      'Accumulate 5 minutes of active high-speed play in Time Attack mode.';

  @override
  String get trophyIronWillTitle => 'Iron Will';

  @override
  String get trophyIronWillDesc =>
      'Win a boss level after dropping down to your absolute final heart.';

  @override
  String get trophyGoldenTouchTitle => 'Golden Touch';

  @override
  String get trophyGoldenTouchDesc =>
      'Unlock your very first custom board or arrow skin theme.';

  @override
  String get trophyDeepDiverTitle => 'Deep Diver';

  @override
  String get trophyDeepDiverDesc =>
      'Reach level 150 as the labyrinth grows exponentially complex.';

  @override
  String get trophyThePuzzlerTitle => 'The Puzzler';

  @override
  String get trophyThePuzzlerDesc =>
      'Complete 50 randomly generated procedural puzzle boards.';

  @override
  String get trophySharpShooterTitle => 'Sharp Shooter';

  @override
  String get trophySharpShooterDesc =>
      'Finish 20 levels using the minimum possible moves.';

  @override
  String get trophyVaultKeeperTitle => 'Vault Keeper';

  @override
  String get trophyVaultKeeperDesc =>
      'Accumulate a massive total of 500 coins from gameplay and ad rewards.';

  @override
  String get trophyMilestoneMasterTitle => 'Milestone Master';

  @override
  String get trophyMilestoneMasterDesc =>
      'Reach level 200 — two-fifths of the way to the 500 max level.';

  @override
  String get trophyBossSlayerTitle => 'Boss Slayer';

  @override
  String get trophyBossSlayerDesc =>
      'Defeat 8 boss levels consecutively without a single defeat.';

  @override
  String get trophyTimeBenderTitle => 'Time Bender';

  @override
  String get trophyTimeBenderDesc =>
      'Freeze time successfully 10 times on intense countdown levels.';

  @override
  String get trophyResilientSpiritTitle => 'Resilient Spirit';

  @override
  String get trophyResilientSpiritDesc =>
      'Recover from a game-over state using an ad continuation reward.';

  @override
  String get trophyBoardCollectorTitle => 'Board Collector';

  @override
  String get trophyBoardCollectorDesc =>
      'Unlock 5 different custom board themes for your collection.';

  @override
  String get trophyApexPredatorTitle => 'Apex Predator';

  @override
  String get trophyApexPredatorDesc =>
      'Reach level 250 — the halfway summit of the current puzzle campaign.';

  @override
  String get trophyFlawlessExecutionTitle => 'Flawless Execution';

  @override
  String get trophyFlawlessExecutionDesc =>
      'Earn 3 stars across 100 separate levels.';

  @override
  String get trophyTacticalMindsetTitle => 'Tactical Mindset';

  @override
  String get trophyTacticalMindsetDesc =>
      'Solve a god-tier puzzle without relying on any hints.';

  @override
  String get trophyDailyDevoteeTitle => 'Daily Devotee';

  @override
  String get trophyDailyDevoteeDesc =>
      'Maintain a 7-day login streak on your daily rewards tracker.';

  @override
  String get trophyMonumentalPioneerTitle => 'Monumental Pioneer';

  @override
  String get trophyMonumentalPioneerDesc =>
      'Unlock your first purely decorative, prestige monumental trophy.';

  @override
  String get trophyHighClimberTitle => 'The High Climber';

  @override
  String get trophyHighClimberDesc =>
      'Reach level 300 — three-fifths of the way to the 500 summit.';

  @override
  String get trophyGrandmasterTitle => 'Grandmaster';

  @override
  String get trophyGrandmasterDesc =>
      'Reach level 350, conquering the most complex grid tangles.';

  @override
  String get trophyEternalFlameTitle => 'Eternal Flame';

  @override
  String get trophyEternalFlameDesc =>
      'Maintain an incredible 14-day continuous login streak.';

  @override
  String get trophyIroncladTitle => 'Ironclad';

  @override
  String get trophyIroncladDesc =>
      'Reach level 400 — four-fifths of the way to the ultimate summit.';

  @override
  String get trophyPerfectionistTitle => 'Perfectionist';

  @override
  String get trophyPerfectionistDesc =>
      'Earn 3 stars on every single level from 1 up to 400.';

  @override
  String get trophyTitanOfTheMazeTitle => 'Titan of the Maze';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'Reach level 450, standing among elite puzzle solvers.';

  @override
  String get trophyThe500ClubTitle => 'The 500 Club';

  @override
  String get trophyThe500ClubDesc =>
      'Reach level 500, hitting the current maximum summit of the puzzle grid!';

  @override
  String get trophyLivingLegendTitle => 'Living Legend';

  @override
  String get trophyLivingLegendDesc =>
      'Clear level 500 with a 3-star rating and zero mistakes.';

  @override
  String get trophyMonumentOfTimeTitle => 'Monument of Time';

  @override
  String get trophyMonumentOfTimeDesc =>
      'A prestige monumental artifact for dedicating over 10 active hours to escaping mazes.';

  @override
  String get trophyAbsoluteVoidTitle => 'The Absolute Void';

  @override
  String get trophyAbsoluteVoidDesc =>
      'A pitch-black monumental prestige trophy awarded for maxing out key progression features.';

  @override
  String get trophyInfiniteHorizonTitle => 'Infinite Horizon';

  @override
  String get trophyInfiniteHorizonDesc =>
      'A monumental placeholder trophy acknowledging that the journey beyond level 500 never ends.';

  @override
  String timeBonusAmount(int seconds) {
    return '+${seconds}s';
  }

  @override
  String get heartsAlreadyFull => 'Hearts are already full';

  @override
  String timeFreezeWait(int seconds) {
    return 'Wait ${seconds}s more before using Time Freeze';
  }

  @override
  String get tapRockToDestroy => 'Tap a rock to destroy it';

  @override
  String get noSolvableArrowFound => 'No solvable arrow found';

  @override
  String get nothingToUndo => 'Nothing to undo';

  @override
  String get blitzCompleteTitle => 'Blitz Complete!';

  @override
  String get blitzOverTitle => 'Blitz Over';

  @override
  String get blitzSplashStage => 'STAGE';

  @override
  String blitzPoints(int score) {
    return '$score pts';
  }

  @override
  String get arrowSpeedEscapeSpeed => 'Escape speed';

  @override
  String get arrowSpeedSlow => 'Slow';

  @override
  String get arrowSpeedNormal => 'Normal';

  @override
  String get arrowSpeedFast => 'Fast';

  @override
  String get accentColorLabel => 'Accent Color';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsConditions => 'Terms & Conditions';

  @override
  String get settingsChooseLanguage => 'Choose Language';

  @override
  String settingsVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortugueseBR => 'Portuguese (BR)';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageFrench => 'French';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'Trophies ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'Lvl $level';
  }

  @override
  String get trophiesPerkHeart => '✨ Perk: +1 Permanent Max Heart';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardTabWeekly => 'Weekly';

  @override
  String get leaderboardTabMonthly => 'Monthly';

  @override
  String get leaderboardTabAllTime => 'All-Time';

  @override
  String get leaderboardYourRank => 'Your Rank';

  @override
  String get leaderboardNotRanked => 'Not ranked yet';

  @override
  String get leaderboardSignInToRank => 'Sign in to appear on the leaderboard';

  @override
  String get leaderboardEmptyState => 'No scores yet — be the first!';

  @override
  String get leaderboardScore => 'Score';

  @override
  String get leaderboardLevel => 'Level';

  @override
  String get leaderboardStars => 'Stars';

  @override
  String get leaderboardTrophies => 'Trophies';

  @override
  String get leaderboardYou => 'You';

  @override
  String get leaderboardRankPrefix => '#';

  @override
  String get leaderboardOptInTitle => 'Show me on leaderboard';

  @override
  String get leaderboardOptInSubtitle => 'Let other players see your rank';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get inventoryTabArrows => 'Arrows';

  @override
  String get inventoryTabBoards => 'Boards';

  @override
  String get inventoryTabItems => 'Items';

  @override
  String get inventoryEquipped => 'Equipped';

  @override
  String get inventoryTapToEquip => 'Tap to equip';

  @override
  String inventoryReachLevel(int level) {
    return 'Reach level $level to unlock';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'Lv $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return 'Need $count more coins';
  }

  @override
  String inventoryBuyItemTitle(String item) {
    return 'Buy $item?';
  }

  @override
  String inventoryUnlockTitle(String title) {
    return 'Unlock $title?';
  }

  @override
  String inventoryCoinsPrice(int count) {
    return '$count coins';
  }

  @override
  String get inventoryBuy => 'Buy';

  @override
  String get rushDifficultyEasy => 'Easy';

  @override
  String get rushDifficultyHard => 'Hard';

  @override
  String get rushDifficultyImpossible => 'Impossible';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePlayingAsGuest => 'Playing as guest';

  @override
  String get profileSignInSuccess => 'Signed in — progress synced';

  @override
  String profileSignInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get profileSaveYourProgress => 'Save your progress';

  @override
  String get profileGuestBody =>
      'Guest accounts live on this device only. Sign in to back up your level, coins, and trophies.';

  @override
  String get profileContinueWithEmail => 'Continue with Email';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody =>
      'Your cloud save stays. This device will reset to a fresh guest account and start from level 1.';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteAccountTitle => 'Delete Account?';

  @override
  String get profileDeleteAccountBody =>
      'This will permanently delete your cloud save and account. This action cannot be undone.';

  @override
  String get profileDelete => 'Delete';

  @override
  String profileDeleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'Sign-out failed: $error';
  }

  @override
  String get profileSignedInBody =>
      'Your progress is backed up to the cloud. Sign in on any device with the same account to continue.';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileStatLevel => 'Level';

  @override
  String get profileStatStars => 'Stars';

  @override
  String get profileStatTrophies => 'Trophies';

  @override
  String get profileTabSignIn => 'Sign In';

  @override
  String get profileTabCreateAccount => 'Create Account';

  @override
  String get profileCreateAccountTitle => 'Create your account';

  @override
  String get profileWelcomeBack => 'Welcome back';

  @override
  String get profileGuestProgressCarries =>
      'Your guest progress will carry over.';

  @override
  String get profileSignInRestoreBody =>
      'Sign in to restore your progress from another device.';

  @override
  String get profileNameHint => 'Name (optional)';

  @override
  String get profileEmailHint => 'Email';

  @override
  String get profilePasswordHint => 'Password';

  @override
  String get profileShowPassword => 'Show password';

  @override
  String get profileHidePassword => 'Hide password';

  @override
  String get profileGeneratePassword => 'Generate password';

  @override
  String get profilePasswordMinLength =>
      'Password must be at least 8 characters.';

  @override
  String get profileStrengthTooShort => 'Too short';

  @override
  String get profileStrengthOkay => 'Okay';

  @override
  String get profileStrengthGood => 'Good';

  @override
  String get profileStrengthStrong => 'Strong';

  @override
  String get profileErrorEmailSignUp =>
      'That email is already registered. Try Sign In instead.';

  @override
  String get profileErrorEmailSignIn =>
      'That email is already registered. Check your password or reset it from the email link.';

  @override
  String get profileErrorInvalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get profileErrorPassword =>
      'Password not accepted. Use 8+ characters with letters and numbers, and avoid common words like \"password\".';

  @override
  String get profileErrorInvalidEmail => 'That email address looks invalid.';

  @override
  String get profileErrorSessionExpired =>
      'Session expired. Please close the app, reopen it, and try again.';

  @override
  String get profileErrorRateLimit =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get profileErrorServerBusy =>
      'Server is busy. Please try again in a moment.';

  @override
  String get profileErrorSignUpGeneric =>
      'Sign-up failed. Please check your details and try again.';

  @override
  String get profileErrorSignInGeneric =>
      'Sign-in failed. Please check your email and password.';

  @override
  String get profileEnterValidEmail => 'Enter a valid email address.';

  @override
  String get profileEnterPassword => 'Enter your password.';

  @override
  String get profileEmailAlreadyPrompt =>
      'That email already has an account. Enter your password to sign in.';

  @override
  String get profileSomethingWrong => 'Something went wrong. Please try again.';

  @override
  String get profileCreateAccountButton => 'Create account';

  @override
  String get profileSignInButton => 'Sign in';

  @override
  String get profileAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get profileDontHaveAccount => 'Don\'t have an account? Create one';

  @override
  String get homePlayer => 'Player';

  @override
  String homeLevelStars(int level, int stars) {
    return 'Level $level · $stars stars';
  }

  @override
  String get homeContinueLabel => 'CONTINUE';

  @override
  String homeLevelNumber(int level) {
    return 'Level $level';
  }

  @override
  String get homeContinue => 'Continue';

  @override
  String get homeDaily => 'Daily';

  @override
  String get homeDailyReady => 'Ready to play';

  @override
  String get homeDailyClaimed => 'Claimed today';

  @override
  String get homeLeaderboard => 'Leaderboard';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get homeInventory => 'Inventory';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'All unlocked · $count items';
  }

  @override
  String get homeInventoryBrowse => 'Browse your gear';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items items';
  }

  @override
  String get homeTrophies => 'Trophies';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$unlocked of $total';
  }

  @override
  String get privacyWelcomeTitle => 'Welcome to Arrow Puzzle';

  @override
  String get privacyWelcomeSubtitle =>
      'Before we begin, please review and accept our terms.';

  @override
  String get privacyBulletLocal =>
      'Your progress is saved locally on your device.';

  @override
  String get privacyBulletCloud =>
      'Optional accounts sync progress to the cloud.';

  @override
  String get privacyBulletAds => 'The game shows ads to keep it free.';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get privacyTermsLink => 'Terms & Conditions';

  @override
  String get privacyAcceptButton => 'Accept & Continue';

  @override
  String get privacyAgreeFooter =>
      'By tapping above you agree to our Terms & Conditions.';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavDaily => 'Daily';

  @override
  String get bottomNavInventory => 'Inventory';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String gameTopBarScore(int score) {
    return 'Score: $score';
  }

  @override
  String get gameTopBarRandom => 'Random';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'Lv.$level';
  }

  @override
  String get gameModeZenMode => 'Zen Mode';

  @override
  String get howToPlayTitle => 'HOW TO PLAY';

  @override
  String get howToPlayBasics => 'THE BASICS';

  @override
  String get howToPlayBoardElements => 'BOARD ELEMENTS';

  @override
  String get howToPlayGameModes => 'GAME MODES';

  @override
  String get howToPlayProStrategies => 'PRO STRATEGIES';

  @override
  String get howToPlayCoreTitle => 'Core Objective';

  @override
  String get howToPlayCoreDesc =>
      'Your goal is to clear the entire puzzle grid by guiding every arrow off the board. When no arrows remain on the board, the level is complete.';

  @override
  String get howToPlayMovementTitle => 'Arrow Movement';

  @override
  String get howToPlayMovementDesc =>
      'Tap any arrow to launch it. Arrows slide forward in the exact direction their arrowhead points: Up, Down, Left, or Right. Even if an arrow has a bent or winding body, it always exits following its tip.';

  @override
  String get howToPlayObstaclesTitle => 'Obstacles & Collisions';

  @override
  String get howToPlayObstaclesDesc =>
      'An arrow can only escape if its entire exit path is completely clear. If another arrow stands in the way, the tapped arrow will shake and stay in place.';

  @override
  String get howToPlayLivesTitle => 'Lives & Health';

  @override
  String get howToPlayLivesDesc =>
      'In Classic mode, you start with 3 hearts. Tapping a blocked arrow costs 1 heart. If you deplete all 3 hearts, you must restart the level. You can toggle Infinite Lives in Settings anytime.';

  @override
  String get howToPlayTurnDotsTitle => 'Turn Dots (Redirectors)';

  @override
  String get howToPlayTurnDotsDesc =>
      'Look for circular dots on empty grid cells marked with small arrows. When a sliding arrow crosses a Turn Dot, it instantly pivots in the dot\'s direction and consumes it, opening unexpected exit routes.';

  @override
  String get howToPlayCombosTitle => 'Combos & Streaks';

  @override
  String get howToPlayCombosDesc =>
      'Release arrows in quick succession (within 1.5 seconds) to trigger combos. Chaining consecutive escapes builds momentum and scores combo multipliers.';

  @override
  String get howToPlayClassicTitle => 'Classic Mode';

  @override
  String get howToPlayClassicDesc =>
      'The standard campaign progression. Advance through handcrafted and procedural stages of escalating size, shape masks, and path complexity with 3 hearts.';

  @override
  String get howToPlayZenTitle => 'Zen Mode';

  @override
  String get howToPlayZenDesc =>
      'Pure relaxation with zero stress. No hearts to lose, no time limits, and no failure states. Ideal for unwinding and practicing complex boards.';

  @override
  String get howToPlayTimeAttackTitle => 'Time Attack';

  @override
  String get howToPlayTimeAttackDesc =>
      'Fast-paced race against the clock! Every arrow you successfully escape awards precious bonus seconds back onto your countdown timer.';

  @override
  String get howToPlayMultiplayerTitle => 'Multiplayer Rooms';

  @override
  String get howToPlayMultiplayerDesc =>
      'Host or join with room seed codes. Both players compete on the exact same randomized layout to see who can solve and escape the board fastest.';

  @override
  String get howToPlayRandomTitle => 'Random Puzzles';

  @override
  String get howToPlayRandomDesc =>
      'Generate infinite on-demand puzzles across Easy, Medium, Hard, Master, and Expert difficulties without affecting your campaign level progress.';

  @override
  String get howToPlayUnpeelTitle => 'Unpeel From the Perimeter';

  @override
  String get howToPlayUnpeelDesc =>
      'Start by scanning the outer borders. Arrows pointing straight outward into empty space can always escape immediately, freeing up critical lanes.';

  @override
  String get howToPlayTraceTitle => 'Trace Blockers in Reverse';

  @override
  String get howToPlayTraceDesc =>
      'When an arrow is blocked, find which arrow blocks it, then find what blocks that second arrow. Unlocking the final blocker in the chain frees everything behind it.';

  @override
  String get howToPlayTapAssistTitle => 'Enable Tap Assist';

  @override
  String get howToPlayTapAssistDesc =>
      'If you play on smaller screens or tend to tap between tight arrow segments, turn on Tap Assist in Settings to automatically map nearby taps to the nearest arrow.';

  @override
  String get multiplayerTitle => 'MULTIPLAYER';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return 'Room code $code copied to clipboard!';
  }

  @override
  String get multiplayerHostRoom => 'HOST ROOM';

  @override
  String get multiplayerHostBody =>
      'Share this room code with a friend to compete on the exact same puzzle layout!';

  @override
  String get multiplayerNewCode => 'New Code';

  @override
  String get multiplayerCopyCode => 'Copy Code';

  @override
  String get multiplayerStartMatch => 'START MATCH';

  @override
  String get multiplayerJoinRoom => 'JOIN ROOM';

  @override
  String get multiplayerJoinBody =>
      'Enter or paste a room code to join the match.';

  @override
  String get multiplayerRoomCodeHint => 'e.g. ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'Please enter a room code';

  @override
  String get multiplayerJoinMatch => 'JOIN MATCH';

  @override
  String get zenCardSubtitle => 'No timer. No limits. Just solve.';

  @override
  String get profileSyncing => 'Syncing...';

  @override
  String get profileSyncFailed => 'Sync failed';

  @override
  String get gameModeTimeBlitz => 'Time Blitz';

  @override
  String get timeBlitzDesc =>
      'Tap arrows to earn time. Blocked taps cost time. Survive as long as you can.';

  @override
  String get timeBlitzOverTitle => 'Time Blitz Over';

  @override
  String get timeBlitzScoreLabel => 'ARROWS CLEARED';

  @override
  String get timeBlitzLevelsLabel => 'Levels reached';

  @override
  String get profileEditName => 'Edit Name';

  @override
  String get profileSave => 'Save';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get shareMessage => 'Check out Arrow Puzzle — a fun maze escape game!';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get settingsShareFriends => 'Share with friends';

  @override
  String get settingsSharingSoon => 'Sharing coming soon';
}
