// lib/data/models/minesweeper_cell.dart

enum MineState { hidden, revealed, flagged }

class MinesweeperCell {
  final int row;
  final int col;
  final bool hasMine;
  int adjacentMines;
  MineState state;

  MinesweeperCell({
    required this.row,
    required this.col,
    required this.hasMine,
    this.adjacentMines = 0,
    this.state = MineState.hidden,
  });

  String get key => '$row,$col';
}