// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppStringsHi extends AppStrings {
  AppStringsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Arrow Puzzle';

  @override
  String get menuHome => 'होम';

  @override
  String get menuDaily => 'दैनिक';

  @override
  String get menuInventory => 'इन्वेंटरी';

  @override
  String get menuSettings => 'सेटिंग्स';

  @override
  String get menuProfile => 'प्रोफ़ाइल';

  @override
  String get menuTrophies => 'ट्रॉफ़ियाँ';

  @override
  String get menuLeaderboard => 'लीडरबोर्ड';

  @override
  String get menuContinue => 'जारी रखें';

  @override
  String menuLevel(int level) {
    return 'स्तर $level';
  }

  @override
  String get buttonPlay => 'खेलें';

  @override
  String get buttonCancel => 'रद्द करें';

  @override
  String get buttonConfirm => 'पुष्टि करें';

  @override
  String get buttonBuy => 'खरीदें';

  @override
  String get buttonRestart => 'पुनः आरंभ करें';

  @override
  String get buttonResume => 'फिर से शुरू करें';

  @override
  String get buttonExit => 'बाहर निकलें';

  @override
  String get buttonClose => 'बंद करें';

  @override
  String get buttonNext => 'अगला स्तर';

  @override
  String get buttonSignIn => 'साइन इन';

  @override
  String get buttonSignUp => 'खाता बनाएं';

  @override
  String get buttonSignOut => 'साइन आउट';

  @override
  String get buttonDeleteAccount => 'खाता हटाएं';

  @override
  String get buttonClaim => 'मुफ्त में प्राप्त करें';

  @override
  String get buttonWatchAd => 'विज्ञापन देखें';

  @override
  String get buttonAccept => 'स्वीकार करें और जारी रखें';

  @override
  String get buttonShare => 'दोस्तों के साथ साझा करें';

  @override
  String get buttonStartBlitz => 'ब्लिट्ज़ शुरू करें';

  @override
  String buttonStartRush(String tier) {
    return '$tier शुरू करें';
  }

  @override
  String get gameModeClassic => 'क्लासिक';

  @override
  String get gameModeZen => 'ज़ेन मोड';

  @override
  String get gameModeTimeAttack => 'समय हमला';

  @override
  String get gameModeArrowRush => 'एरो रश';

  @override
  String get gameModeBlitz => 'ब्लिट्ज़';

  @override
  String get gameModeMineArrows => 'माइन एरो';

  @override
  String get difficultyEasy => 'आसान';

  @override
  String get difficultyHard => 'कठिन';

  @override
  String get difficultyImpossible => 'असंभव';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsDarkMode => 'डार्क मोड';

  @override
  String get settingsAccentColor => 'एक्सेंट रंग';

  @override
  String get settingsAudioHaptics => 'ऑडियो और कंपन';

  @override
  String get settingsSoundEffects => 'ध्वनि प्रभाव';

  @override
  String get settingsMusic => 'संगीत';

  @override
  String get settingsVibration => 'कंपन';

  @override
  String get settingsArrowSpeed => 'एरो गति';

  @override
  String get settingsAbout => 'परिचय';

  @override
  String get settingsPrivacy => 'गोपनीयता नीति';

  @override
  String get settingsTerms => 'नियम और शर्तें';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String settingsVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get settingsSharingComingSoon => 'साझा करना जल्द आ रहा है';

  @override
  String get consentTitle => 'Arrow Puzzle में आपका स्वागत है';

  @override
  String get consentSubtitle =>
      'शुरू करने से पहले, कृपया हमारी शर्तें देखें और स्वीकार करें।';

  @override
  String get consentLocalProgress =>
      'आपकी प्रगति आपके डिवाइस पर स्थानीय रूप से सहेजी जाती है।';

  @override
  String get consentCloudSync =>
      'वैकल्पिक खाते प्रगति को क्लाउड पर सिंक करते हैं।';

  @override
  String get consentAds => 'गेम मुफ़्त रखने के लिए विज्ञापन दिखाता है।';

  @override
  String get consentAgreement =>
      'ऊपर टैप करके आप हमारी नियम और शर्तें स्वीकार करते हैं।';

  @override
  String get dialogExitTitle => 'गेम से बाहर निकलें?';

  @override
  String get dialogExitMessage => 'क्या आप वाकई छोड़ना चाहते हैं?';

  @override
  String get dialogSignOutTitle => 'साइन आउट करें?';

  @override
  String get dialogSignOutMessage =>
      'आपका क्लाउड सेव बना रहता है। यह डिवाइस स्तर 1 से नए अतिथि खाते पर रीसेट होगा।';

  @override
  String get dialogDeleteTitle => 'खाता हटाएं?';

  @override
  String get dialogDeleteMessage =>
      'यह आपका क्लाउड सेव और खाता स्थायी रूप से हटा देगा। इसे वापस नहीं लाया जा सकता।';

  @override
  String get profileGuest => 'अतिथि के रूप में खेल रहे हैं';

  @override
  String get profileSaveToCloud => 'क्लाउड में सहेजें';

  @override
  String get profileSynced => 'सिंक हो गया';

  @override
  String get profileSignedIn => 'साइन इन है';

  @override
  String get profileStatsLevel => 'स्तर';

  @override
  String get profileStatsStars => 'सितारे';

  @override
  String get profileStatsTrophies => 'ट्रॉफ़ियाँ';

  @override
  String get dailyRewardsTitle => 'दैनिक इनाम';

  @override
  String dailyRewardsDay(int day, int max) {
    return '$max में से दिन $day';
  }

  @override
  String get dailyRewardsComeBack => 'कल फिर आएं';

  @override
  String get dailyRewardsClaimed => 'आज प्राप्त किया!';

  @override
  String get levelComplete => 'स्तर पूर्ण!';

  @override
  String get levelFailed => 'जीवन समाप्त!';

  @override
  String get levelTimeUp => 'समय समाप्त!';

  @override
  String get gameOverRestart => 'स्तर पुनः आरंभ करें';

  @override
  String get gameOverHome => 'होम';

  @override
  String get blitzTitle => 'ब्लिट्ज़';

  @override
  String get blitzStage => 'चरण';

  @override
  String get blitzComplete => 'ब्लिट्ज़ पूर्ण!';

  @override
  String get blitzOver => 'ब्लिट्ज़ समाप्त';

  @override
  String get blitzFinalScore => 'अंतिम स्कोर';

  @override
  String blitzSurvivedAll(int count) {
    return 'आपने सभी $count चरण पूरे किए।';
  }

  @override
  String blitzClearedOf(int cleared, int total) {
    return '$total में से $cleared चरण पूरे किए।';
  }

  @override
  String get commonComingSoon => 'जल्द आ रहा है';

  @override
  String get commonLoading => 'लोड हो रहा है...';

  @override
  String get commonError => 'कुछ गलत हो गया। कृपया पुन: प्रयास करें।';

  @override
  String get commonRetry => 'पुन: प्रयास करें';

  @override
  String get dailyRewardsClaimFree => 'मुफ्त में प्राप्त करें';

  @override
  String get dailyRewardsWatchAd => 'विज्ञापन देखें';

  @override
  String get dailyRewardsSnackClaimed => 'प्राप्त किया!';

  @override
  String get dailyRewardsClaimedToday => 'आज प्राप्त किया!';

  @override
  String dailyRewardsNextIn(String time) {
    return 'अगला इनाम $time में';
  }

  @override
  String get unlockTitle => 'बधाई हो!';

  @override
  String get unlockSubtitle => 'नया बोर्ड अनलॉक';

  @override
  String get unlockAddedToInventory => 'आपकी इन्वेंटरी में जोड़ा गया';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count सिक्के';
  }

  @override
  String get buttonCheckInventory => 'इन्वेंटरी देखें';

  @override
  String get buttonMainMenu => 'मुख्य मेनू';

  @override
  String get dailyChallengesTitle => 'दैनिक चुनौतियाँ';

  @override
  String get dailyChallengesSubtitle =>
      'बोनस इनाम पाने के लिए विशेष मोड पूरे करें।';

  @override
  String get dailyRewardsSubtitle => 'अपना स्ट्रीक इनाम प्राप्त करें';

  @override
  String get activeChallengesTitle => 'सक्रिय चुनौतियाँ';

  @override
  String get blitzSubtitle =>
      'कई स्तरों की श्रृंखला पूरी करें। समय कम होता जाता है। दिल बने रहते हैं।';

  @override
  String get badgeNew => 'नया';

  @override
  String get mineArrowsTitle => 'माइन एरोज़';

  @override
  String get mineArrowsSubtitle =>
      'छिपे हुए ग्रिड माइन से बचते हुए तीर साफ़ करें!';

  @override
  String get badgeComingSoon => 'जल्द आ रहा है';

  @override
  String get mineArrowsComingSoonSnack => 'माइन एरोज़ चुनौती जल्द आ रही है!';

  @override
  String get dailyRewardsLabel => 'दैनिक इनाम';

  @override
  String dayOfMax(int day, int max) {
    return 'दिन $day / $max';
  }

  @override
  String get comeBackTomorrow => 'कल फिर आएं';

  @override
  String plusCoins(int count) {
    return '+$count सिक्के';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'मुफ़्त में प्राप्त करें';

  @override
  String get loadingLabel => 'लोड हो रहा है...';

  @override
  String watchAdCoins(int coins) {
    return 'विज्ञापन देखें → +$coins सिक्के';
  }

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get claimedToday => 'आज प्राप्त हो गया!';

  @override
  String nextRewardIn(String time) {
    return 'अगला इनाम $time में';
  }

  @override
  String get closeLabel => 'बंद करें';

  @override
  String get claimedSnack => 'प्राप्त हो गया!';

  @override
  String get arrowRushTitle => 'एरो रश';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return '$tier अनलॉक करने के लिए स्तर $level तक पहुंचें';
  }

  @override
  String startTier(String tier) {
    return '$tier शुरू करें';
  }

  @override
  String lvLabel(int level) {
    return 'स्तर $level';
  }

  @override
  String get adNotAvailable => 'विज्ञापन उपलब्ध नहीं, बाद में प्रयास करें';

  @override
  String get adBadge => 'AD';

  @override
  String get homeButton => 'होम';

  @override
  String get gameOverTimeUp => 'समय समाप्त!';

  @override
  String get gameOverOutOfTime => 'समय खत्म!';

  @override
  String get gameOverOutOfLives => 'जीवन खत्म!';

  @override
  String gameOverRewardTime(int seconds) {
    return '+$secondsसे';
  }

  @override
  String gameOverRewardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count जीवन',
      one: '+$count जीवन',
    );
    return '$_temp0';
  }

  @override
  String gameOverTimeAttackStats(int cleared, int level) {
    return 'पूरे किए पहेली: $cleared\nअंतिम स्तर: $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'विज्ञापन देखें → $reward';
  }

  @override
  String get gameOverStartNewRun => 'नई शुरुआत';

  @override
  String get gameOverRestartLevel => 'स्तर पुनः आरंभ';

  @override
  String get levelCompleteTitle => 'स्तर पूरा!';

  @override
  String get levelCompleteNewTrophy => 'नई ट्रॉफ़ी';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count यादृच्छिक आइटम',
      one: '+$count यादृच्छिक आइटम',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => 'आपने खेल पूरा किया!';

  @override
  String get levelCompleteNextLevel => 'अगला स्तर';

  @override
  String get levelCompleteCoinsDoubled => 'सिक्के दोगुने!';

  @override
  String get levelCompleteDoubleCoins => 'सिक्के दोगुने करें';

  @override
  String get pauseTitle => 'रुका हुआ';

  @override
  String get pauseResume => 'जारी रखें';

  @override
  String get pauseRestart => 'पुनः आरंभ';

  @override
  String get pauseMainMenu => 'मुख्य मेनू';

  @override
  String get itemBombName => 'बम';

  @override
  String get itemBombDesc => 'एक चट्टान नष्ट करें';

  @override
  String get itemHintName => 'संकेत';

  @override
  String get itemHintDesc => 'अगला हल किए जा सकने वाला तीर दिखाएं';

  @override
  String get itemUndoName => 'पूर्ववत करें';

  @override
  String get itemUndoDesc => 'आखिरी बचा हुआ तीर वापस लाएं';

  @override
  String get itemHeartFlaskName => 'हृदय शीशी';

  @override
  String get itemHeartFlaskDesc => 'एक जीवन बहाल करें';

  @override
  String get itemTimeFreezeName => 'समय स्थिर करें';

  @override
  String get itemTimeFreezeDesc => 'टाइमर में 30 सेकंड जोड़ें';

  @override
  String get themeNeon => 'नियॉन';

  @override
  String get themeClassic => 'क्लासिक';

  @override
  String get themeRetro => 'रेट्रो';

  @override
  String get themeCyber => 'साइबर';

  @override
  String get themeHacker => 'हैकर';

  @override
  String get themeAurora => 'अरोरा';

  @override
  String get themeBlueprint => 'ब्लूप्रिंट';

  @override
  String get themeForest => 'वन';

  @override
  String get themePastel => 'पेस्टल';

  @override
  String get themeSunset => 'सूर्यास्त';

  @override
  String get themeRainbow => 'इंद्रधनुष';

  @override
  String get boardMinimal => 'न्यूनतम';

  @override
  String get boardNebula => 'नीहारिका';

  @override
  String get boardBlueprint => 'ब्लूप्रिंट';

  @override
  String get boardForest => 'वन';

  @override
  String get boardOcean => 'महासागर';

  @override
  String get boardEmber => 'अंगारा';

  @override
  String get boardCosmic => 'ब्रह्मांडीय';

  @override
  String get boardGeometric => 'ज्यामितीय';

  @override
  String get boardGold => 'स्वर्ण';

  @override
  String get boardHacker => 'हैकर';

  @override
  String get boardPaper => 'कागज़';

  @override
  String get boardIce => 'बर्फ़';

  @override
  String get boardSand => 'रेत';

  @override
  String get boardCloud => 'बादल';

  @override
  String get boardMint => 'पुदीना';

  @override
  String get boardRose => 'गुलाब';

  @override
  String get boardLavender => 'लैवेंडर';

  @override
  String get boardSky => 'आकाश';

  @override
  String get boardPearl => 'मोती';

  @override
  String get boardHoney => 'शहद';

  @override
  String get trophyFirstEscapeTitle => '🌟 पहला जागरण';

  @override
  String get trophyFirstEscapeDesc =>
      'आपका पहला भूलभुलैया पार हुआ! आपने ट्रॉफ़ी प्रणाली का द्वार खोल दिया है। AHB.Dev की अंतिम पहेली यात्रा में आपका स्वागत है!';

  @override
  String get trophyPointBlankTitle => 'नज़दीकी निशाना';

  @override
  String get trophyPointBlankDesc =>
      'अपनी पहली पहेली सटीकता के साथ सफलतापूर्वक पूरी करें।';

  @override
  String get trophyTrialOfTwoTitle => 'दो की परीक्षा';

  @override
  String get trophyTrialOfTwoDesc =>
      'प्रारंभिक परीक्षाओं की कठोर दो-जीवन सीमा पर विजय प्राप्त करें।';

  @override
  String get trophyQuickThinkerTitle => 'तेज़ विचारक';

  @override
  String get trophyQuickThinkerDesc =>
      '20-सेकंड की विस्तारित सीमा के भीतर कोई भी स्तर शीघ्रता से पूरा करें।';

  @override
  String get trophyArrowSmithTitle => 'तीर शिल्पी';

  @override
  String get trophyArrowSmithDesc =>
      'हार माने या पुनः आरंभ किए बिना 10 स्तर पूरे करें।';

  @override
  String get trophyCleanSlateTitle => 'साफ़ शुरुआत';

  @override
  String get trophyCleanSlateDesc =>
      'एक भी अवरुद्ध तीर टैप के बिना स्तर पूरा करें।';

  @override
  String get trophySparkOfGeniusTitle => 'प्रतिभा की चिंगारी';

  @override
  String get trophySparkOfGeniusDesc =>
      'कठिन परिस्थिति से निकलने के लिए अपना पहला संकेत आइटम उपयोग करें।';

  @override
  String get trophyUnwindTitle => 'आराम';

  @override
  String get trophyUnwindDesc =>
      'एक गलत कदम वापस लेने के लिए अपना पहला पूर्ववत आइटम उपयोग करें।';

  @override
  String get trophyRockBreakerTitle => 'चट्टान तोड़ने वाला';

  @override
  String get trophyRockBreakerDesc =>
      'सामरिक बम तीर से अपनी पहली चट्टान बाधा को उड़ा दें।';

  @override
  String get trophySurvivalistBadgeTitle => 'उत्तरजीवी';

  @override
  String get trophySurvivalistBadgeDesc =>
      'पहली 25 परीक्षाएं जीतीं! अपनी अधिकतम जीवन संख्या स्थायी रूप से 2 से 3 कर दी।';

  @override
  String get trophyWayfinderTitle => 'मार्गदर्शक';

  @override
  String get trophyWayfinderDesc =>
      'स्तर 50 पर पहुंचें और प्रारंभिक भूलभुलैया में अपनी महारत साबित करें।';

  @override
  String get trophyTangleTamerTitle => 'उलझन वश में';

  @override
  String get trophyTangleTamerDesc =>
      'एक भी दिशात्मक त्रुटि के बिना लगातार 10 स्तर पूरे करें।';

  @override
  String get trophyTimeLordTitle => 'समय के स्वामी';

  @override
  String get trophyTimeLordDesc =>
      'बचे हुए सेकंडों के साथ एक समयबद्ध देव-स्तरीय परीक्षा में टिके रहें।';

  @override
  String get trophyCenturyMarkTitle => 'शतक चिह्न';

  @override
  String get trophyCenturyMarkDesc =>
      'स्तर 100 पर पहुंचें — 500 शिखर की ओर एक-पांचवां हिस्सा!';

  @override
  String get trophyBombTechnicianTitle => 'बम तकनीशियन';

  @override
  String get trophyBombTechnicianDesc =>
      'सामरिक बमों का उपयोग करके अपने अभियान में 25 चट्टानें साफ़ करें।';

  @override
  String get trophyUntouchableTitle => 'अछूत';

  @override
  String get trophyUntouchableDesc =>
      'एक भी जीवन खोए बिना लगातार 5 स्तर पूरे करें।';

  @override
  String get trophyStargazerTitle => 'तारा दर्शक';

  @override
  String get trophyStargazerDesc =>
      '30 विभिन्न पहेली बोर्डों पर 3 सितारे अर्जित करें।';

  @override
  String get trophyMasterOfAnglesTitle => 'कोणों के गुरु';

  @override
  String get trophyMasterOfAnglesDesc =>
      'अनाथ पुनर्निर्देशक बिंदुओं से भरी एक जटिल पहेली पूरी करें।';

  @override
  String get trophyHalfwayToGloryTitle => 'गौरव की ओर आधा';

  @override
  String get trophyHalfwayToGloryDesc =>
      'स्तर 125 पर पहुंचें, मध्य-खेल प्रभुत्व स्थापित करें।';

  @override
  String get trophyTheStrategistTitle => 'रणनीतिकार';

  @override
  String get trophyTheStrategistDesc =>
      'एक ही सत्र में सभी उपलब्ध इन्वेंटरी आइटम कम से कम एक बार उपयोग करें।';

  @override
  String get trophyQuickSilverTitle => 'पारा';

  @override
  String get trophyQuickSilverDesc =>
      'टाइम अटैक मोड में 5 मिनट की सक्रिय उच्च-गति खेल जमा करें।';

  @override
  String get trophyIronWillTitle => 'लोहे की इच्छा';

  @override
  String get trophyIronWillDesc =>
      'अपनी आखिरी जीवन तक पहुंचने के बाद बॉस स्तर जीतें।';

  @override
  String get trophyGoldenTouchTitle => 'स्वर्णिम स्पर्श';

  @override
  String get trophyGoldenTouchDesc =>
      'अपना पहला कस्टम बोर्ड या तीर स्किन थीम अनलॉक करें।';

  @override
  String get trophyDeepDiverTitle => 'गहरा गोताखोर';

  @override
  String get trophyDeepDiverDesc =>
      'स्तर 150 पर पहुंचें जब भूलभुलैया तेज़ी से जटिल होती जाए।';

  @override
  String get trophyThePuzzlerTitle => 'पहेली विशेषज्ञ';

  @override
  String get trophyThePuzzlerDesc =>
      '50 यादृच्छिक रूप से उत्पन्न प्रक्रियात्मक पहेली बोर्ड पूरे करें।';

  @override
  String get trophySharpShooterTitle => 'तीरंदाज़';

  @override
  String get trophySharpShooterDesc =>
      'न्यूनतम संभव चालों में 20 स्तर पूरे करें।';

  @override
  String get trophyVaultKeeperTitle => 'तिजोरी रक्षक';

  @override
  String get trophyVaultKeeperDesc =>
      'गेमप्ले और विज्ञापन पुरस्कारों से कुल 500 सिक्के जमा करें।';

  @override
  String get trophyMilestoneMasterTitle => 'पड़ाव मास्टर';

  @override
  String get trophyMilestoneMasterDesc =>
      'स्तर 200 पर पहुंचें — 500 अधिकतम की ओर दो-पांचवां हिस्सा।';

  @override
  String get trophyBossSlayerTitle => 'बॉस संहारक';

  @override
  String get trophyBossSlayerDesc =>
      'एक भी हार के बिना लगातार 8 बॉस स्तर हराएं।';

  @override
  String get trophyTimeBenderTitle => 'समय मोड़ने वाला';

  @override
  String get trophyTimeBenderDesc =>
      'गहन काउंटडाउन स्तरों पर 10 बार सफलतापूर्वक समय स्थिर करें।';

  @override
  String get trophyResilientSpiritTitle => 'लचीली आत्मा';

  @override
  String get trophyResilientSpiritDesc =>
      'विज्ञापन निरंतरता पुरस्कार का उपयोग करके गेम-ओवर से उबरें।';

  @override
  String get trophyBoardCollectorTitle => 'बोर्ड संग्राहक';

  @override
  String get trophyBoardCollectorDesc =>
      'अपने संग्रह के लिए 5 अलग कस्टम बोर्ड थीम अनलॉक करें।';

  @override
  String get trophyApexPredatorTitle => 'शीर्ष शिकारी';

  @override
  String get trophyApexPredatorDesc =>
      'स्तर 250 पर पहुंचें — वर्तमान पहेली अभियान का आधा शिखर।';

  @override
  String get trophyFlawlessExecutionTitle => 'निर्दोष निष्पादन';

  @override
  String get trophyFlawlessExecutionDesc =>
      '100 अलग स्तरों पर 3 सितारे अर्जित करें।';

  @override
  String get trophyTacticalMindsetTitle => 'सामरिक मानसिकता';

  @override
  String get trophyTacticalMindsetDesc =>
      'किसी भी संकेत पर निर्भर किए बिना देव-स्तरीय पहेली हल करें।';

  @override
  String get trophyDailyDevoteeTitle => 'दैनिक भक्त';

  @override
  String get trophyDailyDevoteeDesc =>
      'अपने दैनिक पुरस्कार ट्रैकर पर 7 दिन की लॉगिन श्रृंखला बनाए रखें।';

  @override
  String get trophyMonumentalPioneerTitle => 'स्मारक अग्रणी';

  @override
  String get trophyMonumentalPioneerDesc =>
      'अपनी पहली विशुद्ध सजावटी, प्रतिष्ठा स्मारक ट्रॉफ़ी अनलॉक करें।';

  @override
  String get trophyHighClimberTitle => 'ऊंचाई पर चढ़ने वाला';

  @override
  String get trophyHighClimberDesc =>
      'स्तर 300 पर पहुंचें — 500 शिखर की ओर तीन-पांचवां हिस्सा।';

  @override
  String get trophyGrandmasterTitle => 'ग्रैंडमास्टर';

  @override
  String get trophyGrandmasterDesc =>
      'स्तर 350 पर पहुंचें, सबसे जटिल ग्रिड उलझनों को जीतें।';

  @override
  String get trophyEternalFlameTitle => 'अनंत ज्वाला';

  @override
  String get trophyEternalFlameDesc =>
      'एक अविश्वसनीय 14-दिन की लगातार लॉगिन श्रृंखला बनाए रखें।';

  @override
  String get trophyIroncladTitle => 'लौह-कवच';

  @override
  String get trophyIroncladDesc =>
      'स्तर 400 पर पहुंचें — अंतिम शिखर की ओर चार-पांचवां हिस्सा।';

  @override
  String get trophyPerfectionistTitle => 'पूर्णतावादी';

  @override
  String get trophyPerfectionistDesc =>
      'स्तर 1 से 400 तक प्रत्येक स्तर पर 3 सितारे अर्जित करें।';

  @override
  String get trophyTitanOfTheMazeTitle => 'भूलभुलैया का टाइटन';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'स्तर 450 पर पहुंचें, कुलीन पहेली हल करने वालों के बीच खड़े हों।';

  @override
  String get trophyThe500ClubTitle => '500 क्लब';

  @override
  String get trophyThe500ClubDesc =>
      'स्तर 500 पर पहुंचें, पहेली ग्रिड के वर्तमान अधिकतम शिखर पर!';

  @override
  String get trophyLivingLegendTitle => 'जीवित किंवदंती';

  @override
  String get trophyLivingLegendDesc =>
      'स्तर 500 को 3-स्टार रेटिंग और शून्य गलतियों के साथ पूरा करें।';

  @override
  String get trophyMonumentOfTimeTitle => 'समय का स्मारक';

  @override
  String get trophyMonumentOfTimeDesc =>
      'भूलभुलैया से बचने में 10 सक्रिय घंटे से अधिक समर्पित करने के लिए एक प्रतिष्ठा स्मारक कलाकृति।';

  @override
  String get trophyAbsoluteVoidTitle => 'पूर्ण शून्य';

  @override
  String get trophyAbsoluteVoidDesc =>
      'प्रमुख प्रगति विशेषताओं को अधिकतम करने के लिए दी गई एक रंग-काली स्मारक प्रतिष्ठा ट्रॉफ़ी।';

  @override
  String get trophyInfiniteHorizonTitle => 'अनंत क्षितिज';

  @override
  String get trophyInfiniteHorizonDesc =>
      'एक स्मारक प्लेसहोल्डर ट्रॉफ़ी जो स्वीकार करती है कि स्तर 500 के बाद की यात्रा कभी समाप्त नहीं होती।';

  @override
  String timeBonusAmount(int seconds) {
    return '+$secondsसे';
  }

  @override
  String get heartsAlreadyFull => 'जीवन पहले से भरे हैं';

  @override
  String timeFreezeWait(int seconds) {
    return 'समय स्थिर करने से पहले $secondsसे और प्रतीक्षा करें';
  }

  @override
  String get tapRockToDestroy => 'नष्ट करने के लिए चट्टान पर टैप करें';

  @override
  String get noSolvableArrowFound => 'कोई हल किए जा सकने वाला तीर नहीं मिला';

  @override
  String get nothingToUndo => 'पूर्ववत करने के लिए कुछ नहीं';

  @override
  String get blitzCompleteTitle => 'ब्लिट्ज़ पूरा!';

  @override
  String get blitzOverTitle => 'ब्लिट्ज़ समाप्त';

  @override
  String get blitzSplashStage => 'चरण';

  @override
  String blitzPoints(int score) {
    return '$score अंक';
  }

  @override
  String get arrowSpeedEscapeSpeed => 'बचने की गति';

  @override
  String get arrowSpeedSlow => 'धीमी';

  @override
  String get arrowSpeedNormal => 'सामान्य';

  @override
  String get arrowSpeedFast => 'तेज़';

  @override
  String get accentColorLabel => 'एक्सेंट रंग';

  @override
  String get settingsShareFriends => 'दोस्तों के साथ साझा करें';

  @override
  String get settingsSharingSoon => 'साझाकरण जल्द आ रहा है';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingsTermsConditions => 'नियम और शर्तें';

  @override
  String get settingsChooseLanguage => 'भाषा चुनें';

  @override
  String settingsVersionLabel(String version) {
    return 'संस्करण $version';
  }

  @override
  String get languageSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageSpanish => 'स्पेनिश';

  @override
  String get languagePortugueseBR => 'पुर्तगाली (BR)';

  @override
  String get languageIndonesian => 'इंडोनेशियाई';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageArabic => 'अरबी';

  @override
  String get languageFrench => 'फ़्रेंच';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'ट्रॉफ़ी ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'स्तर $level';
  }

  @override
  String get trophiesPerkHeart => '✨ लाभ: +1 स्थायी अधिकतम जीवन';

  @override
  String get leaderboardTitle => 'लीडरबोर्ड';

  @override
  String get leaderboardComingSoon => 'जल्द आ रहा है';

  @override
  String get leaderboardDescription =>
      'दुनिया भर के खिलाड़ियों से मुकाबला करें। ऑनलाइन लीडरबोर्ड शुरू होते ही आपके स्कोर और रैंकिंग यहाँ दिखेंगे।';

  @override
  String get inventoryTitle => 'इन्वेंटरी';

  @override
  String get inventoryTabArrows => 'तीर';

  @override
  String get inventoryTabBoards => 'बोर्ड';

  @override
  String get inventoryTabItems => 'आइटम';

  @override
  String get inventoryEquipped => 'लगा हुआ';

  @override
  String get inventoryTapToEquip => 'लगाने के लिए टैप करें';

  @override
  String inventoryReachLevel(int level) {
    return 'अनलॉक करने के लिए स्तर $level तक पहुंचें';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'स्तर $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return '$count और सिक्के चाहिए';
  }

  @override
  String inventoryBuyItemTitle(String item) {
    return '$item खरीदें?';
  }

  @override
  String inventoryUnlockTitle(String title) {
    return '$title अनलॉक करें?';
  }

  @override
  String inventoryCoinsPrice(int count) {
    return '$count सिक्के';
  }

  @override
  String get inventoryBuy => 'खरीदें';

  @override
  String get rushDifficultyEasy => 'आसान';

  @override
  String get rushDifficultyHard => 'कठिन';

  @override
  String get rushDifficultyImpossible => 'असंभव';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profilePlayingAsGuest => 'अतिथि के रूप में खेल रहे हैं';

  @override
  String get profileSignInSuccess => 'साइन इन — प्रगति सिंक हो गई';

  @override
  String profileSignInFailed(String error) {
    return 'साइन इन विफल: $error';
  }

  @override
  String get profileSaveYourProgress => 'अपनी प्रगति सहेजें';

  @override
  String get profileGuestBody =>
      'अतिथि खाते केवल इस डिवाइस पर रहते हैं। अपना स्तर, सिक्के और ट्रॉफ़ी बैकअप करने के लिए साइन इन करें।';

  @override
  String get profileContinueWithEmail => 'ईमेल से जारी रखें';

  @override
  String get profileSignOutTitle => 'साइन आउट करें?';

  @override
  String get profileSignOutBody =>
      'आपका क्लाउड सेव रहेगा। यह डिवाइस नए अतिथि खाते में रीसेट होकर स्तर 1 से शुरू होगा।';

  @override
  String get profileCancel => 'रद्द करें';

  @override
  String get profileSignOut => 'साइन आउट';

  @override
  String get profileDeleteAccountTitle => 'खाता हटाएं?';

  @override
  String get profileDeleteAccountBody =>
      'इससे आपका क्लाउड सेव और खाता स्थायी रूप से हट जाएगा। इसे वापस नहीं लाया जा सकता।';

  @override
  String get profileDelete => 'हटाएं';

  @override
  String profileDeleteFailed(String error) {
    return 'हटाना विफल: $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'साइन आउट विफल: $error';
  }

  @override
  String get profileSignedInBody =>
      'आपकी प्रगति क्लाउड में बैकअप है। जारी रखने के लिए किसी भी डिवाइस पर उसी खाते से साइन इन करें।';

  @override
  String get profileDeleteAccount => 'खाता हटाएं';

  @override
  String get profileStatLevel => 'स्तर';

  @override
  String get profileStatStars => 'सितारे';

  @override
  String get profileStatTrophies => 'ट्रॉफ़ी';

  @override
  String get profileTabSignIn => 'साइन इन';

  @override
  String get profileTabCreateAccount => 'खाता बनाएं';

  @override
  String get profileCreateAccountTitle => 'अपना खाता बनाएं';

  @override
  String get profileWelcomeBack => 'वापसी पर स्वागत';

  @override
  String get profileGuestProgressCarries =>
      'आपकी अतिथि प्रगति स्थानांतरित हो जाएगी।';

  @override
  String get profileSignInRestoreBody =>
      'दूसरे डिवाइस से अपनी प्रगति बहाल करने के लिए साइन इन करें।';

  @override
  String get profileNameHint => 'नाम (वैकल्पिक)';

  @override
  String get profileEmailHint => 'ईमेल';

  @override
  String get profilePasswordHint => 'पासवर्ड';

  @override
  String get profileShowPassword => 'पासवर्ड दिखाएं';

  @override
  String get profileHidePassword => 'पासवर्ड छिपाएं';

  @override
  String get profileGeneratePassword => 'पासवर्ड बनाएं';

  @override
  String get profilePasswordMinLength =>
      'पासवर्ड कम से कम 8 अक्षर का होना चाहिए।';

  @override
  String get profileStrengthTooShort => 'बहुत छोटा';

  @override
  String get profileStrengthOkay => 'ठीक';

  @override
  String get profileStrengthGood => 'अच्छा';

  @override
  String get profileStrengthStrong => 'मज़बूत';

  @override
  String get profileErrorEmailSignUp =>
      'यह ईमेल पहले से पंजीकृत है। साइन इन आज़माएं।';

  @override
  String get profileErrorEmailSignIn =>
      'यह ईमेल पहले से पंजीकृत है। अपना पासवर्ड जांचें या ईमेल लिंक से रीसेट करें।';

  @override
  String get profileErrorInvalidCredentials =>
      'ईमेल या पासवर्ड गलत है। फिर से प्रयास करें।';

  @override
  String get profileErrorPassword =>
      'पासवर्ड स्वीकार नहीं हुआ। 8+ अक्षर अंकों और वर्णों के साथ रखें, और \"password\" जैसे सामान्य शब्द न रखें।';

  @override
  String get profileErrorInvalidEmail => 'यह ईमेल अमान्य लगता है।';

  @override
  String get profileErrorSessionExpired =>
      'सत्र समाप्त। ऐप बंद करें, दोबारा खोलें और पुनः प्रयास करें।';

  @override
  String get profileErrorRateLimit =>
      'बहुत अधिक प्रयास। एक मिनट रुकें और पुनः प्रयास करें।';

  @override
  String get profileErrorServerBusy =>
      'सर्वर व्यस्त है। थोड़ी देर में पुनः प्रयास करें।';

  @override
  String get profileErrorSignUpGeneric =>
      'साइन-अप विफल। अपनी जानकारी जांचें और पुनः प्रयास करें।';

  @override
  String get profileErrorSignInGeneric =>
      'साइन-इन विफल। अपना ईमेल और पासवर्ड जांचें।';

  @override
  String get profileEnterValidEmail => 'मान्य ईमेल पता दर्ज करें।';

  @override
  String get profileEnterPassword => 'अपना पासवर्ड दर्ज करें।';

  @override
  String get profileEmailAlreadyPrompt =>
      'इस ईमेल का खाता पहले से है। साइन इन करने के लिए अपना पासवर्ड दर्ज करें।';

  @override
  String get profileSomethingWrong => 'कुछ गलत हो गया। पुनः प्रयास करें।';

  @override
  String get profileCreateAccountButton => 'खाता बनाएं';

  @override
  String get profileSignInButton => 'साइन इन';

  @override
  String get profileAlreadyHaveAccount => 'पहले से खाता है? साइन इन करें';

  @override
  String get profileDontHaveAccount => 'खाता नहीं है? एक बनाएं';

  @override
  String get homePlayer => 'खिलाड़ी';

  @override
  String homeLevelStars(int level, int stars) {
    return 'स्तर $level · $stars सितारे';
  }

  @override
  String get homeContinueLabel => 'जारी रखें';

  @override
  String homeLevelNumber(int level) {
    return 'स्तर $level';
  }

  @override
  String get homeContinue => 'जारी रखें';

  @override
  String get homeDaily => 'दैनिक';

  @override
  String get homeDailyReady => 'खेलने के लिए तैयार';

  @override
  String get homeDailyClaimed => 'आज प्राप्त हो गया';

  @override
  String get homeLeaderboard => 'लीडरबोर्ड';

  @override
  String get homeComingSoon => 'जल्द आ रहा है';

  @override
  String get homeInventory => 'इन्वेंटरी';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'सब अनलॉक · $count आइटम';
  }

  @override
  String get homeInventoryBrowse => 'अपना सामान देखें';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items आइटम';
  }

  @override
  String get homeTrophies => 'ट्रॉफ़ी';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$total में से $unlocked';
  }

  @override
  String get privacyWelcomeTitle => 'Arrow Puzzle में आपका स्वागत है';

  @override
  String get privacyWelcomeSubtitle =>
      'शुरू करने से पहले, कृपया हमारी शर्तें देखें और स्वीकार करें।';

  @override
  String get privacyBulletLocal =>
      'आपकी प्रगति आपके डिवाइस पर स्थानीय रूप से सहेजी जाती है।';

  @override
  String get privacyBulletCloud =>
      'वैकल्पिक खाते प्रगति को क्लाउड में सिंक करते हैं।';

  @override
  String get privacyBulletAds => 'गेम मुफ्त रखने के लिए विज्ञापन दिखाता है।';

  @override
  String get privacyPolicyLink => 'गोपनीयता नीति';

  @override
  String get privacyTermsLink => 'नियम और शर्तें';

  @override
  String get privacyAcceptButton => 'स्वीकारें और जारी रखें';

  @override
  String get privacyAgreeFooter =>
      'ऊपर टैप करके आप हमारी नियम और शर्तों से सहमत हैं।';

  @override
  String get bottomNavHome => 'होम';

  @override
  String get bottomNavDaily => 'दैनिक';

  @override
  String get bottomNavInventory => 'इन्वेंटरी';

  @override
  String get bottomNavSettings => 'सेटिंग्स';

  @override
  String gameTopBarScore(int score) {
    return 'स्कोर: $score';
  }

  @override
  String get gameTopBarRandom => 'यादृच्छिक';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'स्तर $level';
  }

  @override
  String get gameModeZenMode => 'ज़ेन मोड';

  @override
  String get howToPlayTitle => 'कैसे खेलें';

  @override
  String get howToPlayBasics => 'मूल बातें';

  @override
  String get howToPlayBoardElements => 'बोर्ड तत्व';

  @override
  String get howToPlayGameModes => 'गेम मोड';

  @override
  String get howToPlayProStrategies => 'प्रो रणनीतियाँ';

  @override
  String get howToPlayCoreTitle => 'मुख्य उद्देश्य';

  @override
  String get howToPlayCoreDesc =>
      'आपका लक्ष्य हर तीर को बोर्ड से बाहर निकालकर पूरी ग्रिड साफ़ करना है। जब कोई तीर न बचे, स्तर पूरा हो जाता है।';

  @override
  String get howToPlayMovementTitle => 'तीर की गति';

  @override
  String get howToPlayMovementDesc =>
      'किसी भी तीर पर टैप करके उसे छोड़ें। तीर अपने सिरे की ठीक दिशा में फिसलते हैं: ऊपर, नीचे, बाएं या दाएं। भले ही तीर का शरीर मुड़ा हो, वह हमेशा सिरे के अनुसार बाहर निकलता है।';

  @override
  String get howToPlayObstaclesTitle => 'बाधाएँ और टकराव';

  @override
  String get howToPlayObstaclesDesc =>
      'तीर तभी बाहर निकल सकता है जब उसका पूरा निकास मार्ग साफ़ हो। कोई दूसरा तीर रास्ते में हो तो टैप किया गया तीर हिलता है और वहीं रुक जाता है।';

  @override
  String get howToPlayLivesTitle => 'जीवन और स्वास्थ्य';

  @override
  String get howToPlayLivesDesc =>
      'क्लासिक मोड में आप 3 जीवन से शुरू करते हैं। अवरुद्ध तीर पर टैप करने से 1 जीवन कम होता है। तीनों खत्म होने पर स्तर पुनः आरंभ करें। सेटिंग्स में Infinite Lives कभी भी चालू कर सकते हैं।';

  @override
  String get howToPlayTurnDotsTitle => 'टर्न डॉट्स (रीडायरेक्टर)';

  @override
  String get howToPlayTurnDotsDesc =>
      'खाली ग्रिड सेल पर छोटे तीरों से चिह्नित गोल बिंदु खोजें। जब फिसलता तीर टर्न डॉट को पार करता है, वह तुरंत उसकी दिशा में मुड़ जाता है और उसे निगल जाता है, अप्रत्याशित निकास मार्ग खोलता है।';

  @override
  String get howToPlayCombosTitle => 'कॉम्बो और श्रृंखलाएँ';

  @override
  String get howToPlayCombosDesc =>
      'तीरों को तेज़ी से छोड़ें (1.5 सेकंड के भीतर) ताकि कॉम्बो सक्रिय हों। लगातार निकलने से गति बढ़ती है और स्कोर गुणक बढ़ता है।';

  @override
  String get howToPlayClassicTitle => 'क्लासिक मोड';

  @override
  String get howToPlayClassicDesc =>
      'मानक अभियान प्रगति। 3 जीवन के साथ हाथ से बने और प्रक्रियात्मक स्तरों में बढ़ते आकार, आकृति मास्क और पथ जटिलता के साथ आगे बढ़ें।';

  @override
  String get howToPlayZenTitle => 'ज़ेन मोड';

  @override
  String get howToPlayZenDesc =>
      'बिना तनाव के शुद्ध विश्राम। खोने के लिए जीवन नहीं, समय सीमा नहीं, विफलता नहीं। जटिल बोर्ड पर अभ्यास और आराम के लिए आदर्श।';

  @override
  String get howToPlayTimeAttackTitle => 'टाइम अटैक';

  @override
  String get howToPlayTimeAttackDesc =>
      'घड़ी के खिलाफ तेज़ दौड़! हर सफल तीर आपके काउंटडाउन टाइमर में बहुमूल्य बोनस सेकंड जोड़ता है।';

  @override
  String get howToPlayMultiplayerTitle => 'मल्टीप्लेयर रूम';

  @override
  String get howToPlayMultiplayerDesc =>
      'रूम सीड कोड के साथ होस्ट करें या जुड़ें। दोनों खिलाड़ी एक ही यादृच्छिक लेआउट पर मुकाबला करते हैं।';

  @override
  String get howToPlayRandomTitle => 'यादृच्छिक पहेलियाँ';

  @override
  String get howToPlayRandomDesc =>
      'अभियान स्तर प्रगति को प्रभावित किए बिना आसान, मध्यम, कठिन, मास्टर और विशेषज्ञ कठिनाई में अनंत ऑन-डिमांड पहेलियाँ उत्पन्न करें।';

  @override
  String get howToPlayUnpeelTitle => 'परिधि से छीलें';

  @override
  String get howToPlayUnpeelDesc =>
      'बाहरी किनारों को स्कैन करके शुरू करें। बाहर की ओर इशारा करने वाले तीर तुरंत बाहर निकल सकते हैं, महत्वपूर्ण मार्ग खाली करते हैं।';

  @override
  String get howToPlayTraceTitle => 'अवरोधकों को उल्टा खोजें';

  @override
  String get howToPlayTraceDesc =>
      'जब कोई तीर अवरुद्ध हो, पता करें कि उसे कौन अवरुद्ध करता है, फिर उस दूसरे तीर को कौन। श्रृंखला का अंतिम अवरोधक खोलने पर उसके पीछे सब कुछ खुल जाता है।';

  @override
  String get howToPlayTapAssistTitle => 'टैप असिस्ट चालू करें';

  @override
  String get howToPlayTapAssistDesc =>
      'अगर छोटी स्क्रीन पर खेलते हैं या तंग तीरों के बीच टैप करते हैं, तो सेटिंग्स में टैप असिस्ट चालू करें ताकि पास के टैप निकटतम तीर से मैप हों।';

  @override
  String get multiplayerTitle => 'मल्टीप्लेयर';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return 'रूम कोड $code क्लिपबोर्ड पर कॉपी हो गया!';
  }

  @override
  String get multiplayerHostRoom => 'होस्ट रूम';

  @override
  String get multiplayerHostBody =>
      'एक ही पहेली लेआउट पर मुकाबला करने के लिए यह कोड दोस्त के साथ साझा करें!';

  @override
  String get multiplayerNewCode => 'नया कोड';

  @override
  String get multiplayerCopyCode => 'कोड कॉपी करें';

  @override
  String get multiplayerStartMatch => 'मैच शुरू करें';

  @override
  String get multiplayerJoinRoom => 'रूम जॉइन करें';

  @override
  String get multiplayerJoinBody => 'जुड़ने के लिए रूम कोड दर्ज या पेस्ट करें।';

  @override
  String get multiplayerRoomCodeHint => 'जैसे ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'कृपया रूम कोड दर्ज करें';

  @override
  String get multiplayerJoinMatch => 'जॉइन';

  @override
  String get zenCardSubtitle => 'समय नहीं। सीमा नहीं। बस हल करें।';

  @override
  String get profileSyncing => 'सिंक हो रहा है...';

  @override
  String get profileSyncFailed => 'सिंक विफल';

  @override
  String get gameModeTimeBlitz => 'टाइम ब्लिट्ज़';

  @override
  String get timeBlitzDesc =>
      'समय पाने के लिए तीर टैप करें। अवरुद्ध टैप समय घटाते हैं। जितना हो सके टिके रहें।';

  @override
  String get timeBlitzOverTitle => 'टाइम ब्लिट्ज़ खत्म';

  @override
  String get timeBlitzScoreLabel => 'तीर साफ़ किए';

  @override
  String get timeBlitzLevelsLabel => 'पहुंचे स्तर';

  @override
  String get profileEditName => 'नाम संपादित करें';

  @override
  String get profileSave => 'सहेजें';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हो गई';
}
