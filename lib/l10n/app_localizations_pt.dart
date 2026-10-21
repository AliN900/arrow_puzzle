// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppStringsPt extends AppStrings {
  AppStringsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Arrow Puzzle';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonResume => 'Continuar';

  @override
  String get buttonExit => 'Sair';

  @override
  String get gameModeClassic => 'Clássico';

  @override
  String get gameModeTimeAttack => 'Contra o tempo';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearance => 'APARÊNCIA';

  @override
  String get settingsDarkMode => 'Modo escuro';

  @override
  String get settingsSoundEffects => 'Efeitos sonoros';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsVibration => 'Vibração';

  @override
  String get settingsArrowSpeed => 'VELOCIDADE DAS FLECHAS';

  @override
  String get settingsAbout => 'SOBRE';

  @override
  String get dialogExitTitle => 'Sair do jogo?';

  @override
  String get dialogExitMessage => 'Tem certeza de que deseja sair?';

  @override
  String get profileSaveToCloud => 'Salvar na nuvem';

  @override
  String get profileSynced => 'Sincronizado';

  @override
  String get profileSignedIn => 'Conectado';

  @override
  String get dailyRewardsTitle => 'RECOMPENSAS DIÁRIAS';

  @override
  String get blitzTitle => 'Blitz';

  @override
  String get unlockTitle => 'Parabéns!';

  @override
  String get unlockSubtitle => 'Novo tabuleiro desbloqueado';

  @override
  String get unlockAddedToInventory => 'Adicionado ao seu inventário';

  @override
  String unlockCoinsEarned(int count) {
    return '+$count MOEDAS';
  }

  @override
  String get buttonCheckInventory => 'Ver inventário';

  @override
  String get buttonMainMenu => 'Menu principal';

  @override
  String get dailyChallengesTitle => 'Desafios diários';

  @override
  String get dailyChallengesSubtitle =>
      'Complete modos especiais para ganhar recompensas bônus.';

  @override
  String get dailyRewardsSubtitle => 'Resgate sua recompensa de sequência';

  @override
  String get activeChallengesTitle => 'Desafios ativos';

  @override
  String get blitzSubtitle =>
      'Enfrente uma sequência de fases. Os tempos apertam. As vidas continuam.';

  @override
  String get badgeNew => 'NOVO';

  @override
  String get mineArrowsTitle => 'Minas de flechas';

  @override
  String get mineArrowsSubtitle =>
      'Limpe flechas enquanto desvia de minas escondidas!';

  @override
  String get badgeComingSoon => 'EM BREVE';

  @override
  String get mineArrowsComingSoonSnack =>
      'O desafio Minas de flechas chegará em breve!';

  @override
  String get dailyRewardsLabel => 'RECOMPENSAS DIÁRIAS';

  @override
  String dayOfMax(int day, int max) {
    return 'Dia $day de $max';
  }

  @override
  String get comeBackTomorrow => 'Volte amanhã';

  @override
  String plusCoins(int count) {
    return '+$count moedas';
  }

  @override
  String plusItems(int count) {
    return '+ $count 🎁';
  }

  @override
  String get claimForFree => 'Resgatar grátis';

  @override
  String get loadingLabel => 'Carregando...';

  @override
  String watchAdCoins(int coins) {
    return 'Assistir anúncio → +$coins moedas';
  }

  @override
  String get notNow => 'Agora não';

  @override
  String get claimedToday => 'Resgatado hoje!';

  @override
  String nextRewardIn(String time) {
    return 'Próxima recompensa em $time';
  }

  @override
  String get closeLabel => 'Fechar';

  @override
  String get claimedSnack => 'Resgatado!';

  @override
  String get arrowRushTitle => 'Arrow Rush';

  @override
  String reachLevelToUnlock(int level, String tier) {
    return 'Alcance o nível $level para desbloquear $tier';
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
  String get adNotAvailable => 'Anúncio indisponível, tente mais tarde';

  @override
  String get adBadge => 'AD';

  @override
  String get homeButton => 'Início';

  @override
  String get gameOverTimeUp => 'Tempo esgotado!';

  @override
  String get gameOverOutOfTime => 'Sem tempo!';

  @override
  String get gameOverOutOfLives => 'Sem vidas!';

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
    return 'Puzzles resolvidos: $cleared\nNível final: $level';
  }

  @override
  String gameOverWatchAdReward(String reward) {
    return 'Assistir anúncio → $reward';
  }

  @override
  String get gameOverStartNewRun => 'Nova partida';

  @override
  String get gameOverRestartLevel => 'Reiniciar nível';

  @override
  String get levelCompleteTitle => 'Nível concluído!';

  @override
  String get levelCompleteNewTrophy => 'NOVO TROFÉU';

  @override
  String levelCompleteRandomItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count ITENS ALEATÓRIOS',
      one: '+$count ITEM ALEATÓRIO',
    );
    return '$_temp0';
  }

  @override
  String get levelCompleteFinishedGame => 'Você terminou o jogo!';

  @override
  String get levelCompleteNextLevel => 'Próximo nível';

  @override
  String get levelCompleteCoinsDoubled => 'Moedas duplicadas!';

  @override
  String get levelCompleteDoubleCoins => 'Duplicar moedas';

  @override
  String get settingsAboutCredits => 'Sobre o Jogo e Créditos';

  @override
  String get aboutTitle => 'Sobre e Créditos';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutDeveloper =>
      'Projetado e Desenvolvido por Ali Hussein (ahb.Dev)';

  @override
  String get aboutOriginalConcept =>
      'Conceito original: ArrowEscape por sidhant947';

  @override
  String get aboutVisitWebsite => 'Visitar o Site do ahb.Dev';

  @override
  String get aboutMusicTitle => 'MÚSICA (OpenGameArt)';

  @override
  String get aboutUnderwaterTheme => 'Tema Subaquático';

  @override
  String get aboutCallerTheme => 'Tema do Menu Principal';

  @override
  String get aboutGrooveTheme => 'Groove do Modo Rush';

  @override
  String get aboutMusicSource =>
      'Todas as faixas de música são provenientes do OpenGameArt.org.';

  @override
  String get aboutIconsTitle => 'ÍCONES (SVG Repo)';

  @override
  String get aboutIconsCredit1 =>
      'Pássaro, Diamante, Óculos, Peixe, Baleia, Flor, Foguete, Chave, Estrela';

  @override
  String get aboutIconsCredit2 => 'Borboleta, Tartaruga';

  @override
  String get aboutIconsCredit3 => 'Coroa, Casa, Árvore';

  @override
  String get aboutIconsCredit4 => 'Coração';

  @override
  String get aboutIconsAuthors =>
      'Por Noah Jacobus, Konstantin Filatov, Solar Icons, Dazzle UI, pixelbazaar, & Iconhub';

  @override
  String get aboutVisitSvgRepo => 'Visitar SVGRepo.com';

  @override
  String get aboutOpenSourceTitle => 'CÓDIGO ABERTO';

  @override
  String get aboutOpenSourceBody =>
      'Este jogo foi construído usando incríveis tecnologias de código aberto:';

  @override
  String get aboutCopyright => '© 2026 ahb.Dev. Todos os direitos reservados.';

  @override
  String gameTimedLevel(String seconds) {
    return 'NÍVEL CRONOMETRADO · ${seconds}s';
  }

  @override
  String get gameSolverCalculating => 'Calculando solução...';

  @override
  String get gameSolverUnsolvable => '❌ IRRESOLVÍVEL! O nível está travado.';

  @override
  String get pauseTitle => 'Pausado';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get pauseRestart => 'Reiniciar';

  @override
  String get pauseMainMenu => 'Menu principal';

  @override
  String get itemBombName => 'Mina';

  @override
  String get itemBombDesc => 'Remova uma mina do tabuleiro';

  @override
  String get itemHintName => 'Dica';

  @override
  String get itemHintDesc => 'Revela a próxima flecha resolvível';

  @override
  String get itemUndoName => 'Desfazer';

  @override
  String get itemUndoDesc => 'Traz de volta a última flecha escapada';

  @override
  String get itemHeartFlaskName => 'Frasco de vida';

  @override
  String get itemHeartFlaskDesc => 'Restaura uma vida';

  @override
  String get itemTimeFreezeName => 'Congelar tempo';

  @override
  String get itemTimeFreezeDesc => 'Adiciona 30 segundos ao cronômetro';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeClassic => 'Clássico';

  @override
  String get themeRetro => 'Retrô';

  @override
  String get themeCyber => 'Cyber';

  @override
  String get themeHacker => 'Hacker';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeBlueprint => 'Planta';

  @override
  String get themeForest => 'Floresta';

  @override
  String get themePastel => 'Pastel';

  @override
  String get themeSunset => 'Pôr do sol';

  @override
  String get themeRainbow => 'Arco-íris';

  @override
  String get boardMinimal => 'Minimalista';

  @override
  String get boardNebula => 'Nebulosa';

  @override
  String get boardBlueprint => 'Planta';

  @override
  String get boardForest => 'Floresta';

  @override
  String get boardOcean => 'Oceano';

  @override
  String get boardEmber => 'Brasa';

  @override
  String get boardCosmic => 'Cósmico';

  @override
  String get boardGeometric => 'Geométrico';

  @override
  String get boardGold => 'Ouro';

  @override
  String get boardHacker => 'Hacker';

  @override
  String get boardPaper => 'Papel';

  @override
  String get boardIce => 'Gelo';

  @override
  String get boardSand => 'Areia';

  @override
  String get boardCloud => 'Nuvem';

  @override
  String get boardMint => 'Menta';

  @override
  String get boardRose => 'Rosa';

  @override
  String get boardLavender => 'Lavanda';

  @override
  String get boardSky => 'Céu';

  @override
  String get boardPearl => 'Pérola';

  @override
  String get boardHoney => 'Mel';

  @override
  String get trophyFirstEscapeTitle => '🌟 O PRIMEIRO DESPERTAR';

  @override
  String get trophyFirstEscapeDesc =>
      'Seu primeiro labirinto escapado! Você desbloqueou o portal para o Sistema de Troféus. Bem-vindo à jornada definitiva de puzzles da AHB.Dev!';

  @override
  String get trophyPointBlankTitle => 'À Queima-Roupa';

  @override
  String get trophyPointBlankDesc =>
      'Supere seu primeiro layout de puzzle com precisão.';

  @override
  String get trophyTrialOfTwoTitle => 'Provação dos Dois';

  @override
  String get trophyTrialOfTwoDesc =>
      'Domine a intensa restrição de duas vidas das primeiras provações.';

  @override
  String get trophyQuickThinkerTitle => 'Mente Rápida';

  @override
  String get trophyQuickThinkerDesc =>
      'Complete qualquer fase rapidamente sob um limite estendido de 20 segundos.';

  @override
  String get trophyArrowSmithTitle => 'Forjador de Flechas';

  @override
  String get trophyArrowSmithDesc =>
      'Complete 10 fases sem desistir ou reiniciar.';

  @override
  String get trophyCleanSlateTitle => 'Ficha Limpa';

  @override
  String get trophyCleanSlateDesc =>
      'Termine uma fase sem um único toque bloqueado.';

  @override
  String get trophySparkOfGeniusTitle => 'Faísca de Gênio';

  @override
  String get trophySparkOfGeniusDesc =>
      'Use sua primeira dica para encontrar um caminho em uma situação complicada.';

  @override
  String get trophyUnwindTitle => 'Relaxe';

  @override
  String get trophyUnwindDesc =>
      'Use seu primeiro desfazer para reverter um passo em falso.';

  @override
  String get trophyRockBreakerTitle => 'Quebra-Rocha';

  @override
  String get trophyRockBreakerDesc =>
      'Destrua seu primeiro obstáculo de rocha com uma flecha bomba tática.';

  @override
  String get trophySurvivalistBadgeTitle => 'O Sobrevivente';

  @override
  String get trophySurvivalistBadgeDesc =>
      'Conquistou as primeiras 25 provações! Melhora permanentemente suas vidas máximas de 2 para 3.';

  @override
  String get trophyWayfinderTitle => 'Guia';

  @override
  String get trophyWayfinderDesc =>
      'Alcance a fase 50 e prove seu domínio dos primeiros labirintos.';

  @override
  String get trophyTangleTamerTitle => 'Domador de Emaranhados';

  @override
  String get trophyTangleTamerDesc =>
      'Complete 10 fases seguidas sem um único erro direcional.';

  @override
  String get trophyTimeLordTitle => 'Senhor do Tempo';

  @override
  String get trophyTimeLordDesc =>
      'Sobreviva a uma provação cronometrada de nível divino com segundos de sobra.';

  @override
  String get trophyCenturyMarkTitle => 'Marca do Centenário';

  @override
  String get trophyCenturyMarkDesc =>
      'Alcance a fase 100 — um quinto do caminho até o topo de 500!';

  @override
  String get trophyBombTechnicianTitle => 'Técnico de Bombas';

  @override
  String get trophyBombTechnicianDesc =>
      'Destrua 25 rochas em sua campanha usando bombas táticas.';

  @override
  String get trophyUntouchableTitle => 'Intocável';

  @override
  String get trophyUntouchableDesc =>
      'Complete 5 fases seguidas sem perder uma única vida.';

  @override
  String get trophyStargazerTitle => 'Observador de Estrelas';

  @override
  String get trophyStargazerDesc =>
      'Ganhe 3 estrelas em 30 tabuleiros diferentes.';

  @override
  String get trophyMasterOfAnglesTitle => 'Mestre dos Ângulos';

  @override
  String get trophyMasterOfAnglesDesc =>
      'Complete um puzzle complexo com muitos pontos redirecionadores órfãos.';

  @override
  String get trophyHalfwayToGloryTitle => 'No Meio da Glória';

  @override
  String get trophyHalfwayToGloryDesc =>
      'Alcance a fase 125, estabelecendo seu domínio do meio do jogo.';

  @override
  String get trophyTheStrategistTitle => 'O Estrategista';

  @override
  String get trophyTheStrategistDesc =>
      'Use todos os itens disponíveis pelo menos uma vez na mesma sessão.';

  @override
  String get trophyQuickSilverTitle => 'Mercúrio';

  @override
  String get trophyQuickSilverDesc =>
      'Acumule 5 minutos de jogo em alta velocidade no modo Contra o Tempo.';

  @override
  String get trophyIronWillTitle => 'Vontade de Ferro';

  @override
  String get trophyIronWillDesc =>
      'Vença uma fase de chefe após cair até sua última vida.';

  @override
  String get trophyGoldenTouchTitle => 'Toque Dourado';

  @override
  String get trophyGoldenTouchDesc =>
      'Desbloqueie seu primeiro tabuleiro ou tema de flecha personalizado.';

  @override
  String get trophyDeepDiverTitle => 'Mergulhador Profundo';

  @override
  String get trophyDeepDiverDesc =>
      'Alcance a fase 150 enquanto o labirinto se torna exponencialmente complexo.';

  @override
  String get trophyThePuzzlerTitle => 'O Enigmista';

  @override
  String get trophyThePuzzlerDesc =>
      'Complete 50 tabuleiros de puzzle gerados proceduralmente.';

  @override
  String get trophySharpShooterTitle => 'Atirador Certeiro';

  @override
  String get trophySharpShooterDesc =>
      'Termine 20 fases usando o mínimo de movimentos possível.';

  @override
  String get trophyVaultKeeperTitle => 'Guardião do Cofre';

  @override
  String get trophyVaultKeeperDesc =>
      'Acumule um total de 500 moedas de gameplay e recompensas de anúncios.';

  @override
  String get trophyMilestoneMasterTitle => 'Mestre dos Marcos';

  @override
  String get trophyMilestoneMasterDesc =>
      'Alcance a fase 200 — dois quintos do caminho até o máximo de 500.';

  @override
  String get trophyBossSlayerTitle => 'Caçador de Chefes';

  @override
  String get trophyBossSlayerDesc =>
      'Derrote 8 fases de chefe seguidas sem uma única derrota.';

  @override
  String get trophyTimeBenderTitle => 'Distorcedor do Tempo';

  @override
  String get trophyTimeBenderDesc =>
      'Congele o tempo com sucesso 10 vezes em fases cronometradas intensas.';

  @override
  String get trophyResilientSpiritTitle => 'Espírito Resiliente';

  @override
  String get trophyResilientSpiritDesc =>
      'Recupere-se de um game over usando uma recompensa de anúncio.';

  @override
  String get trophyBoardCollectorTitle => 'Colecionador de Tabuleiros';

  @override
  String get trophyBoardCollectorDesc =>
      'Desbloqueie 5 temas de tabuleiro personalizados para sua coleção.';

  @override
  String get trophyApexPredatorTitle => 'Predador de Elite';

  @override
  String get trophyApexPredatorDesc =>
      'Alcance a fase 250 — a metade da campanha atual de puzzles.';

  @override
  String get trophyFlawlessExecutionTitle => 'Execução Impecável';

  @override
  String get trophyFlawlessExecutionDesc =>
      'Ganhe 3 estrelas em 100 fases diferentes.';

  @override
  String get trophyTacticalMindsetTitle => 'Mentalidade Tática';

  @override
  String get trophyTacticalMindsetDesc =>
      'Resolva um puzzle de nível divino sem usar nenhuma dica.';

  @override
  String get trophyDailyDevoteeTitle => 'Devoto Diário';

  @override
  String get trophyDailyDevoteeDesc =>
      'Mantenha uma sequência de 7 dias no seu registro de recompensas diárias.';

  @override
  String get trophyMonumentalPioneerTitle => 'Pioneiro Monumental';

  @override
  String get trophyMonumentalPioneerDesc =>
      'Desbloqueie seu primeiro troféu monumental puramente decorativo.';

  @override
  String get trophyHighClimberTitle => 'O Escalador';

  @override
  String get trophyHighClimberDesc =>
      'Alcance a fase 300 — três quintos do caminho até o topo de 500.';

  @override
  String get trophyGrandmasterTitle => 'Grão-Mestre';

  @override
  String get trophyGrandmasterDesc =>
      'Alcance a fase 350, conquistando os emaranhados mais complexos.';

  @override
  String get trophyEternalFlameTitle => 'Chama Eterna';

  @override
  String get trophyEternalFlameDesc =>
      'Mantenha uma sequência incrível de 14 dias consecutivos de login.';

  @override
  String get trophyIroncladTitle => 'Blindado';

  @override
  String get trophyIroncladDesc =>
      'Alcance a fase 400 — quatro quintos do caminho até o topo final.';

  @override
  String get trophyPerfectionistTitle => 'Perfeccionista';

  @override
  String get trophyPerfectionistDesc =>
      'Ganhe 3 estrelas em todas as fases da 1 até a 400.';

  @override
  String get trophyTitanOfTheMazeTitle => 'Titã do Labirinto';

  @override
  String get trophyTitanOfTheMazeDesc =>
      'Alcance a fase 450, entre os solucionadores de elite.';

  @override
  String get trophyThe500ClubTitle => 'O Clube dos 500';

  @override
  String get trophyThe500ClubDesc =>
      'Alcance a fase 500, o topo máximo atual da grade de puzzles!';

  @override
  String get trophyLivingLegendTitle => 'Lenda Viva';

  @override
  String get trophyLivingLegendDesc =>
      'Complete a fase 500 com 3 estrelas e zero erros.';

  @override
  String get trophyMonumentOfTimeTitle => 'Monumento ao Tempo';

  @override
  String get trophyMonumentOfTimeDesc =>
      'Artefato monumental de prestígio por dedicar mais de 10 horas ativas escapando de labirintos.';

  @override
  String get trophyAbsoluteVoidTitle => 'O Vazio Absoluto';

  @override
  String get trophyAbsoluteVoidDesc =>
      'Troféu monumental de prestígio totalmente negro concedido por maximizar os principais recursos de progressão.';

  @override
  String get trophyInfiniteHorizonTitle => 'Horizonte Infinito';

  @override
  String get trophyInfiniteHorizonDesc =>
      'Troféu monumental de reconhecimento: a jornada além da fase 500 nunca termina.';

  @override
  String timeBonusAmount(int seconds) {
    return '+${seconds}s';
  }

  @override
  String get heartsAlreadyFull => 'As vidas já estão cheias';

  @override
  String timeFreezeWait(int seconds) {
    return 'Aguarde mais ${seconds}s antes de usar Congelar tempo';
  }

  @override
  String get tapRockToDestroy => 'Toque em uma rocha para destruí-la';

  @override
  String get noSolvableArrowFound => 'Nenhuma flecha resolvível encontrada';

  @override
  String get nothingToUndo => 'Nada para desfazer';

  @override
  String get blitzSplashStage => 'ETAPA';

  @override
  String get arrowSpeedEscapeSpeed => 'Velocidade de escape';

  @override
  String get arrowSpeedSlow => 'Lenta';

  @override
  String get arrowSpeedNormal => 'Normal';

  @override
  String get arrowSpeedFast => 'Rápida';

  @override
  String get accentColorLabel => 'Cor de destaque';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidade';

  @override
  String get settingsTermsConditions => 'Termos e condições';

  @override
  String get settingsChooseLanguage => 'Escolher idioma';

  @override
  String settingsVersionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortugueseBR => 'Português (BR)';

  @override
  String get languageIndonesian => 'Indonésio';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageFrench => 'Francês';

  @override
  String trophiesTitle(int unlocked, int total) {
    return 'Troféus ($unlocked / $total)';
  }

  @override
  String trophiesLevelBadge(int level) {
    return 'Nv $level';
  }

  @override
  String get trophiesPerkHeart => '✨ Vantagem: +1 vida máxima permanente';

  @override
  String get leaderboardTitle => 'Classificação';

  @override
  String get leaderboardTabWeekly => 'Semanal';

  @override
  String get leaderboardTabMonthly => 'Mensal';

  @override
  String get leaderboardTabAllTime => 'Geral';

  @override
  String get leaderboardSignInToRank => 'Faça login para aparecer';

  @override
  String get leaderboardEmptyState => 'Sem pontuações ainda';

  @override
  String get leaderboardLevel => 'Nível';

  @override
  String get leaderboardStars => 'Estrelas';

  @override
  String get inventoryTitle => 'Inventário';

  @override
  String get inventoryTabArrows => 'Flechas';

  @override
  String get inventoryTabBoards => 'Tabuleiros';

  @override
  String get inventoryTabItems => 'Itens';

  @override
  String get inventoryEquipped => 'Equipado';

  @override
  String get inventoryTapToEquip => 'Toque para equipar';

  @override
  String inventoryReachLevel(int level) {
    return 'Alcance o nível $level para desbloquear';
  }

  @override
  String inventoryLevelBadge(int level) {
    return 'Nv $level';
  }

  @override
  String inventoryNeedMoreCoins(int count) {
    return 'Faltam $count moedas';
  }

  @override
  String get rushDifficultyEasy => 'Fácil';

  @override
  String get rushDifficultyHard => 'Difícil';

  @override
  String get rushDifficultyImpossible => 'Impossível';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePlayingAsGuest => 'Jogando como convidado';

  @override
  String get profileSaveYourProgress => 'Salve seu progresso';

  @override
  String get profileGuestBody =>
      'Contas de convidado vivem apenas neste dispositivo. Entre para fazer backup do seu nível, moedas e troféus.';

  @override
  String get profileContinueWithEmail => 'Continuar com e-mail';

  @override
  String get profileSignOutTitle => 'Sair?';

  @override
  String get profileSignOutBody =>
      'Seu save na nuvem permanece. Este dispositivo será redefinido para uma nova conta de convidado e começará do nível 1.';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileSignOut => 'Sair';

  @override
  String get profileDeleteAccountTitle => 'Excluir conta?';

  @override
  String get profileDeleteAccountBody =>
      'Isso excluirá permanentemente seu save na nuvem e sua conta. Esta ação não pode ser desfeita.';

  @override
  String get profileDelete => 'Excluir';

  @override
  String profileDeleteFailed(String error) {
    return 'Falha ao excluir: $error';
  }

  @override
  String profileSignOutFailed(String error) {
    return 'Falha ao sair: $error';
  }

  @override
  String get profileSignedInBody =>
      'Seu progresso está salvo na nuvem. Entre em qualquer dispositivo com a mesma conta para continuar.';

  @override
  String get profileDeleteAccount => 'Excluir conta';

  @override
  String get profileStatLevel => 'Nível';

  @override
  String get profileStatStars => 'Estrelas';

  @override
  String get profileStatTrophies => 'Troféus';

  @override
  String get profileTabSignIn => 'Entrar';

  @override
  String get profileTabCreateAccount => 'Criar conta';

  @override
  String get profileCreateAccountTitle => 'Crie sua conta';

  @override
  String get profileWelcomeBack => 'Bem-vindo de volta';

  @override
  String get profileGuestProgressCarries =>
      'Seu progresso de convidado será transferido.';

  @override
  String get profileSignInRestoreBody =>
      'Entre para restaurar seu progresso de outro dispositivo.';

  @override
  String get profileNameHint => 'Nome (opcional)';

  @override
  String get profileEmailHint => 'E-mail';

  @override
  String get profilePasswordHint => 'Senha';

  @override
  String get profileShowPassword => 'Mostrar senha';

  @override
  String get profileHidePassword => 'Ocultar senha';

  @override
  String get profileGeneratePassword => 'Gerar senha';

  @override
  String get profilePasswordMinLength =>
      'A senha deve ter pelo menos 8 caracteres.';

  @override
  String get profileStrengthTooShort => 'Muito curta';

  @override
  String get profileStrengthOkay => 'Razoável';

  @override
  String get profileStrengthGood => 'Boa';

  @override
  String get profileStrengthStrong => 'Forte';

  @override
  String get profileErrorEmailSignUp =>
      'Esse e-mail já está registrado. Tente Entrar.';

  @override
  String get profileErrorEmailSignIn =>
      'Esse e-mail já está registrado. Verifique sua senha ou redefina pelo link do e-mail.';

  @override
  String get profileErrorInvalidCredentials =>
      'E-mail ou senha incorretos. Tente novamente.';

  @override
  String get profileErrorPassword =>
      'Senha não aceita. Use 8+ caracteres com letras e números, e evite palavras comuns como \"password\".';

  @override
  String get profileErrorInvalidEmail => 'Esse e-mail parece inválido.';

  @override
  String get profileErrorSessionExpired =>
      'Sessão expirada. Feche o app, abra novamente e tente outra vez.';

  @override
  String get profileErrorRateLimit =>
      'Muitas tentativas. Aguarde um minuto e tente novamente.';

  @override
  String get profileErrorServerBusy => 'Servidor ocupado. Tente em instantes.';

  @override
  String get profileErrorSignUpGeneric =>
      'Falha no cadastro. Verifique seus dados e tente novamente.';

  @override
  String get profileErrorSignInGeneric =>
      'Falha ao entrar. Verifique seu e-mail e senha.';

  @override
  String get profileEnterValidEmail => 'Digite um e-mail válido.';

  @override
  String get profileEnterPassword => 'Digite sua senha.';

  @override
  String get profileEmailAlreadyPrompt =>
      'Esse e-mail já tem uma conta. Digite sua senha para entrar.';

  @override
  String get profileSomethingWrong => 'Algo deu errado. Tente novamente.';

  @override
  String get profileCreateAccountButton => 'Criar conta';

  @override
  String get profileSignInButton => 'Entrar';

  @override
  String get profileAlreadyHaveAccount => 'Já tem uma conta? Entrar';

  @override
  String get profileDontHaveAccount => 'Não tem conta? Crie uma';

  @override
  String get homePlayer => 'Jogador';

  @override
  String homeLevelStars(int level, int stars) {
    return 'Nível $level · $stars estrelas';
  }

  @override
  String get homeContinueLabel => 'CONTINUAR';

  @override
  String homeLevelNumber(int level) {
    return 'Nível $level';
  }

  @override
  String get homeDaily => 'Diário';

  @override
  String get homeDailyReady => 'Pronto para jogar';

  @override
  String get homeDailyClaimed => 'Resgatado hoje';

  @override
  String get homeLeaderboard => 'Classificação';

  @override
  String get homeInventory => 'Inventário';

  @override
  String homeInventoryAllUnlocked(int count) {
    return 'Tudo desbloqueado · $count itens';
  }

  @override
  String get homeInventoryBrowse => 'Explore seu equipamento';

  @override
  String homeInventoryCounts(int owned, int total, int items) {
    return '$owned/$total · $items itens';
  }

  @override
  String get homeTrophies => 'Troféus';

  @override
  String homeTrophiesCount(int unlocked, int total) {
    return '$unlocked de $total';
  }

  @override
  String get privacyWelcomeTitle => 'Bem-vindo ao Arrow Puzzle';

  @override
  String get privacyWelcomeSubtitle =>
      'Antes de começar, revise e aceite nossos termos.';

  @override
  String get privacyBulletLocal =>
      'Seu progresso é salvo localmente no seu dispositivo.';

  @override
  String get privacyBulletCloud =>
      'Contas opcionais sincronizam o progresso na nuvem.';

  @override
  String get privacyBulletAds =>
      'O jogo exibe anúncios para continuar gratuito.';

  @override
  String get privacyPolicyLink => 'Política de privacidade';

  @override
  String get privacyTermsLink => 'Termos e condições';

  @override
  String get privacyAcceptButton => 'Aceitar e continuar';

  @override
  String get privacyAgreeFooter =>
      'Ao tocar acima você concorda com nossos Termos e condições.';

  @override
  String get bottomNavHome => 'Início';

  @override
  String get bottomNavDaily => 'Diário';

  @override
  String get bottomNavInventory => 'Inventário';

  @override
  String get bottomNavSettings => 'Configurações';

  @override
  String gameTopBarScore(int score) {
    return 'Pontos: $score';
  }

  @override
  String get gameTopBarRandom => 'Aleatório';

  @override
  String gameTopBarLevelNumber(String level) {
    return 'Nv.$level';
  }

  @override
  String get gameModeZenMode => 'Modo Zen';

  @override
  String get howToPlayTitle => 'COMO JOGAR';

  @override
  String get howToPlayBasics => 'O BÁSICO';

  @override
  String get howToPlayBoardElements => 'ELEMENTOS DO TABULEIRO';

  @override
  String get howToPlayGameModes => 'MODOS DE JOGO';

  @override
  String get howToPlayProStrategies => 'ESTRATÉGIAS PRO';

  @override
  String get howToPlayCoreTitle => 'Objetivo principal';

  @override
  String get howToPlayCoreDesc =>
      'Seu objetivo é limpar toda a grade guiando cada flecha para fora do tabuleiro. Quando não restarem flechas, a fase termina.';

  @override
  String get howToPlayMovementTitle => 'Movimento das flechas';

  @override
  String get howToPlayMovementDesc =>
      'Toque em qualquer flecha para lançá-la. As flechas deslizam na direção exata da ponta: cima, baixo, esquerda ou direita. Mesmo com corpo curvado, sempre saem seguindo a ponta.';

  @override
  String get howToPlayObstaclesTitle => 'Obstáculos e colisões';

  @override
  String get howToPlayObstaclesDesc =>
      'Uma flecha só escapa se todo o caminho de saída estiver livre. Se outra flecha bloquear, ela treme e fica no lugar.';

  @override
  String get howToPlayLivesTitle => 'Vidas e saúde';

  @override
  String get howToPlayLivesDesc =>
      'No modo Clássico, você começa com 3 vidas. Tocar numa flecha bloqueada custa 1 vida. Se perder as 3, reinicie a fase. Você pode ativar Vidas Infinitas nos Ajustes.';

  @override
  String get howToPlayTurnDotsTitle => 'Pontos de Curva (redirecionadores)';

  @override
  String get howToPlayTurnDotsDesc =>
      'Procure pontos circulares em células vazias marcadas com pequenas setas. Ao atravessar um Ponto de Curva, a flecha deslizante vira na direção dele e o consome, abrindo rotas inesperadas.';

  @override
  String get howToPlayCombosTitle => 'Combos e sequências';

  @override
  String get howToPlayCombosDesc =>
      'Libere flechas em rápida sucessão (dentro de 1,5 s) para ativar combos. Encadear fugas consecutivas acumula impulso e multiplica a pontuação.';

  @override
  String get howToPlayClassicTitle => 'Modo Clássico';

  @override
  String get howToPlayClassicDesc =>
      'A progressão padrão da campanha. Avance por fases artesanais e procedurais com tamanho, máscaras e complexidade crescentes, com 3 vidas.';

  @override
  String get howToPlayZenTitle => 'Modo Zen';

  @override
  String get howToPlayZenDesc =>
      'Relaxamento puro sem estresse. Sem vidas a perder, sem tempo, sem falhas. Ideal para relaxar e praticar tabuleiros complexos.';

  @override
  String get howToPlayTimeAttackTitle => 'Contra o Tempo';

  @override
  String get howToPlayTimeAttackDesc =>
      'Corrida frenética contra o relógio! Cada flecha escapada com sucesso devolve segundos preciosos ao cronômetro.';

  @override
  String get howToPlayMultiplayerTitle => 'Salas Multijogador';

  @override
  String get howToPlayMultiplayerDesc =>
      'Crie ou entre com códigos-semente. Os dois jogadores competem no mesmo layout aleatório para ver quem resolve mais rápido.';

  @override
  String get howToPlayRandomTitle => 'Puzzles Aleatórios';

  @override
  String get howToPlayRandomDesc =>
      'Gere puzzles infinitos sob demanda nas dificuldades Fácil, Médio, Difícil, Mestre e Especialista sem afetar o progresso da campanha.';

  @override
  String get howToPlayUnpeelTitle => 'Descasque pelas bordas';

  @override
  String get howToPlayUnpeelDesc =>
      'Comece pelas bordas externas. Flechas apontando para fora podem escapar de imediato, liberando rotas críticas.';

  @override
  String get howToPlayTraceTitle => 'Rastreie bloqueios ao contrário';

  @override
  String get howToPlayTraceDesc =>
      'Quando uma flecha estiver bloqueada, descubra qual a bloqueia e depois o que bloqueia essa segunda. Liberar o último bloqueador solta tudo atrás.';

  @override
  String get howToPlayTapAssistTitle => 'Ative o Toque Assistido';

  @override
  String get howToPlayTapAssistDesc =>
      'Se joga em telas pequenas ou costuma tocar entre flechas apertadas, ative o Toque Assistido nos Ajustes para mapear toques à flecha mais próxima.';

  @override
  String get multiplayerTitle => 'MULTIJOGADOR';

  @override
  String multiplayerRoomCodeCopied(String code) {
    return 'Código da sala $code copiado para a área de transferência!';
  }

  @override
  String get multiplayerHostRoom => 'SALA ANFITRIÃ';

  @override
  String get multiplayerHostBody =>
      'Compartilhe este código com um amigo para competir no mesmo layout de puzzle!';

  @override
  String get multiplayerNewCode => 'Novo código';

  @override
  String get multiplayerCopyCode => 'Copiar código';

  @override
  String get multiplayerStartMatch => 'INICIAR PARTIDA';

  @override
  String get multiplayerJoinRoom => 'ENTRAR NA SALA';

  @override
  String get multiplayerJoinBody =>
      'Digite ou cole um código de sala para entrar.';

  @override
  String get multiplayerRoomCodeHint => 'ex. ROOM-849201';

  @override
  String get multiplayerRoomCodeRequired => 'Digite um código de sala';

  @override
  String get multiplayerJoinMatch => 'ENTRAR';

  @override
  String get profileSyncing => 'Sincronizando...';

  @override
  String get profileSyncFailed => 'Falha ao sincronizar';

  @override
  String get gameModeTimeBlitz => 'Contra o Tempo Extremo';

  @override
  String get timeBlitzDesc =>
      'Toque flechas para ganhar tempo. Toques bloqueados custam tempo. Sobreviva o máximo possível.';

  @override
  String get profileEditName => 'Editar nome';

  @override
  String get profileSave => 'Salvar';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get shareMessage =>
      'Confira Arrow Puzzle — um jogo divertido de escape de labirinto!';

  @override
  String get copyLink => 'Copiar link';

  @override
  String get linkCopied => 'Link copiado';

  @override
  String get settingsShareFriends => 'Compartilhar com amigos';

  @override
  String get blitzTimeLeftLabel => 'TEMPO RESTANTE';

  @override
  String get levelSelectButton => 'Níveis';

  @override
  String levelDetailsTitle(int level) {
    return 'Nível $level';
  }

  @override
  String get levelDetailsCompleted => 'Concluído';

  @override
  String get levelDetailsNotPlayed => 'Ainda não jogado';

  @override
  String get levelDetailsStart => 'Começar';

  @override
  String get zenModeLabel => 'RELAXAR';

  @override
  String get zenModeTitle => 'Modo Zen';

  @override
  String get zenModeSubtitle => 'Sem vidas, sem tempo. Só puzzles.';
}
