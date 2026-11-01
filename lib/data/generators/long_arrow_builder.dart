import 'dart:math';
import '../models/arrow.dart';


enum SeedMode { corner, random, rowScan, colScan }

class BuilderStyle {
  final String name;
  final double straightBias;
  final double biasJitter;
  final int maxLen;
  final double lenSpread;
  final SeedMode seedMode;

  const BuilderStyle(this.name, this.straightBias, this.biasJitter,
      this.maxLen, this.lenSpread, this.seedMode);

  static const all = [
    // SeedMode.corner guarantees the arrows hug the walls and interlock perfectly.
    BuilderStyle('maze', 0.85, 0.05, 22, 0.30, SeedMode.corner),
  ];

  static BuilderStyle forLevel(int level, {bool allowLong = false, bool isMaze = false}) {
    return all[0];
  }

  static int maxLenForLevel(int level, int baseMax) {
    if (level <= 10)  return 18;
    if (level <= 20)  return 20;
    if (level <= 40)  return 22;
    if (level <= 80)  return 25;
    return 25;
  }

  BuilderStyle relaxed(int attempt) => BuilderStyle(
      name,
      (straightBias + 0.02 * attempt).clamp(0.15, 0.95),
      biasJitter,
      (maxLen - attempt).clamp(20, 35),
      lenSpread,
      seedMode);
}

class LongArrowBuilder {
  final Random rng;
  final BuilderStyle style;

  LongArrowBuilder({
    required this.rng,
    required this.style,
  });

  static const _nbs = [[-1, 0], [1, 0], [0, -1], [0, 1]];


  /// Returns arrows in solve order (first = clearable first), or null.
  List<ArrowModel>? build({
    required Set<String> mask,
    required int gridSize,
    required int levelNumber,
    int repairIters = 1000, // <-- Changed from 400 to 1000
  }) {
    final cells = <int>{};
    for (final k in mask) {
      final p = k.split(',');
      cells.add(int.parse(p[0]) * 1000 + int.parse(p[1]));
    }

    final paths = _partition(cells);
    if (paths.isEmpty) return null;
    if (!_mergeSingletons(paths)) return null;

    // Random starting orientation (path[0] = head).
    for (int i = 0; i < paths.length; i++) {
      if (rng.nextBool()) paths[i] = paths[i].reversed.toList();
    }

    var order = _peel(paths, gridSize);
    for (int it = 0; it < repairIters && order.length < paths.length; it++) {
      final done = order.toSet();
      final stuck = [
        for (int i = 0; i < paths.length; i++)
          if (!done.contains(i)) i
      ];
      final i = stuck[rng.nextInt(stuck.length)];
      paths[i] = paths[i].reversed.toList();
      final next = _peel(paths, gridSize);
      if (next.length >= order.length) {
        order = next; // keep (sideways moves allowed)
      } else {
        paths[i] = paths[i].reversed.toList(); // revert
      }
    }
    if (order.length < paths.length) return null;

    return [
      for (int k = 0; k < order.length; k++)
        _toArrow(paths[order[k]], 'a_${levelNumber}_$k'),
    ];
  }

