import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../data/level_generator/level_generator.dart';
import '../data/models/arrow.dart';
import '../data/models/level.dart';

/// Uses the real level generator so you can see mines + slash arrows
/// in a genuine level, with all its winding arrow shapes.
///
/// Try different level numbers — higher = bigger board.
/// Around 350-450 the grid tends to be ~20×20.
class TestMineLevel {
  TestMineLevel._();

  /// Generates a real level. If the generator didn't place any mines
  /// (some level numbers roll 0 rocks), mines + slash arrows are
  /// patched in by converting long normal arrows.
  static LevelModel create({
    int levelNumber = 400,
    int fallbackMineCount = 3,
  }) {
    final lv = LevelGenerator.generateLevel(levelNumber);

    debugPrint('⚙️ TEST: level $levelNumber → '
        'gridSize=${lv.gridSize}, arrows=${lv.arrows.length}, '
        'rocks=${lv.rocks.length}, '
        'slashes=${lv.arrows.where((a) => a.type == ArrowType.slash).length}');

    if (lv.rocks.isNotEmpty) return lv;
    return _patchMines(lv, fallbackMineCount);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Fallback: only used when the real generator returned no mines.
  // ─────────────────────────────────────────────────────────────────────

  static LevelModel _patchMines(LevelModel level, int desiredCount) {
    final gridSize = level.gridSize;
    final rng = Random(level.levelNumber * 7331 + 991);

    // Occupied cells = arrow bodies + existing mines.
    final occupied = <String>{};
    for (final a in level.arrows) {
      for (final pt in a.path) {
        occupied.add('${pt[0]},${pt[1]}');
      }
    }
    for (final r in level.rocks) {
      occupied.add('${r.row},${r.col}');
    }

    final orphanSet = <String>{
      for (final od in level.orphanDots) od.key,
    };

    final arrows = level.arrows.map((a) => a.copyWith()).toList();
    final newMines = <RockModel>[];

    // Find arrows with a long, unblocked straight exit ray.
    final candidates = <({int idx, List<List<int>> ray})>[];
    for (int i = 0; i < arrows.length; i++) {
      final a = arrows[i];
      if (a.type != ArrowType.normal) continue;
      if (a.isLeavingArrow) continue;
      if (a.path.length < ArrowConstants.slashMinLength) continue;

      final delta = a.direction.delta;
      var r = a.path[0][0] + delta[0];
      var c = a.path[0][1] + delta[1];
      final ray = <List<int>>[];
      final visited = <String>{};
      bool blocked = false;

      while (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
        final key = '$r,$c';
        if (visited.contains(key)) { blocked = true; break; }
        visited.add(key);
        if (orphanSet.contains(key)) { blocked = true; break; }
        if (occupied.contains(key)) { blocked = true; break; }
        ray.add([r, c]);
        r += delta[0];
        c += delta[1];
      }

      if (blocked || ray.length < 8) continue;
      candidates.add((idx: i, ray: ray));
    }

    if (candidates.isEmpty) {
      debugPrint('⚙️ TEST: no slash candidates — returning base level.');
      return level;
    }

    candidates.shuffle(rng);
    int placed = 0;
    for (final cand in candidates) {
      if (placed >= desiredCount) break;

      const minStep = 3;
      final maxStep = min(6, cand.ray.length - 2);
      if (maxStep < minStep) continue;

      final step = minStep + rng.nextInt(maxStep - minStep + 1);
      final cell = cand.ray[step - 1];

      bool tooClose = false;
      for (final m in newMines) {
        if ((m.row - cell[0]).abs() + (m.col - cell[1]).abs() < 4) {
          tooClose = true;
          break;
        }
      }
      if (tooClose) continue;

      arrows[cand.idx] = arrows[cand.idx].copyWith(type: ArrowType.slash);
      newMines.add(RockModel(
        id: 'mine_test_$placed',
        row: cell[0],
        col: cell[1],
      ));
      occupied.add('${cell[0]},${cell[1]}');
      placed++;
    }

    debugPrint('⚙️ TEST: patched $placed mines into level ${level.levelNumber}');

    return LevelModel(
      levelNumber: level.levelNumber,
      gridSize: level.gridSize,
      arrows: arrows,
      rocks: [...level.rocks, ...newMines],
      maskShape: level.maskShape,
      mask: level.mask,
      orphanDots: level.orphanDots,
    );
  }
}