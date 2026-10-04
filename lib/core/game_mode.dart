
import 'package:flutter/material.dart';

enum GameMode {
  classic('Classic', Icons.grid_on_rounded, Colors.deepPurple),
  zen('Zen Mode', Icons.self_improvement_rounded, Colors.teal),
  timeAttack('Time Attack', Icons.timer_rounded, Colors.orange),
  minesweeper('Mine Arrows', Icons.bug_report_rounded, Colors.redAccent),
  endlessRush('Arrow Rush', Icons.bolt_rounded, Colors.amber);

  final String label;
  final IconData icon;
  final Color color;

  const GameMode(this.label, this.icon, this.color);

  bool get isMinesweeper => this == GameMode.minesweeper;
  bool get isEndlessRush => this == GameMode.endlessRush;
}