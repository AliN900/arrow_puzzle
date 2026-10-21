// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppStringsAr extends AppStrings {
  AppStringsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أرو بزل';

  @override
  String get buttonCancel => 'إلغاء';

  @override
  String get buttonResume => 'استئناف';

  @override
  String get buttonExit => 'خروج';

  @override
  String get gameModeClassic => 'كلاسيكي';

  @override
  String get gameModeTimeAttack => 'ضد الوقت';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsSoundEffects => 'المؤثرات الصوتية';

  @override
  String get settingsMusic => 'الموسيقى';

  @override
  String get settingsVibration => 'الاهتزاز';

  @override
  String get settingsArrowSpeed => 'سرعة السهم';

  @override
  String get settingsAbout => 'حول';

  @override
  String get dialogExitTitle => 'هل تريد الخروج من اللعبة؟';

  @override
  String get dialogExitMessage => 'هل أنت متأكد من أنك تريد الخروج؟';

  @override
  String get profileSaveToCloud => 'احفظ في السحابة';

  @override
  String get profileSynced => 'تمت المزامنة';

  @override
  String get profileSignedIn => 'مسجّل الدخول';

  @override
  String get dailyRewardsTitle => 'المكافآت اليومية';

  @override
  String get blitzTitle => 'بليتز';

  @override
  String get unlockTitle => 'تهانينا!';

  @override
  String get unlockSubtitle => 'لوحة جديدة مفتوحة';

  @override
  String get unlockAddedToInventory => 'تمت الإضافة إلى مخزونك';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count عملات';
  }

  @override
  String get buttonCheckInventory => 'عرض المخزون';

  @override
  String get buttonMainMenu => 'القائمة الرئيسية';

  @override
  String get dailyChallengesTitle => 'التحديات اليومية';

  @override
  String get dailyChallengesSubtitle =>
      'أكمل الأوضاع الخاصة لكسب مكافآت إضافية.';

  @override
  String get dailyRewardsSubtitle => 'استلم مكافأة سلسلتك';

  @override
  String get activeChallengesTitle => 'التحديات النشطة';

  @override
  String get blitzSubtitle =>
      'اجتز سلسلة من المراحل. الوقت يضيق. القلوب تستمر.';

  @override
  String get badgeNew => 'جديد';

  @override
  String get mineArrowsTitle => 'أسهم الألغام';

  @override
  String get mineArrowsSubtitle => 'نظّف الأسهم مع تجنّب الألغام المخفية!';

  @override
  String get badgeComingSoon => 'قريباً';

  @override
  String get mineArrowsComingSoonSnack => 'تحدي أسهم الألغام قادم قريباً!';

  @override
  String get dailyRewardsLabel => 'المكافآت اليومية';

  @override
  String dayOfMax(int day, int max) {
    return 'اليوم $day من $max';
  }

  @override
  String get comeBackTomorrow => 'عد غداً';

  @override
  String plusCoins(int count) {
    return '+$count عملة';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'استلم مجاناً';

  @override
  String get loadingLabel => 'جارٍ التحميل...';

  @override
  String watchAdCoins(int coins) {
    return 'شاهد الإعلان → +$coins عملة';
  }

  @override
  String get notNow => 'ليس الآن';

  @override
  String get claimedToday => 'تم الاستلام اليوم!';

  @override
  String nextRewardIn(String time) {
    return 'المكافأة التالية خلال $time';
  }

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get claimedSnack => 'تم الاستلام!';

  @override
  String get arrowRushTitle => 'Arrow Rush';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return 'وصل إلى المستوى $level لفتح $tier';
  }

  @override
  String startTier(String tier) {
    return 'ابدأ $tier';
  }

  @override
  String lvLabel(int level) {
    return 'مستوى $level';
  }

  @override
  String get adNotAvailable => 'الإعلان غير متاح، حاول لاحقًا';

  @override
  String get adBadge => 'إعلان';

  @override
  String get homeButton => 'الرئيسية';

  @override
  String get gameOverTimeUp => 'انتهى الوقت!';

  @override
  String get gameOverOutOfTime => 'نفد الوقت!';

  @override
  String get gameOverOutOfLives => 'نفدت الأرواح!';

  @override
  String gameOverRewardTime(int seconds) {
    return '+$secondsث';
  }

  @override
  String gameOverRewardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count حيوات',
      one: '+$count حياة',
    );
    return '$_temp0';
  }

  @override
  String gameOverTimeAttackStats(int cleared, int level) {
    return 'الألغاز المكتملة: $cleared\nالمستوى النهائي: $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'شاهد الإعلان → $reward';
  }

  @override
  String get gameOverStartNewRun => 'بدء جولة جديدة';

  @override
  String get gameOverRestartLevel => 'إعادة المستوى';

  @override
  String get levelCompleteTitle => 'اكتمل المستوى!';

  @override
  String get levelCompleteNewTrophy => 'جائزة جديدة';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count عناصر عشوائية',
      one: '+$count عنصر عشوائي',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => 'لقد أكملت اللعبة!';

  @override
  String get levelCompleteNextLevel => 'المستوى التالي';

  @override
  String get levelCompleteCoinsDoubled => 'تضاعفت العملات!';

  @override
  String get levelCompleteDoubleCoins => 'ضاعف العملات';

  @override
  String get settingsAboutCredits => 'حول اللعبة والحقوق';

  @override
  String get aboutTitle => 'حول والحقوق';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutDeveloper => 'تصميم وتطوير علي حسين (ahb.Dev)';

  @override
  String get aboutOriginalConcept =>
      'فكرة اللعبة الأصلية: ArrowEscape بواسطة sidhant947';

  @override
  String get aboutVisitWebsite => 'زيارة موقع ahb.Dev';

  @override
  String get aboutMusicTitle => 'الموسيقى (OpenGameArt)';

  @override
  String get aboutUnderwaterTheme => 'ثيم تحت الماء';

  @override
  String get aboutCallerTheme => 'ثيم القائمة الرئيسية';

  @override
  String get aboutGrooveTheme => 'ثيم Rushmode';

  @override
  String get aboutMusicSource => 'جميع المقطوعات الموسيقية من OpenGameArt.org.';

  @override
  String get aboutIconsTitle => 'الأيقونات (SVG Repo)';

  @override
  String get aboutIconsCredit1 =>
      'طائر، ماس، نظارات، سمكة، حوت، زهرة، صاروخ، مفتاح، نجمة';

  @override
  String get aboutIconsCredit2 => 'فراشة، سلحفاة';

  @override
  String get aboutIconsCredit3 => 'تاج، منزل، شجرة';

  @override
  String get aboutIconsCredit4 => 'قلب';

  @override
  String get aboutIconsAuthors =>
      'بواسطة Noah Jacobus, Konstantin Filatov, Solar Icons, Dazzle UI, pixelbazaar, & Iconhub';

  @override
  String get aboutVisitSvgRepo => 'زيارة SVGRepo.com';

  @override
  String get aboutOpenSourceTitle => 'مفتوح المصدر';

  @override
  String get aboutOpenSourceBody =>
      'تم بناء هذه اللعبة باستخدام تقنيات مفتوحة المصدر رائعة:';

  @override
  String get aboutCopyright => '© 2026 ahb.Dev. جميع الحقوق محفوظة.';

  @override
  String gameTimedLevel(String seconds) {
    return 'مستوى محدد · $seconds ثانية';
  }

  @override
  String get gameSolverCalculating => 'جاري حساب الحل...';

  @override
  String get gameSolverUnsolvable => '❌ غير قابل للحل! المستوى مغلق.';

  @override
  String get pauseTitle => 'متوقف مؤقتًا';

  @override
  String get pauseResume => 'استئناف';

  @override
  String get pauseRestart => 'إعادة';

  @override
  String get pauseMainMenu => 'القائمة الرئيسية';

  @override
  String get itemBombName => 'لغم';

  @override
  String get itemBombDesc => 'أزل لغماً واحداً من اللوحة';

  @override
  String get itemHintName => 'تلميح';

  @override
  String get itemHintDesc => 'اكشف السهم التالي القابل للحل';

  @override
  String get itemUndoName => 'تراجع';

  @override
  String get itemUndoDesc => 'أعِد آخر سهم هارب';

  @override
  String get itemHeartFlaskName => 'قارورة القلب';

  @override
  String get itemHeartFlaskDesc => 'استعِد حياة واحدة';

  @override
  String get itemTimeFreezeName => 'تجميد الوقت';

  @override
  String get itemTimeFreezeDesc => 'أضف 30 ثانية إلى المؤقت';

  @override
  String get themeNeon => 'نيون';

  @override
  String get themeClassic => 'كلاسيكي';

  @override
  String get themeRetro => 'ريترو';

  @override
  String get themeCyber => 'سيبر';

  @override
  String get themeHacker => 'هاكر';

  @override
  String get themeAurora => 'الشفق القطبي';

  @override
  String get themeBlueprint => 'مخطط';

  @override
  String get themeForest => 'غابة';

  @override
  String get themePastel => 'باستيل';

  @override
  String get themeSunset => 'الغروب';

  @override
  String get themeRainbow => 'قوس قزح';

  @override
  String get boardMinimal => 'بسيط';

  @override
  String get boardNebula => 'سديم';

  @override
  String get boardBlueprint => 'مخطط';

  @override
  String get boardForest => 'غابة';

  @override
  String get boardOcean => 'محيط';

  @override
  String get boardEmber => 'جمرة';

  @override
  String get boardCosmic => 'كوني';

  @override
  String get boardGeometric => 'هندسي';

  @override
  String get boardGold => 'ذهبي';

  @override
  String get boardHacker => 'هاكر';

  @override
  String get boardPaper => 'ورق';

  @override
  String get boardIce => 'جليد';

  @override
  String get boardSand => 'رمل';

  @override
  String get boardCloud => 'سحابة';

  @override
  String get boardMint => 'نعناع';

  @override
  String get boardRose => 'وردة';

  @override
  String get boardLavender => 'خزامى';

  @override
  String get boardSky => 'سماء';

  @override
  String get boardPearl => 'لؤلؤة';

  @override
  String get boardHoney => 'عسل';

  @override
  String get trophyFirstEscapeTitle => '🌟 الصحوة الأولى';

  @override
  String get trophyFirstEscapeDesc =>
      'أول متاهة تهرب منها! لقد فتحت بوابة نظام الجوائز. مرحبًا بك في رحلة الألغاز النهائية من AHB.Dev!';

  @override
  String get trophyPointBlankTitle => 'من مسافة قريبة';

  @override
  String get trophyPointBlankDesc => 'أكمل أول تصميم لغز بدقة.';

  @override
  String get trophyTrialOfTwoTitle => 'اختبار الاثنين';

  @override
  String get trophyTrialOfTwoDesc =>
      'تغلّب على قيد الحياة المزدوج القاسي في الاختبارات الأولى.';

  @override
  String get trophyQuickThinkerTitle => 'المفكر السريع';

  @override
  String get trophyQuickThinkerDesc =>
      'أكمل أي مستوى بسرعة تحت عتبة ممتدة من 20 ثانية.';

  @override
  String get trophyArrowSmithTitle => 'حدّاد الأسهم';

  @override
  String get trophyArrowSmithDesc => 'أكمل 10 مستويات دون استسلام أو إعادة.';

  @override
  String get trophyCleanSlateTitle => 'بداية نظيفة';

  @override
  String get trophyCleanSlateDesc => 'أكمل مستوى دون نقرة سهم محجوبة واحدة.';

  @override
  String get trophySparkOfGeniusTitle => 'شرارة العبقرية';

  @override
  String get trophySparkOfGeniusDesc =>
      'استخدم أول تلميح لك لإيجاد طريق في موقف صعب.';

  @override
  String get trophyUnwindTitle => 'ارتخِ';

  @override
  String get trophyUnwindDesc => 'استخدم أول تراجع لك لعكس خطوة خاطئة.';

  @override
  String get trophyRockBreakerTitle => 'كاسر الصخور';

  @override
  String get trophyRockBreakerDesc =>
      'دمّر أول عقبة صخرية لك باستخدام سهم قنبلة تكتيكي.';

  @override
  String get trophySurvivalistBadgeTitle => 'الناجي';

  @override
  String get trophySurvivalistBadgeDesc =>
      'قهرت أول 25 اختبارًا! يرقّي الحد الأقصى لحياتك بشكل دائم من 2 إلى 3.';

  @override
  String get trophyWayfinderTitle => 'دليل الطريق';

  @override
  String get trophyWayfinderDesc =>
      'وصل إلى المستوى 50 وأثبت إتقانك للمتاهات الأولى.';

  @override
  String get trophyTangleTamerTitle => 'روّض التشابك';

  @override
  String get trophyTangleTamerDesc =>
      'أكمل 10 مستويات متتالية دون خطأ اتجاهي واحد.';

  @override
  String get trophyTimeLordTitle => 'سيّد الوقت';

  @override
  String get trophyTimeLordDesc =>
      'انجُ من اختبار موقوت بمستوى إلهي مع ثوانٍ فائضة.';

  @override
  String get trophyCenturyMarkTitle => 'علامة المئة';

  @override
  String get trophyCenturyMarkDesc =>
      'وصل إلى المستوى 100 — خُمس الطريق إلى قمة 500!';

  @override
  String get trophyBombTechnicianTitle => 'فني القنابل';

  @override
  String get trophyBombTechnicianDesc =>
      'أزل 25 صخرة خلال حملتك باستخدام القنابل التكتيكية.';

  @override
  String get trophyUntouchableTitle => 'لا يُمَس';

  @override
  String get trophyUntouchableDesc =>
      'أكمل 5 مستويات متتالية دون خسارة حياة واحدة.';

  @override
  String get trophyStargazerTitle => 'راصد النجوم';

  @override
  String get trophyStargazerDesc => 'احصل على 3 نجوم عبر 30 لوحة ألغاز مختلفة.';

  @override
  String get trophyMasterOfAnglesTitle => 'سيّد الزوايا';

  @override
  String get trophyMasterOfAnglesDesc =>
      'أكمل لغزًا معقدًا يعتمد بشكل كبير على نقاط إعادة التوجيه اليتيمة.';

  @override
  String get trophyHalfwayToGloryTitle => 'منتصف الطريق إلى المجد';

  @override
  String get trophyHalfwayToGloryDesc =>
      'وصل إلى المستوى 125، مثبتًا هيمنتك في منتصف اللعبة.';

  @override
  String get trophyTheStrategistTitle => 'الاستراتيجي';

  @override
  String get trophyTheStrategistDesc =>
      'استخدم جميع عناصر المخزون المتاحة مرة واحدة على الأقل خلال جلسة واحدة.';

  @override
  String get trophyQuickSilverTitle => 'الزئبق';

  @override
  String get trophyQuickSilverDesc =>
      'اجمع 5 دقائق من اللعب السريع في وضع سباق الوقت.';

  @override
  String get trophyIronWillTitle => 'إرادة من حديد';

  @override
  String get trophyIronWillDesc =>
      'اربح مستوى زعيم بعد الوصول إلى آخر حياة لك.';

  @override
  String get trophyGoldenTouchTitle => 'اللمسة الذهبية';

  @override
  String get trophyGoldenTouchDesc => 'افتح أول لوحة أو سمة سهم مخصصة لك.';

  @override
  String get trophyDeepDiverTitle => 'الغواص العميق';

  @override
  String get trophyDeepDiverDesc =>
      'وصل إلى المستوى 150 بينما تزداد المتاهة تعقيدًا هائلًا.';

  @override
  String get trophyThePuzzlerTitle => 'مُحلّل الألغاز';

  @override
  String get trophyThePuzzlerDesc =>
      'أكمل 50 لوحة ألغاز مولّدة إجرائيًا بشكل عشوائي.';

  @override
  String get trophySharpShooterTitle => 'الرامي الماهر';

  @override
  String get trophySharpShooterDesc =>
      'أكمل 20 مستوى باستخدام أقل عدد ممكن من الحركات.';

  @override
  String get trophyVaultKeeperTitle => 'حارس الخزانة';

  @override
  String get trophyVaultKeeperDesc =>
      'اجمع إجمالي 500 عملة من اللعب ومكافآت الإعلانات.';

  @override
  String get trophyMilestoneMasterTitle => 'سيّد المحطات';

  @override
  String get trophyMilestoneMasterDesc =>
      'وصل إلى المستوى 200 — خُمسا الطريق إلى الحد الأقصى 500.';

  @override
  String get trophyBossSlayerTitle => 'قاتل الزعماء';

  @override
  String get trophyBossSlayerDesc =>
      'اهزم 8 مستويات زعماء متتالية دون هزيمة واحدة.';

  @override
  String get trophyTimeBenderTitle => 'مُنحني الوقت';

  @override
  String get trophyTimeBenderDesc =>
      'جمّد الوقت بنجاح 10 مرات في مستويات العد التنازلي المكثفة.';

  @override
  String get trophyResilientSpiritTitle => 'روح صلبة';

  @override
  String get trophyResilientSpiritDesc =>
      'تعافَ من حالة انتهاء اللعبة باستخدام مكافأة متابعة الإعلان.';

  @override
  String get trophyBoardCollectorTitle => 'جامع اللوحات';

  @override
  String get trophyBoardCollectorDesc =>
      'افتح 5 سمات لوحة مخصصة مختلفة لمجموعتك.';

  @override
  String get trophyApexPredatorTitle => 'المفترس الأعلى';

  @override
  String get trophyApexPredatorDesc =>
      'وصل إلى المستوى 250 — قمة منتصف حملة الألغاز الحالية.';

  @override
  String get trophyFlawlessExecutionTitle => 'تنفيذ لا تشوبه شائبة';

  @override
  String get trophyFlawlessExecutionDesc =>
      'احصل على 3 نجوم عبر 100 مستوى منفصل.';

  @override
  String get trophyTacticalMindsetTitle => 'عقلية تكتيكية';

  @override
  String get trophyTacticalMindsetDesc =>
      'حل لغزًا بمستوى إلهي دون الاعتماد على أي تلميحات.';

  @override
  String get trophyDailyDevoteeTitle => 'المخلص اليومي';

  @override
  String get trophyDailyDevoteeDesc =>
      'حافظ على سلسلة تسجيل دخول مدتها 7 أيام في متتبع المكافآت اليومية.';

  @override
  String get trophyMonumentalPioneerTitle => 'الرائد التذكاري';

  @override
  String get trophyMonumentalPioneerDesc =>
      'افتح أول جائزة تذكارية للهيبة زخرفية بحتة.';

  @override
  String get trophyHighClimberTitle => 'المتسلق العالي';

  @override
  String get trophyHighClimberDesc =>
      'وصل إلى المستوى 300 — ثلاثة أخماس الطريق إلى قمة 500.';

  @override
  String get trophyGrandmasterTitle => 'الأستاذ الأكبر';

  @override
  String get trophyGrandmasterDesc =>
      'وصل إلى المستوى 350، متغلبًا على أعقد تشابكات الشبكة.';

  @override
  String get trophyEternalFlameTitle => 'اللهب الأبدي';

  @override
  String get trophyEternalFlameDesc =>
      'حافظ على سلسلة تسجيل دخول متواصلة مذهلة لمدة 14 يومًا.';

  @override
  String get trophyIroncladTitle => 'مُدرّع';

  @override
  String get trophyIroncladDesc =>
      'وصل إلى المستوى 400 — أربعة أخماس الطريق إلى القمة النهائية.';

  @override
  String get trophyPerfectionistTitle => 'الكمالي';

  @override
  String get trophyPerfectionistDesc =>
      'احصل على 3 نجوم في كل مستوى من 1 إلى 400.';

  @override
  String get trophyTitanOfTheMazeTitle => 'عملاق المتاهة';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'وصل إلى المستوى 450، واقفًا بين نخبة حلّالي الألغاز.';

  @override
  String get trophyThe500ClubTitle => 'نادي الـ500';

  @override
  String get trophyThe500ClubDesc =>
      'وصل إلى المستوى 500، محققًا القمة القصوى الحالية لشبكة الألغاز!';

  @override
  String get trophyLivingLegendTitle => 'أسطورة حية';

  @override
  String get trophyLivingLegendDesc =>
      'أكمل المستوى 500 بتقييم 3 نجوم وصفر أخطاء.';

  @override
  String get trophyMonumentOfTimeTitle => 'نصب الوقت';

  @override
  String get trophyMonumentOfTimeDesc =>
      'قطعة أثرية تذكارية للهيبة تُمنح لتكريس أكثر من 10 ساعات نشطة للهروب من المتاهات.';

  @override
  String get trophyAbsoluteVoidTitle => 'الفراغ المطلق';

  @override
  String get trophyAbsoluteVoidDesc =>
      'جائزة تذكارية للهيبة سوداء بالكامل تُمنح لتعظيم ميزات التقدم الرئيسية.';

  @override
  String get trophyInfiniteHorizonTitle => 'الأفق اللانهائي';

  @override
  String get trophyInfiniteHorizonDesc =>
      'جائزة تذكارية تُقرّ بأن الرحلة بعد المستوى 500 لا تنتهي أبدًا.';

  @override
  String timeBonusAmount(int seconds) {
    return '+$secondsث';
  }

  @override
  String get heartsAlreadyFull => 'القلوب ممتلئة بالفعل';

  @override
  String timeFreezeWait(int seconds) {
    return 'انتظر $secondsث إضافية قبل استخدام تجميد الوقت';
  }

  @override
  String get tapRockToDestroy => 'انقر على صخرة لتدميرها';

  @override
  String get noSolvableArrowFound => 'لم يتم العثور على سهم قابل للحل';

  @override
  String get nothingToUndo => 'لا شيء للتراجع عنه';

  @override
  String get blitzSplashStage => 'المرحلة';

  @override
  String get arrowSpeedEscapeSpeed => 'سرعة الهروب';

  @override
  String get arrowSpeedSlow => 'بطيئة';

  @override
  String get arrowSpeedNormal => 'عادية';

  @override
  String get arrowSpeedFast => 'سريعة';

  @override
  String get accentColorLabel => 'لون التمييز';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsTermsConditions => 'الشروط والأحكام';

  @override
  String get settingsChooseLanguage => 'اختر اللغة';

  @override
  String settingsVersionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get languageSystemDefault => 'افتراضي النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languagePortugueseBR => 'البرتغالية (BR)';

  @override
  String get languageIndonesian => 'الإندونيسية';

  @override
  String get languageHindi => 'الهندية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'الجوائز ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'مستوى $level';
  }

  @override
  String get trophiesPerkHeart => '✨ ميزة: +1 حياة قصوى دائمة';

  @override
  String get leaderboardTitle => 'قائمة المتصدرين';

  @override
  String get leaderboardTabWeekly => 'أسبوعي';

  @override
  String get leaderboardTabMonthly => 'شهري';

  @override
  String get leaderboardTabAllTime => 'الإجمالي';

  @override
  String get leaderboardSignInToRank => 'سجّل الدخول للظهور في القائمة';

  @override
  String get leaderboardEmptyState => 'لا توجد نتائج بعد';

  @override
  String get leaderboardLevel => 'المستوى';

  @override
  String get leaderboardStars => 'النجوم';

  @override
  String get inventoryTitle => 'المخزون';

  @override
  String get inventoryTabArrows => 'الأسهم';

  @override
  String get inventoryTabBoards => 'اللوحات';

  @override
  String get inventoryTabItems => 'العناصر';

  @override
  String get inventoryEquipped => 'مُجهّز';

  @override
  String get inventoryTapToEquip => 'انقر للتجهيز';

  @override
  String inventoryReachLevel(int level) {
    return 'وصل إلى المستوى $level لفتحه';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'مستوى $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return 'تحتاج $count عملة أخرى';
  }

  @override
  String get rushDifficultyEasy => 'سهل';

  @override
  String get rushDifficultyHard => 'صعب';

  @override
  String get rushDifficultyImpossible => 'مستحيل';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profilePlayingAsGuest => 'اللعب كضيف';

  @override
  String get profileSaveYourProgress => 'احفظ تقدمك';

  @override
  String get profileGuestBody =>
      'حسابات الضيف تبقى على هذا الجهاز فقط. سجّل الدخول لنسخ مستواك وعملاتك وجوائزك احتياطيًا.';

  @override
  String get profileContinueWithEmail => 'المتابعة بالبريد الإلكتروني';

  @override
  String get profileSignOutTitle => 'تسجيل الخروج؟';

  @override
  String get profileSignOutBody =>
      'سيبقى حفظك السحابي. سيُعاد ضبط هذا الجهاز إلى حساب ضيف جديد ويبدأ من المستوى 1.';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get profileSignOut => 'تسجيل الخروج';

  @override
  String get profileDeleteAccountTitle => 'حذف الحساب؟';

  @override
  String get profileDeleteAccountBody =>
      'سيؤدي هذا إلى حذف حفظك السحابي وحسابك نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get profileDelete => 'حذف';

  @override
  String profileDeleteFailed(String error) {
    return 'فشل الحذف: $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'فشل تسجيل الخروج: $error';
  }

  @override
  String get profileSignedInBody =>
      'تم نسخ تقدمك احتياطيًا إلى السحابة. سجّل الدخول على أي جهاز بنفس الحساب للمتابعة.';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileStatLevel => 'المستوى';

  @override
  String get profileStatStars => 'النجوم';

  @override
  String get profileStatTrophies => 'الجوائز';

  @override
  String get profileTabSignIn => 'تسجيل الدخول';

  @override
  String get profileTabCreateAccount => 'إنشاء حساب';

  @override
  String get profileCreateAccountTitle => 'أنشئ حسابك';

  @override
  String get profileWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get profileGuestProgressCarries => 'سيتم نقل تقدمك كضيف.';

  @override
  String get profileSignInRestoreBody =>
      'سجّل الدخول لاستعادة تقدمك من جهاز آخر.';

  @override
  String get profileNameHint => 'الاسم (اختياري)';

  @override
  String get profileEmailHint => 'البريد الإلكتروني';

  @override
  String get profilePasswordHint => 'كلمة المرور';

  @override
  String get profileShowPassword => 'إظهار كلمة المرور';

  @override
  String get profileHidePassword => 'إخفاء كلمة المرور';

  @override
  String get profileGeneratePassword => 'إنشاء كلمة مرور';

  @override
  String get profilePasswordMinLength =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل.';

  @override
  String get profileStrengthTooShort => 'قصيرة جدًا';

  @override
  String get profileStrengthOkay => 'مقبولة';

  @override
  String get profileStrengthGood => 'جيدة';

  @override
  String get profileStrengthStrong => 'قوية';

  @override
  String get profileErrorEmailSignUp =>
      'هذا البريد مسجّل مسبقًا. جرّب تسجيل الدخول.';

  @override
  String get profileErrorEmailSignIn =>
      'هذا البريد مسجّل مسبقًا. تحقق من كلمة المرور أو أعد ضبطها من رابط البريد.';

  @override
  String get profileErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. حاول مجددًا.';

  @override
  String get profileErrorPassword =>
      'لم يتم قبول كلمة المرور. استخدم 8+ أحرف مع أرقام وحروف، وتجنّب كلمات شائعة مثل \"password\".';

  @override
  String get profileErrorInvalidEmail => 'يبدو هذا البريد غير صالح.';

  @override
  String get profileErrorSessionExpired =>
      'انتهت الجلسة. أغلق التطبيق وأعد فتحه وحاول مجددًا.';

  @override
  String get profileErrorRateLimit =>
      'محاولات كثيرة. انتظر دقيقة وحاول مجددًا.';

  @override
  String get profileErrorServerBusy => 'الخادم مشغول. حاول بعد قليل.';

  @override
  String get profileErrorSignUpGeneric =>
      'فشل التسجيل. تحقق من بياناتك وحاول مجددًا.';

  @override
  String get profileErrorSignInGeneric =>
      'فشل تسجيل الدخول. تحقق من بريدك وكلمة المرور.';

  @override
  String get profileEnterValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get profileEnterPassword => 'أدخل كلمة المرور.';

  @override
  String get profileEmailAlreadyPrompt =>
      'هذا البريد لديه حساب بالفعل. أدخل كلمة المرور لتسجيل الدخول.';

  @override
  String get profileSomethingWrong => 'حدث خطأ ما. حاول مجددًا.';

  @override
  String get profileCreateAccountButton => 'إنشاء حساب';

  @override
  String get profileSignInButton => 'تسجيل الدخول';

  @override
  String get profileAlreadyHaveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get profileDontHaveAccount => 'ليس لديك حساب؟ أنشئ واحدًا';

  @override
  String get homePlayer => 'اللاعب';

  @override
  String homeLevelStars(int level, int stars) {
    return 'المستوى $level · $stars نجمة';
  }

  @override
  String get homeContinueLabel => 'متابعة';

  @override
  String homeLevelNumber(int level) {
    return 'المستوى $level';
  }

  @override
  String get homeDaily => 'يومي';

  @override
  String get homeDailyReady => 'جاهز للعب';

  @override
  String get homeDailyClaimed => 'تم الاستلام اليوم';

  @override
  String get homeLeaderboard => 'المتصدرون';

  @override
  String get homeInventory => 'المخزون';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'كل شيء مفتوح · $count عنصر';
  }

  @override
  String get homeInventoryBrowse => 'تصفّح عتادك';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items عنصر';
  }

  @override
  String get homeTrophies => 'الجوائز';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$unlocked من $total';
  }

  @override
  String get privacyWelcomeTitle => 'مرحبًا بك في Arrow Puzzle';

  @override
  String get privacyWelcomeSubtitle =>
      'قبل أن نبدأ، يرجى مراجعة شروطنا والموافقة عليها.';

  @override
  String get privacyBulletLocal => 'يتم حفظ تقدمك محليًا على جهازك.';

  @override
  String get privacyBulletCloud =>
      'الحسابات الاختيارية تزامن التقدم مع السحابة.';

  @override
  String get privacyBulletAds => 'يعرض اللعبة إعلانات لتبقى مجانية.';

  @override
  String get privacyPolicyLink => 'سياسة الخصوصية';

  @override
  String get privacyTermsLink => 'الشروط والأحكام';

  @override
  String get privacyAcceptButton => 'الموافقة والمتابعة';

  @override
  String get privacyAgreeFooter =>
      'بالنقر أعلاه فإنك توافق على الشروط والأحكام.';

  @override
  String get bottomNavHome => 'الرئيسية';

  @override
  String get bottomNavDaily => 'يومي';

  @override
  String get bottomNavInventory => 'المخزون';

  @override
  String get bottomNavSettings => 'الإعدادات';

  @override
  String gameTopBarScore(int score) {
    return 'النتيجة: $score';
  }

  @override
  String get gameTopBarRandom => 'عشوائي';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'مستوى $level';
  }

  @override
  String get gameModeZenMode => 'وضع زن';

  @override
  String get howToPlayTitle => 'كيفية اللعب';

  @override
  String get howToPlayBasics => 'الأساسيات';

  @override
  String get howToPlayBoardElements => 'عناصر اللوحة';

  @override
  String get howToPlayGameModes => 'أنماط اللعب';

  @override
  String get howToPlayProStrategies => 'استراتيجيات احترافية';

  @override
  String get howToPlayCoreTitle => 'الهدف الأساسي';

  @override
  String get howToPlayCoreDesc =>
      'هدفك هو تفريغ الشبكة بالكامل بإخراج كل سهم من اللوحة. عند عدم بقاء أي سهم، يكتمل المستوى.';

  @override
  String get howToPlayMovementTitle => 'حركة السهم';

  @override
  String get howToPlayMovementDesc =>
      'انقر على أي سهم لإطلاقه. تنزلق الأسهم في الاتجاه الذي يشير إليه رأس السهم بدقة: أعلى، أسفل، يسار أو يمين. حتى لو كان جسم السهم مثنيًا، فإنه يخرج دائمًا متبعًا رأسه.';

  @override
  String get howToPlayObstaclesTitle => 'العوائق والاصطدامات';

  @override
  String get howToPlayObstaclesDesc =>
      'لا يستطيع السهم الخروج إلا إذا كان مساره بالكامل خاليًا. إذا اعترضه سهم آخر، يهتز السهم المنقور ويبقى مكانه.';

  @override
  String get howToPlayLivesTitle => 'الحياة والصحة';

  @override
  String get howToPlayLivesDesc =>
      'في النمط الكلاسيكي تبدأ بـ 3 حيوات. نقر سهم محجوب يخصم حياة. عند نفاده يجب إعادة المستوى. يمكنك تفعيل الحياة اللانهائية من الإعدادات في أي وقت.';

  @override
  String get howToPlayTurnDotsTitle => 'نقاط الانعطاف (المُوجّهات)';

  @override
  String get howToPlayTurnDotsDesc =>
      'ابحث عن نقاط دائرية على خلايا فارغة بأسهم صغيرة. عندما يعبر سهم منزلق نقطة انعطاف، ينحرف فورًا في اتجاهها ويلتهمها، فاتحًا مسارات غير متوقعة.';

  @override
  String get howToPlayCombosTitle => 'السلاسل المتتالية';

  @override
  String get howToPlayCombosDesc =>
      'أطلق الأسهم بتعاقب سريع (خلال 1.5 ثانية) لتفعيل الكومبو. تسلسل الهروب المتواصل يبني الزخم ويضاعف النقاط.';

  @override
  String get howToPlayClassicTitle => 'النمط الكلاسيكي';

  @override
  String get howToPlayClassicDesc =>
      'تقدّم الحملة القياسي. تقدم عبر مراحل مصنوعة ومُولَّدة بحجم وأقنعة مسار متزايدة، بثلاث حيوات.';

  @override
  String get howToPlayZenTitle => 'نمط زن';

  @override
  String get howToPlayZenDesc =>
      'استرخاء خالص بلا توتر. لا حيوات تُفقد، لا حدود زمنية، لا فشل. مثالي للراحة والتدريب على اللوحات المعقدة.';

  @override
  String get howToPlayTimeAttackTitle => 'سباق الوقت';

  @override
  String get howToPlayTimeAttackDesc =>
      'سباق سريع ضد الساعة! كل سهم تهرب به يمنحك ثواني إضافية ثمينة على العداد.';

  @override
  String get howToPlayMultiplayerTitle => 'غرف متعددة اللاعبين';

  @override
  String get howToPlayMultiplayerDesc =>
      'استضف أو انضم بأكواد البذرة. يتنافس اللاعبان على نفس التخطيط العشوائي لمعرفة الأسرع في الحل.';

  @override
  String get howToPlayRandomTitle => 'ألغاز عشوائية';

  @override
  String get howToPlayRandomDesc =>
      'أنشئ ألغازًا لا نهائية عند الطلب بمستويات سهل، متوسط، صعب، ماستر، وخبير دون التأثير على تقدم الحملة.';

  @override
  String get howToPlayUnpeelTitle => 'قشّر من المحيط';

  @override
  String get howToPlayUnpeelDesc =>
      'ابدأ بمسح الحدود الخارجية. الأسهم المتجهة للخارج إلى فضاء فارغ يمكنها دائمًا الهروب فورًا، محررة مسارات حرجة.';

  @override
  String get howToPlayTraceTitle => 'تتبّع المعوّقات بالعكس';

  @override
  String get howToPlayTraceDesc =>
      'عندما يكون سهم محجوبًا، ابحث عن السهم الذي يحجبه، ثم ما يحجب ذلك السهم الثاني. تحرير المعوق الأخير يفتح كل ما خلفه.';

  @override
  String get howToPlayTapAssistTitle => 'تفعيل مساعد النقر';

  @override
  String get howToPlayTapAssistDesc =>
      'إذا كنت تلعب على شاشات صغيرة أو تنقر بين أسهم متقاربة، فعّل مساعد النقر من الإعدادات لتوجيه النقرات تلقائيًا إلى السهم الأقرب.';

  @override
  String get multiplayerTitle => 'متعدد اللاعبين';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return 'تم نسخ كود الغرفة $code إلى الحافظة!';
  }

  @override
  String get multiplayerHostRoom => 'غرفة الاستضافة';

  @override
  String get multiplayerHostBody =>
      'شارك هذا الكود مع صديق للتنافس على نفس تخطيط الألغاز!';

  @override
  String get multiplayerNewCode => 'كود جديد';

  @override
  String get multiplayerCopyCode => 'نسخ الكود';

  @override
  String get multiplayerStartMatch => 'ابدأ المباراة';

  @override
  String get multiplayerJoinRoom => 'الانضمام لغرفة';

  @override
  String get multiplayerJoinBody => 'أدخل أو الصق كود الغرفة للانضمام.';

  @override
  String get multiplayerRoomCodeHint => 'مثال ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'يرجى إدخال كود الغرفة';

  @override
  String get multiplayerJoinMatch => 'انضم';

  @override
  String get profileSyncing => 'جارٍ المزامنة...';

  @override
  String get profileSyncFailed => 'فشلت المزامنة';

  @override
  String get gameModeTimeBlitz => 'بليتز الزمن';

  @override
  String get timeBlitzDesc =>
      'انقر الأسهم لتكسب وقتًا. النقرات المحجوبة تخسر وقتًا. اصمد أطول فترة ممكنة.';

  @override
  String get profileEditName => 'تعديل الاسم';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get shareMessage => 'جرّب Arrow Puzzle — لعبة متاهة ممتعة!';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get linkCopied => 'تم نسخ الرابط';

  @override
  String get settingsShareFriends => 'شارك مع الأصدقاء';

  @override
  String get blitzTimeLeftLabel => 'الوقت المتبقي';

  @override
  String get levelSelectButton => 'المستويات';

  @override
  String levelDetailsTitle(int level) {
    return 'المستوى $level';
  }

  @override
  String get levelDetailsCompleted => 'مكتمل';

  @override
  String get levelDetailsNotPlayed => 'لم تُلعب بعد';

  @override
  String get levelDetailsStart => 'ابدأ';

  @override
  String get zenModeLabel => 'استرخِ';

  @override
  String get zenModeTitle => 'الوضع الهادئ';

  @override
  String get zenModeSubtitle => 'بدون قلوب أو مؤقتات. فقط الألغاز.';
}
