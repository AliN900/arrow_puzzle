import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppStrings
/// returned by `AppStrings.of(context)`.
///
/// Applications need to include `AppStrings.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppStrings.localizationsDelegates,
///   supportedLocales: AppStrings.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppStrings.supportedLocales
/// property.
abstract class AppStrings {
  AppStrings(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Arrow Puzzle'**
  String get appName;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get menuDaily;

  /// No description provided for @menuInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get menuInventory;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuTrophies.
  ///
  /// In en, this message translates to:
  /// **'Trophies'**
  String get menuTrophies;

  /// No description provided for @menuLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get menuLeaderboard;

  /// No description provided for @menuContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get menuContinue;

  /// No description provided for @menuLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String menuLevel(int level);

  /// No description provided for @buttonPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get buttonPlay;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buttonBuy;

  /// No description provided for @buttonRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get buttonRestart;

  /// No description provided for @buttonResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get buttonResume;

  /// No description provided for @buttonExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get buttonExit;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get buttonNext;

  /// No description provided for @buttonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get buttonSignIn;

  /// No description provided for @buttonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get buttonSignUp;

  /// No description provided for @buttonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get buttonSignOut;

  /// No description provided for @buttonDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get buttonDeleteAccount;

  /// No description provided for @buttonClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim for free'**
  String get buttonClaim;

  /// No description provided for @buttonWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get buttonWatchAd;

  /// No description provided for @buttonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get buttonAccept;

  /// No description provided for @buttonShare.
  ///
  /// In en, this message translates to:
  /// **'Share with friends'**
  String get buttonShare;

  /// No description provided for @buttonStartBlitz.
  ///
  /// In en, this message translates to:
  /// **'Start Blitz'**
  String get buttonStartBlitz;

  /// No description provided for @buttonStartRush.
  ///
  /// In en, this message translates to:
  /// **'Start {tier}'**
  String buttonStartRush(String tier);

  /// No description provided for @gameModeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get gameModeClassic;

  /// No description provided for @gameModeZen.
  ///
  /// In en, this message translates to:
  /// **'Zen Mode'**
  String get gameModeZen;

  /// No description provided for @gameModeTimeAttack.
  ///
  /// In en, this message translates to:
  /// **'Time Attack'**
  String get gameModeTimeAttack;

  /// No description provided for @gameModeArrowRush.
  ///
  /// In en, this message translates to:
  /// **'Arrow Rush'**
  String get gameModeArrowRush;

  /// No description provided for @gameModeBlitz.
  ///
  /// In en, this message translates to:
  /// **'Blitz'**
  String get gameModeBlitz;

  /// No description provided for @gameModeMineArrows.
  ///
  /// In en, this message translates to:
  /// **'Mine Arrows'**
  String get gameModeMineArrows;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyImpossible.
  ///
  /// In en, this message translates to:
  /// **'Impossible'**
  String get difficultyImpossible;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColor;

  /// No description provided for @settingsAudioHaptics.
  ///
  /// In en, this message translates to:
  /// **'AUDIO & HAPTICS'**
  String get settingsAudioHaptics;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsArrowSpeed.
  ///
  /// In en, this message translates to:
  /// **'ARROW SPEED'**
  String get settingsArrowSpeed;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTerms;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsSharingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sharing coming soon'**
  String get settingsSharingComingSoon;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Arrow Puzzle'**
  String get consentTitle;

  /// No description provided for @consentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Before we begin, please review and accept our terms.'**
  String get consentSubtitle;

  /// No description provided for @consentLocalProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved locally on your device.'**
  String get consentLocalProgress;

  /// No description provided for @consentCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Optional accounts sync progress to the cloud.'**
  String get consentCloudSync;

  /// No description provided for @consentAds.
  ///
  /// In en, this message translates to:
  /// **'The game shows ads to keep it free.'**
  String get consentAds;

  /// No description provided for @consentAgreement.
  ///
  /// In en, this message translates to:
  /// **'By tapping above you agree to our Terms & Conditions.'**
  String get consentAgreement;

  /// No description provided for @dialogExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get dialogExitTitle;

  /// No description provided for @dialogExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave?'**
  String get dialogExitMessage;

  /// No description provided for @dialogSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get dialogSignOutTitle;

  /// No description provided for @dialogSignOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cloud save stays. This device will reset to a fresh guest account and start from level 1.'**
  String get dialogSignOutMessage;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your cloud save and account. This action cannot be undone.'**
  String get dialogDeleteMessage;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Playing as guest'**
  String get profileGuest;

  /// No description provided for @profileSaveToCloud.
  ///
  /// In en, this message translates to:
  /// **'Save to Cloud'**
  String get profileSaveToCloud;

  /// No description provided for @profileSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get profileSynced;

  /// No description provided for @profileSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedIn;

  /// No description provided for @profileStatsLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get profileStatsLevel;

  /// No description provided for @profileStatsStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get profileStatsStars;

  /// No description provided for @profileStatsTrophies.
  ///
  /// In en, this message translates to:
  /// **'Trophies'**
  String get profileStatsTrophies;

  /// No description provided for @dailyRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY REWARDS'**
  String get dailyRewardsTitle;

  /// No description provided for @dailyRewardsDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {max}'**
  String dailyRewardsDay(int day, int max);

  /// No description provided for @dailyRewardsComeBack.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow'**
  String get dailyRewardsComeBack;

  /// No description provided for @dailyRewardsClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed today!'**
  String get dailyRewardsClaimed;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get levelComplete;

  /// No description provided for @levelFailed.
  ///
  /// In en, this message translates to:
  /// **'Out of Lives!'**
  String get levelFailed;

  /// No description provided for @levelTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Out of Time!'**
  String get levelTimeUp;

  /// No description provided for @gameOverRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart Level'**
  String get gameOverRestart;

  /// No description provided for @gameOverHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get gameOverHome;

  /// No description provided for @blitzTitle.
  ///
  /// In en, this message translates to:
  /// **'Blitz'**
  String get blitzTitle;

  /// No description provided for @blitzStage.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get blitzStage;

  /// No description provided for @blitzComplete.
  ///
  /// In en, this message translates to:
  /// **'Blitz Complete!'**
  String get blitzComplete;

  /// No description provided for @blitzOver.
  ///
  /// In en, this message translates to:
  /// **'Blitz Over'**
  String get blitzOver;

  /// No description provided for @blitzFinalScore.
  ///
  /// In en, this message translates to:
  /// **'FINAL SCORE'**
  String get blitzFinalScore;

  /// No description provided for @blitzSurvivedAll.
  ///
  /// In en, this message translates to:
  /// **'You survived all {count} stages.'**
  String blitzSurvivedAll(int count);

  /// No description provided for @blitzClearedOf.
  ///
  /// In en, this message translates to:
  /// **'Cleared {cleared} of {total} stages.'**
  String blitzClearedOf(int cleared, int total);

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @dailyRewardsClaimFree.
  ///
  /// In en, this message translates to:
  /// **'Claim for free'**
  String get dailyRewardsClaimFree;

  /// No description provided for @dailyRewardsWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get dailyRewardsWatchAd;

  /// No description provided for @dailyRewardsSnackClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed!'**
  String get dailyRewardsSnackClaimed;

  /// No description provided for @dailyRewardsClaimedToday.
  ///
  /// In en, this message translates to:
  /// **'Claimed today!'**
  String get dailyRewardsClaimedToday;

  /// No description provided for @dailyRewardsNextIn.
  ///
  /// In en, this message translates to:
  /// **'Next reward in {time}'**
  String dailyRewardsNextIn(String time);

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get unlockTitle;

  /// No description provided for @unlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New board unlocked'**
  String get unlockSubtitle;

  /// No description provided for @unlockAddedToInventory.
  ///
  /// In en, this message translates to:
  /// **'Added to your inventory'**
  String get unlockAddedToInventory;

  /// No description provided for @unlockCoinsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{count} COINS'**
  String unlockCoinsEarned(int count);

  /// No description provided for @buttonCheckInventory.
  ///
  /// In en, this message translates to:
  /// **'Check Inventory'**
  String get buttonCheckInventory;

  /// No description provided for @buttonMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get buttonMainMenu;

  /// No description provided for @dailyChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenges'**
  String get dailyChallengesTitle;

  /// No description provided for @dailyChallengesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete special modes to earn bonus rewards.'**
  String get dailyChallengesSubtitle;

  /// No description provided for @dailyRewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Claim your streak reward'**
  String get dailyRewardsSubtitle;

  /// No description provided for @activeChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Challenges'**
  String get activeChallengesTitle;

  /// No description provided for @blitzSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear a gauntlet of stages. Timers tighten. Hearts carry.'**
  String get blitzSubtitle;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @mineArrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mine Arrows'**
  String get mineArrowsTitle;

  /// No description provided for @mineArrowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear arrows while dodging hidden grid mines!'**
  String get mineArrowsSubtitle;

  /// No description provided for @badgeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get badgeComingSoon;

  /// No description provided for @mineArrowsComingSoonSnack.
  ///
  /// In en, this message translates to:
  /// **'Mine Arrows challenge is coming soon!'**
  String get mineArrowsComingSoonSnack;

  /// No description provided for @dailyRewardsLabel.
  ///
  /// In en, this message translates to:
  /// **'DAILY REWARDS'**
  String get dailyRewardsLabel;

  /// No description provided for @dayOfMax.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {max}'**
  String dayOfMax(int day, int max);

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow'**
  String get comeBackTomorrow;

  /// No description provided for @plusCoins.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins'**
  String plusCoins(int count);

  /// No description provided for @plusItems.
  ///
  /// In en, this message translates to:
  /// **'+ {count} 🎁'**
  String plusItems(int count);

  /// No description provided for @claimForFree.
  ///
  /// In en, this message translates to:
  /// **'Claim for free'**
  String get claimForFree;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// No description provided for @watchAdCoins.
  ///
  /// In en, this message translates to:
  /// **'Watch ad → +{coins} coins'**
  String watchAdCoins(int coins);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @claimedToday.
  ///
  /// In en, this message translates to:
  /// **'Claimed today!'**
  String get claimedToday;

  /// No description provided for @nextRewardIn.
  ///
  /// In en, this message translates to:
  /// **'Next reward in {time}'**
  String nextRewardIn(String time);

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @claimedSnack.
  ///
  /// In en, this message translates to:
  /// **'Claimed!'**
  String get claimedSnack;

  /// No description provided for @arrowRushTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrow Rush'**
  String get arrowRushTitle;

  /// No description provided for @reachLevelToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Reach level {level} to unlock {tier}'**
  String reachLevelToUnlock(int level, String tier);

  /// No description provided for @startTier.
  ///
  /// In en, this message translates to:
  /// **'Start {tier}'**
  String startTier(String tier);

  /// No description provided for @lvLabel.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String lvLabel(int level);

  /// No description provided for @adNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Ad not available, try again later'**
  String get adNotAvailable;

  /// No description provided for @adBadge.
  ///
  /// In en, this message translates to:
  /// **'AD'**
  String get adBadge;

  /// No description provided for @homeButton.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeButton;

  /// No description provided for @gameOverTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get gameOverTimeUp;

  /// No description provided for @gameOverOutOfTime.
  ///
  /// In en, this message translates to:
  /// **'Out of Time!'**
  String get gameOverOutOfTime;

  /// No description provided for @gameOverOutOfLives.
  ///
  /// In en, this message translates to:
  /// **'Out of Lives!'**
  String get gameOverOutOfLives;

  /// No description provided for @gameOverRewardTime.
  ///
  /// In en, this message translates to:
  /// **'+{seconds}s'**
  String gameOverRewardTime(int seconds);

  /// No description provided for @gameOverRewardHearts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+{count} heart} other{+{count} hearts}}'**
  String gameOverRewardHearts(int count);

  /// No description provided for @gameOverTimeAttackStats.
  ///
  /// In en, this message translates to:
  /// **'Puzzles Cleared: {cleared}\nFinal Level: {level}'**
  String gameOverTimeAttackStats(int cleared, int level);

  /// No description provided for @gameOverWatchAdReward.
  ///
  /// In en, this message translates to:
  /// **'Watch ad → {reward}'**
  String gameOverWatchAdReward(String reward);

  /// No description provided for @gameOverStartNewRun.
  ///
  /// In en, this message translates to:
  /// **'Start New Run'**
  String get gameOverStartNewRun;

  /// No description provided for @gameOverRestartLevel.
  ///
  /// In en, this message translates to:
  /// **'Restart Level'**
  String get gameOverRestartLevel;

  /// No description provided for @levelCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get levelCompleteTitle;

  /// No description provided for @levelCompleteNewTrophy.
  ///
  /// In en, this message translates to:
  /// **'NEW TROPHY'**
  String get levelCompleteNewTrophy;

  /// No description provided for @levelCompleteRandomItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+{count} RANDOM ITEM} other{+{count} RANDOM ITEMS}}'**
  String levelCompleteRandomItems(int count);

  /// No description provided for @levelCompleteFinishedGame.
  ///
  /// In en, this message translates to:
  /// **'You Finished the Game!'**
  String get levelCompleteFinishedGame;

  /// No description provided for @levelCompleteNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get levelCompleteNextLevel;

  /// No description provided for @levelCompleteCoinsDoubled.
  ///
  /// In en, this message translates to:
  /// **'Coins Doubled!'**
  String get levelCompleteCoinsDoubled;

  /// No description provided for @levelCompleteDoubleCoins.
  ///
  /// In en, this message translates to:
  /// **'Double Coins'**
  String get levelCompleteDoubleCoins;

  /// No description provided for @pauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseTitle;

  /// No description provided for @pauseResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pauseResume;

  /// No description provided for @pauseRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get pauseRestart;

  /// No description provided for @pauseMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get pauseMainMenu;

  /// No description provided for @itemBombName.
  ///
  /// In en, this message translates to:
  /// **'Bomb'**
  String get itemBombName;

  /// No description provided for @itemBombDesc.
  ///
  /// In en, this message translates to:
  /// **'Destroy one rock'**
  String get itemBombDesc;

  /// No description provided for @itemHintName.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get itemHintName;

  /// No description provided for @itemHintDesc.
  ///
  /// In en, this message translates to:
  /// **'Reveal the next solvable arrow'**
  String get itemHintDesc;

  /// No description provided for @itemUndoName.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get itemUndoName;

  /// No description provided for @itemUndoDesc.
  ///
  /// In en, this message translates to:
  /// **'Bring back the last escaped arrow'**
  String get itemUndoDesc;

  /// No description provided for @itemHeartFlaskName.
  ///
  /// In en, this message translates to:
  /// **'Heart Flask'**
  String get itemHeartFlaskName;

  /// No description provided for @itemHeartFlaskDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore one heart'**
  String get itemHeartFlaskDesc;

  /// No description provided for @itemTimeFreezeName.
  ///
  /// In en, this message translates to:
  /// **'Time Freeze'**
  String get itemTimeFreezeName;

  /// No description provided for @itemTimeFreezeDesc.
  ///
  /// In en, this message translates to:
  /// **'Add 30 seconds to the timer'**
  String get itemTimeFreezeDesc;

  /// No description provided for @themeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get themeNeon;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeClassic;

  /// No description provided for @themeRetro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get themeRetro;

  /// No description provided for @themeCyber.
  ///
  /// In en, this message translates to:
  /// **'Cyber'**
  String get themeCyber;

  /// No description provided for @themeHacker.
  ///
  /// In en, this message translates to:
  /// **'Hacker'**
  String get themeHacker;

  /// No description provided for @themeAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get themeAurora;

  /// No description provided for @themeBlueprint.
  ///
  /// In en, this message translates to:
  /// **'Blueprint'**
  String get themeBlueprint;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themePastel.
  ///
  /// In en, this message translates to:
  /// **'Pastel'**
  String get themePastel;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get themeRainbow;

  /// No description provided for @boardMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get boardMinimal;

  /// No description provided for @boardNebula.
  ///
  /// In en, this message translates to:
  /// **'Nebula'**
  String get boardNebula;

  /// No description provided for @boardBlueprint.
  ///
  /// In en, this message translates to:
  /// **'Blueprint'**
  String get boardBlueprint;

  /// No description provided for @boardForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get boardForest;

  /// No description provided for @boardOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get boardOcean;

  /// No description provided for @boardEmber.
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get boardEmber;

  /// No description provided for @boardCosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic'**
  String get boardCosmic;

  /// No description provided for @boardGeometric.
  ///
  /// In en, this message translates to:
  /// **'Geometric'**
  String get boardGeometric;

  /// No description provided for @boardGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get boardGold;

  /// No description provided for @boardHacker.
  ///
  /// In en, this message translates to:
  /// **'Hacker'**
  String get boardHacker;

  /// No description provided for @boardPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get boardPaper;

  /// No description provided for @boardIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get boardIce;

  /// No description provided for @boardSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get boardSand;

  /// No description provided for @boardCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get boardCloud;

  /// No description provided for @boardMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get boardMint;

  /// No description provided for @boardRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get boardRose;

  /// No description provided for @boardLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get boardLavender;

  /// No description provided for @boardSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get boardSky;

  /// No description provided for @boardPearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get boardPearl;

  /// No description provided for @boardHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get boardHoney;

  /// No description provided for @trophyFirstEscapeTitle.
  ///
  /// In en, this message translates to:
  /// **'🌟 THE FIRST AWAKENING'**
  String get trophyFirstEscapeTitle;

  /// No description provided for @trophyFirstEscapeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your very first maze escaped! You have unlocked the gateway to the Trophy System. Welcome to AHB.Dev\'s ultimate puzzle journey!'**
  String get trophyFirstEscapeDesc;

  /// No description provided for @trophyPointBlankTitle.
  ///
  /// In en, this message translates to:
  /// **'Point Blank'**
  String get trophyPointBlankTitle;

  /// No description provided for @trophyPointBlankDesc.
  ///
  /// In en, this message translates to:
  /// **'Successfully clear your first puzzle layout with precision.'**
  String get trophyPointBlankDesc;

  /// No description provided for @trophyTrialOfTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial of Two'**
  String get trophyTrialOfTwoTitle;

  /// No description provided for @trophyTrialOfTwoDesc.
  ///
  /// In en, this message translates to:
  /// **'Conquer the intense two-heart restriction of the early trials.'**
  String get trophyTrialOfTwoDesc;

  /// No description provided for @trophyQuickThinkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Thinker'**
  String get trophyQuickThinkerTitle;

  /// No description provided for @trophyQuickThinkerDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete any level swiftly under a stretched 20-second threshold.'**
  String get trophyQuickThinkerDesc;

  /// No description provided for @trophyArrowSmithTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrow Smith'**
  String get trophyArrowSmithTitle;

  /// No description provided for @trophyArrowSmithDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 10 levels without giving up or restarting.'**
  String get trophyArrowSmithDesc;

  /// No description provided for @trophyCleanSlateTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean Slate'**
  String get trophyCleanSlateTitle;

  /// No description provided for @trophyCleanSlateDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish a level without a single blocked arrow tap.'**
  String get trophyCleanSlateDesc;

  /// No description provided for @trophySparkOfGeniusTitle.
  ///
  /// In en, this message translates to:
  /// **'Spark of Genius'**
  String get trophySparkOfGeniusTitle;

  /// No description provided for @trophySparkOfGeniusDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your first hint item to find a path through a sticky situation.'**
  String get trophySparkOfGeniusDesc;

  /// No description provided for @trophyUnwindTitle.
  ///
  /// In en, this message translates to:
  /// **'Unwind'**
  String get trophyUnwindTitle;

  /// No description provided for @trophyUnwindDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your first undo item to reverse a misstep.'**
  String get trophyUnwindDesc;

  /// No description provided for @trophyRockBreakerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rock Breaker'**
  String get trophyRockBreakerTitle;

  /// No description provided for @trophyRockBreakerDesc.
  ///
  /// In en, this message translates to:
  /// **'Successfully blast away your first rock obstacle using a tactical bomb arrow.'**
  String get trophyRockBreakerDesc;

  /// No description provided for @trophySurvivalistBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'The Survivalist'**
  String get trophySurvivalistBadgeTitle;

  /// No description provided for @trophySurvivalistBadgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Conquered the first 25 trials! Permanently upgrades your max hearts from 2 to 3.'**
  String get trophySurvivalistBadgeDesc;

  /// No description provided for @trophyWayfinderTitle.
  ///
  /// In en, this message translates to:
  /// **'Wayfinder'**
  String get trophyWayfinderTitle;

  /// No description provided for @trophyWayfinderDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 50 and prove your mastery of early mazes.'**
  String get trophyWayfinderDesc;

  /// No description provided for @trophyTangleTamerTitle.
  ///
  /// In en, this message translates to:
  /// **'Tangle Tamer'**
  String get trophyTangleTamerTitle;

  /// No description provided for @trophyTangleTamerDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 10 levels in a row without making a single directional error.'**
  String get trophyTangleTamerDesc;

  /// No description provided for @trophyTimeLordTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Lord'**
  String get trophyTimeLordTitle;

  /// No description provided for @trophyTimeLordDesc.
  ///
  /// In en, this message translates to:
  /// **'Survive a timed God-level trial with countdown seconds to spare.'**
  String get trophyTimeLordDesc;

  /// No description provided for @trophyCenturyMarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Century Mark'**
  String get trophyCenturyMarkTitle;

  /// No description provided for @trophyCenturyMarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 100 — one-fifth of the way to the 500 summit!'**
  String get trophyCenturyMarkDesc;

  /// No description provided for @trophyBombTechnicianTitle.
  ///
  /// In en, this message translates to:
  /// **'Bomb Technician'**
  String get trophyBombTechnicianTitle;

  /// No description provided for @trophyBombTechnicianDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 25 rock obstacles across your campaign using tactical bombs.'**
  String get trophyBombTechnicianDesc;

  /// No description provided for @trophyUntouchableTitle.
  ///
  /// In en, this message translates to:
  /// **'Untouchable'**
  String get trophyUntouchableTitle;

  /// No description provided for @trophyUntouchableDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 levels consecutively without losing a single heart.'**
  String get trophyUntouchableDesc;

  /// No description provided for @trophyStargazerTitle.
  ///
  /// In en, this message translates to:
  /// **'Stargazer'**
  String get trophyStargazerTitle;

  /// No description provided for @trophyStargazerDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn 3 stars across 30 different puzzle boards.'**
  String get trophyStargazerDesc;

  /// No description provided for @trophyMasterOfAnglesTitle.
  ///
  /// In en, this message translates to:
  /// **'Master of Angles'**
  String get trophyMasterOfAnglesTitle;

  /// No description provided for @trophyMasterOfAnglesDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a complex puzzle heavily featuring orphan redirector dots.'**
  String get trophyMasterOfAnglesDesc;

  /// No description provided for @trophyHalfwayToGloryTitle.
  ///
  /// In en, this message translates to:
  /// **'Halfway to Glory'**
  String get trophyHalfwayToGloryTitle;

  /// No description provided for @trophyHalfwayToGloryDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 125, establishing your mid-game dominance.'**
  String get trophyHalfwayToGloryDesc;

  /// No description provided for @trophyTheStrategistTitle.
  ///
  /// In en, this message translates to:
  /// **'The Strategist'**
  String get trophyTheStrategistTitle;

  /// No description provided for @trophyTheStrategistDesc.
  ///
  /// In en, this message translates to:
  /// **'Utilize all available inventory items at least once during a single session.'**
  String get trophyTheStrategistDesc;

  /// No description provided for @trophyQuickSilverTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Silver'**
  String get trophyQuickSilverTitle;

  /// No description provided for @trophyQuickSilverDesc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 5 minutes of active high-speed play in Time Attack mode.'**
  String get trophyQuickSilverDesc;

  /// No description provided for @trophyIronWillTitle.
  ///
  /// In en, this message translates to:
  /// **'Iron Will'**
  String get trophyIronWillTitle;

  /// No description provided for @trophyIronWillDesc.
  ///
  /// In en, this message translates to:
  /// **'Win a boss level after dropping down to your absolute final heart.'**
  String get trophyIronWillDesc;

  /// No description provided for @trophyGoldenTouchTitle.
  ///
  /// In en, this message translates to:
  /// **'Golden Touch'**
  String get trophyGoldenTouchTitle;

  /// No description provided for @trophyGoldenTouchDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock your very first custom board or arrow skin theme.'**
  String get trophyGoldenTouchDesc;

  /// No description provided for @trophyDeepDiverTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Diver'**
  String get trophyDeepDiverTitle;

  /// No description provided for @trophyDeepDiverDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 150 as the labyrinth grows exponentially complex.'**
  String get trophyDeepDiverDesc;

  /// No description provided for @trophyThePuzzlerTitle.
  ///
  /// In en, this message translates to:
  /// **'The Puzzler'**
  String get trophyThePuzzlerTitle;

  /// No description provided for @trophyThePuzzlerDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 randomly generated procedural puzzle boards.'**
  String get trophyThePuzzlerDesc;

  /// No description provided for @trophySharpShooterTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharp Shooter'**
  String get trophySharpShooterTitle;

  /// No description provided for @trophySharpShooterDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish 20 levels using the minimum possible moves.'**
  String get trophySharpShooterDesc;

  /// No description provided for @trophyVaultKeeperTitle.
  ///
  /// In en, this message translates to:
  /// **'Vault Keeper'**
  String get trophyVaultKeeperTitle;

  /// No description provided for @trophyVaultKeeperDesc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate a massive total of 500 coins from gameplay and ad rewards.'**
  String get trophyVaultKeeperDesc;

  /// No description provided for @trophyMilestoneMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone Master'**
  String get trophyMilestoneMasterTitle;

  /// No description provided for @trophyMilestoneMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 200 — two-fifths of the way to the 500 max level.'**
  String get trophyMilestoneMasterDesc;

  /// No description provided for @trophyBossSlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Boss Slayer'**
  String get trophyBossSlayerTitle;

  /// No description provided for @trophyBossSlayerDesc.
  ///
  /// In en, this message translates to:
  /// **'Defeat 8 boss levels consecutively without a single defeat.'**
  String get trophyBossSlayerDesc;

  /// No description provided for @trophyTimeBenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Bender'**
  String get trophyTimeBenderTitle;

  /// No description provided for @trophyTimeBenderDesc.
  ///
  /// In en, this message translates to:
  /// **'Freeze time successfully 10 times on intense countdown levels.'**
  String get trophyTimeBenderDesc;

  /// No description provided for @trophyResilientSpiritTitle.
  ///
  /// In en, this message translates to:
  /// **'Resilient Spirit'**
  String get trophyResilientSpiritTitle;

  /// No description provided for @trophyResilientSpiritDesc.
  ///
  /// In en, this message translates to:
  /// **'Recover from a game-over state using an ad continuation reward.'**
  String get trophyResilientSpiritDesc;

  /// No description provided for @trophyBoardCollectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Board Collector'**
  String get trophyBoardCollectorTitle;

  /// No description provided for @trophyBoardCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock 5 different custom board themes for your collection.'**
  String get trophyBoardCollectorDesc;

  /// No description provided for @trophyApexPredatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Apex Predator'**
  String get trophyApexPredatorTitle;

  /// No description provided for @trophyApexPredatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 250 — the halfway summit of the current puzzle campaign.'**
  String get trophyApexPredatorDesc;

  /// No description provided for @trophyFlawlessExecutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Flawless Execution'**
  String get trophyFlawlessExecutionTitle;

  /// No description provided for @trophyFlawlessExecutionDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn 3 stars across 100 separate levels.'**
  String get trophyFlawlessExecutionDesc;

  /// No description provided for @trophyTacticalMindsetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tactical Mindset'**
  String get trophyTacticalMindsetTitle;

  /// No description provided for @trophyTacticalMindsetDesc.
  ///
  /// In en, this message translates to:
  /// **'Solve a god-tier puzzle without relying on any hints.'**
  String get trophyTacticalMindsetDesc;

  /// No description provided for @trophyDailyDevoteeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Devotee'**
  String get trophyDailyDevoteeTitle;

  /// No description provided for @trophyDailyDevoteeDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day login streak on your daily rewards tracker.'**
  String get trophyDailyDevoteeDesc;

  /// No description provided for @trophyMonumentalPioneerTitle.
  ///
  /// In en, this message translates to:
  /// **'Monumental Pioneer'**
  String get trophyMonumentalPioneerTitle;

  /// No description provided for @trophyMonumentalPioneerDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock your first purely decorative, prestige monumental trophy.'**
  String get trophyMonumentalPioneerDesc;

  /// No description provided for @trophyHighClimberTitle.
  ///
  /// In en, this message translates to:
  /// **'The High Climber'**
  String get trophyHighClimberTitle;

  /// No description provided for @trophyHighClimberDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 300 — three-fifths of the way to the 500 summit.'**
  String get trophyHighClimberDesc;

  /// No description provided for @trophyGrandmasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get trophyGrandmasterTitle;

  /// No description provided for @trophyGrandmasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 350, conquering the most complex grid tangles.'**
  String get trophyGrandmasterDesc;

  /// No description provided for @trophyEternalFlameTitle.
  ///
  /// In en, this message translates to:
  /// **'Eternal Flame'**
  String get trophyEternalFlameTitle;

  /// No description provided for @trophyEternalFlameDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain an incredible 14-day continuous login streak.'**
  String get trophyEternalFlameDesc;

  /// No description provided for @trophyIroncladTitle.
  ///
  /// In en, this message translates to:
  /// **'Ironclad'**
  String get trophyIroncladTitle;

  /// No description provided for @trophyIroncladDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 400 — four-fifths of the way to the ultimate summit.'**
  String get trophyIroncladDesc;

  /// No description provided for @trophyPerfectionistTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get trophyPerfectionistTitle;

  /// No description provided for @trophyPerfectionistDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn 3 stars on every single level from 1 up to 400.'**
  String get trophyPerfectionistDesc;

  /// No description provided for @trophyTitanOfTheMazeTitle.
  ///
  /// In en, this message translates to:
  /// **'Titan of the Maze'**
  String get trophyTitanOfTheMazeTitle;

  /// No description provided for @trophyTitanOfTheMazeDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 450, standing among elite puzzle solvers.'**
  String get trophyTitanOfTheMazeDesc;

  /// No description provided for @trophyThe500ClubTitle.
  ///
  /// In en, this message translates to:
  /// **'The 500 Club'**
  String get trophyThe500ClubTitle;

  /// No description provided for @trophyThe500ClubDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 500, hitting the current maximum summit of the puzzle grid!'**
  String get trophyThe500ClubDesc;

  /// No description provided for @trophyLivingLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Living Legend'**
  String get trophyLivingLegendTitle;

  /// No description provided for @trophyLivingLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear level 500 with a 3-star rating and zero mistakes.'**
  String get trophyLivingLegendDesc;

  /// No description provided for @trophyMonumentOfTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Monument of Time'**
  String get trophyMonumentOfTimeTitle;

  /// No description provided for @trophyMonumentOfTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'A prestige monumental artifact for dedicating over 10 active hours to escaping mazes.'**
  String get trophyMonumentOfTimeDesc;

  /// No description provided for @trophyAbsoluteVoidTitle.
  ///
  /// In en, this message translates to:
  /// **'The Absolute Void'**
  String get trophyAbsoluteVoidTitle;

  /// No description provided for @trophyAbsoluteVoidDesc.
  ///
  /// In en, this message translates to:
  /// **'A pitch-black monumental prestige trophy awarded for maxing out key progression features.'**
  String get trophyAbsoluteVoidDesc;

  /// No description provided for @trophyInfiniteHorizonTitle.
  ///
  /// In en, this message translates to:
  /// **'Infinite Horizon'**
  String get trophyInfiniteHorizonTitle;

  /// No description provided for @trophyInfiniteHorizonDesc.
  ///
  /// In en, this message translates to:
  /// **'A monumental placeholder trophy acknowledging that the journey beyond level 500 never ends.'**
  String get trophyInfiniteHorizonDesc;

  /// No description provided for @timeBonusAmount.
  ///
  /// In en, this message translates to:
  /// **'+{seconds}s'**
  String timeBonusAmount(int seconds);

  /// No description provided for @heartsAlreadyFull.
  ///
  /// In en, this message translates to:
  /// **'Hearts are already full'**
  String get heartsAlreadyFull;

  /// No description provided for @timeFreezeWait.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds}s more before using Time Freeze'**
  String timeFreezeWait(int seconds);

  /// No description provided for @tapRockToDestroy.
  ///
  /// In en, this message translates to:
  /// **'Tap a rock to destroy it'**
  String get tapRockToDestroy;

  /// No description provided for @noSolvableArrowFound.
  ///
  /// In en, this message translates to:
  /// **'No solvable arrow found'**
  String get noSolvableArrowFound;

  /// No description provided for @nothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo'**
  String get nothingToUndo;

  /// No description provided for @blitzCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Blitz Complete!'**
  String get blitzCompleteTitle;

  /// No description provided for @blitzOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Blitz Over'**
  String get blitzOverTitle;

  /// No description provided for @blitzSplashStage.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get blitzSplashStage;

  /// No description provided for @blitzPoints.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String blitzPoints(int score);

  /// No description provided for @arrowSpeedEscapeSpeed.
  ///
  /// In en, this message translates to:
  /// **'Escape speed'**
  String get arrowSpeedEscapeSpeed;

  /// No description provided for @arrowSpeedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get arrowSpeedSlow;

  /// No description provided for @arrowSpeedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get arrowSpeedNormal;

  /// No description provided for @arrowSpeedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get arrowSpeedFast;

  /// No description provided for @accentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColorLabel;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTermsConditions;

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsChooseLanguage;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersionLabel(String version);

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortugueseBR.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (BR)'**
  String get languagePortugueseBR;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @trophiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Trophies ({unlocked} / {total})'**
  String trophiesTitle(int unlocked, int total);

  /// No description provided for @trophiesLevelBadge.
  ///
  /// In en, this message translates to:
  /// **'Lvl {level}'**
  String trophiesLevelBadge(int level);

  /// No description provided for @trophiesPerkHeart.
  ///
  /// In en, this message translates to:
  /// **'✨ Perk: +1 Permanent Max Heart'**
  String get trophiesPerkHeart;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardTabWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get leaderboardTabWeekly;

  /// No description provided for @leaderboardTabMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get leaderboardTabMonthly;

  /// No description provided for @leaderboardTabAllTime.
  ///
  /// In en, this message translates to:
  /// **'All-Time'**
  String get leaderboardTabAllTime;

  /// No description provided for @leaderboardYourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get leaderboardYourRank;

  /// No description provided for @leaderboardNotRanked.
  ///
  /// In en, this message translates to:
  /// **'Not ranked yet'**
  String get leaderboardNotRanked;

  /// No description provided for @leaderboardSignInToRank.
  ///
  /// In en, this message translates to:
  /// **'Sign in to appear on the leaderboard'**
  String get leaderboardSignInToRank;

  /// No description provided for @leaderboardEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No scores yet — be the first!'**
  String get leaderboardEmptyState;

  /// No description provided for @leaderboardScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get leaderboardScore;

  /// No description provided for @leaderboardLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get leaderboardLevel;

  /// No description provided for @leaderboardStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get leaderboardStars;

  /// No description provided for @leaderboardTrophies.
  ///
  /// In en, this message translates to:
  /// **'Trophies'**
  String get leaderboardTrophies;

  /// No description provided for @leaderboardYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leaderboardYou;

  /// No description provided for @leaderboardRankPrefix.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get leaderboardRankPrefix;

  /// No description provided for @leaderboardOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'Show me on leaderboard'**
  String get leaderboardOptInTitle;

  /// No description provided for @leaderboardOptInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let other players see your rank'**
  String get leaderboardOptInSubtitle;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTitle;

  /// No description provided for @inventoryTabArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrows'**
  String get inventoryTabArrows;

  /// No description provided for @inventoryTabBoards.
  ///
  /// In en, this message translates to:
  /// **'Boards'**
  String get inventoryTabBoards;

  /// No description provided for @inventoryTabItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get inventoryTabItems;

  /// No description provided for @inventoryEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get inventoryEquipped;

  /// No description provided for @inventoryTapToEquip.
  ///
  /// In en, this message translates to:
  /// **'Tap to equip'**
  String get inventoryTapToEquip;

  /// No description provided for @inventoryReachLevel.
  ///
  /// In en, this message translates to:
  /// **'Reach level {level} to unlock'**
  String inventoryReachLevel(int level);

  /// No description provided for @inventoryLevelBadge.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String inventoryLevelBadge(int level);

  /// No description provided for @inventoryNeedMoreCoins.
  ///
  /// In en, this message translates to:
  /// **'Need {count} more coins'**
  String inventoryNeedMoreCoins(int count);

  /// No description provided for @inventoryBuyItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy {item}?'**
  String inventoryBuyItemTitle(String item);

  /// No description provided for @inventoryUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock {title}?'**
  String inventoryUnlockTitle(String title);

  /// No description provided for @inventoryCoinsPrice.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String inventoryCoinsPrice(int count);

  /// No description provided for @inventoryBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get inventoryBuy;

  /// No description provided for @rushDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get rushDifficultyEasy;

  /// No description provided for @rushDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get rushDifficultyHard;

  /// No description provided for @rushDifficultyImpossible.
  ///
  /// In en, this message translates to:
  /// **'Impossible'**
  String get rushDifficultyImpossible;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePlayingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Playing as guest'**
  String get profilePlayingAsGuest;

  /// No description provided for @profileSignInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in — progress synced'**
  String get profileSignInSuccess;

  /// No description provided for @profileSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String profileSignInFailed(String error);

  /// No description provided for @profileSaveYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Save your progress'**
  String get profileSaveYourProgress;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Guest accounts live on this device only. Sign in to back up your level, coins, and trophies.'**
  String get profileGuestBody;

  /// No description provided for @profileContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get profileContinueWithEmail;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your cloud save stays. This device will reset to a fresh guest account and start from level 1.'**
  String get profileSignOutBody;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your cloud save and account. This action cannot be undone.'**
  String get profileDeleteAccountBody;

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDelete;

  /// No description provided for @profileDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String profileDeleteFailed(String error);

  /// No description provided for @profileSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-out failed: {error}'**
  String profileSignOutFailed(String error);

  /// No description provided for @profileSignedInBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress is backed up to the cloud. Sign in on any device with the same account to continue.'**
  String get profileSignedInBody;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileStatLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get profileStatLevel;

  /// No description provided for @profileStatStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get profileStatStars;

  /// No description provided for @profileStatTrophies.
  ///
  /// In en, this message translates to:
  /// **'Trophies'**
  String get profileStatTrophies;

  /// No description provided for @profileTabSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get profileTabSignIn;

  /// No description provided for @profileTabCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get profileTabCreateAccount;

  /// No description provided for @profileCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get profileCreateAccountTitle;

  /// No description provided for @profileWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get profileWelcomeBack;

  /// No description provided for @profileGuestProgressCarries.
  ///
  /// In en, this message translates to:
  /// **'Your guest progress will carry over.'**
  String get profileGuestProgressCarries;

  /// No description provided for @profileSignInRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to restore your progress from another device.'**
  String get profileSignInRestoreBody;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get profileNameHint;

  /// No description provided for @profileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailHint;

  /// No description provided for @profilePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get profilePasswordHint;

  /// No description provided for @profileShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get profileShowPassword;

  /// No description provided for @profileHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get profileHidePassword;

  /// No description provided for @profileGeneratePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate password'**
  String get profileGeneratePassword;

  /// No description provided for @profilePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get profilePasswordMinLength;

  /// No description provided for @profileStrengthTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get profileStrengthTooShort;

  /// No description provided for @profileStrengthOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get profileStrengthOkay;

  /// No description provided for @profileStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get profileStrengthGood;

  /// No description provided for @profileStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get profileStrengthStrong;

  /// No description provided for @profileErrorEmailSignUp.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered. Try Sign In instead.'**
  String get profileErrorEmailSignUp;

  /// No description provided for @profileErrorEmailSignIn.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered. Check your password or reset it from the email link.'**
  String get profileErrorEmailSignIn;

  /// No description provided for @profileErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get profileErrorInvalidCredentials;

  /// No description provided for @profileErrorPassword.
  ///
  /// In en, this message translates to:
  /// **'Password not accepted. Use 8+ characters with letters and numbers, and avoid common words like \"password\".'**
  String get profileErrorPassword;

  /// No description provided for @profileErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address looks invalid.'**
  String get profileErrorInvalidEmail;

  /// No description provided for @profileErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please close the app, reopen it, and try again.'**
  String get profileErrorSessionExpired;

  /// No description provided for @profileErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get profileErrorRateLimit;

  /// No description provided for @profileErrorServerBusy.
  ///
  /// In en, this message translates to:
  /// **'Server is busy. Please try again in a moment.'**
  String get profileErrorServerBusy;

  /// No description provided for @profileErrorSignUpGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign-up failed. Please check your details and try again.'**
  String get profileErrorSignUpGeneric;

  /// No description provided for @profileErrorSignInGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please check your email and password.'**
  String get profileErrorSignInGeneric;

  /// No description provided for @profileEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get profileEnterValidEmail;

  /// No description provided for @profileEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get profileEnterPassword;

  /// No description provided for @profileEmailAlreadyPrompt.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account. Enter your password to sign in.'**
  String get profileEmailAlreadyPrompt;

  /// No description provided for @profileSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get profileSomethingWrong;

  /// No description provided for @profileCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get profileCreateAccountButton;

  /// No description provided for @profileSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignInButton;

  /// No description provided for @profileAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get profileAlreadyHaveAccount;

  /// No description provided for @profileDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get profileDontHaveAccount;

  /// No description provided for @homePlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get homePlayer;

  /// No description provided for @homeLevelStars.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {stars} stars'**
  String homeLevelStars(int level, int stars);

  /// No description provided for @homeContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get homeContinueLabel;

  /// No description provided for @homeLevelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String homeLevelNumber(int level);

  /// No description provided for @homeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeContinue;

  /// No description provided for @homeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get homeDaily;

  /// No description provided for @homeDailyReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get homeDailyReady;

  /// No description provided for @homeDailyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed today'**
  String get homeDailyClaimed;

  /// No description provided for @homeLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get homeLeaderboard;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get homeComingSoon;

  /// No description provided for @homeInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get homeInventory;

  /// No description provided for @homeInventoryAllUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All unlocked · {count} items'**
  String homeInventoryAllUnlocked(int count);

  /// No description provided for @homeInventoryBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse your gear'**
  String get homeInventoryBrowse;

  /// No description provided for @homeInventoryCounts.
  ///
  /// In en, this message translates to:
  /// **'{owned}/{total} · {items} items'**
  String homeInventoryCounts(int owned, int total, int items);

  /// No description provided for @homeTrophies.
  ///
  /// In en, this message translates to:
  /// **'Trophies'**
  String get homeTrophies;

  /// No description provided for @homeTrophiesCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total}'**
  String homeTrophiesCount(int unlocked, int total);

  /// No description provided for @privacyWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Arrow Puzzle'**
  String get privacyWelcomeTitle;

  /// No description provided for @privacyWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Before we begin, please review and accept our terms.'**
  String get privacyWelcomeSubtitle;

  /// No description provided for @privacyBulletLocal.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved locally on your device.'**
  String get privacyBulletLocal;

  /// No description provided for @privacyBulletCloud.
  ///
  /// In en, this message translates to:
  /// **'Optional accounts sync progress to the cloud.'**
  String get privacyBulletCloud;

  /// No description provided for @privacyBulletAds.
  ///
  /// In en, this message translates to:
  /// **'The game shows ads to keep it free.'**
  String get privacyBulletAds;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @privacyTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get privacyTermsLink;

  /// No description provided for @privacyAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get privacyAcceptButton;

  /// No description provided for @privacyAgreeFooter.
  ///
  /// In en, this message translates to:
  /// **'By tapping above you agree to our Terms & Conditions.'**
  String get privacyAgreeFooter;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get bottomNavDaily;

  /// No description provided for @bottomNavInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get bottomNavInventory;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// No description provided for @gameTopBarScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String gameTopBarScore(int score);

  /// No description provided for @gameTopBarRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get gameTopBarRandom;

  /// No description provided for @gameTopBarLevelNumber.
  ///
  /// In en, this message translates to:
  /// **'Lv.{level}'**
  String gameTopBarLevelNumber(String level);

  /// No description provided for @gameModeZenMode.
  ///
  /// In en, this message translates to:
  /// **'Zen Mode'**
  String get gameModeZenMode;

  /// No description provided for @howToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get howToPlayTitle;

  /// No description provided for @howToPlayBasics.
  ///
  /// In en, this message translates to:
  /// **'THE BASICS'**
  String get howToPlayBasics;

  /// No description provided for @howToPlayBoardElements.
  ///
  /// In en, this message translates to:
  /// **'BOARD ELEMENTS'**
  String get howToPlayBoardElements;

  /// No description provided for @howToPlayGameModes.
  ///
  /// In en, this message translates to:
  /// **'GAME MODES'**
  String get howToPlayGameModes;

  /// No description provided for @howToPlayProStrategies.
  ///
  /// In en, this message translates to:
  /// **'PRO STRATEGIES'**
  String get howToPlayProStrategies;

  /// No description provided for @howToPlayCoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Core Objective'**
  String get howToPlayCoreTitle;

  /// No description provided for @howToPlayCoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Your goal is to clear the entire puzzle grid by guiding every arrow off the board. When no arrows remain on the board, the level is complete.'**
  String get howToPlayCoreDesc;

  /// No description provided for @howToPlayMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrow Movement'**
  String get howToPlayMovementTitle;

  /// No description provided for @howToPlayMovementDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap any arrow to launch it. Arrows slide forward in the exact direction their arrowhead points: Up, Down, Left, or Right. Even if an arrow has a bent or winding body, it always exits following its tip.'**
  String get howToPlayMovementDesc;

  /// No description provided for @howToPlayObstaclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Obstacles & Collisions'**
  String get howToPlayObstaclesTitle;

  /// No description provided for @howToPlayObstaclesDesc.
  ///
  /// In en, this message translates to:
  /// **'An arrow can only escape if its entire exit path is completely clear. If another arrow stands in the way, the tapped arrow will shake and stay in place.'**
  String get howToPlayObstaclesDesc;

  /// No description provided for @howToPlayLivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Lives & Health'**
  String get howToPlayLivesTitle;

  /// No description provided for @howToPlayLivesDesc.
  ///
  /// In en, this message translates to:
  /// **'In Classic mode, you start with 3 hearts. Tapping a blocked arrow costs 1 heart. If you deplete all 3 hearts, you must restart the level. You can toggle Infinite Lives in Settings anytime.'**
  String get howToPlayLivesDesc;

  /// No description provided for @howToPlayTurnDotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn Dots (Redirectors)'**
  String get howToPlayTurnDotsTitle;

  /// No description provided for @howToPlayTurnDotsDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for circular dots on empty grid cells marked with small arrows. When a sliding arrow crosses a Turn Dot, it instantly pivots in the dot\'s direction and consumes it, opening unexpected exit routes.'**
  String get howToPlayTurnDotsDesc;

  /// No description provided for @howToPlayCombosTitle.
  ///
  /// In en, this message translates to:
  /// **'Combos & Streaks'**
  String get howToPlayCombosTitle;

  /// No description provided for @howToPlayCombosDesc.
  ///
  /// In en, this message translates to:
  /// **'Release arrows in quick succession (within 1.5 seconds) to trigger combos. Chaining consecutive escapes builds momentum and scores combo multipliers.'**
  String get howToPlayCombosDesc;

  /// No description provided for @howToPlayClassicTitle.
  ///
  /// In en, this message translates to:
  /// **'Classic Mode'**
  String get howToPlayClassicTitle;

  /// No description provided for @howToPlayClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The standard campaign progression. Advance through handcrafted and procedural stages of escalating size, shape masks, and path complexity with 3 hearts.'**
  String get howToPlayClassicDesc;

  /// No description provided for @howToPlayZenTitle.
  ///
  /// In en, this message translates to:
  /// **'Zen Mode'**
  String get howToPlayZenTitle;

  /// No description provided for @howToPlayZenDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure relaxation with zero stress. No hearts to lose, no time limits, and no failure states. Ideal for unwinding and practicing complex boards.'**
  String get howToPlayZenDesc;

  /// No description provided for @howToPlayTimeAttackTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Attack'**
  String get howToPlayTimeAttackTitle;

  /// No description provided for @howToPlayTimeAttackDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast-paced race against the clock! Every arrow you successfully escape awards precious bonus seconds back onto your countdown timer.'**
  String get howToPlayTimeAttackDesc;

  /// No description provided for @howToPlayMultiplayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Rooms'**
  String get howToPlayMultiplayerTitle;

  /// No description provided for @howToPlayMultiplayerDesc.
  ///
  /// In en, this message translates to:
  /// **'Host or join with room seed codes. Both players compete on the exact same randomized layout to see who can solve and escape the board fastest.'**
  String get howToPlayMultiplayerDesc;

  /// No description provided for @howToPlayRandomTitle.
  ///
  /// In en, this message translates to:
  /// **'Random Puzzles'**
  String get howToPlayRandomTitle;

  /// No description provided for @howToPlayRandomDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate infinite on-demand puzzles across Easy, Medium, Hard, Master, and Expert difficulties without affecting your campaign level progress.'**
  String get howToPlayRandomDesc;

  /// No description provided for @howToPlayUnpeelTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpeel From the Perimeter'**
  String get howToPlayUnpeelTitle;

  /// No description provided for @howToPlayUnpeelDesc.
  ///
  /// In en, this message translates to:
  /// **'Start by scanning the outer borders. Arrows pointing straight outward into empty space can always escape immediately, freeing up critical lanes.'**
  String get howToPlayUnpeelDesc;

  /// No description provided for @howToPlayTraceTitle.
  ///
  /// In en, this message translates to:
  /// **'Trace Blockers in Reverse'**
  String get howToPlayTraceTitle;

  /// No description provided for @howToPlayTraceDesc.
  ///
  /// In en, this message translates to:
  /// **'When an arrow is blocked, find which arrow blocks it, then find what blocks that second arrow. Unlocking the final blocker in the chain frees everything behind it.'**
  String get howToPlayTraceDesc;

  /// No description provided for @howToPlayTapAssistTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Tap Assist'**
  String get howToPlayTapAssistTitle;

  /// No description provided for @howToPlayTapAssistDesc.
  ///
  /// In en, this message translates to:
  /// **'If you play on smaller screens or tend to tap between tight arrow segments, turn on Tap Assist in Settings to automatically map nearby taps to the nearest arrow.'**
  String get howToPlayTapAssistDesc;

  /// No description provided for @multiplayerTitle.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLAYER'**
  String get multiplayerTitle;

  /// No description provided for @multiplayerRoomCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Room code {code} copied to clipboard!'**
  String multiplayerRoomCodeCopied(String code);

  /// No description provided for @multiplayerHostRoom.
  ///
  /// In en, this message translates to:
  /// **'HOST ROOM'**
  String get multiplayerHostRoom;

  /// No description provided for @multiplayerHostBody.
  ///
  /// In en, this message translates to:
  /// **'Share this room code with a friend to compete on the exact same puzzle layout!'**
  String get multiplayerHostBody;

  /// No description provided for @multiplayerNewCode.
  ///
  /// In en, this message translates to:
  /// **'New Code'**
  String get multiplayerNewCode;

  /// No description provided for @multiplayerCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get multiplayerCopyCode;

  /// No description provided for @multiplayerStartMatch.
  ///
  /// In en, this message translates to:
  /// **'START MATCH'**
  String get multiplayerStartMatch;

  /// No description provided for @multiplayerJoinRoom.
  ///
  /// In en, this message translates to:
  /// **'JOIN ROOM'**
  String get multiplayerJoinRoom;

  /// No description provided for @multiplayerJoinBody.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste a room code to join the match.'**
  String get multiplayerJoinBody;

  /// No description provided for @multiplayerRoomCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ROOM-849201'**
  String get multiplayerRoomCodeHint;

  /// No description provided for @multiplayerRoomCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a room code'**
  String get multiplayerRoomCodeRequired;

  /// No description provided for @multiplayerJoinMatch.
  ///
  /// In en, this message translates to:
  /// **'JOIN MATCH'**
  String get multiplayerJoinMatch;

  /// No description provided for @zenCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No timer. No limits. Just solve.'**
  String get zenCardSubtitle;

  /// No description provided for @profileSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get profileSyncing;

  /// No description provided for @profileSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get profileSyncFailed;

  /// No description provided for @gameModeTimeBlitz.
  ///
  /// In en, this message translates to:
  /// **'Time Blitz'**
  String get gameModeTimeBlitz;

  /// No description provided for @timeBlitzDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap arrows to earn time. Blocked taps cost time. Survive as long as you can.'**
  String get timeBlitzDesc;

  /// No description provided for @timeBlitzOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Blitz Over'**
  String get timeBlitzOverTitle;

  /// No description provided for @timeBlitzScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'ARROWS CLEARED'**
  String get timeBlitzScoreLabel;

  /// No description provided for @timeBlitzLevelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Levels reached'**
  String get timeBlitzLevelsLabel;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get profileEditName;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out Arrow Puzzle — a fun maze escape game!'**
  String get shareMessage;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @settingsShareFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with friends'**
  String get settingsShareFriends;

  /// No description provided for @settingsSharingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sharing coming soon'**
  String get settingsSharingSoon;
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(lookupAppStrings(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

AppStrings lookupAppStrings(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppStringsAr();
    case 'en':
      return AppStringsEn();
    case 'es':
      return AppStringsEs();
    case 'fr':
      return AppStringsFr();
    case 'hi':
      return AppStringsHi();
    case 'id':
      return AppStringsId();
    case 'pt':
      return AppStringsPt();
  }

  throw FlutterError(
    'AppStrings.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
