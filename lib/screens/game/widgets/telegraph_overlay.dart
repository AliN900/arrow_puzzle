import 'package:flutter/material.dart';
import '../../../data/models/arrow.dart';
import '../../../game/game_state.dart';

class TelegraphOverlay extends StatelessWidget {
  final GameState gameState;
  final double boardSize;

  const TelegraphOverlay({
    super.key,
    required this.gameState,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    if (gameState.telegraphArrows.isEmpty) {
      return const SizedBox.shrink();
    }

    final gridSize = gameState.level.gridSize;
    final cellSize = boardSize / gridSize;

    return IgnorePointer(
      child: Stack(
        children: gameState.telegraphArrows.expand((arrow) {
          const color = Colors.amberAccent;

          return arrow.path.map((pt) {
            final row = pt[0];
            final col = pt[1];
            final isHead =
                pt[0] == arrow.path[0][0] && pt[1] == arrow.path[0][1];

            return Positioned(
              left: col * cellSize,
              top: row * cellSize,
              width: cellSize,
              height: cellSize,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 80),
                opacity: (DateTime.now().millisecondsSinceEpoch ~/ 100) % 2 == 0
                    ? 1.0
                    : 0.15,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color,
                      width: isHead ? 2.5 : 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: color,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: isHead
                      ? Center(
                    child: Icon(
                      _getDirectionIcon(arrow.direction),
                      color: color,
                      size: cellSize * 0.5,
                    ),
                  )
                      : null,
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  IconData _getDirectionIcon(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
        return Icons.keyboard_arrow_up_rounded;
      case ArrowDirection.down:
        return Icons.keyboard_arrow_down_rounded;
      case ArrowDirection.left:
        return Icons.keyboard_arrow_left_rounded;
      case ArrowDirection.right:
        return Icons.keyboard_arrow_right_rounded;
    }
  }
}