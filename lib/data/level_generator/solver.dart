import 'dart:typed_data';
import '../models/arrow.dart';
import '../models/level.dart';

class LevelSolver {
  static const int maxStates = 10000;

  static List<String>? solve(LevelModel level, [int maxStatesLimit = maxStates]) {
    final gridSize = level.gridSize;
    final arrows = level.arrows;
    final orphanDots = level.orphanDots;

    // Allocate buffers dynamically based on level.gridSize
    final totalCells = gridSize * gridSize;
    final board = Uint16List(totalCells);
    final orphanTypes = Uint8List(totalCells);
    final activeOrphans = List<bool>.filled(totalCells, false);
    final exitVisited = Uint32List(totalCells);

    // Mines currently alive. Slash arrows remove entries from here on
    // exit; backtracking restores them.
    final rockCells = <int>{};
    for (final rock in level.rocks) {
      rockCells.add(rock.row * gridSize + rock.col);
    }

    for (int i = 0; i < arrows.length; i++) {
      final arrow = arrows[i];
      for (final pt in arrow.path) {
        board[pt[0] * gridSize + pt[1]] = i + 1;
      }
    }

    for (final od in orphanDots) {
      final idx = od.row * gridSize + od.col;
      orphanTypes[idx] = od.type.index;
      activeOrphans[idx] = true;
    }

    final activeArrows = List<bool>.filled(arrows.length, true);

    int arrowHash = 0;
    for (int i = 0; i < arrows.length; i++) {
      arrowHash ^= arrows[i].id.hashCode;
    }
    int dotHash = orphanDots.length * 997;
    for (final od in orphanDots) {
      dotHash ^= od.key.hashCode;
    }

    // ── CHANGE THIS ──
    // final visited = <String>{};
    final visited = <int>{};

    final path = <String>[];
    int statesVisited = 0;
    int exitToken = 0;

    // Track what the greedy pass cleared so we can undo it cleanly.
    final greedyCleared = <int>[];
    final greedyMines = <List<int>>[];

    void undoGreedy() {
      for (int k = greedyCleared.length - 1; k >= 0; k--) {
        final idx = greedyCleared[k];
        path.removeLast();
        for (final pt in arrows[idx].path) {
          board[pt[0] * gridSize + pt[1]] = idx + 1;
        }
        arrowHash ^= arrows[idx].id.hashCode;
        activeArrows[idx] = true;
        for (final mineCell in greedyMines[k]) {
          rockCells.add(mineCell);
        }
      }
      greedyCleared.clear();
      greedyMines.clear();
    }

    bool dfs(int remainingCount) {
      if (remainingCount == 0) return true;
      if (statesVisited > maxStatesLimit) return false;

      bool progress = true;
      while (progress) {
        progress = false;
        for (int i = 0; i < arrows.length; i++) {
          if (!activeArrows[i]) continue;
          exitToken++;
          if (exitToken == 0) {
            exitVisited.fillRange(0, exitVisited.length, 0);
            exitToken = 1;
          }
          final result = _simulateExit(
            i,
            gridSize,
            board,
            activeOrphans,
            orphanTypes,
            arrows,
            exitVisited,
            exitToken,
            rockCells,
          );
          if (result == null) continue;

          final consumed = result.consumed;
          final minesHit = result.minesHit;

          bool consumesRedirector = false;
          for (final idx in consumed) {
            if (activeOrphans[idx] &&
                orphanTypes[idx] != OrphanDotType.neutral.index) {
              consumesRedirector = true;
              break;
            }
          }

          if (!consumesRedirector) {
            activeArrows[i] = false;
            final id = arrows[i].id;
            arrowHash ^= id.hashCode;
            for (final pt in arrows[i].path) {
              board[pt[0] * gridSize + pt[1]] = 0;
            }
            for (final idx in consumed) {
              if (activeOrphans[idx]) {
                activeOrphans[idx] = false;
                final odKey = '${idx ~/ gridSize},${idx % gridSize}';
                dotHash ^= odKey.hashCode;
              }
            }
            // Slash arrow cleared every mine on its exit path.
            for (final mineCell in minesHit) {
              rockCells.remove(mineCell);
            }
            path.add(id);
            greedyCleared.add(i);
            greedyMines.add(minesHit);
            progress = true;
          }
        }
      }

      if (path.length == arrows.length) return true;

      // ── CHANGE THIS ──
      // final hash = '$arrowHash|$dotHash';
      // Use a combined integer hash instead of a string
      final hash = (arrowHash * 31) ^ dotHash;
      if (visited.contains(hash)) {
        undoGreedy();
        return false;
      }
      visited.add(hash);
      statesVisited++;

      for (int i = 0; i < arrows.length; i++) {
        if (!activeArrows[i]) continue;

        exitToken++;
        if (exitToken == 0) {
          exitVisited.fillRange(0, exitVisited.length, 0);
          exitToken = 1;
        }
        final result = _simulateExit(
          i,
          gridSize,
          board,
          activeOrphans,
          orphanTypes,
          arrows,
          exitVisited,
          exitToken,
          rockCells,
        );
        if (result == null) continue;

        final consumed = result.consumed;
        final minesHit = result.minesHit;

        activeArrows[i] = false;
        final id = arrows[i].id;
        arrowHash ^= id.hashCode;

        for (final pt in arrows[i].path) {
          board[pt[0] * gridSize + pt[1]] = 0;
        }

        final deactivated = <int>[];
        for (final idx in consumed) {
          if (activeOrphans[idx]) {
            activeOrphans[idx] = false;
            deactivated.add(idx);
            final odKey = '${idx ~/ gridSize},${idx % gridSize}';
            dotHash ^= odKey.hashCode;
          }
        }

        // Slash arrow clears its mines for this branch.
        for (final mineCell in minesHit) {
          rockCells.remove(mineCell);
        }

        path.add(id);

        if (dfs(arrows.length - path.length)) return true;

        path.removeLast();

        // Restore mines this branch cleared.
        for (final mineCell in minesHit) {
          rockCells.add(mineCell);
        }

        for (final idx in deactivated) {
          activeOrphans[idx] = true;
          final odKey = '${idx ~/ gridSize},${idx % gridSize}';
          dotHash ^= odKey.hashCode;
        }
        for (final pt in arrows[i].path) {
          board[pt[0] * gridSize + pt[1]] = i + 1;
        }
        arrowHash ^= id.hashCode;
        activeArrows[i] = true;
      }

      undoGreedy();
      return false;
    }

    if (dfs(arrows.length)) return path;
    return null;
  }