  List<List<List<int>>> _partition(Set<int> cells) {
    final free = Set<int>.from(cells);
    final paths = <List<List<int>>>[];

    int degree(int r, int c) {
      int n = 0;
      for (final d in _nbs) {
        if (free.contains((r + d[0]) * 1000 + (c + d[1]))) n++;
      }
      return n;
    }

    while (free.isNotEmpty) {
      int seed;
      switch (style.seedMode) {
        case SeedMode.random:
          seed = free.elementAt(rng.nextInt(free.length));
          break;
        case SeedMode.rowScan:
          seed = free.reduce(min);
          break;
        case SeedMode.colScan:
          seed = free.reduce((a, b) =>
          (a % 1000 * 1000 + a ~/ 1000) < (b % 1000 * 1000 + b ~/ 1000) ? a : b);
          break;
        case SeedMode.corner:
          int bestDeg = 9;
          final ties = <int>[];
          for (final p in free) {
            final dg = degree(p ~/ 1000, p % 1000);
            if (dg < bestDeg) {
              bestDeg = dg;
              ties..clear()..add(p);
            } else if (dg == bestDeg) {
              ties.add(p);
            }
          }
          seed = ties[rng.nextInt(ties.length)];
      }

      final bias = (style.straightBias +
          (rng.nextDouble() - 0.5) * 2 * style.biasJitter)
          .clamp(0.1, 0.98);
      final cap = (style.maxLen *
          (1 - style.lenSpread + style.lenSpread * rng.nextDouble()))
          .round()
          .clamp(3, style.maxLen);

      free.remove(seed);
      final path = <List<int>>[[seed ~/ 1000, seed % 1000]];

      while (path.length < cap) {
        final h = path.last;
        final opts = <List<int>>[];
        for (final d in _nbs) {
          final r = h[0] + d[0], c = h[1] + d[1];
          if (free.contains(r * 1000 + c)) opts.add([r, c]);
        }
        if (opts.isEmpty) break;

        List<int>? straight;
        if (path.length >= 2) {
          final p = path[path.length - 2];
          final dr = h[0] - p[0], dc = h[1] - p[1];
          for (final o in opts) {
            if (o[0] - h[0] == dr && o[1] - h[1] == dc) straight = o;
          }
        }

        List<int> pick;
        if (straight != null && rng.nextDouble() < bias) {
          pick = straight;
        } else {
          if (style.seedMode == SeedMode.corner) {
            // Maze levels: Hug the walls to create interlocking rings
            int best = 9;
            final bestOpts = <List<int>>[];
            for (final o in opts) {
              final dg = degree(o[0], o[1]);
              if (dg < best) {
                best = dg;
                bestOpts..clear()..add(o);
              } else if (dg == best) {
                bestOpts.add(o);
              }
            }
            pick = bestOpts[rng.nextInt(bestOpts.length)];
          } else {
            // Snake levels: Turn randomly to cross the middle
            pick = opts[rng.nextInt(opts.length)];
          }
        }
        free.remove(pick[0] * 1000 + pick[1]);
        path.add(pick);
      }
      paths.add(path);
    }
    return paths;
  }

  // ── 2. No one-cell arrows: glue each to a neighbouring path ──────
  bool _mergeSingletons(List<List<List<int>>> paths) {
    for (int guard = 0; guard < 3000; guard++) {
      final si = paths.indexWhere((p) => p.length == 1);
      if (si == -1) return true;
      final x = paths[si][0];

      bool done = false;
      for (final nb in _nbs) {
        final r = x[0] + nb[0], c = x[1] + nb[1];
        for (int j = 0; j < paths.length; j++) {
          if (j == si) continue;
          final P = paths[j];
          final idx = P.indexWhere((q) => q[0] == r && q[1] == c);
          if (idx == -1) continue;
          if (idx == P.length - 1) {
            P.add(x);
          } else if (idx == 0) {
            P.insert(0, x);
          } else {
            // Split P at the neighbour: prefix + x, suffix becomes its own arrow.
            final suffix = P.sublist(idx + 1);
            paths[j] = [...P.sublist(0, idx + 1), x];
            paths.add(suffix);
          }
          done = true;
          break;
        }
        if (done) break;
      }
      if (!done) return false;
      paths.removeAt(si);
    }
    return false;
  }

  // ── 3. Exact greedy peel (no redirectors/mines yet) ───────────────
  List<int> _peel(List<List<List<int>>> paths, int gridSize) {
    final owner = List<int>.filled(gridSize * gridSize, -1);
    for (int i = 0; i < paths.length; i++) {
      for (final pt in paths[i]) {
        owner[pt[0] * gridSize + pt[1]] = i;
      }
    }
    final alive = List<bool>.filled(paths.length, true);
    final order = <int>[];

    bool progress = true;
    while (progress) {
      progress = false;
      for (int i = 0; i < paths.length; i++) {
        if (!alive[i]) continue;
        final h = paths[i][0], n = paths[i][1];
        final dr = h[0] - n[0], dc = h[1] - n[1];
        int r = h[0] + dr, c = h[1] + dc;
        bool clear = true;
        while (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
          if (owner[r * gridSize + c] != -1) {
            clear = false; // another arrow, or its own curled body
            break;
          }
          r += dr;
          c += dc;
        }
        if (clear) {
          for (final pt in paths[i]) {
            owner[pt[0] * gridSize + pt[1]] = -1;
          }
          alive[i] = false;
          order.add(i);
          progress = true;
        }
      }
    }
    return order;
  }

  ArrowModel _toArrow(List<List<int>> path, String id) {
    final h = path[0], n = path[1];
    final dr = h[0] - n[0], dc = h[1] - n[1];
    final dir = dr < 0
        ? ArrowDirection.up
        : dr > 0
        ? ArrowDirection.down
        : dc < 0
        ? ArrowDirection.left
        : ArrowDirection.right;
    return ArrowModel(id: id, row: h[0], col: h[1], direction: dir, path: path);
  }
}