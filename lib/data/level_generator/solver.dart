import 'dart:typed_data';

import '../models/arrow.dart';
import '../models/level.dart';

/// Exact backtracking solver for the same exit rules used by GameState.
///
/// Important differences from the previous implementation:
/// - Every decision is explored; currently-clearable arrows are not greedily
///   forced because consuming a redirector can change later exits.
/// - Each recursive move has a strictly local undo operation.
/// - Memoization uses the complete active-arrow / active-dot / active-rock
///   state, not a lossy XOR hash.
class LevelSolver {
  LevelSolver._();

  static const int maxStates = 80000;

  static List<String>? solve(
    LevelModel level, [
    int maxStatesLimit = maxStates,
  ]) {
    if (maxStatesLimit <= 0) return null;
    final engine = _SolverEngine.tryCreate(level);
    if (engine == null) return null;
    return engine.solve(maxStatesLimit);
  }

  /// Returns the exact number of arrows that can exit before any move is made.
  /// This uses the same redirector and slash/rock behavior as [solve].
  static int countInitialMoves(LevelModel level) {
    final engine = _SolverEngine.tryCreate(level);
    if (engine == null) return 0;
    return engine.initiallyClearableArrowIds().length;
  }

  /// Exposes the IDs of the arrows that can exit in the untouched level.
  static List<String> initiallyClearableArrowIds(LevelModel level) {
    final engine = _SolverEngine.tryCreate(level);
    if (engine == null) return const [];
    return engine.initiallyClearableArrowIds();
  }

  /// Compatibility helper for code that previously requested a greedy solve.
  /// It now uses the exact rules, with a modest state budget.
  static List<String>? greedySolve(LevelModel level) =>
      solve(level, 12000);
}

class _ExitOutcome {
  final List<int> consumedOrphans;
  final List<int> destroyedRocks;

  const _ExitOutcome(this.consumedOrphans, this.destroyedRocks);
}

class _SolverEngine {
  final LevelModel level;
  final int gridSize;
  final List<ArrowModel> arrows;
  final Int32List board;
  final Int32List orphanIndexAtCell;
  final Uint8List orphanTypes;
  final List<bool> activeOrphans;
  final Int32List rockIndexAtCell;
  final List<bool> activeRocks;
  final List<bool> activeArrows;
  final List<int> exitVisited;

  final Set<String> failedStates = <String>{};
  final List<String> solutionPath = <String>[];

  int _exitToken = 0;
  int statesVisited = 0;
  int _stateLimit = LevelSolver.maxStates;
  bool _budgetExhausted = false;

  _SolverEngine._({
    required this.level,
    required this.gridSize,
    required this.arrows,
    required this.board,
    required this.orphanIndexAtCell,
    required this.orphanTypes,
    required this.activeOrphans,
    required this.rockIndexAtCell,
    required this.activeRocks,
    required this.activeArrows,
    required this.exitVisited,
  });

  static _SolverEngine? tryCreate(LevelModel level) {
    final size = level.gridSize;
    if (size <= 0 || size > 512) return null;

    final totalCells = size * size;
    if (totalCells <= 0 || totalCells > 1000000) return null;

    final board = Int32List(totalCells);
    final orphanIndexAtCell = Int32List(totalCells)..fillRange(0, totalCells, -1);
    final rockIndexAtCell = Int32List(totalCells)..fillRange(0, totalCells, -1);
    final orphanTypes = Uint8List(level.orphanDots.length);
    final activeOrphans = List<bool>.filled(level.orphanDots.length, true);
    final activeRocks = List<bool>.filled(level.rocks.length, true);
    final activeArrows = List<bool>.filled(level.arrows.length, true);
    final exitVisited = List<int>.filled(totalCells, 0);
    final seenIds = <String>{};

    for (int arrowIndex = 0; arrowIndex < level.arrows.length; arrowIndex++) {
      final arrow = level.arrows[arrowIndex];
      if (arrow.id.isEmpty || !seenIds.add(arrow.id) || arrow.path.isEmpty) {
        return null;
      }
      if (arrow.path.first.length < 2 ||
          arrow.path.first[0] != arrow.row ||
          arrow.path.first[1] != arrow.col) {
        return null;
      }

      final localCells = <int>{};
      for (int pathIndex = 0; pathIndex < arrow.path.length; pathIndex++) {
        final point = arrow.path[pathIndex];
        if (point.length < 2) return null;
        final row = point[0];
        final col = point[1];
        if (row < 0 || row >= size || col < 0 || col >= size) return null;
        if (pathIndex > 0) {
          final previous = arrow.path[pathIndex - 1];
          final distance = (row - previous[0]).abs() +
              (col - previous[1]).abs();
          // GameState draws and moves one orthogonal cell at a time. Reject
          // malformed jumps rather than certifying them as ordinary arrows.
          if (distance != 1) return null;
        }
        final cell = row * size + col;
        if (!localCells.add(cell) || board[cell] != 0) return null;
        board[cell] = arrowIndex + 1;
      }
    }

    for (int i = 0; i < level.rocks.length; i++) {
      final rock = level.rocks[i];
      if (rock.row < 0 || rock.row >= size || rock.col < 0 || rock.col >= size) {
        return null;
      }
      final cell = rock.row * size + rock.col;
      if (rockIndexAtCell[cell] != -1) return null;
      rockIndexAtCell[cell] = i;
    }

    for (int i = 0; i < level.orphanDots.length; i++) {
      final dot = level.orphanDots[i];
      if (dot.row < 0 || dot.row >= size || dot.col < 0 || dot.col >= size) {
        return null;
      }
      final cell = dot.row * size + dot.col;
      if (orphanIndexAtCell[cell] != -1) return null;
      orphanIndexAtCell[cell] = i;
      orphanTypes[i] = dot.type.index;
    }

    return _SolverEngine._(
      level: level,
      gridSize: size,
      arrows: level.arrows,
      board: board,
      orphanIndexAtCell: orphanIndexAtCell,
      orphanTypes: orphanTypes,
      activeOrphans: activeOrphans,
      rockIndexAtCell: rockIndexAtCell,
      activeRocks: activeRocks,
      activeArrows: activeArrows,
      exitVisited: exitVisited,
    );
  }