  static ({List<int> consumed, List<int> minesHit})? _simulateExit(
      int arrowIdx,
      int gridSize,
      Uint16List board,
      List<bool> activeOrphans,
      Uint8List orphanTypes,
      List<ArrowModel> arrows,
      Uint32List exitVisited,
      int token,
      Set<int> rockCells,
      ) {
    final arrow = arrows[arrowIdx];
    final isSlash = arrow.type == ArrowType.slash;
    ArrowDirection currentDir = arrow.direction;
    final head = arrow.path[0];
    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final consumed = <int>[];
    final minesHit = <int>[];

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final idx = nr * gridSize + nc;

      // Mine on the path.
      if (rockCells.contains(idx)) {
        if (isSlash) {
          // Slash arrows slice through every mine on the path.
          minesHit.add(idx);
        } else {
          // Normal arrows are blocked.
          return null;
        }
      } else {
        if (exitVisited[idx] == token) return null;
        exitVisited[idx] = token;

        if (activeOrphans[idx]) {
          consumed.add(idx);
          final typeVal = orphanTypes[idx];
          if (typeVal == 0) {
            currentDir = ArrowDirection.up;
          } else if (typeVal == 1) {
            currentDir = ArrowDirection.down;
          } else if (typeVal == 2) {
            currentDir = ArrowDirection.left;
          } else if (typeVal == 3) {
            currentDir = ArrowDirection.right;
          }
        } else {
          final val = board[idx];
          if (val != 0 && val != arrowIdx + 1) {
            return null;
          }
        }
      }

      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }

    return (consumed: consumed, minesHit: minesHit);
  }
}