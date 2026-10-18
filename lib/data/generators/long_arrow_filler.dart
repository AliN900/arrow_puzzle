import 'dart:math';

import '../models/arrow.dart';

/// Fills a silhouette mask with long, non-overlapping arrow paths.
///
/// Design goals, in order:
///   1. Every path stays strictly inside the mask.
///   2. Paths are biased straight → fewer, longer arrows.
///   3. Paths never overlap → all cells get consumed.
///   4. Path direction = direction of the last segment (arrowhead direction).
///
/// Tune via [straightBias]:
///   0.50 = snaky, lots of turns
///   0.70 = balanced (default)
///   0.85 = long straight runs, few turns
class LongArrowFiller {
  final Random rng;
  final double straightBias;

  LongArrowFiller({
    required this.rng,
    this.straightBias = 0.70,
  });

  List<ArrowModel> fill({required Set<String> mask}) {
    final free = Set<String>.from(mask);
    final arrows = <ArrowModel>[];
    int nextId = 0;

    // Seed order: cells with the fewest free neighbours first (corners
    // and edges), so the open middle is left for long runs.
    final seeds = mask.toList()
      ..sort((a, b) => _freeNeighborCount(a, free)
          .compareTo(_freeNeighborCount(b, free)));

    for (final seed in seeds) {
      if (!free.contains(seed)) continue;

      final path = _growPath(seed, free);
      if (path.length < 2) {
        free.remove(seed);
        continue;
      }

      // Consume the cells this arrow occupies.
      for (final cell in path) {
        free.remove('${cell[0]},${cell[1]}');
      }

      // The arrowhead sits at the end of the path.
      final head = path.last;
      arrows.add(ArrowModel(
        id: (nextId++).toString(),
        row: head[0],
        col: head[1],
        direction: _directionFromTail(path),
        path: path,
      ));
    }

    return arrows;
  }

  // ─────────────────────────────────────────────────────────────────
  // Path growth
  // ─────────────────────────────────────────────────────────────────

  List<List<int>> _growPath(String startKey, Set<String> free) {
    final start = _parse(startKey);
    final path = <List<int>>[start];
    final used = <String>{startKey};

    while (true) {
      final head = path.last;
      final candidates = _freeNeighbors(head, free, used);
      if (candidates.isEmpty) break;

      List<int>? lastDir;
      if (path.length >= 2) {
        final prev = path[path.length - 2];
        lastDir = [head[0] - prev[0], head[1] - prev[1]];
      }

      final scored = candidates.map((c) {
        final d = [c[0] - head[0], c[1] - head[1]];
        final sameDir = lastDir != null &&
            d[0] == lastDir[0] &&
            d[1] == lastDir[1];
        final score = sameDir ? straightBias : (1.0 - straightBias);
        return (cell: c, score: score);
      }).toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      final topScore = scored.first.score;
      final topTier =
      scored.where((s) => s.score == topScore).toList();
      final chosen = topTier[rng.nextInt(topTier.length)].cell;

      path.add(chosen);
      used.add('${chosen[0]},${chosen[1]}');
    }

    return path;
  }

  List<List<int>> _freeNeighbors(
      List<int> cell,
      Set<String> free,
      Set<String> used,
      ) {
    final out = <List<int>>[];
    const deltas = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    for (final d in deltas) {
      final r = cell[0] + d[0];
      final c = cell[1] + d[1];
      final key = '$r,$c';
      if (free.contains(key) && !used.contains(key)) {
        out.add([r, c]);
      }
    }
    return out;
  }

  int _freeNeighborCount(String key, Set<String> free) {
    final p = _parse(key);
    int count = 0;
    const deltas = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    for (final d in deltas) {
      if (free.contains('${p[0] + d[0]},${p[1] + d[1]}')) count++;
    }
    return count;
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────

  List<int> _parse(String key) {
    final parts = key.split(',');
    return [int.parse(parts[0]), int.parse(parts[1])];
  }

  ArrowDirection _directionFromTail(List<List<int>> path) {
    if (path.length < 2) return ArrowDirection.right;
    final last = path[path.length - 1];
    final prev = path[path.length - 2];
    final dRow = last[0] - prev[0];
    final dCol = last[1] - prev[1];
    if (dRow < 0) return ArrowDirection.up;
    if (dRow > 0) return ArrowDirection.down;
    if (dCol < 0) return ArrowDirection.left;
    return ArrowDirection.right;
  }
}