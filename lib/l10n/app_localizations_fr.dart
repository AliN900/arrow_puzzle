// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppStringsFr extends AppStrings {
  AppStringsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Arrow Puzzle';

  @override
  String get menuHome => 'Accueil';

  @override
  String get menuDaily => 'Quotidien';

  @override
  String get menuInventory => 'Inventaire';

  @override
  String get menuSettings => 'Paramètres';

  @override
  String get menuProfile => 'Profil';

  @override
  String get menuTrophies => 'Trophées';

  @override
  String get menuLeaderboard => 'Classement';

  @override
  String get menuContinue => 'Continuer';

  @override
  String menuLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get buttonPlay => 'Jouer';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonConfirm => 'Confirmer';

  @override
  String get buttonBuy => 'Acheter';

  @override
  String get buttonRestart => 'Redémarrer';

  @override
  String get buttonResume => 'Reprendre';

  @override
  String get buttonExit => 'Quitter';

  @override
  String get buttonClose => 'Fermer';

  @override
  String get buttonNext => 'Niveau suivant';

  @override
  String get buttonSignIn => 'Se connecter';

  @override
  String get buttonSignUp => 'Créer un compte';

  @override
  String get buttonSignOut => 'Se déconnecter';

  @override
  String get buttonDeleteAccount => 'Supprimer le compte';

  @override
  String get buttonClaim => 'Réclamer gratuitement';

  @override
  String get buttonWatchAd => 'Regarder une pub';

  @override
  String get buttonAccept => 'Accepter et continuer';

  @override
  String get buttonShare => 'Partager avec des amis';

  @override
  String get buttonStartBlitz => 'Démarrer Blitz';

  @override
  String buttonStartRush(String tier) {
    return 'Démarrer $tier';
  }

  @override
  String get gameModeClassic => 'Classique';

  @override
  String get gameModeZen => 'Mode Zen';

  @override
  String get gameModeTimeAttack => 'Contre-la-montre';

  @override
  String get gameModeArrowRush => 'Flèche Rapide';

  @override
  String get gameModeBlitz => 'Blitz';

  @override
  String get gameModeMineArrows => 'Flèches Piégées';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get difficultyImpossible => 'Impossible';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'APPARENCE';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsAccentColor => 'Couleur d\'accent';

  @override
  String get settingsAudioHaptics => 'AUDIO ET VIBRATIONS';

  @override
  String get settingsSoundEffects => 'Effets sonores';

  @override
  String get settingsMusic => 'Musique';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsArrowSpeed => 'VITESSE DES FLÈCHES';

  @override
  String get settingsAbout => 'À PROPOS';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsTerms => 'Conditions générales';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsSharingComingSoon => 'Partage bientôt disponible';

  @override
  String get consentTitle => 'Bienvenue dans Arrow Puzzle';

  @override
  String get consentSubtitle =>
      'Avant de commencer, veuillez consulter et accepter nos conditions.';

  @override
  String get consentLocalProgress =>
      'Votre progression est enregistrée localement sur votre appareil.';

  @override
  String get consentCloudSync =>
      'Les comptes optionnels synchronisent la progression dans le cloud.';

  @override
  String get consentAds => 'Le jeu affiche des publicités pour rester gratuit.';

  @override
  String get consentAgreement =>
      'En appuyant ci-dessus, vous acceptez nos Conditions générales.';

  @override
  String get dialogExitTitle => 'Quitter le jeu ?';

  @override
  String get dialogExitMessage => 'Êtes-vous sûr de vouloir partir ?';

  @override
  String get dialogSignOutTitle => 'Se déconnecter ?';

  @override
  String get dialogSignOutMessage =>
      'Votre sauvegarde cloud est conservée. Cet appareil sera réinitialisé sur un compte invité à partir du niveau 1.';

  @override
  String get dialogDeleteTitle => 'Supprimer le compte ?';

  @override
  String get dialogDeleteMessage =>
      'Cela supprimera définitivement votre compte et votre sauvegarde cloud. Action irréversible.';

  @override
  String get profileGuest => 'Vous jouez en tant qu\'invité';

  @override
  String get profileSaveToCloud => 'Sauver dans le cloud';

  @override
  String get profileSynced => 'Synchronisé';

  @override
  String get profileSignedIn => 'Connecté';

  @override
  String get profileStatsLevel => 'Niveau';

  @override
  String get profileStatsStars => 'Étoiles';

  @override
  String get profileStatsTrophies => 'Trophées';

  @override
  String get dailyRewardsTitle => 'RÉCOMPENSES QUOTIDIENNES';

  @override
  String dailyRewardsDay(int day, int max) {
    return 'Jour $day sur $max';
  }

  @override
  String get dailyRewardsComeBack => 'Revenez demain';

  @override
  String get dailyRewardsClaimed => 'Réclamé aujourd\'hui !';

  @override
  String get levelComplete => 'Niveau terminé !';

  @override
  String get levelFailed => 'Plus de vies !';

  @override
  String get levelTimeUp => 'Temps écoulé !';

  @override
  String get gameOverRestart => 'Redémarrer le niveau';

  @override
  String get gameOverHome => 'Accueil';

  @override
  String get blitzTitle => 'Blitz';

  @override
  String get blitzStage => 'ÉTAPE';

  @override
  String get blitzComplete => 'Blitz terminé !';

  @override
  String get blitzOver => 'Blitz terminé';

  @override
  String get blitzFinalScore => 'SCORE FINAL';

  @override
  String blitzSurvivedAll(int count) {
    return 'Vous avez survécu aux $count étapes.';
  }

  @override
  String blitzClearedOf(int cleared, int total) {
    return 'Vous avez terminé $cleared sur $total étapes.';
  }

  @override
  String get commonComingSoon => 'Bientôt disponible';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonError => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get dailyRewardsClaimFree => 'Réclamer gratuitement';

  @override
  String get dailyRewardsWatchAd => 'Regarder une pub';

  @override
  String get dailyRewardsSnackClaimed => 'Réclamé !';

  @override
  String get dailyRewardsClaimedToday => 'Réclamé aujourd\'hui !';

  @override
  String dailyRewardsNextIn(String time) {
    return 'Prochaine récompense dans $time';
  }

  @override
  String get unlockTitle => 'Félicitations !';

  @override
  String get unlockSubtitle => 'Nouveau plateau débloqué';

  @override
  String get unlockAddedToInventory => 'Ajouté à votre inventaire';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count PIÈCES';
  }

  @override
  String get buttonCheckInventory => 'Voir l\'inventaire';

  @override
  String get buttonMainMenu => 'Menu principal';

  @override
  String get dailyChallengesTitle => 'Défis quotidiens';

  @override
  String get dailyChallengesSubtitle =>
      'Terminez des modes spéciaux pour gagner des récompenses bonus.';

  @override
  String get dailyRewardsSubtitle => 'Réclamez votre récompense de série';

  @override
  String get activeChallengesTitle => 'Défis actifs';

  @override
  String get blitzSubtitle =>
      'Affrontez une série de niveaux. Le temps se resserre. Les cœurs tiennent.';

  @override
  String get badgeNew => 'NOUVEAU';

  @override
  String get mineArrowsTitle => 'Flèches piégées';

  @override
  String get mineArrowsSubtitle =>
      'Éliminez des flèches en évitant les mines cachées !';

  @override
  String get badgeComingSoon => 'BIENTÔT';

  @override
  String get mineArrowsComingSoonSnack =>
      'Le défi Flèches piégées arrive bientôt !';

  @override
  String get dailyRewardsLabel => 'RÉCOMPENSES QUOTIDIENNES';

  @override
  String dayOfMax(int day, int max) {
    return 'Jour $day sur $max';
  }

  @override
  String get comeBackTomorrow => 'Revenez demain';

  @override
  String plusCoins(int count) {
    return '+$count pièces';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'Réclamer gratuitement';

  @override
  String get loadingLabel => 'Chargement...';

  @override
  String watchAdCoins(int coins) {
    return 'Regarder une pub → +$coins pièces';
  }

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get claimedToday => 'Réclamé aujourd\'hui !';

  @override
  String nextRewardIn(String time) {
    return 'Prochaine récompense dans $time';
  }

  @override
  String get closeLabel => 'Fermer';

  @override
  String get claimedSnack => 'Réclamé !';

  @override
  String get arrowRushTitle => 'Arrow Rush';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return 'Atteignez le niveau $level pour débloquer $tier';
  }

  @override
  String startTier(String tier) {
    return 'Commencer $tier';
  }

  @override
  String lvLabel(int level) {
    return 'Niv $level';
  }

  @override
  String get adNotAvailable => 'Publicité indisponible, réessayez plus tard';

  @override
  String get adBadge => 'PUB';

  @override
  String get homeButton => 'Accueil';

  @override
  String get gameOverTimeUp => 'Temps écoulé !';

  @override
  String get gameOverOutOfTime => 'Plus de temps !';

  @override
  String get gameOverOutOfLives => 'Plus de vies !';

  @override
  String gameOverRewardTime(int seconds) {
    return '+${seconds}s';
  }

  @override
  String gameOverRewardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count vies',
      one: '+$count vie',
    );
    return '$_temp0';
  }

  @override
  String gameOverTimeAttackStats(int cleared, int level) {
    return 'Puzzles résolus : $cleared\nNiveau final : $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'Regarder une pub → $reward';
  }

  @override
  String get gameOverStartNewRun => 'Nouvelle partie';

  @override
  String get gameOverRestartLevel => 'Recommencer le niveau';

  @override
  String get levelCompleteTitle => 'Niveau terminé !';

  @override
  String get levelCompleteNewTrophy => 'NOUVEAU TROPHÉE';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count OBJETS ALÉATOIRES',
      one: '+$count OBJET ALÉATOIRE',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => 'Vous avez terminé le jeu !';

  @override
  String get levelCompleteNextLevel => 'Niveau suivant';

  @override
  String get levelCompleteCoinsDoubled => 'Pièces doublées !';

  @override
  String get levelCompleteDoubleCoins => 'Doubler les pièces';

  @override
  String get pauseTitle => 'En pause';

  @override
  String get pauseResume => 'Reprendre';

  @override
  String get pauseRestart => 'Recommencer';

  @override
  String get pauseMainMenu => 'Menu principal';

  @override
  String get itemBombName => 'Bombe';

  @override
  String get itemBombDesc => 'Détruit un rocher';

  @override
  String get itemHintName => 'Indice';

  @override
  String get itemHintDesc => 'Révèle la prochaine flèche résoluble';

  @override
  String get itemUndoName => 'Annuler';

  @override
  String get itemUndoDesc => 'Ramène la dernière flèche échappée';

  @override
  String get itemHeartFlaskName => 'Fiole de cœur';

  @override
  String get itemHeartFlaskDesc => 'Restaure un cœur';

  @override
  String get itemTimeFreezeName => 'Gel du temps';

  @override
  String get itemTimeFreezeDesc => 'Ajoute 30 secondes au chrono';

  @override
  String get themeNeon => 'Néon';

  @override
  String get themeClassic => 'Classique';

  @override
  String get themeRetro => 'Rétro';

  @override
  String get themeCyber => 'Cyber';

  @override
  String get themeHacker => 'Hacker';

  @override
  String get themeAurora => 'Aurore';

  @override
  String get themeBlueprint => 'Plan';

  @override
  String get themeForest => 'Forêt';

  @override
  String get themePastel => 'Pastel';

  @override
  String get themeSunset => 'Coucher de soleil';

  @override
  String get themeRainbow => 'Arc-en-ciel';

  @override
  String get boardMinimal => 'Minimal';

  @override
  String get boardNebula => 'Nébuleuse';

  @override
  String get boardBlueprint => 'Plan';

  @override
  String get boardForest => 'Forêt';

  @override
  String get boardOcean => 'Océan';

  @override
  String get boardEmber => 'Braise';

  @override
  String get boardCosmic => 'Cosmique';

  @override
  String get boardGeometric => 'Géométrique';

  @override
  String get boardGold => 'Or';

  @override
  String get boardHacker => 'Hacker';

  @override
  String get boardPaper => 'Papier';

  @override
  String get boardIce => 'Glace';

  @override
  String get boardSand => 'Sable';

  @override
  String get boardCloud => 'Nuage';

  @override
  String get boardMint => 'Menthe';

  @override
  String get boardRose => 'Rose';

  @override
  String get boardLavender => 'Lavande';

  @override
  String get boardSky => 'Ciel';

  @override
  String get boardPearl => 'Perle';

  @override
  String get boardHoney => 'Miel';

  @override
  String get trophyFirstEscapeTitle => '🌟 LE PREMIER ÉVEIL';

  @override
  String get trophyFirstEscapeDesc =>
      'Votre tout premier labyrinthe franchi ! Vous avez débloqué la porte du Système de Trophées. Bienvenue dans l\'aventure ultime de puzzles d\'AHB.Dev !';

  @override
  String get trophyPointBlankTitle => 'À Bout Portant';

  @override
  String get trophyPointBlankDesc =>
      'Terminez votre premier puzzle avec précision.';

  @override
  String get trophyTrialOfTwoTitle => 'L\'Épreuve des Deux';

  @override
  String get trophyTrialOfTwoDesc =>
      'Surmontez la restriction intense de deux cœurs des premières épreuves.';

  @override
  String get trophyQuickThinkerTitle => 'Esprit Vif';

  @override
  String get trophyQuickThinkerDesc =>
      'Terminez rapidement n\'importe quel niveau sous un seuil étendu de 20 secondes.';

  @override
  String get trophyArrowSmithTitle => 'Forgeron de Flèches';

  @override
  String get trophyArrowSmithDesc =>
      'Terminez 10 niveaux sans abandonner ni recommencer.';

  @override
  String get trophyCleanSlateTitle => 'Table Rase';

  @override
  String get trophyCleanSlateDesc =>
      'Terminez un niveau sans un seul tapotement de flèche bloquée.';

  @override
  String get trophySparkOfGeniusTitle => 'Étincelle de Génie';

  @override
  String get trophySparkOfGeniusDesc =>
      'Utilisez votre premier indice pour trouver un chemin dans une situation délicate.';

  @override
  String get trophyUnwindTitle => 'Détente';

  @override
  String get trophyUnwindDesc =>
      'Utilisez votre première annulation pour revenir sur un faux pas.';

  @override
  String get trophyRockBreakerTitle => 'Briseur de Rochers';

  @override
  String get trophyRockBreakerDesc =>
      'Faites exploser votre premier obstacle rocheux avec une flèche bombe tactique.';

  @override
  String get trophySurvivalistBadgeTitle => 'Le Survivant';

  @override
  String get trophySurvivalistBadgeDesc =>
      'A conquis les 25 premières épreuves ! Améliore définitivement vos cœurs max de 2 à 3.';

  @override
  String get trophyWayfinderTitle => 'Guide';

  @override
  String get trophyWayfinderDesc =>
      'Atteignez le niveau 50 et prouvez votre maîtrise des premiers labyrinthes.';

  @override
  String get trophyTangleTamerTitle => 'Dompteur d\'Enchevêtrements';

  @override
  String get trophyTangleTamerDesc =>
      'Terminez 10 niveaux d\'affilée sans une seule erreur directionnelle.';

  @override
  String get trophyTimeLordTitle => 'Seigneur du Temps';

  @override
  String get trophyTimeLordDesc =>
      'Survivez à une épreuve chronométrée de niveau divin avec des secondes d\'avance.';

  @override
  String get trophyCenturyMarkTitle => 'La Marque du Siècle';

  @override
  String get trophyCenturyMarkDesc =>
      'Atteignez le niveau 100 — un cinquième du chemin vers le sommet de 500 !';

  @override
  String get trophyBombTechnicianTitle => 'Technicien en Bombes';

  @override
  String get trophyBombTechnicianDesc =>
      'Détruisez 25 rochers dans votre campagne à l\'aide de bombes tactiques.';

  @override
  String get trophyUntouchableTitle => 'Intouchable';

  @override
  String get trophyUntouchableDesc =>
      'Terminez 5 niveaux consécutifs sans perdre un seul cœur.';

  @override
  String get trophyStargazerTitle => 'Observateur d\'Étoiles';

  @override
  String get trophyStargazerDesc =>
      'Obtenez 3 étoiles sur 30 plateaux différents.';

  @override
  String get trophyMasterOfAnglesTitle => 'Maître des Angles';

  @override
  String get trophyMasterOfAnglesDesc =>
      'Terminez un puzzle complexe mettant fortement en scène des points de redirection orphelins.';

  @override
  String get trophyHalfwayToGloryTitle => 'À Mi-Chemin de la Gloire';

  @override
  String get trophyHalfwayToGloryDesc =>
      'Atteignez le niveau 125, établissant votre domination en milieu de partie.';

  @override
  String get trophyTheStrategistTitle => 'Le Stratège';

  @override
  String get trophyTheStrategistDesc =>
      'Utilisez tous les objets disponibles au moins une fois dans une même session.';

  @override
  String get trophyQuickSilverTitle => 'Vif-Argent';

  @override
  String get trophyQuickSilverDesc =>
      'Cumulez 5 minutes de jeu à grande vitesse en mode Contre-la-Montre.';

  @override
  String get trophyIronWillTitle => 'Volonté de Fer';

  @override
  String get trophyIronWillDesc =>
      'Remportez un niveau boss après être tombé à votre tout dernier cœur.';

  @override
  String get trophyGoldenTouchTitle => 'Touche d\'Or';

  @override
  String get trophyGoldenTouchDesc =>
      'Débloquez votre tout premier plateau ou thème de flèche personnalisé.';

  @override
  String get trophyDeepDiverTitle => 'Plongeur des Profondeurs';

  @override
  String get trophyDeepDiverDesc =>
      'Atteignez le niveau 150 alors que le labyrinthe devient exponentiellement complexe.';

  @override
  String get trophyThePuzzlerTitle => 'Le Puzzleur';

  @override
  String get trophyThePuzzlerDesc =>
      'Terminez 50 plateaux de puzzle générés de manière procédurale.';

  @override
  String get trophySharpShooterTitle => 'Tireur d\'Élite';

  @override
  String get trophySharpShooterDesc =>
      'Terminez 20 niveaux en utilisant le minimum de mouvements possible.';

  @override
  String get trophyVaultKeeperTitle => 'Gardien du Coffre';

  @override
  String get trophyVaultKeeperDesc =>
      'Cumulez un total de 500 pièces via le jeu et les récompenses publicitaires.';

  @override
  String get trophyMilestoneMasterTitle => 'Maître des Étapes';

  @override
  String get trophyMilestoneMasterDesc =>
      'Atteignez le niveau 200 — deux cinquièmes du chemin vers le maximum de 500.';

  @override
  String get trophyBossSlayerTitle => 'Tueur de Boss';

  @override
  String get trophyBossSlayerDesc =>
      'Vainquez 8 niveaux boss consécutifs sans une seule défaite.';

  @override
  String get trophyTimeBenderTitle => 'Le Faussaire du Temps';

  @override
  String get trophyTimeBenderDesc =>
      'Gelez le temps avec succès 10 fois dans des niveaux au compte à rebours intense.';

  @override
  String get trophyResilientSpiritTitle => 'Esprit Résilient';

  @override
  String get trophyResilientSpiritDesc =>
      'Récupérez après un game over grâce à une récompense de continuation publicitaire.';

  @override
  String get trophyBoardCollectorTitle => 'Collectionneur de Plateaux';

  @override
  String get trophyBoardCollectorDesc =>
      'Débloquez 5 thèmes de plateau personnalisés pour votre collection.';

  @override
  String get trophyApexPredatorTitle => 'Prédateur Alpha';

  @override
  String get trophyApexPredatorDesc =>
      'Atteignez le niveau 250 — le sommet à mi-parcours de la campagne actuelle.';

  @override
  String get trophyFlawlessExecutionTitle => 'Exécution Impeccable';

  @override
  String get trophyFlawlessExecutionDesc =>
      'Obtenez 3 étoiles sur 100 niveaux distincts.';

  @override
  String get trophyTacticalMindsetTitle => 'État d\'Esprit Tactique';

  @override
  String get trophyTacticalMindsetDesc =>
      'Résolvez un puzzle de niveau divin sans aucun indice.';

  @override
  String get trophyDailyDevoteeTitle => 'Dévot Quotidien';

  @override
  String get trophyDailyDevoteeDesc =>
      'Maintenez une série de 7 jours sur votre suivi de récompenses quotidiennes.';

  @override
  String get trophyMonumentalPioneerTitle => 'Pionnier Monumental';

  @override
  String get trophyMonumentalPioneerDesc =>
      'Débloquez votre premier trophée monumental de prestige purement décoratif.';

  @override
  String get trophyHighClimberTitle => 'Le Grand Grimpeur';

  @override
  String get trophyHighClimberDesc =>
      'Atteignez le niveau 300 — trois cinquièmes du chemin vers le sommet de 500.';

  @override
  String get trophyGrandmasterTitle => 'Grand Maître';

  @override
  String get trophyGrandmasterDesc =>
      'Atteignez le niveau 350, conquérant les enchevêtrements les plus complexes.';

  @override
  String get trophyEternalFlameTitle => 'Flamme Éternelle';

  @override
  String get trophyEternalFlameDesc =>
      'Maintenez une série incroyable de 14 jours de connexion continue.';

  @override
  String get trophyIroncladTitle => 'Cuirassé';

  @override
  String get trophyIroncladDesc =>
      'Atteignez le niveau 400 — quatre cinquièmes du chemin vers le sommet ultime.';

  @override
  String get trophyPerfectionistTitle => 'Perfectionniste';

  @override
  String get trophyPerfectionistDesc =>
      'Obtenez 3 étoiles à chaque niveau, du 1 au 400.';

  @override
  String get trophyTitanOfTheMazeTitle => 'Titan du Labyrinthe';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'Atteignez le niveau 450, parmi les solveurs de puzzles d\'élite.';

  @override
  String get trophyThe500ClubTitle => 'Le Club des 500';

  @override
  String get trophyThe500ClubDesc =>
      'Atteignez le niveau 500, sommet maximal actuel de la grille de puzzle !';

  @override
  String get trophyLivingLegendTitle => 'Légende Vivante';

  @override
  String get trophyLivingLegendDesc =>
      'Terminez le niveau 500 avec une note de 3 étoiles et zéro erreur.';

  @override
  String get trophyMonumentOfTimeTitle => 'Monument du Temps';

  @override
  String get trophyMonumentOfTimeDesc =>
      'Artefact monumental de prestige décerné pour avoir consacré plus de 10 heures actives à échapper aux labyrinthes.';

  @override
  String get trophyAbsoluteVoidTitle => 'Le Vide Absolu';

  @override
  String get trophyAbsoluteVoidDesc =>
      'Trophée monumental de prestige noir absolu décerné pour avoir maximisé les fonctionnalités clés de progression.';

  @override
  String get trophyInfiniteHorizonTitle => 'Horizon Infini';

  @override
  String get trophyInfiniteHorizonDesc =>
      'Trophée monumental symbolique reconnaissant que le voyage au-delà du niveau 500 ne se termine jamais.';

  @override
  String timeBonusAmount(int seconds) {
    return '+${seconds}s';
  }

  @override
  String get heartsAlreadyFull => 'Les cœurs sont déjà pleins';

  @override
  String timeFreezeWait(int seconds) {
    return 'Attendez encore ${seconds}s avant d\'utiliser Gel du temps';
  }

  @override
  String get tapRockToDestroy => 'Touchez un rocher pour le détruire';

  @override
  String get noSolvableArrowFound => 'Aucune flèche résoluble trouvée';

  @override
  String get nothingToUndo => 'Rien à annuler';

  @override
  String get blitzCompleteTitle => 'Blitz terminé !';

  @override
  String get blitzOverTitle => 'Blitz terminé';

  @override
  String get blitzSplashStage => 'ÉTAPE';

  @override
  String blitzPoints(int score) {
    return '$score pts';
  }

  @override
  String get arrowSpeedEscapeSpeed => 'Vitesse d\'échappement';

  @override
  String get arrowSpeedSlow => 'Lente';

  @override
  String get arrowSpeedNormal => 'Normale';

  @override
  String get arrowSpeedFast => 'Rapide';

  @override
  String get accentColorLabel => 'Couleur d\'accent';

  @override
  String get settingsShareFriends => 'Partager avec des amis';

  @override
  String get settingsSharingSoon => 'Partage bientôt disponible';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsTermsConditions => 'Conditions générales';

  @override
  String get settingsChooseLanguage => 'Choisir la langue';

  @override
  String settingsVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get languageSystemDefault => 'Par défaut du système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languagePortugueseBR => 'Portugais (BR)';

  @override
  String get languageIndonesian => 'Indonésien';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageFrench => 'Français';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'Trophées ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'Niv $level';
  }

  @override
  String get trophiesPerkHeart => '✨ Avantage : +1 cœur max permanent';

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get leaderboardComingSoon => 'Bientôt disponible';

  @override
  String get leaderboardDescription =>
      'Affrontez des joueurs du monde entier. Vos scores et classements apparaîtront ici dès que le classement en ligne sera disponible.';

  @override
  String get inventoryTitle => 'Inventaire';

  @override
  String get inventoryTabArrows => 'Flèches';

  @override
  String get inventoryTabBoards => 'Plateaux';

  @override
  String get inventoryTabItems => 'Objets';

  @override
  String get inventoryEquipped => 'Équipé';

  @override
  String get inventoryTapToEquip => 'Toucher pour équiper';

  @override
  String inventoryReachLevel(int level) {
    return 'Atteignez le niveau $level pour débloquer';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'Niv $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return 'Il manque $count pièces';
  }

  @override
  String inventoryBuyItemTitle(String item) {
    return 'Acheter $item ?';
  }

  @override
  String inventoryUnlockTitle(String title) {
    return 'Débloquer $title ?';
  }

  @override
  String inventoryCoinsPrice(int count) {
    return '$count pièces';
  }

  @override
  String get inventoryBuy => 'Acheter';

  @override
  String get rushDifficultyEasy => 'Facile';

  @override
  String get rushDifficultyHard => 'Difficile';

  @override
  String get rushDifficultyImpossible => 'Impossible';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePlayingAsGuest => 'Jeu en invité';

  @override
  String get profileSignInSuccess => 'Connecté — progression synchronisée';

  @override
  String profileSignInFailed(String error) {
    return 'Échec de connexion : $error';
  }

  @override
  String get profileSaveYourProgress => 'Sauvegardez votre progression';

  @override
  String get profileGuestBody =>
      'Les comptes invités ne vivent que sur cet appareil. Connectez-vous pour sauvegarder votre niveau, vos pièces et vos trophées.';

  @override
  String get profileContinueWithEmail => 'Continuer avec e-mail';

  @override
  String get profileSignOutTitle => 'Se déconnecter ?';

  @override
  String get profileSignOutBody =>
      'Votre sauvegarde cloud est conservée. Cet appareil sera réinitialisé sur un nouveau compte invité et repartira du niveau 1.';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get profileDeleteAccountBody =>
      'Cela supprimera définitivement votre sauvegarde cloud et votre compte. Cette action est irréversible.';

  @override
  String get profileDelete => 'Supprimer';

  @override
  String profileDeleteFailed(String error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'Échec de déconnexion : $error';
  }

  @override
  String get profileSignedInBody =>
      'Votre progression est sauvegardée dans le cloud. Connectez-vous sur n\'importe quel appareil avec le même compte pour continuer.';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileStatLevel => 'Niveau';

  @override
  String get profileStatStars => 'Étoiles';

  @override
  String get profileStatTrophies => 'Trophées';

  @override
  String get profileTabSignIn => 'Connexion';

  @override
  String get profileTabCreateAccount => 'Créer un compte';

  @override
  String get profileCreateAccountTitle => 'Créez votre compte';

  @override
  String get profileWelcomeBack => 'Bon retour';

  @override
  String get profileGuestProgressCarries =>
      'Votre progression invité sera transférée.';

  @override
  String get profileSignInRestoreBody =>
      'Connectez-vous pour restaurer votre progression depuis un autre appareil.';

  @override
  String get profileNameHint => 'Nom (facultatif)';

  @override
  String get profileEmailHint => 'E-mail';

  @override
  String get profilePasswordHint => 'Mot de passe';

  @override
  String get profileShowPassword => 'Afficher le mot de passe';

  @override
  String get profileHidePassword => 'Masquer le mot de passe';

  @override
  String get profileGeneratePassword => 'Générer un mot de passe';

  @override
  String get profilePasswordMinLength =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get profileStrengthTooShort => 'Trop court';

  @override
  String get profileStrengthOkay => 'Correct';

  @override
  String get profileStrengthGood => 'Bon';

  @override
  String get profileStrengthStrong => 'Fort';

  @override
  String get profileErrorEmailSignUp =>
      'Cet e-mail est déjà enregistré. Essayez Connexion.';

  @override
  String get profileErrorEmailSignIn =>
      'Cet e-mail est déjà enregistré. Vérifiez votre mot de passe ou réinitialisez-le via le lien e-mail.';

  @override
  String get profileErrorInvalidCredentials =>
      'E-mail ou mot de passe incorrect. Réessayez.';

  @override
  String get profileErrorPassword =>
      'Mot de passe refusé. Utilisez 8+ caractères avec lettres et chiffres, et évitez les mots courants comme « password ».';

  @override
  String get profileErrorInvalidEmail =>
      'Cette adresse e-mail semble invalide.';

  @override
  String get profileErrorSessionExpired =>
      'Session expirée. Fermez l\'application, rouvrez-la et réessayez.';

  @override
  String get profileErrorRateLimit =>
      'Trop de tentatives. Patientez une minute et réessayez.';

  @override
  String get profileErrorServerBusy =>
      'Serveur occupé. Réessayez dans un instant.';

  @override
  String get profileErrorSignUpGeneric =>
      'Échec d\'inscription. Vérifiez vos informations et réessayez.';

  @override
  String get profileErrorSignInGeneric =>
      'Échec de connexion. Vérifiez votre e-mail et mot de passe.';

  @override
  String get profileEnterValidEmail => 'Saisissez une adresse e-mail valide.';

  @override
  String get profileEnterPassword => 'Saisissez votre mot de passe.';

  @override
  String get profileEmailAlreadyPrompt =>
      'Cet e-mail possède déjà un compte. Saisissez votre mot de passe pour vous connecter.';

  @override
  String get profileSomethingWrong => 'Une erreur est survenue. Réessayez.';

  @override
  String get profileCreateAccountButton => 'Créer un compte';

  @override
  String get profileSignInButton => 'Se connecter';

  @override
  String get profileAlreadyHaveAccount => 'Déjà un compte ? Connectez-vous';

  @override
  String get profileDontHaveAccount => 'Pas de compte ? Créez-en un';

  @override
  String get homePlayer => 'Joueur';

  @override
  String homeLevelStars(int level, int stars) {
    return 'Niveau $level · $stars étoiles';
  }

  @override
  String get homeContinueLabel => 'CONTINUER';

  @override
  String homeLevelNumber(int level) {
    return 'Niveau $level';
  }

  @override
  String get homeContinue => 'Continuer';

  @override
  String get homeDaily => 'Quotidien';

  @override
  String get homeDailyReady => 'Prêt à jouer';

  @override
  String get homeDailyClaimed => 'Réclamé aujourd\'hui';

  @override
  String get homeLeaderboard => 'Classement';

  @override
  String get homeComingSoon => 'Bientôt disponible';

  @override
  String get homeInventory => 'Inventaire';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'Tout débloqué · $count objets';
  }

  @override
  String get homeInventoryBrowse => 'Parcourez votre équipement';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items objets';
  }

  @override
  String get homeTrophies => 'Trophées';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$unlocked sur $total';
  }

  @override
  String get privacyWelcomeTitle => 'Bienvenue dans Arrow Puzzle';

  @override
  String get privacyWelcomeSubtitle =>
      'Avant de commencer, veuillez consulter et accepter nos conditions.';

  @override
  String get privacyBulletLocal =>
      'Votre progression est enregistrée localement sur votre appareil.';

  @override
  String get privacyBulletCloud =>
      'Les comptes facultatifs synchronisent la progression dans le cloud.';

  @override
  String get privacyBulletAds =>
      'Le jeu affiche des publicités pour rester gratuit.';

  @override
  String get privacyPolicyLink => 'Politique de confidentialité';

  @override
  String get privacyTermsLink => 'Conditions générales';

  @override
  String get privacyAcceptButton => 'Accepter et continuer';

  @override
  String get privacyAgreeFooter =>
      'En appuyant ci-dessus, vous acceptez nos Conditions générales.';

  @override
  String get bottomNavHome => 'Accueil';

  @override
  String get bottomNavDaily => 'Quotidien';

  @override
  String get bottomNavInventory => 'Inventaire';

  @override
  String get bottomNavSettings => 'Paramètres';

  @override
  String gameTopBarScore(int score) {
    return 'Score : $score';
  }

  @override
  String get gameTopBarRandom => 'Aléatoire';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'Niv.$level';
  }

  @override
  String get gameModeZenMode => 'Mode Zen';

  @override
  String get howToPlayTitle => 'COMMENT JOUER';

  @override
  String get howToPlayBasics => 'LES BASES';

  @override
  String get howToPlayBoardElements => 'ÉLÉMENTS DU PLATEAU';

  @override
  String get howToPlayGameModes => 'MODES DE JEU';

  @override
  String get howToPlayProStrategies => 'STRATÉGIES PRO';

  @override
  String get howToPlayCoreTitle => 'Objectif principal';

  @override
  String get howToPlayCoreDesc =>
      'Votre but est de vider toute la grille en guidant chaque flèche hors du plateau. Quand il n\'en reste plus, le niveau est terminé.';

  @override
  String get howToPlayMovementTitle => 'Mouvement des flèches';

  @override
  String get howToPlayMovementDesc =>
      'Touchez une flèche pour la lancer. Les flèches glissent exactement dans la direction de leur pointe : haut, bas, gauche ou droite. Même si le corps est courbé, la flèche sort toujours dans l\'axe de sa pointe.';

  @override
  String get howToPlayObstaclesTitle => 'Obstacles et collisions';

  @override
  String get howToPlayObstaclesDesc =>
      'Une flèche ne peut sortir que si tout son chemin est libre. Si une autre flèche bloque, celle que vous avez touchée tremble et reste en place.';

  @override
  String get howToPlayLivesTitle => 'Vies et santé';

  @override
  String get howToPlayLivesDesc =>
      'En mode Classique, vous commencez avec 3 cœurs. Toucher une flèche bloquée coûte 1 cœur. À zéro, recommencez le niveau. Vous pouvez activer Vies Infinies dans les Paramètres.';

  @override
  String get howToPlayTurnDotsTitle => 'Points tournants (redirigeurs)';

  @override
  String get howToPlayTurnDotsDesc =>
      'Repérez les points circulaires sur les cases vides, marqués de petites flèches. Quand une flèche glissante traverse un Point Tournant, elle pivote dans sa direction et le consomme, ouvrant des passages inattendus.';

  @override
  String get howToPlayCombosTitle => 'Combos et séries';

  @override
  String get howToPlayCombosDesc =>
      'Libérez des flèches en succession rapide (moins de 1,5 s) pour déclencher des combos. Enchaîner les évasions accumule l\'élan et multiplie le score.';

  @override
  String get howToPlayClassicTitle => 'Mode Classique';

  @override
  String get howToPlayClassicDesc =>
      'La progression standard de la campagne. Avancez à travers des niveaux artisanaux et procéduraux de taille, masques et complexité croissants, avec 3 cœurs.';

  @override
  String get howToPlayZenTitle => 'Mode Zen';

  @override
  String get howToPlayZenDesc =>
      'Détente pure et sans stress. Pas de cœurs à perdre, pas de limite de temps, pas d\'échec. Idéal pour se détendre et s\'entraîner sur des plateaux complexes.';

  @override
  String get howToPlayTimeAttackTitle => 'Contre-la-Montre';

  @override
  String get howToPlayTimeAttackDesc =>
      'Course effrénée contre le chrono ! Chaque flèche échappée avec succès vous rend de précieuses secondes bonus.';

  @override
  String get howToPlayMultiplayerTitle => 'Salons multijoueurs';

  @override
  String get howToPlayMultiplayerDesc =>
      'Hébergez ou rejoignez avec des codes de graine. Les deux joueurs s\'affrontent sur le même plateau aléatoire pour voir qui le résout le plus vite.';

  @override
  String get howToPlayRandomTitle => 'Puzzles aléatoires';

  @override
  String get howToPlayRandomDesc =>
      'Générez des puzzles infinis à la demande en difficultés Facile, Moyen, Difficile, Maître et Expert sans affecter la progression de la campagne.';

  @override
  String get howToPlayUnpeelTitle => 'Épluchez par le bord';

  @override
  String get howToPlayUnpeelDesc =>
      'Commencez par scanner les bords extérieurs. Les flèches pointant vers l\'extérieur peuvent toujours s\'échapper immédiatement, libérant des voies essentielles.';

  @override
  String get howToPlayTraceTitle => 'Remontez les bloqueurs à l\'envers';

  @override
  String get howToPlayTraceDesc =>
      'Quand une flèche est bloquée, trouvez celle qui la bloque, puis ce qui bloque cette deuxième. Libérer le dernier bloqueur ouvre tout ce qui est derrière.';

  @override
  String get howToPlayTapAssistTitle => 'Activer l\'assistance tactile';

  @override
  String get howToPlayTapAssistDesc =>
      'Si vous jouez sur petit écran ou touchez entre des flèches serrées, activez l\'Assistance Tactile dans les Paramètres pour assigner les touchers à la flèche la plus proche.';

  @override
  String get multiplayerTitle => 'MULTIJOUEUR';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return 'Code du salon $code copié dans le presse-papiers !';
  }

  @override
  String get multiplayerHostRoom => 'SALON HÔTE';

  @override
  String get multiplayerHostBody =>
      'Partagez ce code avec un ami pour vous affronter sur le même plateau !';

  @override
  String get multiplayerNewCode => 'Nouveau code';

  @override
  String get multiplayerCopyCode => 'Copier le code';

  @override
  String get multiplayerStartMatch => 'DÉMARRER LE MATCH';

  @override
  String get multiplayerJoinRoom => 'REJOINDRE UN SALON';

  @override
  String get multiplayerJoinBody =>
      'Saisissez ou collez un code de salon pour rejoindre.';

  @override
  String get multiplayerRoomCodeHint => 'ex. ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'Veuillez saisir un code de salon';

  @override
  String get multiplayerJoinMatch => 'REJOINDRE';

  @override
  String get zenCardSubtitle =>
      'Pas de chrono. Pas de limites. Résolvez, c\'est tout.';

  @override
  String get profileSyncing => 'Synchronisation...';

  @override
  String get profileSyncFailed => 'Échec de la synchronisation';

  @override
  String get gameModeTimeBlitz => 'Blitz Chrono';

  @override
  String get timeBlitzDesc =>
      'Touchez les flèches pour gagner du temps. Les taps bloqués coûtent du temps. Survivez le plus longtemps possible.';

  @override
  String get timeBlitzOverTitle => 'Blitz Chrono Terminé';

  @override
  String get timeBlitzScoreLabel => 'FLÈCHES ÉLIMINÉES';

  @override
  String get timeBlitzLevelsLabel => 'Niveaux atteints';

  @override
  String get profileEditName => 'Modifier le nom';

  @override
  String get profileSave => 'Enregistrer';

  @override
  String get profileUpdated => 'Profil mis à jour';
}
