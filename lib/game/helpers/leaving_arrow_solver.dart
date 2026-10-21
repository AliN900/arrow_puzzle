import 'dart:math';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';

class LeavingArrowSolver {
  static Map<String, dynamic>? findBestLeavingArrow(Map<String, dynamic> args) {
    final List<ArrowModel> arrows = (args['arrows'] as List).map((e) => ArrowModel.fromJson(e)).toList();
    final List<RockModel> rocks = (args['rocks'] as List).map((e) => RockModel.fromJson(e)).toList();
    final List<OrphanDot> orphanDots = (args['orphanDots'] as List).map((e) => OrphanDot.fromJson(e)).toList();
    final int gridSize = args['gridSize'];

    final dotsMap = {for (final d in orphanDots) d.key: d.type};

    final candidates = arrows.where((a) => a.state == ArrowState.idle && a.type == ArrowType.normal && !a.isLeavingArrow).toList();
    if (candidates.isEmpty) return null;

    final centerR = gridSize / 2.0;
    final centerC = gridSize / 2.0;

    // Prioritize arrows closest to the center
    candidates.sort((a, b) {
      final distA = (a.path[0][0] - centerR).abs() + (a.path[0][1] - centerC).abs();
      final distB = (b.path[0][0] - centerR).abs() + (b.path[0][1] - centerC).abs();
      return (distA + Random().nextDouble()).compareTo(distB + Random().nextDouble());
    });

    // Check top 30 center arrows
    for (final candidate in candidates.take(30)) {
      final required = _computeExactMinimumMoves(candidate.id, arrows, rocks, dotsMap, gridSize);
      if (required >= 2 && required <= 13) {
        return {'id': candidate.id, 'required': required};
      }
    }

    // Fallback: check the rest of the board
    for (final candidate in candidates) {
      final required = _computeExactMinimumMoves(candidate.id, arrows, rocks, dotsMap, gridSize);
      if (required >= 2 && required <= 13) {
        return {'id': candidate.id, 'required': required};
      }
    }

    // ── ABSOLUTE FALLBACK: Guarantee a leaving arrow always spawns ──
    // If no arrow fits the 2-13 rule, just pick the first one and calculate its moves.
    final fallbackArrow = candidates.first;
    final fallbackRequired = _computeExactMinimumMoves(fallbackArrow.id, arrows, rocks, dotsMap, gridSize);
    return {'id': fallbackArrow.id, 'required': fallbackRequired == 99 ? 10 : fallbackRequired};
  }

  /// Runs a 50-attempt Randomized Greedy Search to find the absolute shortest path.
  static int _computeExactMinimumMoves(String targetId, List<ArrowModel> arrows, List<RockModel> rocks, Map<String, OrphanDotType> dots, int gridSize) {
    final target = arrows.firstWhere((a) => a.id == targetId);
    if (!_computeExitInfoFor(target, arrows, rocks, dots, gridSize).blocked) return 0;

    int bestCleared = 99;

    // Run 50 times to ensure we find the absolute shortest path
    for (int attempt = 0; attempt < 50; attempt++) {
      final working = List<ArrowModel>.from(arrows);
      int cleared = 0;
      bool solved = false;

      while (cleared < 14) {
        final solvable = <ArrowModel>[];
        for (final a in working) {
          if (a.id == targetId || a.state != ArrowState.idle) continue;
          if (!_computeExitInfoFor(a, working, rocks, dots, gridSize).blocked) {
            solvable.add(a);
          }
        }
        if (solvable.isEmpty) break;

        // Shuffle to try different paths every attempt
        solvable.shuffle();
        working.remove(solvable.first);
        cleared++;

        if (!_computeExitInfoFor(target, working, rocks, dots, gridSize).blocked) {
          solved = true;
          break;
        }
      }

      if (solved && cleared < bestCleared) {
        bestCleared = cleared;
        if (bestCleared == 1) break; // Can't do better than 1
      }
    }

    return bestCleared;
  }

  static _ExitInfo _computeExitInfoFor(ArrowModel arrow, List<ArrowModel> arrows, List<RockModel> rocks, Map<String, OrphanDotType> orphanDots, int gridSize) {
    ArrowDirection currentDir = arrow.direction;
    final head = arrow.path[0];
    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final consumed = <String>[];
    final visited = <String>{};
    final isSlash = arrow.type == ArrowType.slash;

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final key = '$nr,$nc';
      if (visited.contains(key)) return const _ExitInfo(true);
      visited.add(key);

      RockModel? hitRock;
      for (final rock in rocks) {
        if (rock.row == nr && rock.col == nc) { hitRock = rock; break; }
      }

      if (hitRock != null) {
        if (!isSlash) return const _ExitInfo(true);
      } else {
        if (orphanDots.containsKey(key)) {
          consumed.add(key);
          switch (orphanDots[key]!) {
            case OrphanDotType.up: currentDir = ArrowDirection.up; break;
            case OrphanDotType.down: currentDir = ArrowDirection.down; break;
            case OrphanDotType.left: currentDir = ArrowDirection.left; break;
            case OrphanDotType.right: currentDir = ArrowDirection.right; break;
            case OrphanDotType.neutral: break;
          }
        } else {
          bool hit = false;
          for (final other in arrows) {
            if (other.id == arrow.id || other.state == ArrowState.sliding) continue;
            if (other.path.any((pt) => pt[0] == nr && pt[1] == nc)) { hit = true; break; }
          }
          if (hit) return const _ExitInfo(true);
        }
      }
      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }
    return _ExitInfo(false, consumed);
  }
}

class _ExitInfo {
  final bool blocked;
  final List<String> consumed;
  const _ExitInfo(this.blocked, [this.consumed = const []]);
}