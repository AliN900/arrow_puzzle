// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppStringsId extends AppStrings {
  AppStringsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Arrow Puzzle';

  @override
  String get menuHome => 'Beranda';

  @override
  String get menuDaily => 'Harian';

  @override
  String get menuInventory => 'Inventaris';

  @override
  String get menuSettings => 'Pengaturan';

  @override
  String get menuProfile => 'Profil';

  @override
  String get menuTrophies => 'Piala';

  @override
  String get menuLeaderboard => 'Peringkat';

  @override
  String get menuContinue => 'Lanjutkan';

  @override
  String menuLevel(int level) {
    return 'Level $level';
  }

  @override
  String get buttonPlay => 'Main';

  @override
  String get buttonCancel => 'Batal';

  @override
  String get buttonConfirm => 'Konfirmasi';

  @override
  String get buttonBuy => 'Beli';

  @override
  String get buttonRestart => 'Mulai ulang';

  @override
  String get buttonResume => 'Lanjutkan';

  @override
  String get buttonExit => 'Keluar';

  @override
  String get buttonClose => 'Tutup';

  @override
  String get buttonNext => 'Level berikutnya';

  @override
  String get buttonSignIn => 'Masuk';

  @override
  String get buttonSignUp => 'Buat akun';

  @override
  String get buttonSignOut => 'Keluar';

  @override
  String get buttonDeleteAccount => 'Hapus akun';

  @override
  String get buttonClaim => 'Klaim gratis';

  @override
  String get buttonWatchAd => 'Tonton iklan';

  @override
  String get buttonAccept => 'Terima & lanjutkan';

  @override
  String get buttonShare => 'Bagikan ke teman';

  @override
  String get buttonStartBlitz => 'Mulai Blitz';

  @override
  String buttonStartRush(String tier) {
    return 'Mulai $tier';
  }

  @override
  String get gameModeClassic => 'Klasik';

  @override
  String get gameModeZen => 'Mode Zen';

  @override
  String get gameModeTimeAttack => 'Lawan Waktu';

  @override
  String get gameModeArrowRush => 'Anak Panah Cepat';

  @override
  String get gameModeBlitz => 'Blitz';

  @override
  String get gameModeMineArrows => 'Panah Ranjau';

  @override
  String get difficultyEasy => 'Mudah';

  @override
  String get difficultyHard => 'Sulit';

  @override
  String get difficultyImpossible => 'Mustahil';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsAppearance => 'TAMPILAN';

  @override
  String get settingsDarkMode => 'Mode Gelap';

  @override
  String get settingsAccentColor => 'Warna Aksen';

  @override
  String get settingsAudioHaptics => 'AUDIO & GETARAN';

  @override
  String get settingsSoundEffects => 'Efek suara';

  @override
  String get settingsMusic => 'Musik';

  @override
  String get settingsVibration => 'Getaran';

  @override
  String get settingsArrowSpeed => 'KECEPATAN PANAH';

  @override
  String get settingsAbout => 'TENTANG';

  @override
  String get settingsPrivacy => 'Kebijakan Privasi';

  @override
  String get settingsTerms => 'Syarat & Ketentuan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String settingsVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get settingsSharingComingSoon => 'Berbagi segera hadir';

  @override
  String get consentTitle => 'Selamat datang di Arrow Puzzle';

  @override
  String get consentSubtitle =>
      'Sebelum memulai, tinjau dan terima syarat kami.';

  @override
  String get consentLocalProgress =>
      'Kemajuan Anda disimpan secara lokal di perangkat.';

  @override
  String get consentCloudSync =>
      'Akun opsional menyinkronkan kemajuan ke cloud.';

  @override
  String get consentAds => 'Game menampilkan iklan agar tetap gratis.';

  @override
  String get consentAgreement =>
      'Dengan menekan di atas, Anda menyetujui Syarat & Ketentuan kami.';

  @override
  String get dialogExitTitle => 'Keluar dari game?';

  @override
  String get dialogExitMessage => 'Yakin ingin keluar?';

  @override
  String get dialogSignOutTitle => 'Keluar dari akun?';

  @override
  String get dialogSignOutMessage =>
      'Kemajuan cloud Anda tetap tersimpan. Perangkat ini akan direset ke akun tamu dari level 1.';

  @override
  String get dialogDeleteTitle => 'Hapus Akun?';

  @override
  String get dialogDeleteMessage =>
      'Ini akan menghapus akun dan kemajuan cloud Anda secara permanen. Tidak dapat dibatalkan.';

  @override
  String get profileGuest => 'Bermain sebagai tamu';

  @override
  String get profileSaveToCloud => 'Simpan ke Cloud';

  @override
  String get profileSynced => 'Tersinkron';

  @override
  String get profileSignedIn => 'Masuk';

  @override
  String get profileStatsLevel => 'Level';

  @override
  String get profileStatsStars => 'Bintang';

  @override
  String get profileStatsTrophies => 'Piala';

  @override
  String get dailyRewardsTitle => 'HADIAH HARIAN';

  @override
  String dailyRewardsDay(int day, int max) {
    return 'Hari $day dari $max';
  }

  @override
  String get dailyRewardsComeBack => 'Kembali besok';

  @override
  String get dailyRewardsClaimed => 'Sudah diklaim hari ini!';

  @override
  String get levelComplete => 'Level Selesai!';

  @override
  String get levelFailed => 'Nyawa habis!';

  @override
  String get levelTimeUp => 'Waktu habis!';

  @override
  String get gameOverRestart => 'Mulai ulang level';

  @override
  String get gameOverHome => 'Beranda';

  @override
  String get blitzTitle => 'Blitz';

  @override
  String get blitzStage => 'TAHAP';

  @override
  String get blitzComplete => 'Blitz Selesai!';

  @override
  String get blitzOver => 'Blitz Berakhir';

  @override
  String get blitzFinalScore => 'SKOR AKHIR';

  @override
  String blitzSurvivedAll(int count) {
    return 'Anda melewati semua $count tahap.';
  }

  @override
  String blitzClearedOf(int cleared, int total) {
    return 'Menyelesaikan $cleared dari $total tahap.';
  }

  @override
  String get commonComingSoon => 'Segera hadir';

  @override
  String get commonLoading => 'Memuat...';

  @override
  String get commonError => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get dailyRewardsClaimFree => 'Klaim gratis';

  @override
  String get dailyRewardsWatchAd => 'Tonton iklan';

  @override
  String get dailyRewardsSnackClaimed => 'Diklaim!';

  @override
  String get dailyRewardsClaimedToday => 'Sudah diklaim hari ini!';

  @override
  String dailyRewardsNextIn(String time) {
    return 'Hadiah berikutnya dalam $time';
  }

  @override
  String get unlockTitle => 'Selamat!';

  @override
  String get unlockSubtitle => 'Papan baru terbuka';

  @override
  String get unlockAddedToInventory => 'Ditambahkan ke inventaris Anda';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count KOIN';
  }

  @override
  String get buttonCheckInventory => 'Cek inventaris';

  @override
  String get buttonMainMenu => 'Menu utama';

  @override
  String get dailyChallengesTitle => 'Tantangan Harian';

  @override
  String get dailyChallengesSubtitle =>
      'Selesaikan mode khusus untuk mendapatkan hadiah bonus.';

  @override
  String get dailyRewardsSubtitle => 'Klaim hadiah rentetanmu';

  @override
  String get activeChallengesTitle => 'Tantangan Aktif';

  @override
  String get blitzSubtitle =>
      'Lewati rentetan level. Waktu semakin ketat. Nyawa terus berlanjut.';

  @override
  String get badgeNew => 'BARU';

  @override
  String get mineArrowsTitle => 'Panah Ranjau';

  @override
  String get mineArrowsSubtitle =>
      'Bersihkan panah sambil menghindari ranjau tersembunyi!';

  @override
  String get badgeComingSoon => 'SEGERA';

  @override
  String get mineArrowsComingSoonSnack =>
      'Tantangan Panah Ranjau akan segera hadir!';

  @override
  String get dailyRewardsLabel => 'HADIAH HARIAN';

  @override
  String dayOfMax(int day, int max) {
    return 'Hari $day dari $max';
  }

  @override
  String get comeBackTomorrow => 'Kembali besok';

  @override
  String plusCoins(int count) {
    return '+$count koin';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'Klaim gratis';

  @override
  String get loadingLabel => 'Memuat...';

  @override
  String watchAdCoins(int coins) {
    return 'Tonton iklan → +$coins koin';
  }

  @override
  String get notNow => 'Nanti saja';

  @override
  String get claimedToday => 'Sudah diklaim hari ini!';

  @override
  String nextRewardIn(String time) {
    return 'Hadiah berikutnya dalam $time';
  }

  @override
  String get closeLabel => 'Tutup';

  @override
  String get claimedSnack => 'Diklaim!';

  @override
  String get arrowRushTitle => 'Arrow Rush';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return 'Capai level $level untuk membuka $tier';
  }

  @override
  String startTier(String tier) {
    return 'Mulai $tier';
  }

  @override
  String lvLabel(int level) {
    return 'Lv $level';
  }

  @override
  String get adNotAvailable => 'Iklan tidak tersedia, coba lagi nanti';

  @override
  String get adBadge => 'AD';

  @override
  String get homeButton => 'Beranda';

  @override
  String get gameOverTimeUp => 'Waktu Habis!';

  @override
  String get gameOverOutOfTime => 'Kehabisan Waktu!';

  @override
  String get gameOverOutOfLives => 'Kehabisan Nyawa!';

  @override
  String gameOverRewardTime(int seconds) {
    return '+${seconds}d';
  }

  @override
  String gameOverRewardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count nyawa',
      one: '+$count nyawa',
    );
    return '$_temp0';
  }

  @override
  String gameOverTimeAttackStats(int cleared, int level) {
    return 'Puzzle Selesai: $cleared\nLevel Akhir: $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'Tonton iklan → $reward';
  }

  @override
  String get gameOverStartNewRun => 'Mulai Ronde Baru';

  @override
  String get gameOverRestartLevel => 'Ulangi Level';

  @override
  String get levelCompleteTitle => 'Level Selesai!';

  @override
  String get levelCompleteNewTrophy => 'TROFI BARU';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count ITEM ACAK',
      one: '+$count ITEM ACAK',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => 'Kamu Menyelesaikan Game!';

  @override
  String get levelCompleteNextLevel => 'Level Berikutnya';

  @override
  String get levelCompleteCoinsDoubled => 'Koin Berlipat!';

  @override
  String get levelCompleteDoubleCoins => 'Gandakan Koin';

  @override
  String get pauseTitle => 'Jeda';

  @override
  String get pauseResume => 'Lanjutkan';

  @override
  String get pauseRestart => 'Ulangi';

  @override
  String get pauseMainMenu => 'Menu Utama';

  @override
  String get itemBombName => 'Bom';

  @override
  String get itemBombDesc => 'Hancurkan satu batu';

  @override
  String get itemHintName => 'Petunjuk';

  @override
  String get itemHintDesc =>
      'Tampilkan panah berikutnya yang bisa diselesaikan';

  @override
  String get itemUndoName => 'Batalkan';

  @override
  String get itemUndoDesc => 'Kembalikan panah terakhir yang keluar';

  @override
  String get itemHeartFlaskName => 'Botol Nyawa';

  @override
  String get itemHeartFlaskDesc => 'Pulihkan satu nyawa';

  @override
  String get itemTimeFreezeName => 'Bekukan Waktu';

  @override
  String get itemTimeFreezeDesc => 'Tambah 30 detik ke pengatur waktu';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeClassic => 'Klasik';

  @override
  String get themeRetro => 'Retro';

  @override
  String get themeCyber => 'Cyber';

  @override
  String get themeHacker => 'Hacker';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeBlueprint => 'Cetak Biru';

  @override
  String get themeForest => 'Hutan';

  @override
  String get themePastel => 'Pastel';

  @override
  String get themeSunset => 'Senja';

  @override
  String get themeRainbow => 'Pelangi';

  @override
  String get boardMinimal => 'Minimalis';

  @override
  String get boardNebula => 'Nebula';

  @override
  String get boardBlueprint => 'Cetak Biru';

  @override
  String get boardForest => 'Hutan';

  @override
  String get boardOcean => 'Samudra';

  @override
  String get boardEmber => 'Bara';

  @override
  String get boardCosmic => 'Kosmik';

  @override
  String get boardGeometric => 'Geometris';

  @override
  String get boardGold => 'Emas';

  @override
  String get boardHacker => 'Hacker';

  @override
  String get boardPaper => 'Kertas';

  @override
  String get boardIce => 'Es';

  @override
  String get boardSand => 'Pasir';

  @override
  String get boardCloud => 'Awan';

  @override
  String get boardMint => 'Mint';

  @override
  String get boardRose => 'Mawar';

  @override
  String get boardLavender => 'Lavender';

  @override
  String get boardSky => 'Langit';

  @override
  String get boardPearl => 'Mutiara';

  @override
  String get boardHoney => 'Madu';

  @override
  String get trophyFirstEscapeTitle => '🌟 KEBANGKITAN PERTAMA';

  @override
  String get trophyFirstEscapeDesc =>
      'Labirin pertamamu berhasil dilewati! Kamu telah membuka gerbang ke Sistem Trofi. Selamat datang di perjalanan puzzle terbaik dari AHB.Dev!';

  @override
  String get trophyPointBlankTitle => 'Jarak Dekat';

  @override
  String get trophyPointBlankDesc =>
      'Berhasil selesaikan tata letak puzzle pertamamu dengan presisi.';

  @override
  String get trophyTrialOfTwoTitle => 'Ujian Dua';

  @override
  String get trophyTrialOfTwoDesc =>
      'Taklukkan batasan dua nyawa yang menantang di ujian awal.';

  @override
  String get trophyQuickThinkerTitle => 'Pemikir Cepat';

  @override
  String get trophyQuickThinkerDesc =>
      'Selesaikan level apa pun dengan cepat di bawah ambang batas 20 detik yang diperlonggar.';

  @override
  String get trophyArrowSmithTitle => 'Pandai Panah';

  @override
  String get trophyArrowSmithDesc =>
      'Selesaikan 10 level tanpa menyerah atau mengulang.';

  @override
  String get trophyCleanSlateTitle => 'Lembaran Bersih';

  @override
  String get trophyCleanSlateDesc =>
      'Selesaikan level tanpa satu pun ketukan panah yang terblokir.';

  @override
  String get trophySparkOfGeniusTitle => 'Percikan Jenius';

  @override
  String get trophySparkOfGeniusDesc =>
      'Gunakan petunjuk pertamamu untuk menemukan jalan dari situasi sulit.';

  @override
  String get trophyUnwindTitle => 'Tenang';

  @override
  String get trophyUnwindDesc =>
      'Gunakan batalkan pertamamu untuk memperbaiki kesalahan langkah.';

  @override
  String get trophyRockBreakerTitle => 'Pemecah Batu';

  @override
  String get trophyRockBreakerDesc =>
      'Ledakkan rintangan batu pertamamu menggunakan panah bom taktis.';

  @override
  String get trophySurvivalistBadgeTitle => 'Sang Penyintas';

  @override
  String get trophySurvivalistBadgeDesc =>
      'Taklukkan 25 ujian pertama! Tingkatkan nyawa maksimummu secara permanen dari 2 ke 3.';

  @override
  String get trophyWayfinderTitle => 'Penunjuk Jalan';

  @override
  String get trophyWayfinderDesc =>
      'Capai level 50 dan buktikan penguasaanmu atas labirin awal.';

  @override
  String get trophyTangleTamerTitle => 'Penjinak Kusut';

  @override
  String get trophyTangleTamerDesc =>
      'Selesaikan 10 level berturut-turut tanpa satu pun kesalahan arah.';

  @override
  String get trophyTimeLordTitle => 'Penguasa Waktu';

  @override
  String get trophyTimeLordDesc =>
      'Bertahanlah dalam ujian berwaktu tingkat dewa dengan sisa detik.';

  @override
  String get trophyCenturyMarkTitle => 'Tanda Seratus';

  @override
  String get trophyCenturyMarkDesc =>
      'Capai level 100 — seperlima jalan menuju puncak 500!';

  @override
  String get trophyBombTechnicianTitle => 'Teknisi Bom';

  @override
  String get trophyBombTechnicianDesc =>
      'Hancurkan 25 batu di seluruh kampanyemu menggunakan bom taktis.';

  @override
  String get trophyUntouchableTitle => 'Tak Tersentuh';

  @override
  String get trophyUntouchableDesc =>
      'Selesaikan 5 level berturut-turut tanpa kehilangan satu nyawa pun.';

  @override
  String get trophyStargazerTitle => 'Pengamat Bintang';

  @override
  String get trophyStargazerDesc =>
      'Dapatkan 3 bintang di 30 papan puzzle berbeda.';

  @override
  String get trophyMasterOfAnglesTitle => 'Ahli Sudut';

  @override
  String get trophyMasterOfAnglesDesc =>
      'Selesaikan puzzle rumit yang banyak menampilkan titik pengalih yatim.';

  @override
  String get trophyHalfwayToGloryTitle => 'Separuh Menuju Kejayaan';

  @override
  String get trophyHalfwayToGloryDesc =>
      'Capai level 125, menegaskan dominasimu di pertengahan permainan.';

  @override
  String get trophyTheStrategistTitle => 'Sang Strategi';

  @override
  String get trophyTheStrategistDesc =>
      'Gunakan semua item yang tersedia setidaknya sekali dalam satu sesi.';

  @override
  String get trophyQuickSilverTitle => 'Air Raksa';

  @override
  String get trophyQuickSilverDesc =>
      'Kumpulkan 5 menit permainan cepat di mode Time Attack.';

  @override
  String get trophyIronWillTitle => 'Kemauan Besi';

  @override
  String get trophyIronWillDesc =>
      'Menangkan level bos setelah turun ke nyawa terakhirmu.';

  @override
  String get trophyGoldenTouchTitle => 'Sentuhan Emas';

  @override
  String get trophyGoldenTouchDesc =>
      'Buka papan atau tema panah kustom pertamamu.';

  @override
  String get trophyDeepDiverTitle => 'Penyelam Dalam';

  @override
  String get trophyDeepDiverDesc =>
      'Capai level 150 saat labirin tumbuh semakin rumit secara eksponensial.';

  @override
  String get trophyThePuzzlerTitle => 'Sang Peneka';

  @override
  String get trophyThePuzzlerDesc =>
      'Selesaikan 50 papan puzzle yang dihasilkan secara prosedural.';

  @override
  String get trophySharpShooterTitle => 'Penembak Jitu';

  @override
  String get trophySharpShooterDesc =>
      'Selesaikan 20 level dengan langkah seminimal mungkin.';

  @override
  String get trophyVaultKeeperTitle => 'Penjaga Gudang';

  @override
  String get trophyVaultKeeperDesc =>
      'Kumpulkan total 500 koin dari permainan dan hadiah iklan.';

  @override
  String get trophyMilestoneMasterTitle => 'Master Tonggak';

  @override
  String get trophyMilestoneMasterDesc =>
      'Capai level 200 — dua per lima jalan menuju maksimum 500.';

  @override
  String get trophyBossSlayerTitle => 'Pembunuh Bos';

  @override
  String get trophyBossSlayerDesc =>
      'Kalahkan 8 level bos berturut-turut tanpa satu pun kekalahan.';

  @override
  String get trophyTimeBenderTitle => 'Pembengkok Waktu';

  @override
  String get trophyTimeBenderDesc =>
      'Bekukan waktu dengan sukses 10 kali di level hitung mundur yang intens.';

  @override
  String get trophyResilientSpiritTitle => 'Semangat Tangguh';

  @override
  String get trophyResilientSpiritDesc =>
      'Pulih dari kondisi game over menggunakan hadiah lanjutan iklan.';

  @override
  String get trophyBoardCollectorTitle => 'Kolektor Papan';

  @override
  String get trophyBoardCollectorDesc =>
      'Buka 5 tema papan kustom berbeda untuk koleksimu.';

  @override
  String get trophyApexPredatorTitle => 'Predator Puncak';

  @override
  String get trophyApexPredatorDesc =>
      'Capai level 250 — puncak separuh dari kampanye puzzle saat ini.';

  @override
  String get trophyFlawlessExecutionTitle => 'Eksekusi Sempurna';

  @override
  String get trophyFlawlessExecutionDesc =>
      'Dapatkan 3 bintang di 100 level terpisah.';

  @override
  String get trophyTacticalMindsetTitle => 'Pola Pikir Taktis';

  @override
  String get trophyTacticalMindsetDesc =>
      'Selesaikan puzzle tingkat dewa tanpa mengandalkan petunjuk apa pun.';

  @override
  String get trophyDailyDevoteeTitle => 'Pemuja Harian';

  @override
  String get trophyDailyDevoteeDesc =>
      'Pertahankan rentetan login 7 hari di pelacak hadiah harianmu.';

  @override
  String get trophyMonumentalPioneerTitle => 'Pionir Monumental';

  @override
  String get trophyMonumentalPioneerDesc =>
      'Buka trofi monumental prestise pertamamu yang murni dekoratif.';

  @override
  String get trophyHighClimberTitle => 'Sang Pendaki';

  @override
  String get trophyHighClimberDesc =>
      'Capai level 300 — tiga per lima jalan menuju puncak 500.';

  @override
  String get trophyGrandmasterTitle => 'Grandmaster';

  @override
  String get trophyGrandmasterDesc =>
      'Capai level 350, taklukkan kusutan grid paling rumit.';

  @override
  String get trophyEternalFlameTitle => 'Api Abadi';

  @override
  String get trophyEternalFlameDesc =>
      'Pertahankan rentetan login 14 hari berturut-turut yang luar biasa.';

  @override
  String get trophyIroncladTitle => 'Berlapis Baja';

  @override
  String get trophyIroncladDesc =>
      'Capai level 400 — empat per lima jalan menuju puncak tertinggi.';

  @override
  String get trophyPerfectionistTitle => 'Perfeksionis';

  @override
  String get trophyPerfectionistDesc =>
      'Dapatkan 3 bintang di setiap level dari 1 hingga 400.';

  @override
  String get trophyTitanOfTheMazeTitle => 'Titan Labirin';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'Capai level 450, berdiri di antara para pemecah puzzle elit.';

  @override
  String get trophyThe500ClubTitle => 'Klub 500';

  @override
  String get trophyThe500ClubDesc =>
      'Capai level 500, puncak maksimum grid puzzle saat ini!';

  @override
  String get trophyLivingLegendTitle => 'Legenda Hidup';

  @override
  String get trophyLivingLegendDesc =>
      'Selesaikan level 500 dengan rating 3 bintang dan tanpa kesalahan.';

  @override
  String get trophyMonumentOfTimeTitle => 'Monumen Waktu';

  @override
  String get trophyMonumentOfTimeDesc =>
      'Artefak monumental prestise karena mendedikasikan lebih dari 10 jam aktif untuk melarikan diri dari labirin.';

  @override
  String get trophyAbsoluteVoidTitle => 'Kekosongan Mutlak';

  @override
  String get trophyAbsoluteVoidDesc =>
      'Trofi monumental prestise hitam pekat yang diberikan karena memaksimalkan fitur progresi utama.';

  @override
  String get trophyInfiniteHorizonTitle => 'Cakrawala Tak Terbatas';

  @override
  String get trophyInfiniteHorizonDesc =>
      'Trofi monumental pengakuan bahwa perjalanan melampaui level 500 tidak pernah berakhir.';

  @override
  String timeBonusAmount(int seconds) {
    return '+${seconds}d';
  }

  @override
  String get heartsAlreadyFull => 'Nyawa sudah penuh';

  @override
  String timeFreezeWait(int seconds) {
    return 'Tunggu ${seconds}d lagi sebelum menggunakan Bekukan Waktu';
  }

  @override
  String get tapRockToDestroy => 'Ketuk batu untuk menghancurkannya';

  @override
  String get noSolvableArrowFound => 'Tidak ada panah yang bisa diselesaikan';

  @override
  String get nothingToUndo => 'Tidak ada yang bisa dibatalkan';

  @override
  String get blitzCompleteTitle => 'Blitz Selesai!';

  @override
  String get blitzOverTitle => 'Blitz Berakhir';

  @override
  String get blitzSplashStage => 'TAHAP';

  @override
  String blitzPoints(int score) {
    return '$score poin';
  }

  @override
  String get arrowSpeedEscapeSpeed => 'Kecepatan kabur';

  @override
  String get arrowSpeedSlow => 'Lambat';

  @override
  String get arrowSpeedNormal => 'Normal';

  @override
  String get arrowSpeedFast => 'Cepat';

  @override
  String get accentColorLabel => 'Warna Aksen';

  @override
  String get settingsPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get settingsTermsConditions => 'Syarat & Ketentuan';

  @override
  String get settingsChooseLanguage => 'Pilih Bahasa';

  @override
  String settingsVersionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String get languageSystemDefault => 'Default sistem';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageSpanish => 'Spanyol';

  @override
  String get languagePortugueseBR => 'Portugis (BR)';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Arab';

  @override
  String get languageFrench => 'Prancis';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'Trofi ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'Lv $level';
  }

  @override
  String get trophiesPerkHeart => '✨ Perk: +1 Nyawa Maksimum Permanen';

  @override
  String get leaderboardTitle => 'Papan Peringkat';

  @override
  String get leaderboardTabWeekly => 'Mingguan';

  @override
  String get leaderboardTabMonthly => 'Bulanan';

  @override
  String get leaderboardTabAllTime => 'Sepanjang Masa';

  @override
  String get leaderboardYourRank => 'Peringkat Anda';

  @override
  String get leaderboardNotRanked => 'Belum diperingkat';

  @override
  String get leaderboardSignInToRank => 'Masuk untuk muncul di papan';

  @override
  String get leaderboardEmptyState => 'Belum ada skor';

  @override
  String get leaderboardScore => 'Skor';

  @override
  String get leaderboardLevel => 'Level';

  @override
  String get leaderboardStars => 'Bintang';

  @override
  String get leaderboardTrophies => 'Trofi';

  @override
  String get leaderboardYou => 'Anda';

  @override
  String get leaderboardRankPrefix => '#';

  @override
  String get leaderboardOptInTitle => 'Tampilkan di papan peringkat';

  @override
  String get leaderboardOptInSubtitle =>
      'Biarkan pemain lain melihat peringkat Anda';

  @override
  String get inventoryTitle => 'Inventaris';

  @override
  String get inventoryTabArrows => 'Panah';

  @override
  String get inventoryTabBoards => 'Papan';

  @override
  String get inventoryTabItems => 'Item';

  @override
  String get inventoryEquipped => 'Terpasang';

  @override
  String get inventoryTapToEquip => 'Ketuk untuk pasang';

  @override
  String inventoryReachLevel(int level) {
    return 'Capai level $level untuk membuka';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'Lv $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return 'Butuh $count koin lagi';
  }

  @override
  String inventoryBuyItemTitle(String item) {
    return 'Beli $item?';
  }

  @override
  String inventoryUnlockTitle(String title) {
    return 'Buka $title?';
  }

  @override
  String inventoryCoinsPrice(int count) {
    return '$count koin';
  }

  @override
  String get inventoryBuy => 'Beli';

  @override
  String get rushDifficultyEasy => 'Mudah';

  @override
  String get rushDifficultyHard => 'Sulit';

  @override
  String get rushDifficultyImpossible => 'Mustahil';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePlayingAsGuest => 'Bermain sebagai tamu';

  @override
  String get profileSignInSuccess => 'Masuk — progres tersinkron';

  @override
  String profileSignInFailed(String error) {
    return 'Gagal masuk: $error';
  }

  @override
  String get profileSaveYourProgress => 'Simpan progresmu';

  @override
  String get profileGuestBody =>
      'Akun tamu hanya ada di perangkat ini. Masuk untuk mencadangkan level, koin, dan trofimu.';

  @override
  String get profileContinueWithEmail => 'Lanjutkan dengan Email';

  @override
  String get profileSignOutTitle => 'Keluar?';

  @override
  String get profileSignOutBody =>
      'Simpanan cloud-mu tetap ada. Perangkat ini akan direset ke akun tamu baru dan mulai dari level 1.';

  @override
  String get profileCancel => 'Batal';

  @override
  String get profileSignOut => 'Keluar';

  @override
  String get profileDeleteAccountTitle => 'Hapus Akun?';

  @override
  String get profileDeleteAccountBody =>
      'Ini akan menghapus simpanan cloud dan akunmu secara permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get profileDelete => 'Hapus';

  @override
  String profileDeleteFailed(String error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'Gagal keluar: $error';
  }

  @override
  String get profileSignedInBody =>
      'Progresmu dicadangkan ke cloud. Masuk di perangkat mana pun dengan akun yang sama untuk melanjutkan.';

  @override
  String get profileDeleteAccount => 'Hapus Akun';

  @override
  String get profileStatLevel => 'Level';

  @override
  String get profileStatStars => 'Bintang';

  @override
  String get profileStatTrophies => 'Trofi';

  @override
  String get profileTabSignIn => 'Masuk';

  @override
  String get profileTabCreateAccount => 'Buat Akun';

  @override
  String get profileCreateAccountTitle => 'Buat akunmu';

  @override
  String get profileWelcomeBack => 'Selamat datang kembali';

  @override
  String get profileGuestProgressCarries => 'Progres tamumu akan dipindahkan.';

  @override
  String get profileSignInRestoreBody =>
      'Masuk untuk memulihkan progresmu dari perangkat lain.';

  @override
  String get profileNameHint => 'Nama (opsional)';

  @override
  String get profileEmailHint => 'Email';

  @override
  String get profilePasswordHint => 'Kata sandi';

  @override
  String get profileShowPassword => 'Tampilkan kata sandi';

  @override
  String get profileHidePassword => 'Sembunyikan kata sandi';

  @override
  String get profileGeneratePassword => 'Buat kata sandi';

  @override
  String get profilePasswordMinLength => 'Kata sandi harus minimal 8 karakter.';

  @override
  String get profileStrengthTooShort => 'Terlalu pendek';

  @override
  String get profileStrengthOkay => 'Cukup';

  @override
  String get profileStrengthGood => 'Bagus';

  @override
  String get profileStrengthStrong => 'Kuat';

  @override
  String get profileErrorEmailSignUp =>
      'Email itu sudah terdaftar. Coba Masuk.';

  @override
  String get profileErrorEmailSignIn =>
      'Email itu sudah terdaftar. Periksa kata sandimu atau reset dari tautan email.';

  @override
  String get profileErrorInvalidCredentials =>
      'Email atau kata sandi salah. Coba lagi.';

  @override
  String get profileErrorPassword =>
      'Kata sandi tidak diterima. Gunakan 8+ karakter dengan huruf dan angka, dan hindari kata umum seperti \"password\".';

  @override
  String get profileErrorInvalidEmail => 'Alamat email itu tidak valid.';

  @override
  String get profileErrorSessionExpired =>
      'Sesi berakhir. Tutup aplikasi, buka lagi, dan coba lagi.';

  @override
  String get profileErrorRateLimit =>
      'Terlalu banyak percobaan. Tunggu satu menit dan coba lagi.';

  @override
  String get profileErrorServerBusy => 'Server sibuk. Coba lagi sebentar.';

  @override
  String get profileErrorSignUpGeneric =>
      'Pendaftaran gagal. Periksa datamu dan coba lagi.';

  @override
  String get profileErrorSignInGeneric =>
      'Masuk gagal. Periksa email dan kata sandimu.';

  @override
  String get profileEnterValidEmail => 'Masukkan alamat email yang valid.';

  @override
  String get profileEnterPassword => 'Masukkan kata sandimu.';

  @override
  String get profileEmailAlreadyPrompt =>
      'Email itu sudah memiliki akun. Masukkan kata sandimu untuk masuk.';

  @override
  String get profileSomethingWrong => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get profileCreateAccountButton => 'Buat akun';

  @override
  String get profileSignInButton => 'Masuk';

  @override
  String get profileAlreadyHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get profileDontHaveAccount => 'Belum punya akun? Buat sekarang';

  @override
  String get homePlayer => 'Pemain';

  @override
  String homeLevelStars(int level, int stars) {
    return 'Level $level · $stars bintang';
  }

  @override
  String get homeContinueLabel => 'LANJUTKAN';

  @override
  String homeLevelNumber(int level) {
    return 'Level $level';
  }

  @override
  String get homeContinue => 'Lanjutkan';

  @override
  String get homeDaily => 'Harian';

  @override
  String get homeDailyReady => 'Siap dimainkan';

  @override
  String get homeDailyClaimed => 'Sudah diklaim hari ini';

  @override
  String get homeLeaderboard => 'Peringkat';

  @override
  String get homeComingSoon => 'Segera hadir';

  @override
  String get homeInventory => 'Inventaris';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'Semua terbuka · $count item';
  }

  @override
  String get homeInventoryBrowse => 'Jelajahi perlengkapanmu';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items item';
  }

  @override
  String get homeTrophies => 'Trofi';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$unlocked dari $total';
  }

  @override
  String get privacyWelcomeTitle => 'Selamat datang di Arrow Puzzle';

  @override
  String get privacyWelcomeSubtitle =>
      'Sebelum memulai, tinjau dan setujui ketentuan kami.';

  @override
  String get privacyBulletLocal =>
      'Progresmu disimpan secara lokal di perangkatmu.';

  @override
  String get privacyBulletCloud =>
      'Akun opsional menyinkronkan progres ke cloud.';

  @override
  String get privacyBulletAds => 'Game menampilkan iklan agar tetap gratis.';

  @override
  String get privacyPolicyLink => 'Kebijakan Privasi';

  @override
  String get privacyTermsLink => 'Syarat & Ketentuan';

  @override
  String get privacyAcceptButton => 'Setujui & Lanjutkan';

  @override
  String get privacyAgreeFooter =>
      'Dengan mengetuk di atas, kamu menyetujui Syarat & Ketentuan kami.';

  @override
  String get bottomNavHome => 'Beranda';

  @override
  String get bottomNavDaily => 'Harian';

  @override
  String get bottomNavInventory => 'Inventaris';

  @override
  String get bottomNavSettings => 'Pengaturan';

  @override
  String gameTopBarScore(int score) {
    return 'Skor: $score';
  }

  @override
  String get gameTopBarRandom => 'Acak';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'Lv.$level';
  }

  @override
  String get gameModeZenMode => 'Mode Zen';

  @override
  String get howToPlayTitle => 'CARA BERMAIN';

  @override
  String get howToPlayBasics => 'DASAR-DASAR';

  @override
  String get howToPlayBoardElements => 'ELEMEN PAPAN';

  @override
  String get howToPlayGameModes => 'MODE PERMAINAN';

  @override
  String get howToPlayProStrategies => 'STRATEGI PRO';

  @override
  String get howToPlayCoreTitle => 'Tujuan Utama';

  @override
  String get howToPlayCoreDesc =>
      'Tujuanmu adalah membersihkan seluruh grid dengan mengarahkan setiap panah keluar papan. Saat tidak ada panah tersisa, level selesai.';

  @override
  String get howToPlayMovementTitle => 'Pergerakan Panah';

  @override
  String get howToPlayMovementDesc =>
      'Ketuk panah mana pun untuk meluncurkannya. Panah meluncur ke arah tepat ujungnya: atas, bawah, kiri, atau kanan. Meskipun badannya bengkok, panah selalu keluar mengikuti ujungnya.';

  @override
  String get howToPlayObstaclesTitle => 'Rintangan & Tabrakan';

  @override
  String get howToPlayObstaclesDesc =>
      'Panah hanya bisa keluar jika seluruh jalur keluarnya benar-benar bersih. Jika ada panah lain menghalangi, panah yang diketuk akan bergetar dan tetap di tempat.';

  @override
  String get howToPlayLivesTitle => 'Nyawa & Kesehatan';

  @override
  String get howToPlayLivesDesc =>
      'Di mode Klasik, kamu mulai dengan 3 nyawa. Mengetuk panah yang terhalang mengurangi 1 nyawa. Jika habis, ulangi level. Kamu bisa mengaktifkan Nyawa Tak Terbatas di Pengaturan.';

  @override
  String get howToPlayTurnDotsTitle => 'Titik Belok (Pengalih)';

  @override
  String get howToPlayTurnDotsDesc =>
      'Cari titik melingkar di sel kosong bertanda panah kecil. Saat panah yang meluncur melewati Titik Belok, ia langsung berbelok sesuai arah titik dan menghabiskannya, membuka rute keluar yang tak terduga.';

  @override
  String get howToPlayCombosTitle => 'Kombo & Rentetan';

  @override
  String get howToPlayCombosDesc =>
      'Lepaskan panah secara berurutan cepat (dalam 1,5 detik) untuk memicu kombo. Rentetan kabur berturut-turut menambah momentum dan skor berlipat.';

  @override
  String get howToPlayClassicTitle => 'Mode Klasik';

  @override
  String get howToPlayClassicDesc =>
      'Progresi kampanye standar. Lewati tahap buatan tangan dan prosedural dengan ukuran, topeng bentuk, dan kerumitan jalur yang meningkat, dengan 3 nyawa.';

  @override
  String get howToPlayZenTitle => 'Mode Zen';

  @override
  String get howToPlayZenDesc =>
      'Relaksasi murni tanpa stres. Tanpa nyawa hilang, tanpa batas waktu, tanpa kegagalan. Ideal untuk bersantai dan berlatih papan rumit.';

  @override
  String get howToPlayTimeAttackTitle => 'Time Attack';

  @override
  String get howToPlayTimeAttackDesc =>
      'Balapan cepat melawan waktu! Setiap panah yang berhasil keluar memberi detik bonus ke penghitung mundurmu.';

  @override
  String get howToPlayMultiplayerTitle => 'Ruang Multipemain';

  @override
  String get howToPlayMultiplayerDesc =>
      'Buat atau gabung dengan kode seed ruangan. Kedua pemain bersaing di tata letak acak yang sama untuk melihat siapa yang menyelesaikan lebih cepat.';

  @override
  String get howToPlayRandomTitle => 'Puzzle Acak';

  @override
  String get howToPlayRandomDesc =>
      'Hasilkan puzzle tanpa batas sesuai permintaan di tingkat Mudah, Sedang, Sulit, Master, dan Ahli tanpa memengaruhi progres kampanyemu.';

  @override
  String get howToPlayUnpeelTitle => 'Kupas dari Tepi';

  @override
  String get howToPlayUnpeelDesc =>
      'Mulai dengan memindai tepi luar. Panah yang menunjuk ke luar ke ruang kosong selalu bisa langsung keluar, membebaskan jalur penting.';

  @override
  String get howToPlayTraceTitle => 'Lacak Penghalang Terbalik';

  @override
  String get howToPlayTraceDesc =>
      'Saat panah terhalang, temukan panah mana yang menghalanginya, lalu apa yang menghalangi panah kedua itu. Membuka penghalang terakhir akan membebaskan semua di belakangnya.';

  @override
  String get howToPlayTapAssistTitle => 'Aktifkan Bantuan Ketuk';

  @override
  String get howToPlayTapAssistDesc =>
      'Jika bermain di layar kecil atau sering mengetuk di antara panah yang berdekatan, aktifkan Bantuan Ketuk di Pengaturan untuk memetakan ketukan otomatis ke panah terdekat.';

  @override
  String get multiplayerTitle => 'MULTIPEMAIN';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return 'Kode ruangan $code disalin ke papan klip!';
  }

  @override
  String get multiplayerHostRoom => 'RUANG HOST';

  @override
  String get multiplayerHostBody =>
      'Bagikan kode ini ke temanmu untuk bersaing di tata letak puzzle yang sama!';

  @override
  String get multiplayerNewCode => 'Kode Baru';

  @override
  String get multiplayerCopyCode => 'Salin Kode';

  @override
  String get multiplayerStartMatch => 'MULAI PERTANDINGAN';

  @override
  String get multiplayerJoinRoom => 'GABUNG RUANG';

  @override
  String get multiplayerJoinBody =>
      'Masukkan atau tempel kode ruangan untuk bergabung.';

  @override
  String get multiplayerRoomCodeHint => 'mis. ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'Masukkan kode ruangan';

  @override
  String get multiplayerJoinMatch => 'GABUNG';

  @override
  String get zenCardSubtitle => 'Tanpa waktu. Tanpa batas. Selesaikan saja.';

  @override
  String get profileSyncing => 'Menyinkronkan...';

  @override
  String get profileSyncFailed => 'Gagal menyinkronkan';

  @override
  String get gameModeTimeBlitz => 'Time Blitz';

  @override
  String get timeBlitzDesc =>
      'Ketuk panah untuk menambah waktu. Ketukan terblokir mengurangi waktu. Bertahanlah selama mungkin.';

  @override
  String get timeBlitzOverTitle => 'Time Blitz Berakhir';

  @override
  String get timeBlitzScoreLabel => 'PANAH DIHABISKAN';

  @override
  String get timeBlitzLevelsLabel => 'Level dicapai';

  @override
  String get profileEditName => 'Ubah Nama';

  @override
  String get profileSave => 'Simpan';

  @override
  String get profileUpdated => 'Profil diperbarui';

  @override
  String get shareMessage => 'Coba Arrow Puzzle — game labirin yang seru!';

  @override
  String get copyLink => 'Salin Tautan';

  @override
  String get linkCopied => 'Tautan disalin';

  @override
  String get settingsShareFriends => 'Bagikan ke teman';

  @override
  String get settingsSharingSoon => 'Segera hadir';
}
