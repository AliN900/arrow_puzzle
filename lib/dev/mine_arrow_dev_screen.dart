import 'dart:math';
import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class MineArrowData {
  final String id;
  final int row;
  final int col;
  final Direction direction;
  final bool isSafe;
  int badgeValue;

  MineArrowData({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    required this.isSafe,
    this.badgeValue = 0,
  });

  List<Point<int>> getFlightPath(int gridSize) {
    final List<Point<int>> path = [];
    int r = row;
    int c = col;

    while (true) {
      switch (direction) {
        case Direction.up:
          r--;
          break;
        case Direction.down:
          r++;
          break;
        case Direction.left:
          c--;
          break;
        case Direction.right:
          c++;
          break;
      }
      if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) break;
      path.add(Point(r, c));
    }
    return path;
  }
}

class MineBoardData {
  final int boardIndex;
  final int gridSize;
  final List<MineArrowData> arrows;
  final Set<Point<int>> mines;

  MineBoardData({
    required this.boardIndex,
    required this.gridSize,
    required this.arrows,
    required this.mines,
  });
}

class MineBoardGenerator {
  static MineBoardData generate({required int boardIndex, int gridSize = 5}) {
    final rand = Random();
    final int totalArrows = (2 + (boardIndex ~/ 2)).clamp(2, 6);
    final Set<Point<int>> safePathCells = {};
    final Set<Point<int>> mineLocations = {};
    final List<MineArrowData> arrows = [];

    // 1. Pick 1 Gold (Safe) Arrow
    final safeRow = rand.nextInt(gridSize);
    final safeCol = rand.nextInt(gridSize);
    final safeDir = Direction.values[rand.nextInt(Direction.values.length)];

    final safeArrow = MineArrowData(
      id: 'safe_0',
      row: safeRow,
      col: safeCol,
      direction: safeDir,
      isSafe: true,
    );

    safePathCells.add(Point(safeRow, safeCol));
    safePathCells.addAll(safeArrow.getFlightPath(gridSize));
    arrows.add(safeArrow);

    // 2. Generate Decoy Arrows & Plant Mines on Non-Safe Cells
    for (int i = 1; i < totalArrows; i++) {
      int r = rand.nextInt(gridSize);
      int c = rand.nextInt(gridSize);
      int attempts = 0;

      while (safePathCells.contains(Point(r, c)) && attempts < 20) {
        r = rand.nextInt(gridSize);
        c = rand.nextInt(gridSize);
        attempts++;
      }

      final dir = Direction.values[rand.nextInt(Direction.values.length)];
      final decoyArrow = MineArrowData(
        id: 'decoy_$i',
        row: r,
        col: c,
        direction: dir,
        isSafe: false,
      );

      final decoyPath = decoyArrow.getFlightPath(gridSize);
      final validMineCells = decoyPath
          .where((cell) => !safePathCells.contains(cell))
          .toList();

      if (validMineCells.isNotEmpty) {
        final mineCell = validMineCells[rand.nextInt(validMineCells.length)];
        mineLocations.add(mineCell);
      }

      arrows.add(decoyArrow);
    }

    // 3. Calculate Mine Count Badges
    for (var arrow in arrows) {
      int count = 0;
      for (var cell in arrow.getFlightPath(gridSize)) {
        if (mineLocations.contains(cell)) count++;
      }
      arrow.badgeValue = count;
    }

    return MineBoardData(
      boardIndex: boardIndex,
      gridSize: gridSize,
      arrows: arrows,
      mines: mineLocations,
    );
  }
}

class MineArrowDevScreen extends StatefulWidget {
  const MineArrowDevScreen({super.key});

  @override
  State<MineArrowDevScreen> createState() => _MineArrowDevScreenState();
}

class _MineArrowDevScreenState extends State<MineArrowDevScreen> {
  int _boardIndex = 1;
  int _streak = 0;
  late MineBoardData _currentBoard;

  @override
  void initState() {
    super.initState();
    _loadBoard();
  }

  void _loadBoard() {
    setState(() {
      _currentBoard = MineBoardGenerator.generate(boardIndex: _boardIndex);
    });
  }

  void _onArrowTap(MineArrowData arrow) {
    if (arrow.badgeValue == 0) {
      // Safe Arrow - Ascend Staircase!
      setState(() {
        _boardIndex++;
        _streak++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('BOARD CLEAR! Ascending to Board $_boardIndex...'),
          duration: const Duration(milliseconds: 600),
          backgroundColor: Colors.green,
        ),
      );
      _loadBoard();
    } else {
      // Mine Hit - Detonation!
      setState(() {
        _streak = 0;
        _boardIndex = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('BOOM! Hit a mine path with badge (${arrow.badgeValue}). Restarting...'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      _loadBoard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      appBar: AppBar(
        title: Text('DEV: Mine Arrow (Board $_boardIndex)'),
        backgroundColor: const Color(0xFF2A2A38),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoard,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard('STAIR BOARD', '$_boardIndex', Colors.amber),
                _StatCard('STREAK', '$_streak', Colors.greenAccent),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252533),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _currentBoard.gridSize,
                    ),
                    itemCount: _currentBoard.gridSize * _currentBoard.gridSize,
                    itemBuilder: (context, index) {
                      final r = index ~/ _currentBoard.gridSize;
                      final c = index % _currentBoard.gridSize;
                      final point = Point(r, c);

                      final arrow = _currentBoard.arrows.firstWhere(
                            (a) => a.row == r && a.col == c,
                        orElse: () => MineArrowData(
                          id: '',
                          row: -1,
                          col: -1,
                          direction: Direction.up,
                          isSafe: false,
                        ),
                      );

                      final isMine = _currentBoard.mines.contains(point);

                      return Container(
                        margin: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMine ? Colors.red.withValues(alpha: 0.3) : Colors.white10,
                          ),
                        ),
                        child: arrow.row != -1
                            ? InkWell(
                          onTap: () => _onArrowTap(arrow),
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                _getArrowIcon(arrow.direction),
                                color: Colors.white,
                                size: 28,
                              ),
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: arrow.badgeValue == 0
                                        ? Colors.green
                                        : Colors.orangeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${arrow.badgeValue}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : (isMine
                            ? const Icon(Icons.dangerous, size: 16, color: Colors.red)
                            : null),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getArrowIcon(Direction dir) {
    switch (dir) {
      case Direction.up:
        return Icons.arrow_upward_rounded;
      case Direction.down:
        return Icons.arrow_downward_rounded;
      case Direction.left:
        return Icons.arrow_back_rounded;
      case Direction.right:
        return Icons.arrow_forward_rounded;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}