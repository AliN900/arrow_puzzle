// lib/screens/game/widgets/minesweeper_overlay.dart

import 'package:flutter/material.dart';
import '../../../data/models/minesweeper_cell.dart';

class MinesweeperGridOverlay extends StatelessWidget {
  final Map<String, MinesweeperCell> cells;
  final double cellSize;

  const MinesweeperGridOverlay({
    super.key,
    required this.cells,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: cells.values.map((cell) {
          if (cell.state == MineState.hidden) return const SizedBox.shrink();

          return Positioned(
            left: cell.col * cellSize,
            top: cell.row * cellSize,
            width: cellSize,
            height: cellSize,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: cell.hasMine
                    ? Colors.red.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: cell.hasMine
                    ? const Icon(Icons.brightness_7_rounded, color: Colors.white, size: 16)
                    : cell.adjacentMines > 0
                    ? Text(
                  '${cell.adjacentMines}',
                  style: TextStyle(
                    fontSize: cellSize * 0.45,
                    fontWeight: FontWeight.w900,
                    color: _getMineNumberColor(cell.adjacentMines),
                  ),
                )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getMineNumberColor(int count) {
    switch (count) {
      case 1:
        return Colors.blueAccent;
      case 2:
        return Colors.greenAccent;
      case 3:
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }
}