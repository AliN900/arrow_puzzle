// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppStringsEs extends AppStrings {
  AppStringsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Arrow Puzzle';

  @override
  String get menuHome => 'Inicio';

  @override
  String get menuDaily => 'Diario';

  @override
  String get menuInventory => 'Inventario';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuProfile => 'Perfil';

  @override
  String get menuTrophies => 'Trofeos';

  @override
  String get menuLeaderboard => 'Clasificación';

  @override
  String get menuContinue => 'Continuar';

  @override
  String menuLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get buttonPlay => 'Jugar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonBuy => 'Comprar';

  @override
  String get buttonRestart => 'Reiniciar';

  @override
  String get buttonResume => 'Reanudar';

  @override
  String get buttonExit => 'Salir';

  @override
  String get buttonClose => 'Cerrar';

  @override
  String get buttonNext => 'Siguiente nivel';

  @override
  String get buttonSignIn => 'Iniciar sesión';

  @override
  String get buttonSignUp => 'Crear cuenta';

  @override
  String get buttonSignOut => 'Cerrar sesión';

  @override
  String get buttonDeleteAccount => 'Eliminar cuenta';

  @override
  String get buttonClaim => 'Reclamar gratis';

  @override
  String get buttonWatchAd => 'Ver anuncio';

  @override
  String get buttonAccept => 'Aceptar y continuar';

  @override
  String get buttonShare => 'Compartir con amigos';

  @override
  String get buttonStartBlitz => 'Comenzar Blitz';

  @override
  String buttonStartRush(String tier) {
    return 'Comenzar $tier';
  }

  @override
  String get gameModeClassic => 'Clásico';

  @override
  String get gameModeZen => 'Modo Zen';

  @override
  String get gameModeTimeAttack => 'Contrarreloj';

  @override
  String get gameModeArrowRush => 'Flecha Rápida';

  @override
  String get gameModeBlitz => 'Blitz';

  @override
  String get gameModeMineArrows => 'Flechas Minadas';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultyImpossible => 'Imposible';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'APARIENCIA';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsAccentColor => 'Color de acento';

  @override
  String get settingsAudioHaptics => 'AUDIO Y VIBRACIÓN';

  @override
  String get settingsSoundEffects => 'Efectos de sonido';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsArrowSpeed => 'VELOCIDAD DE FLECHAS';

  @override
  String get settingsAbout => 'ACERCA DE';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsTerms => 'Términos y condiciones';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsSharingComingSoon => 'Compartir próximamente';

  @override
  String get consentTitle => 'Bienvenido a Arrow Puzzle';

  @override
  String get consentSubtitle =>
      'Antes de comenzar, revisa y acepta nuestros términos.';

  @override
  String get consentLocalProgress =>
      'Tu progreso se guarda localmente en tu dispositivo.';

  @override
  String get consentCloudSync =>
      'Las cuentas opcionales sincronizan el progreso en la nube.';

  @override
  String get consentAds =>
      'El juego muestra anuncios para seguir siendo gratis.';

  @override
  String get consentAgreement =>
      'Al pulsar arriba aceptas nuestros Términos y condiciones.';

  @override
  String get dialogExitTitle => '¿Salir del juego?';

  @override
  String get dialogExitMessage => '¿Estás seguro de que quieres salir?';

  @override
  String get dialogSignOutTitle => '¿Cerrar sesión?';

  @override
  String get dialogSignOutMessage =>
      'Tu partida en la nube se mantiene. Este dispositivo se restablecerá a una cuenta de invitado desde el nivel 1.';

  @override
  String get dialogDeleteTitle => '¿Eliminar cuenta?';

  @override
  String get dialogDeleteMessage =>
      'Esto eliminará permanentemente tu cuenta y partida en la nube. No se puede deshacer.';

  @override
  String get profileGuest => 'Jugando como invitado';

  @override
  String get profileSaveToCloud => 'Guardar en la nube';

  @override
  String get profileSynced => 'Sincronizado';

  @override
  String get profileSignedIn => 'Sesión iniciada';

  @override
  String get profileStatsLevel => 'Nivel';

  @override
  String get profileStatsStars => 'Estrellas';

  @override
  String get profileStatsTrophies => 'Trofeos';

  @override
  String get dailyRewardsTitle => 'RECOMPENSAS DIARIAS';

  @override
  String dailyRewardsDay(int day, int max) {
    return 'Día $day de $max';
  }

  @override
  String get dailyRewardsComeBack => 'Vuelve mañana';

  @override
  String get dailyRewardsClaimed => '¡Reclamado hoy!';

  @override
  String get levelComplete => '¡Nivel completado!';

  @override
  String get levelFailed => '¡Sin vidas!';

  @override
  String get levelTimeUp => '¡Sin tiempo!';

  @override
  String get gameOverRestart => 'Reiniciar nivel';

  @override
  String get gameOverHome => 'Inicio';

  @override
  String get blitzTitle => 'Blitz';

  @override
  String get blitzStage => 'ETAPA';

  @override
  String get blitzComplete => '¡Blitz completado!';

  @override
  String get blitzOver => 'Blitz terminado';

  @override
  String get blitzFinalScore => 'PUNTUACIÓN FINAL';

  @override
  String blitzSurvivedAll(int count) {
    return 'Sobreviviste a las $count etapas.';
  }

  @override
  String blitzClearedOf(int cleared, int total) {
    return 'Completaste $cleared de $total etapas.';
  }

  @override
  String get commonComingSoon => 'Próximamente';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get dailyRewardsClaimFree => 'Reclamar gratis';

  @override
  String get dailyRewardsWatchAd => 'Ver anuncio';

  @override
  String get dailyRewardsSnackClaimed => '¡Reclamado!';

  @override
  String get dailyRewardsClaimedToday => '¡Reclamado hoy!';

  @override
  String dailyRewardsNextIn(String time) {
    return 'Próxima recompensa en $time';
  }

  @override
  String get unlockTitle => '¡Enhorabuena!';

  @override
  String get unlockSubtitle => 'Nuevo tablero desbloqueado';

  @override
  String get unlockAddedToInventory => 'Añadido a tu inventario';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count MONEDAS';
  }

  @override
  String get buttonCheckInventory => 'Ver inventario';

  @override
  String get buttonMainMenu => 'Menú principal';

  @override
  String get dailyChallengesTitle => 'Desafíos diarios';

  @override
  String get dailyChallengesSubtitle =>
      'Completa modos especiales para ganar recompensas extra.';

  @override
  String get dailyRewardsSubtitle => 'Reclama tu recompensa de racha';

  @override
  String get activeChallengesTitle => 'Desafíos activos';

  @override
  String get blitzSubtitle =>
      'Supera una serie de niveles. Los tiempos se ajustan. Las vidas se mantienen.';

  @override
  String get badgeNew => 'NUEVO';

  @override
  String get mineArrowsTitle => 'Minas de flechas';

  @override
  String get mineArrowsSubtitle =>
      '¡Despeja flechas mientras esquivas minas ocultas!';

  @override
  String get badgeComingSoon => 'PRÓXIMAMENTE';

  @override
  String get mineArrowsComingSoonSnack =>
      '¡El desafío Minas de flechas llegará pronto!';

  @override
  String get dailyRewardsLabel => 'RECOMPENSAS DIARIAS';

  @override
  String dayOfMax(int day, int max) {
    return 'Día $day de $max';
  }

  @override
  String get comeBackTomorrow => 'Vuelve mañana';

  @override
  String plusCoins(int count) {
    return '+$count monedas';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'Reclamar gratis';

  @override
  String get loadingLabel => 'Cargando...';

  @override
  String watchAdCoins(int coins) {
    return 'Ver anuncio → +$coins monedas';
  }

  @override
  String get notNow => 'Ahora no';

  @override
  String get claimedToday => '¡Reclamado hoy!';

  @override
  String nextRewardIn(String time) {
    return 'Próxima recompensa en $time';
  }

  @override
  String get closeLabel => 'Cerrar';

  @override
  String get claimedSnack => '¡Reclamado!';

  @override
  String get arrowRushTitle => 'Arrow Rush';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return 'Alcanza el nivel $level para desbloquear $tier';
  }

  @override
  String startTier(String tier) {
    return 'Iniciar $tier';
  }

  @override
  String lvLabel(int level) {
    return 'Nv $level';
  }

  @override
  String get adNotAvailable => 'Anuncio no disponible, inténtalo más tarde';

  @override
  String get adBadge => 'AD';

  @override
  String get homeButton => 'Inicio';

  @override
  String get gameOverTimeUp => '¡Se acabó el tiempo!';

  @override
  String get gameOverOutOfTime => '¡Sin tiempo!';

  @override
  String get gameOverOutOfLives => '¡Sin vidas!';

  @override
  String gameOverRewardTime(int seconds) {
    return '+${seconds}s';
  }

  @override
  String gameOverRewardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count vidas',
      one: '+$count vida',
    );
    return '$_temp0';
  }

  @override
  String gameOverTimeAttackStats(int cleared, int level) {
    return 'Puzles resueltos: $cleared\nNivel final: $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'Ver anuncio → $reward';
  }

  @override
  String get gameOverStartNewRun => 'Nueva partida';

  @override
  String get gameOverRestartLevel => 'Reiniciar nivel';

  @override
  String get levelCompleteTitle => '¡Nivel completado!';

  @override
  String get levelCompleteNewTrophy => 'NUEVO TROFEO';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count OBJETOS ALEATORIOS',
      one: '+$count OBJETO ALEATORIO',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => '¡Terminaste el juego!';

  @override
  String get levelCompleteNextLevel => 'Siguiente nivel';

  @override
  String get levelCompleteCoinsDoubled => '¡Monedas duplicadas!';

  @override
  String get levelCompleteDoubleCoins => 'Duplicar monedas';

  @override
  String get pauseTitle => 'Pausado';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get pauseRestart => 'Reiniciar';

  @override
  String get pauseMainMenu => 'Menú principal';

  @override
  String get itemBombName => 'Bomba';

  @override
  String get itemBombDesc => 'Destruye una roca';

  @override
  String get itemHintName => 'Pista';

  @override
  String get itemHintDesc => 'Revela la siguiente flecha solucionable';

  @override
  String get itemUndoName => 'Deshacer';

  @override
  String get itemUndoDesc => 'Recupera la última flecha escapada';

  @override
  String get itemHeartFlaskName => 'Frasco de vida';

  @override
  String get itemHeartFlaskDesc => 'Restaura una vida';

  @override
  String get itemTimeFreezeName => 'Congelar tiempo';

  @override
  String get itemTimeFreezeDesc => 'Añade 30 segundos al temporizador';

  @override
  String get themeNeon => 'Neón';

  @override
  String get themeClassic => 'Clásico';

  @override
  String get themeRetro => 'Retro';

  @override
  String get themeCyber => 'Cyber';

  @override
  String get themeHacker => 'Hacker';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeBlueprint => 'Plano';

  @override
  String get themeForest => 'Bosque';

  @override
  String get themePastel => 'Pastel';

  @override
  String get themeSunset => 'Atardecer';

  @override
  String get themeRainbow => 'Arcoíris';

  @override
  String get boardMinimal => 'Minimalista';

  @override
  String get boardNebula => 'Nebulosa';

  @override
  String get boardBlueprint => 'Plano';

  @override
  String get boardForest => 'Bosque';

  @override
  String get boardOcean => 'Océano';

  @override
  String get boardEmber => 'Brasa';

  @override
  String get boardCosmic => 'Cósmico';

  @override
  String get boardGeometric => 'Geométrico';

  @override
  String get boardGold => 'Oro';

  @override
  String get boardHacker => 'Hacker';

  @override
  String get boardPaper => 'Papel';

  @override
  String get boardIce => 'Hielo';

  @override
  String get boardSand => 'Arena';

  @override
  String get boardCloud => 'Nube';

  @override
  String get boardMint => 'Menta';

  @override
  String get boardRose => 'Rosa';

  @override
  String get boardLavender => 'Lavanda';

  @override
  String get boardSky => 'Cielo';

  @override
  String get boardPearl => 'Perla';

  @override
  String get boardHoney => 'Miel';

  @override
  String get trophyFirstEscapeTitle => '🌟 EL PRIMER DESPERTAR';

  @override
  String get trophyFirstEscapeDesc =>
      '¡Tu primer laberinto escapado! Has desbloqueado la puerta al Sistema de Trofeos. ¡Bienvenido a la aventura definitiva de puzles de AHB.Dev!';

  @override
  String get trophyPointBlankTitle => 'A Quemarropa';

  @override
  String get trophyPointBlankDesc =>
      'Supera tu primer diseño de puzle con precisión.';

  @override
  String get trophyTrialOfTwoTitle => 'Prueba de Dos';

  @override
  String get trophyTrialOfTwoDesc =>
      'Vence la intensa restricción de dos vidas de las pruebas iniciales.';

  @override
  String get trophyQuickThinkerTitle => 'Mente Rápida';

  @override
  String get trophyQuickThinkerDesc =>
      'Completa cualquier nivel rápidamente bajo un umbral ampliado de 20 segundos.';

  @override
  String get trophyArrowSmithTitle => 'Forjador de Flechas';

  @override
  String get trophyArrowSmithDesc =>
      'Supera 10 niveles sin rendirte ni reiniciar.';

  @override
  String get trophyCleanSlateTitle => 'Pizarra Limpia';

  @override
  String get trophyCleanSlateDesc =>
      'Termina un nivel sin un solo toque bloqueado.';

  @override
  String get trophySparkOfGeniusTitle => 'Chispa de Genio';

  @override
  String get trophySparkOfGeniusDesc =>
      'Usa tu primera pista para encontrar un camino en una situación complicada.';

  @override
  String get trophyUnwindTitle => 'Relájate';

  @override
  String get trophyUnwindDesc =>
      'Usa tu primer deshacer para revertir un paso en falso.';

  @override
  String get trophyRockBreakerTitle => 'Rompe Rocas';

  @override
  String get trophyRockBreakerDesc =>
      'Destruye tu primer obstáculo de roca usando una flecha bomba táctica.';

  @override
  String get trophySurvivalistBadgeTitle => 'El Superviviente';

  @override
  String get trophySurvivalistBadgeDesc =>
      '¡Superaste las primeras 25 pruebas! Mejora permanentemente tus vidas máximas de 2 a 3.';

  @override
  String get trophyWayfinderTitle => 'Guía';

  @override
  String get trophyWayfinderDesc =>
      'Alcanza el nivel 50 y demuestra tu dominio de los primeros laberintos.';

  @override
  String get trophyTangleTamerTitle => 'Domador de Enredos';

  @override
  String get trophyTangleTamerDesc =>
      'Supera 10 niveles seguidos sin un solo error direccional.';

  @override
  String get trophyTimeLordTitle => 'Señor del Tiempo';

  @override
  String get trophyTimeLordDesc =>
      'Sobrevive a una prueba cronometrada de nivel divino con segundos de sobra.';

  @override
  String get trophyCenturyMarkTitle => 'Marca del Centenario';

  @override
  String get trophyCenturyMarkDesc =>
      'Alcanza el nivel 100 — ¡un quinto del camino a la cima de 500!';

  @override
  String get trophyBombTechnicianTitle => 'Técnico de Bombas';

  @override
  String get trophyBombTechnicianDesc =>
      'Destruye 25 rocas en tu campaña usando bombas tácticas.';

  @override
  String get trophyUntouchableTitle => 'Intocable';

  @override
  String get trophyUntouchableDesc =>
      'Completa 5 niveles seguidos sin perder una sola vida.';

  @override
  String get trophyStargazerTitle => 'Observador de Estrellas';

  @override
  String get trophyStargazerDesc =>
      'Consigue 3 estrellas en 30 tableros diferentes.';

  @override
  String get trophyMasterOfAnglesTitle => 'Maestro de Ángulos';

  @override
  String get trophyMasterOfAnglesDesc =>
      'Completa un puzle complejo con muchos puntos redirigidos huérfanos.';

  @override
  String get trophyHalfwayToGloryTitle => 'A Mitad de la Gloria';

  @override
  String get trophyHalfwayToGloryDesc =>
      'Alcanza el nivel 125, estableciendo tu dominio de mitad de partida.';

  @override
  String get trophyTheStrategistTitle => 'El Estratega';

  @override
  String get trophyTheStrategistDesc =>
      'Usa todos los objetos disponibles al menos una vez en una misma sesión.';

  @override
  String get trophyQuickSilverTitle => 'Mercurio';

  @override
  String get trophyQuickSilverDesc =>
      'Acumula 5 minutos de juego rápido en el modo Contrarreloj.';

  @override
  String get trophyIronWillTitle => 'Voluntad de Hierro';

  @override
  String get trophyIronWillDesc =>
      'Gana un nivel de jefe tras bajar a tu última vida.';

  @override
  String get trophyGoldenTouchTitle => 'Toque Dorado';

  @override
  String get trophyGoldenTouchDesc =>
      'Desbloquea tu primer tablero o tema de flecha personalizado.';

  @override
  String get trophyDeepDiverTitle => 'Buceador Profundo';

  @override
  String get trophyDeepDiverDesc =>
      'Alcanza el nivel 150 mientras el laberinto se vuelve exponencialmente complejo.';

  @override
  String get trophyThePuzzlerTitle => 'El Enigmista';

  @override
  String get trophyThePuzzlerDesc =>
      'Completa 50 tableros de puzle generados proceduralmente.';

  @override
  String get trophySharpShooterTitle => 'Tirador Certero';

  @override
  String get trophySharpShooterDesc =>
      'Termina 20 niveles usando el mínimo de movimientos posible.';

  @override
  String get trophyVaultKeeperTitle => 'Guardián de la Bóveda';

  @override
  String get trophyVaultKeeperDesc =>
      'Acumula un total de 500 monedas de juego y recompensas de anuncios.';

  @override
  String get trophyMilestoneMasterTitle => 'Maestro de Hitos';

  @override
  String get trophyMilestoneMasterDesc =>
      'Alcanza el nivel 200 — dos quintos del camino al máximo de 500.';

  @override
  String get trophyBossSlayerTitle => 'Cazador de Jefes';

  @override
  String get trophyBossSlayerDesc =>
      'Derrota 8 niveles de jefe seguidos sin una sola derrota.';

  @override
  String get trophyTimeBenderTitle => 'Distorsionador del Tiempo';

  @override
  String get trophyTimeBenderDesc =>
      'Congela el tiempo con éxito 10 veces en niveles contrarreloj intensos.';

  @override
  String get trophyResilientSpiritTitle => 'Espíritu Resiliente';

  @override
  String get trophyResilientSpiritDesc =>
      'Recupérate de un game over usando una recompensa de anuncio.';

  @override
  String get trophyBoardCollectorTitle => 'Coleccionista de Tableros';

  @override
  String get trophyBoardCollectorDesc =>
      'Desbloquea 5 temas de tablero personalizados para tu colección.';

  @override
  String get trophyApexPredatorTitle => 'Depredador Alfa';

  @override
  String get trophyApexPredatorDesc =>
      'Alcanza el nivel 250 — la mitad de la actual campaña de puzles.';

  @override
  String get trophyFlawlessExecutionTitle => 'Ejecución Impecable';

  @override
  String get trophyFlawlessExecutionDesc =>
      'Consigue 3 estrellas en 100 niveles distintos.';

  @override
  String get trophyTacticalMindsetTitle => 'Mente Táctica';

  @override
  String get trophyTacticalMindsetDesc =>
      'Resuelve un puzle de nivel divino sin usar pistas.';

  @override
  String get trophyDailyDevoteeTitle => 'Devoto Diario';

  @override
  String get trophyDailyDevoteeDesc =>
      'Mantén una racha de 7 días en tu registro de recompensas diarias.';

  @override
  String get trophyMonumentalPioneerTitle => 'Pionero Monumental';

  @override
  String get trophyMonumentalPioneerDesc =>
      'Desbloquea tu primer trofeo monumental puramente decorativo.';

  @override
  String get trophyHighClimberTitle => 'El Escalador';

  @override
  String get trophyHighClimberDesc =>
      'Alcanza el nivel 300 — tres quintos del camino a la cima de 500.';

  @override
  String get trophyGrandmasterTitle => 'Gran Maestro';

  @override
  String get trophyGrandmasterDesc =>
      'Alcanza el nivel 350, conquistando los enredos más complejos.';

  @override
  String get trophyEternalFlameTitle => 'Llama Eterna';

  @override
  String get trophyEternalFlameDesc =>
      'Mantén una racha increíble de 14 días de inicio de sesión.';

  @override
  String get trophyIroncladTitle => 'Blindado';

  @override
  String get trophyIroncladDesc =>
      'Alcanza el nivel 400 — cuatro quintos del camino a la cima.';

  @override
  String get trophyPerfectionistTitle => 'Perfeccionista';

  @override
  String get trophyPerfectionistDesc =>
      'Consigue 3 estrellas en todos los niveles del 1 al 400.';

  @override
  String get trophyTitanOfTheMazeTitle => 'Titán del Laberinto';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'Alcanza el nivel 450, entre los solucionadores de élite.';

  @override
  String get trophyThe500ClubTitle => 'El Club de los 500';

  @override
  String get trophyThe500ClubDesc =>
      'Alcanza el nivel 500, ¡la cima máxima actual del puzle!';

  @override
  String get trophyLivingLegendTitle => 'Leyenda Viva';

  @override
  String get trophyLivingLegendDesc =>
      'Supera el nivel 500 con 3 estrellas y cero errores.';

  @override
  String get trophyMonumentOfTimeTitle => 'Monumento al Tiempo';

  @override
  String get trophyMonumentOfTimeDesc =>
      'Artefacto monumental de prestigio por dedicar más de 10 horas activas a escapar de laberintos.';

  @override
  String get trophyAbsoluteVoidTitle => 'El Vacío Absoluto';

  @override
  String get trophyAbsoluteVoidDesc =>
      'Trofeo monumental de prestigio negro absoluto otorgado por maximizar las funciones clave de progreso.';

  @override
  String get trophyInfiniteHorizonTitle => 'Horizonte Infinito';

  @override
  String get trophyInfiniteHorizonDesc =>
      'Trofeo monumental de reconocimiento: el viaje más allá del nivel 500 nunca termina.';

  @override
  String timeBonusAmount(int seconds) {
    return '+${seconds}s';
  }

  @override
  String get heartsAlreadyFull => 'Las vidas ya están llenas';

  @override
  String timeFreezeWait(int seconds) {
    return 'Espera ${seconds}s más antes de usar Congelar tiempo';
  }

  @override
  String get tapRockToDestroy => 'Toca una roca para destruirla';

  @override
  String get noSolvableArrowFound =>
      'No se encontró ninguna flecha solucionable';

  @override
  String get nothingToUndo => 'Nada que deshacer';

  @override
  String get blitzCompleteTitle => '¡Blitz completado!';

  @override
  String get blitzOverTitle => 'Blitz terminado';

  @override
  String get blitzSplashStage => 'ETAPA';

  @override
  String blitzPoints(int score) {
    return '$score pts';
  }

  @override
  String get arrowSpeedEscapeSpeed => 'Velocidad de escape';

  @override
  String get arrowSpeedSlow => 'Lenta';

  @override
  String get arrowSpeedNormal => 'Normal';

  @override
  String get arrowSpeedFast => 'Rápida';

  @override
  String get accentColorLabel => 'Color de acento';

  @override
  String get settingsShareFriends => 'Compartir con amigos';

  @override
  String get settingsSharingSoon => 'Compartir próximamente';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTermsConditions => 'Términos y condiciones';

  @override
  String get settingsChooseLanguage => 'Elegir idioma';

  @override
  String settingsVersionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortugueseBR => 'Portugués (BR)';

  @override
  String get languageIndonesian => 'Indonesio';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageFrench => 'Francés';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'Trofeos ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'Nv $level';
  }

  @override
  String get trophiesPerkHeart => '✨ Ventaja: +1 vida máxima permanente';

  @override
  String get leaderboardTitle => 'Clasificación';

  @override
  String get leaderboardComingSoon => 'Próximamente';

  @override
  String get leaderboardDescription =>
      'Compite con jugadores de todo el mundo. Tus puntuaciones y clasificaciones aparecerán aquí cuando la clasificación en línea esté disponible.';

  @override
  String get inventoryTitle => 'Inventario';

  @override
  String get inventoryTabArrows => 'Flechas';

  @override
  String get inventoryTabBoards => 'Tableros';

  @override
  String get inventoryTabItems => 'Objetos';

  @override
  String get inventoryEquipped => 'Equipado';

  @override
  String get inventoryTapToEquip => 'Toca para equipar';

  @override
  String inventoryReachLevel(int level) {
    return 'Alcanza el nivel $level para desbloquear';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'Nv $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return 'Faltan $count monedas';
  }

  @override
  String inventoryBuyItemTitle(String item) {
    return '¿Comprar $item?';
  }

  @override
  String inventoryUnlockTitle(String title) {
    return '¿Desbloquear $title?';
  }

  @override
  String inventoryCoinsPrice(int count) {
    return '$count monedas';
  }

  @override
  String get inventoryBuy => 'Comprar';

  @override
  String get rushDifficultyEasy => 'Fácil';

  @override
  String get rushDifficultyHard => 'Difícil';

  @override
  String get rushDifficultyImpossible => 'Imposible';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePlayingAsGuest => 'Jugando como invitado';

  @override
  String get profileSignInSuccess => 'Sesión iniciada — progreso sincronizado';

  @override
  String profileSignInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get profileSaveYourProgress => 'Guarda tu progreso';

  @override
  String get profileGuestBody =>
      'Las cuentas de invitado solo viven en este dispositivo. Inicia sesión para respaldar tu nivel, monedas y trofeos.';

  @override
  String get profileContinueWithEmail => 'Continuar con correo';

  @override
  String get profileSignOutTitle => '¿Cerrar sesión?';

  @override
  String get profileSignOutBody =>
      'Tu guardado en la nube se mantiene. Este dispositivo se restablecerá a una cuenta de invitado nueva y comenzará desde el nivel 1.';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileDeleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get profileDeleteAccountBody =>
      'Esto eliminará permanentemente tu guardado en la nube y tu cuenta. Esta acción no se puede deshacer.';

  @override
  String get profileDelete => 'Eliminar';

  @override
  String profileDeleteFailed(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get profileSignedInBody =>
      'Tu progreso está respaldado en la nube. Inicia sesión en cualquier dispositivo con la misma cuenta para continuar.';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileStatLevel => 'Nivel';

  @override
  String get profileStatStars => 'Estrellas';

  @override
  String get profileStatTrophies => 'Trofeos';

  @override
  String get profileTabSignIn => 'Iniciar sesión';

  @override
  String get profileTabCreateAccount => 'Crear cuenta';

  @override
  String get profileCreateAccountTitle => 'Crea tu cuenta';

  @override
  String get profileWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get profileGuestProgressCarries =>
      'Tu progreso de invitado se transferirá.';

  @override
  String get profileSignInRestoreBody =>
      'Inicia sesión para restaurar tu progreso desde otro dispositivo.';

  @override
  String get profileNameHint => 'Nombre (opcional)';

  @override
  String get profileEmailHint => 'Correo';

  @override
  String get profilePasswordHint => 'Contraseña';

  @override
  String get profileShowPassword => 'Mostrar contraseña';

  @override
  String get profileHidePassword => 'Ocultar contraseña';

  @override
  String get profileGeneratePassword => 'Generar contraseña';

  @override
  String get profilePasswordMinLength =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get profileStrengthTooShort => 'Muy corta';

  @override
  String get profileStrengthOkay => 'Aceptable';

  @override
  String get profileStrengthGood => 'Buena';

  @override
  String get profileStrengthStrong => 'Fuerte';

  @override
  String get profileErrorEmailSignUp =>
      'Ese correo ya está registrado. Prueba Iniciar sesión.';

  @override
  String get profileErrorEmailSignIn =>
      'Ese correo ya está registrado. Revisa tu contraseña o restablécelo desde el enlace del correo.';

  @override
  String get profileErrorInvalidCredentials =>
      'Correo o contraseña incorrectos. Inténtalo de nuevo.';

  @override
  String get profileErrorPassword =>
      'Contraseña no aceptada. Usa 8+ caracteres con letras y números, y evita palabras comunes como \"password\".';

  @override
  String get profileErrorInvalidEmail => 'Ese correo parece inválido.';

  @override
  String get profileErrorSessionExpired =>
      'Sesión expirada. Cierra la app, ábrela de nuevo e inténtalo otra vez.';

  @override
  String get profileErrorRateLimit =>
      'Demasiados intentos. Espera un minuto e inténtalo de nuevo.';

  @override
  String get profileErrorServerBusy =>
      'El servidor está ocupado. Inténtalo en un momento.';

  @override
  String get profileErrorSignUpGeneric =>
      'Error al registrarse. Revisa tus datos e inténtalo de nuevo.';

  @override
  String get profileErrorSignInGeneric =>
      'Error al iniciar sesión. Revisa tu correo y contraseña.';

  @override
  String get profileEnterValidEmail => 'Introduce un correo válido.';

  @override
  String get profileEnterPassword => 'Introduce tu contraseña.';

  @override
  String get profileEmailAlreadyPrompt =>
      'Ese correo ya tiene una cuenta. Introduce tu contraseña para iniciar sesión.';

  @override
  String get profileSomethingWrong => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get profileCreateAccountButton => 'Crear cuenta';

  @override
  String get profileSignInButton => 'Iniciar sesión';

  @override
  String get profileAlreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get profileDontHaveAccount => '¿No tienes cuenta? Crea una';

  @override
  String get homePlayer => 'Jugador';

  @override
  String homeLevelStars(int level, int stars) {
    return 'Nivel $level · $stars estrellas';
  }

  @override
  String get homeContinueLabel => 'CONTINUAR';

  @override
  String homeLevelNumber(int level) {
    return 'Nivel $level';
  }

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeDaily => 'Diario';

  @override
  String get homeDailyReady => 'Listo para jugar';

  @override
  String get homeDailyClaimed => 'Reclamado hoy';

  @override
  String get homeLeaderboard => 'Clasificación';

  @override
  String get homeComingSoon => 'Próximamente';

  @override
  String get homeInventory => 'Inventario';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'Todo desbloqueado · $count objetos';
  }

  @override
  String get homeInventoryBrowse => 'Explora tu equipo';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items objetos';
  }

  @override
  String get homeTrophies => 'Trofeos';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$unlocked de $total';
  }

  @override
  String get privacyWelcomeTitle => 'Bienvenido a Arrow Puzzle';

  @override
  String get privacyWelcomeSubtitle =>
      'Antes de empezar, revisa y acepta nuestros términos.';

  @override
  String get privacyBulletLocal =>
      'Tu progreso se guarda localmente en tu dispositivo.';

  @override
  String get privacyBulletCloud =>
      'Las cuentas opcionales sincronizan el progreso en la nube.';

  @override
  String get privacyBulletAds =>
      'El juego muestra anuncios para seguir siendo gratis.';

  @override
  String get privacyPolicyLink => 'Política de privacidad';

  @override
  String get privacyTermsLink => 'Términos y condiciones';

  @override
  String get privacyAcceptButton => 'Aceptar y continuar';

  @override
  String get privacyAgreeFooter =>
      'Al tocar arriba aceptas nuestros Términos y condiciones.';

  @override
  String get bottomNavHome => 'Inicio';

  @override
  String get bottomNavDaily => 'Diario';

  @override
  String get bottomNavInventory => 'Inventario';

  @override
  String get bottomNavSettings => 'Ajustes';

  @override
  String gameTopBarScore(int score) {
    return 'Puntos: $score';
  }

  @override
  String get gameTopBarRandom => 'Aleatorio';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'Nv.$level';
  }

  @override
  String get gameModeZenMode => 'Modo Zen';

  @override
  String get howToPlayTitle => 'CÓMO JUGAR';

  @override
  String get howToPlayBasics => 'LO BÁSICO';

  @override
  String get howToPlayBoardElements => 'ELEMENTOS DEL TABLERO';

  @override
  String get howToPlayGameModes => 'MODOS DE JUEGO';

  @override
  String get howToPlayProStrategies => 'ESTRATEGIAS PRO';

  @override
  String get howToPlayCoreTitle => 'Objetivo principal';

  @override
  String get howToPlayCoreDesc =>
      'Tu meta es despejar toda la cuadrícula guiando cada flecha fuera del tablero. Cuando no queden flechas, el nivel estará completo.';

  @override
  String get howToPlayMovementTitle => 'Movimiento de flechas';

  @override
  String get howToPlayMovementDesc =>
      'Toca cualquier flecha para lanzarla. Las flechas se deslizan en la dirección exacta a la que apunta su punta: arriba, abajo, izquierda o derecha. Aunque el cuerpo de la flecha esté doblado, siempre sale siguiendo su punta.';

  @override
  String get howToPlayObstaclesTitle => 'Obstáculos y colisiones';

  @override
  String get howToPlayObstaclesDesc =>
      'Una flecha solo puede escapar si su camino de salida está completamente despejado. Si otra flecha bloquea el paso, la flecha tocada vibrará y se quedará en su sitio.';

  @override
  String get howToPlayLivesTitle => 'Vidas y salud';

  @override
  String get howToPlayLivesDesc =>
      'En el modo Clásico empiezas con 3 vidas. Tocar una flecha bloqueada cuesta 1 vida. Si pierdes las 3, debes reiniciar el nivel. Puedes activar Vidas Infinitas en Ajustes cuando quieras.';

  @override
  String get howToPlayTurnDotsTitle => 'Puntos giratorios (redirigidores)';

  @override
  String get howToPlayTurnDotsDesc =>
      'Busca puntos circulares en celdas vacías marcados con pequeñas flechas. Cuando una flecha deslizante cruza un Punto Giratorio, gira al instante en la dirección del punto y lo consume, abriendo rutas inesperadas.';

  @override
  String get howToPlayCombosTitle => 'Combos y rachas';

  @override
  String get howToPlayCombosDesc =>
      'Libera flechas en rápida sucesión (en menos de 1,5 segundos) para activar combos. Encadenar escapes consecutivos acumula impulso y multiplica la puntuación.';

  @override
  String get howToPlayClassicTitle => 'Modo Clásico';

  @override
  String get howToPlayClassicDesc =>
      'La progresión de campaña estándar. Avanza por niveles artesanales y procedurales con tamaño, máscaras y complejidad crecientes, con 3 vidas.';

  @override
  String get howToPlayZenTitle => 'Modo Zen';

  @override
  String get howToPlayZenDesc =>
      'Relajación pura sin estrés. Sin vidas que perder, sin tiempo, sin fallos. Ideal para relajarse y practicar tableros complejos.';

  @override
  String get howToPlayTimeAttackTitle => 'Contrarreloj';

  @override
  String get howToPlayTimeAttackDesc =>
      '¡Carrera frenética contra el reloj! Cada flecha que escapas con éxito suma segundos extra a tu cuenta atrás.';

  @override
  String get howToPlayMultiplayerTitle => 'Salas multijugador';

  @override
  String get howToPlayMultiplayerDesc =>
      'Crea o únete con códigos semilla. Ambos jugadores compiten en el mismo diseño aleatorio para ver quién lo resuelve más rápido.';

  @override
  String get howToPlayRandomTitle => 'Puzles aleatorios';

  @override
  String get howToPlayRandomDesc =>
      'Genera puzles infinitos bajo demanda en dificultades Fácil, Media, Difícil, Maestro y Experto sin afectar tu progreso de campaña.';

  @override
  String get howToPlayUnpeelTitle => 'Pela desde el borde';

  @override
  String get howToPlayUnpeelDesc =>
      'Empieza escaneando los bordes exteriores. Las flechas que apuntan hacia afuera pueden escapar de inmediato, liberando carriles clave.';

  @override
  String get howToPlayTraceTitle => 'Rastrea bloqueadores al revés';

  @override
  String get howToPlayTraceDesc =>
      'Cuando una flecha esté bloqueada, encuentra qué flecha la bloquea y luego qué bloquea a esa segunda. Liberar el último bloqueador desbloquea todo lo demás.';

  @override
  String get howToPlayTapAssistTitle => 'Activa el Toque Asistido';

  @override
  String get howToPlayTapAssistDesc =>
      'Si juegas en pantallas pequeñas o sueles tocar entre flechas apretadas, activa el Toque Asistido en Ajustes para asignar automáticamente los toques a la flecha más cercana.';

  @override
  String get multiplayerTitle => 'MULTIJUGADOR';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return '¡Código de sala $code copiado al portapapeles!';
  }

  @override
  String get multiplayerHostRoom => 'SALA ANFITRIÓN';

  @override
  String get multiplayerHostBody =>
      '¡Comparte este código con un amigo para competir en el mismo diseño de puzle!';

  @override
  String get multiplayerNewCode => 'Nuevo código';

  @override
  String get multiplayerCopyCode => 'Copiar código';

  @override
  String get multiplayerStartMatch => 'INICIAR PARTIDA';

  @override
  String get multiplayerJoinRoom => 'UNIRSE A SALA';

  @override
  String get multiplayerJoinBody =>
      'Introduce o pega un código de sala para unirte.';

  @override
  String get multiplayerRoomCodeHint => 'p. ej. ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'Introduce un código de sala';

  @override
  String get multiplayerJoinMatch => 'UNIRSE';

  @override
  String get zenCardSubtitle => 'Sin tiempo. Sin límites. Solo resuelve.';

  @override
  String get profileSyncing => 'Sincronizando...';

  @override
  String get profileSyncFailed => 'Error al sincronizar';

  @override
  String get gameModeTimeBlitz => 'Contrarreloj Extremo';

  @override
  String get timeBlitzDesc =>
      'Toca flechas para ganar tiempo. Los toques bloqueados cuestan tiempo. Sobrevive lo máximo posible.';

  @override
  String get timeBlitzOverTitle => 'Contrarreloj Extremo Terminado';

  @override
  String get timeBlitzScoreLabel => 'FLECHAS ELIMINADAS';

  @override
  String get timeBlitzLevelsLabel => 'Niveles alcanzados';

  @override
  String get profileEditName => 'Editar nombre';

  @override
  String get profileSave => 'Guardar';

  @override
  String get profileUpdated => 'Perfil actualizado';
}
