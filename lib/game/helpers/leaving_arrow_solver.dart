import 'dart:math';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';

class LeavingArrowSolver {
  static Map<String, dynamic>? findBestLeavingArrow(Map<String, dynamic> args) {
    final List<ArrowModel> arrows = (args['arrows'] as List)
        .map((e) => ArrowModel.fromJson(e))
        .toList();
    final List<RockModel> rocks = (args['rocks'] as List)
        .map((e) => RockModel.fromJson(e))
        .toList();
    final List<OrphanDot> orphanDots = (args['orphanDots'] as List)
        .map((e) => OrphanDot.fromJson(e))
        .toList();
    final int gridSize = args['gridSize'];

    final dotsMap = {for (final d in orphanDots) d.key: d.type};

    final candidates = arrows
        .where(
          (a) =>
              a.state == ArrowState.idle &&
              a.type == ArrowType.normal &&
              !a.isLeavingArrow,
        )
        .toList();
    if (candidates.isEmpty) return null;

    final centerR = gridSize / 2.0;
    final centerC = gridSize / 2.0;

    // Prioritize arrows closest to the center
    final tieBreak = <String, double>{};
    final rng = Random();
    for (final candidate in candidates) {
      tieBreak[candidate.id] = rng.nextDouble();
    }

    candidates.sort((a, b) {
      final distA =
          (a.path[0][0] - centerR).abs() + (a.path[0][1] - centerC).abs();
      final distB =
          (b.path[0][0] - centerR).abs() + (b.path[0][1] - centerC).abs();
      return (distA + tieBreak[a.id]!).compareTo(distB + tieBreak[b.id]!);
    });

    // Check top 30 center arrows
    for (final candidate in candidates.take(30)) {
      final required = _computeExactMinimumMoves(
        candidate.id,
        arrows,
        rocks,
        dotsMap,
        gridSize,
      );
      if (required >= 2 && required <= 13) {
        // ignore: avoid_print
        print('🔍 leaving solver → required=$required (candidates tried)');
        return {'id': candidate.id, 'required': required};
      }
    }

    // Fallback: check the rest of the board
    for (final candidate in candidates) {
      final required = _computeExactMinimumMoves(
        candidate.id,
        arrows,
        rocks,
        dotsMap,
        gridSize,
      );
      if (required >= 2 && required <= 13) {
        // ignore: avoid_print
        print('🔍 leaving solver → required=$required (candidates tried)');
        return {'id': candidate.id, 'required': required};
      }
    }

    // // ── ABSOLUTE FALLBACK: Guarantee a leaving arrow always spawns ──
    // // If no arrow fits the 2-13 rule, just pick the first one and calculate its moves.
    // final fallbackArrow = candidates.first;
    // final fallbackRequired = _computeExactMinimumMoves(fallbackArrow.id, arrows, rocks, dotsMap, gridSize);
    // return {'id': fallbackArrow.id, 'required': fallbackRequired == 99 ? 10 : fallbackRequired};
    return null;
  }