  List<String>? solve(int stateLimit) {
    _stateLimit = stateLimit;
    if (_search(arrows.length)) return List<String>.from(solutionPath);
    return null;
  }

  List<String> initiallyClearableArrowIds() {
    final ids = <String>[];
    for (int i = 0; i < arrows.length; i++) {
      if (activeArrows[i] && _simulateExit(i) != null) {
        ids.add(arrows[i].id);
      }
    }
    return ids;
  }

  _ExitOutcome? _simulateExit(int arrowIndex) {
    final arrow = arrows[arrowIndex];
    if (arrow.path.isEmpty) return null;

    final head = arrow.path[0];
    var direction = arrow.direction;
    var delta = direction.delta;
    int row = head[0] + delta[0];
    int col = head[1] + delta[1];
    final consumed = <int>[];
    final destroyed = <int>[];

    final token = ++_exitToken;
    final isSlash = arrow.type == ArrowType.slash;

    while (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      final cell = row * gridSize + col;
      if (exitVisited[cell] == token) return null;
      exitVisited[cell] = token;

      final rockIndex = rockIndexAtCell[cell];
      if (rockIndex != -1 && activeRocks[rockIndex]) {
        // GameState checks rocks before orphan dots and arrow bodies.
        if (!isSlash) return null;
        destroyed.add(rockIndex);
      } else {
        final orphanIndex = orphanIndexAtCell[cell];
        if (orphanIndex != -1 && activeOrphans[orphanIndex]) {
          consumed.add(orphanIndex);
          switch (OrphanDotType.values[orphanTypes[orphanIndex]]) {
            case OrphanDotType.up:
              direction = ArrowDirection.up;
              break;
            case OrphanDotType.down:
              direction = ArrowDirection.down;
              break;
            case OrphanDotType.left:
              direction = ArrowDirection.left;
              break;
            case OrphanDotType.right:
              direction = ArrowDirection.right;
              break;
            case OrphanDotType.neutral:
              break;
          }
        } else {
          final occupant = board[cell];
          // GameState ignores the moving arrow's own body and blocks on every
          // other non-sliding arrow. All arrows in this solver are stationary.
          if (occupant != 0 && occupant != arrowIndex + 1) return null;
        }
      }

      delta = direction.delta;
      row += delta[0];
      col += delta[1];
    }

    return _ExitOutcome(consumed, destroyed);
  }

  bool _search(int remaining) {
    if (remaining == 0) return true;
    if (_budgetExhausted) return false;

    final key = _stateKey();
    if (failedStates.contains(key)) return false;

    if (statesVisited >= _stateLimit) {
      _budgetExhausted = true;
      return false;
    }
    statesVisited++;

    for (int i = 0; i < arrows.length; i++) {
      if (!activeArrows[i]) continue;

      final outcome = _simulateExit(i);
      if (outcome == null) continue;

      _applyClear(i, outcome);
      solutionPath.add(arrows[i].id);

      if (_search(remaining - 1)) return true;

      solutionPath.removeLast();
      _undoClear(i, outcome);

      if (_budgetExhausted) return false;
    }

    failedStates.add(key);
    return false;
  }

  void _applyClear(int arrowIndex, _ExitOutcome outcome) {
    activeArrows[arrowIndex] = false;
    for (final point in arrows[arrowIndex].path) {
      board[point[0] * gridSize + point[1]] = 0;
    }
    for (final index in outcome.consumedOrphans) {
      activeOrphans[index] = false;
    }
    for (final index in outcome.destroyedRocks) {
      activeRocks[index] = false;
    }
  }

  void _undoClear(int arrowIndex, _ExitOutcome outcome) {
    for (final index in outcome.destroyedRocks) {
      activeRocks[index] = true;
    }
    for (final index in outcome.consumedOrphans) {
      activeOrphans[index] = true;
    }
    for (final point in arrows[arrowIndex].path) {
      board[point[0] * gridSize + point[1]] = arrowIndex + 1;
    }
    activeArrows[arrowIndex] = true;
  }

  /// A collision-free canonical state key. The separators make the three
  /// independently-sized bit vectors unambiguous.
  String _stateKey() {
    final codes = <int>[];
    for (final active in activeArrows) {
      codes.add(active ? 1 : 0);
    }
    codes.add(255);
    for (final active in activeOrphans) {
      codes.add(active ? 1 : 0);
    }
    codes.add(254);
    for (final active in activeRocks) {
      codes.add(active ? 1 : 0);
    }
    return String.fromCharCodes(codes);
  }
}
