import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

enum RushDifficulty {
  easy(
    fallbackLabel: 'Easy',
    gridBonus: 0,
    arrowMult: 1.0,
    delayMult: 1.0,
    lossOffset: 0.00,
    speedMult: 1.00,
    coinMult: 1.0,
    unlockLevel: 0,
  ),
  hard(
    fallbackLabel: 'Hard',
    gridBonus: 2,
    arrowMult: 1.4,
    delayMult: 0.70,
    lossOffset: -0.03,
    speedMult: 1.15,
    coinMult: 1.5,
    unlockLevel: 15,
  ),
  impossible(
    fallbackLabel: 'Impossible',
    gridBonus: 4,
    arrowMult: 2.0,
    delayMult: 0.50,
    lossOffset: -0.07,
    speedMult: 1.30,
    coinMult: 2.5,
    unlockLevel: 50,
  );

  final String fallbackLabel;
  final int gridBonus;
  final double arrowMult;
  final double delayMult;
  final double lossOffset;
  final double speedMult;
  final double coinMult;
  final int unlockLevel;

  const RushDifficulty({
    required this.fallbackLabel,
    required this.gridBonus,
    required this.arrowMult,
    required this.delayMult,
    required this.lossOffset,
    required this.speedMult,
    required this.coinMult,
    required this.unlockLevel,
  });

  /// Backwards-compatible getter — returns the fallback English label.
  /// Prefer [localizedLabel] in UI code so it can be translated.
  String get label => fallbackLabel;

  /// Localized label. Must be called with a BuildContext.
  String localizedLabel(BuildContext context) {
    final strings = AppStrings.of(context);
    switch (this) {
      case RushDifficulty.easy:
        return strings.rushDifficultyEasy;
      case RushDifficulty.hard:
        return strings.rushDifficultyHard;
      case RushDifficulty.impossible:
        return strings.rushDifficultyImpossible;
    }
  }
}