  /// Exact minimum number of arrows that must clear before [targetId]
  /// becomes solvable. Uses transitive blocker closure (BFS over "who
  /// blocks whom"). No budget, no randomness — runs in ~2ms.
  static int _computeExactMinimumMoves(
    String targetId,
    List<ArrowModel> arrows,
    List<RockModel> rocks,
    Map<String, OrphanDotType> dots,
    int gridSize,
  ) {
    final arrowById = {for (final a in arrows) a.id: a};
    final target = arrowById[targetId];
    if (target == null) return 99;

    if (!_computeExitInfoFor(target, arrows, rocks, dots, gridSize).blocked) {
      return 0;
    }

    final mustClear = <String>{};
    final clearedMines = <String>{};
    final queue = <String>[targetId];
    int iterations = 0;
    const maxIterations = 200;

    while (queue.isNotEmpty && iterations < maxIterations) {
      iterations++;
      final id = queue.removeAt(0);
      final arrow = arrowById[id];
      if (arrow == null) continue;

      ArrowDirection dir = arrow.direction;
      final head = arrow.path[0];
      int nr = head[0] + dir.delta[0];
      int nc = head[1] + dir.delta[1];
      final visited = <int>{};

      while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
        final packed = nr * 1000 + nc;
        if (visited.contains(packed)) break;
        visited.add(packed);
        final key = '$nr,$nc';

        // ── Mine check ──
        RockModel? rockHit;
        for (final r in rocks) {
          if (r.row == nr && r.col == nc) {
            rockHit = r;
            break;
          }
        }
        if (rockHit != null) {
          if (arrow.type == ArrowType.slash) {
            // Slash arrows clear mines for free.
            nr += dir.delta[0];
            nc += dir.delta[1];
            continue;
          }
          if (clearedMines.contains(rockHit.id)) {
            // Known cleared by a slash we already queued.
            nr += dir.delta[0];
            nc += dir.delta[1];
            continue;
          }
          // Normal arrow blocked by mine — need a slash arrow.
          bool foundSlash = false;
          for (final other in arrows) {
            if (other.id == id) continue;
            if (other.state == ArrowState.sliding) continue;
            if (other.type != ArrowType.slash) continue;
            if (_slashRayHitsMine(other, rockHit, dots, gridSize)) {
              if (!mustClear.contains(other.id)) {
                mustClear.add(other.id);
                queue.add(other.id);
              }
              clearedMines.add(rockHit.id);
              foundSlash = true;
              break;
            }
          }
          if (!foundSlash) return 99;
          nr += dir.delta[0];
          nc += dir.delta[1];
          continue;
        }

        // ── Redirector / arrow check ──
        if (dots.containsKey(key)) {
          final t = dots[key]!;
          if (t == OrphanDotType.up) {
            dir = ArrowDirection.up;
          } else if (t == OrphanDotType.down) {
            dir = ArrowDirection.down;
          } else if (t == OrphanDotType.left) {
            dir = ArrowDirection.left;
          } else if (t == OrphanDotType.right) {
            dir = ArrowDirection.right;
          }
        } else {
          for (final other in arrows) {
            if (other.id == id) continue;
            if (other.state == ArrowState.sliding) continue;
            if (mustClear.contains(other.id)) continue;
            bool hit = false;
            for (final pt in other.path) {
              if (pt[0] == nr && pt[1] == nc) {
                hit = true;
                break;
              }
            }
            if (hit) {
              mustClear.add(other.id);
              queue.add(other.id);
              break;
            }
          }
        }
        nr += dir.delta[0];
        nc += dir.delta[1];
      }
    }

    return mustClear.length;
  }

  /// True if [slash]'s exit ray (with redirectors applied) passes through
  /// [mine]. Ignores blockers — those are handled by the BFS separately.
  static bool _slashRayHitsMine(
    ArrowModel slash,
    RockModel mine,
    Map<String, OrphanDotType> dots,
    int gridSize,
  ) {
    ArrowDirection dir = slash.direction;
    final head = slash.path[0];
    int nr = head[0] + dir.delta[0];
    int nc = head[1] + dir.delta[1];
    final visited = <int>{};

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final packed = nr * 1000 + nc;
      if (visited.contains(packed)) return false;
      visited.add(packed);

      if (nr == mine.row && nc == mine.col) return true;

      final key = '$nr,$nc';
      if (dots.containsKey(key)) {
        final t = dots[key]!;
        if (t == OrphanDotType.up) {
          dir = ArrowDirection.up;
        } else if (t == OrphanDotType.down) {
          dir = ArrowDirection.down;
        } else if (t == OrphanDotType.left) {
          dir = ArrowDirection.left;
        } else if (t == OrphanDotType.right) {
          dir = ArrowDirection.right;
        }
      }

      nr += dir.delta[0];
      nc += dir.delta[1];
    }
    return false;
  }

  static _ExitInfo _computeExitInfoFor(
    ArrowModel arrow,
    List<ArrowModel> arrows,
    List<RockModel> rocks,
    Map<String, OrphanDotType> orphanDots,
    int gridSize,
  ) {
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
        if (rock.row == nr && rock.col == nc) {
          hitRock = rock;
          break;
        }
      }

      if (hitRock != null) {
        if (!isSlash) return const _ExitInfo(true);
      } else {
        if (orphanDots.containsKey(key)) {
          consumed.add(key);
          switch (orphanDots[key]!) {
            case OrphanDotType.up:
              currentDir = ArrowDirection.up;
              break;
            case OrphanDotType.down:
              currentDir = ArrowDirection.down;
              break;
            case OrphanDotType.left:
              currentDir = ArrowDirection.left;
              break;
            case OrphanDotType.right:
              currentDir = ArrowDirection.right;
              break;
            case OrphanDotType.neutral:
              break;
          }
        } else {
          bool hit = false;
          for (final other in arrows) {
            if (other.id == arrow.id || other.state == ArrowState.sliding) {
              continue;
            }
            if (other.path.any((pt) => pt[0] == nr && pt[1] == nc)) {
              hit = true;
              break;
            }
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
