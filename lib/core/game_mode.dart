import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum GameMode {
  classic('Classic', Icons.grid_on_rounded, Colors.deepPurple),
  zen('Zen Mode', Icons.self_improvement_rounded, Colors.teal),
  timeAttack('Time Attack', Icons.timer_rounded, Colors.orange),
  minesweeper('Mine Arrows', Icons.bug_report_rounded, Colors.redAccent),
  endlessRush('Arrow Rush', Icons.bolt_rounded, Colors.amber),
  blitz('Blitz', Icons.local_fire_department_rounded, Color(0xFF00BCD4)),
  timeBlitz('Time Blitz', Icons.hourglass_bottom_rounded, Color(0xFFFF5722));

  final String label;
  final IconData icon;
  final Color color;

  const GameMode(this.label, this.icon, this.color);

  bool get isMinesweeper => this == GameMode.minesweeper;
  bool get isEndlessRush => this == GameMode.endlessRush;
  bool get isBlitz => this == GameMode.blitz;
  bool get isTimeBlitz => this == GameMode.timeBlitz;

  String localizedLabel(BuildContext context) {
    final s = AppStrings.of(context);
    switch (this) {
      case GameMode.classic:      return s.gameModeClassic;
      case GameMode.zen:          return s.gameModeZenMode;
      case GameMode.timeAttack:   return s.gameModeTimeAttack;
      case GameMode.minesweeper:  return s.mineArrowsTitle;
      case GameMode.endlessRush:  return s.arrowRushTitle;
      case GameMode.blitz:        return s.blitzTitle;
      case GameMode.timeBlitz:    return s.gameModeTimeBlitz;
    }
  }
}