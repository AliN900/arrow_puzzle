import 'dart:math';
import '../../data/level_generator/solver.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';

class EndlessSpawner {
  static final Random _rng = Random();

  static ArrowModel? trySpawnArrow({
    required int gridSize,
    required List<ArrowModel> existingArrows,
    required List<RockModel> rocks,
  }) {
    final occupiedCells = <String>{};
    for (final rock in rocks) {
      occupiedCells.add('${rock.row},${rock.col}');
    }
    for (final arrow in existingArrows) {
      for (final pt in arrow.path) {
        occupiedCells.add('${pt[0]},${pt[1]}');
      }
    }

    final emptyCells = <List<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!occupiedCells.contains('$r,$c')) {
          emptyCells.add([r, c]);
        }
      }
    }

    if (emptyCells.length < 2) return null;
    emptyCells.shuffle(_rng);

    // Limit head candidate evaluations per tick to prevent UI stuttering
    for (final head in emptyCells.take(8)) {
      final directions = ArrowDirection.values.toList()..shuffle(_rng);
      for (final dir in directions) {
        final maxLength = min(4, gridSize);
        final targetLength = _rng.nextInt(maxLength - 1) + 2;

        final path = <List<int>>[head];
        final visitedPath = <String>{'${head[0]},${head[1]}'};

        final firstStep = dir.oppositeDelta;
        final nr = head[0] + firstStep[0];
        final nc = head[1] + firstStep[1];

        if (nr < 0 ||
            nr >= gridSize ||
            nc < 0 ||
            nc >= gridSize ||
            occupiedCells.contains('$nr,$nc')) {
          continue;
        }

        path.add([nr, nc]);
        visitedPath.add('$nr,$nc');

        int currR = nr;
        int currC = nc;

        for (int i = 2; i < targetLength; i++) {
          final possibleSteps = <List<int>>[
            dir.oppositeDelta,
            dir.turnLeft.delta,
            dir.turnRight.delta,
          ]..shuffle(_rng);

          bool stepAdded = false;
          for (final step in possibleSteps) {
            final testR = currR + step[0];
            final testC = currC + step[1];
            final k = '$testR,$testC';

            if (testR >= 0 &&
                testR < gridSize &&
                testC >= 0 &&
                testC < gridSize &&
                !occupiedCells.contains(k) &&
                !visitedPath.contains(k)) {
              path.add([testR, testC]);
              visitedPath.add(k);
              currR = testR;
              currC = testC;
              stepAdded = true;
              break;
            }
          }

          if (!stepAdded) break;
        }

        if (path.length < 2) continue;

        final candidate = ArrowModel(
          id: 'spawner_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(1000)}',
          row: head[0],
          col: head[1],
          direction: dir,
          state: ArrowState.idle,
          type: ArrowType.normal,
          path: path,
        );

        if (_verifyClearableWithSolver(
          candidate: candidate,
          existingArrows: existingArrows,
          rocks: rocks,
          gridSize: gridSize,
        )) {
          return candidate;
        }
      }
    }
    return null;
  }

  static bool _verifyClearableWithSolver({
    required ArrowModel candidate,
    required List<ArrowModel> existingArrows,
    required List<RockModel> rocks,
    required int gridSize,
  }) {
    final activeExisting = existingArrows
        .where((a) => a.state != ArrowState.sliding)
        .toList();

    final fullSquareMask = <String>{};
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        fullSquareMask.add('$r,$c');
      }
    }

    final testLevel = LevelModel(
      levelNumber: 9999,
      gridSize: gridSize,
      arrows: [...activeExisting, candidate],
      rocks: rocks,
      maskShape: MaskShape.square,
      mask: fullSquareMask,
      orphanDots: [],
    );

    try {
      final solution = LevelSolver.solve(testLevel, 100);
      return solution != null;
    } catch (_) {
      return false;
    }
  }
}

extension on ArrowDirection {
  List<int> get oppositeDelta {
    switch (this) {
      case ArrowDirection.up:
        return [1, 0];
      case ArrowDirection.down:
        return [-1, 0];
      case ArrowDirection.left:
        return [0, 1];
      case ArrowDirection.right:
        return [0, -1];
    }
  }
}