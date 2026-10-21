import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

import '../models/arrow.dart';
import '../models/level.dart';
import '../../core/constants.dart';
import 'solver.dart';
import 'mask_generator.dart';

class LevelGenerator {
  static LevelModel generateLevel(
      int levelNumber, {
        bool complexPaths = false,
        int? seed,
      }) {
    final baseSeed = seed ?? (levelNumber * 103 + 51 + (complexPaths ? 99991 : 0));

    for (int attempt = 0; attempt < 20; attempt++) {
      final actualSeed = baseSeed + (attempt * 777); // Shift seed on retry
      final rng = Random(actualSeed);

      final type = AppConstants.levelTypeFor(levelNumber);
      int gridSize = AppConstants.gridSizeForLevel(levelNumber);
      if (levelNumber == 213) gridSize = 32;
      if (levelNumber == 395) gridSize = 35;
      if (levelNumber == 437) gridSize = 36;

      final maskShape = _shapeFor(type, rng);
      final mask = MaskGenerator.shapeByName(maskShape.name, gridSize, rng);
      final params = _paramsFor(levelNumber, type, gridSize, mask, complexPaths: complexPaths);

      final level = _generateReverse(
        levelNumber: levelNumber,
        gridSize: gridSize,
        mask: mask,
        params: params,
        type: type,
        rng: rng,
        maskShape: maskShape,
        complexPaths: complexPaths,
      );

      // ── NEW: reject levels with too many unfilled mask cells ──
      final filled = <int>{};
      for (final a in level.arrows) {
        for (final pt in a.path) {
          filled.add(pt[0] * 1000 + pt[1]);
        }
      }
      for (final r in level.rocks) {
        filled.add(r.row * 1000 + r.col);
      }
      final fillRatio = filled.length / level.mask.length;

      if (fillRatio < 0.75) {
        debugPrint('❌ L$levelNumber attempt $attempt: fill '
            '${(fillRatio * 100).toStringAsFixed(1)}% — retrying');
        continue;
      }

      // ── THE FIX: Verify solvability ──
      if (LevelSolver.solve(level, 200000) != null) {
        return level;
      }

      debugPrint('❌ Normal L$levelNumber attempt $attempt failed (deadlock). Retrying...');
    }

    debugPrint('⚠️ FATAL: Could not generate solvable normal level $levelNumber.');
    return _generateFallbackLevel(levelNumber);   // ← was the 5×5 stub
  }


  /// Last-resort fallback. Fully-filled small grid, trivially solvable.
  /// Never returns an "empty center" — every mask cell is part of an arrow.
  static LevelModel _generateFallbackLevel(int levelNumber) {
    const gridSize = 8;
    final mask = <String>{
      for (int r = 0; r < gridSize; r++)
        for (int c = 0; c < gridSize; c++) '$r,$c',
    };
    final arrows = <ArrowModel>[];
    for (int r = 0; r < gridSize; r++) {
      // Each row is one horizontal arrow, head at rightmost cell.
      // Every arrow exits right immediately (rightmost cell → off-board).
      arrows.add(ArrowModel(
        id: 'fallback_${r}',
        row: r,
        col: gridSize - 1,
        direction: ArrowDirection.right,
        path: [
          for (int c = gridSize - 1; c >= 0; c--) [r, c],
        ],
      ));
    }
    return LevelModel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      arrows: arrows,
      maskShape: MaskShape.square,
      mask: mask,
    );
  }


  /// Builds a level from an **externally supplied mask** (e.g. an ASCII art
  /// silhouette) using the same reverse-generation pipeline as campaign
  /// levels. The result is guaranteed solvable, and arrows only occupy cells
  /// inside [mask] — so the shape is preserved.
  ///
  /// [avgLengthOverride] lets the caller request longer, snakier arrows than
  /// the level-based default. Good values for art levels: 4–8.
  static LevelModel generateFromMask({
    required int levelNumber,
    required Set<String> mask,
    required int gridSize,
    required MaskShape maskShape,
    int? seed,
    bool complexPaths = false,
    int? avgLengthOverride,
  }) {
    final baseSeed = seed ?? (levelNumber * 103 + 51 + (complexPaths ? 99991 : 0));

    int? veryLongMinOv;
    int? longMinOv;
    int? veryLongMaxOv;

    if (avgLengthOverride != null) {
      veryLongMinOv = avgLengthOverride + 1;
      longMinOv = avgLengthOverride;
      veryLongMaxOv = 25;
    }

    for (int attempt = 0; attempt < 20; attempt++) {
      final actualSeed = baseSeed + (attempt * 1337);
      final rng = Random(actualSeed);

      const type = LevelType.normal;
      var params = _paramsFor(
        levelNumber, type, gridSize, mask, complexPaths: complexPaths,
      );

      final level = _generateReverse(
        levelNumber: levelNumber,
        gridSize: gridSize,
        mask: mask,
        params: params,
        type: type,
        rng: rng,
        maskShape: maskShape,
        complexPaths: complexPaths,
        veryLongMinOv: veryLongMinOv,
        longMinOv: longMinOv,
        veryLongMaxOv: veryLongMaxOv,
      );

      // ── NEW: reject levels with too many unfilled mask cells ──
      final filled = <int>{};
      for (final a in level.arrows) {
        for (final pt in a.path) {
          filled.add(pt[0] * 1000 + pt[1]);
        }
      }
      for (final r in level.rocks) {
        filled.add(r.row * 1000 + r.col);
      }
      final fillRatio = filled.length / level.mask.length;

      if (fillRatio < 0.75) {
        debugPrint('❌ L$levelNumber attempt $attempt: fill '
            '${(fillRatio * 100).toStringAsFixed(1)}% — retrying');
        continue;
      }

      // ── THE FIX: Use LevelSolver with a massive limit ──
      if (LevelSolver.solve(level, 200000) != null) {
        debugPrint('✅ Solvable level $levelNumber generated on attempt $attempt');
        return level;
      }

      debugPrint('❌ Attempt $attempt failed (unclearable). Retrying...');
    }

    debugPrint('⚠️ FATAL: Could not generate solvable level $levelNumber after 20 attempts.');
    return _generateFallbackLevel(levelNumber);   // ← same as generateLevel
  }

  static LevelModel _generateReverse({
    required int levelNumber,
    required int gridSize,
    required Set<String> mask,
    required _Params params,
    required LevelType type,
    required Random rng,
    required MaskShape maskShape,
    bool complexPaths = false,
    int? veryLongMinOv,
    int? longMinOv,
    int? veryLongMaxOv,
  }) {
    final maskCells = mask.map((k) {
      final parts = k.split(',');
      return [int.parse(parts[0]), int.parse(parts[1])];
    }).toList();

    final maskPacked = <int>{};
    for (final cell in maskCells) {
      maskPacked.add(cell[0] * 1000 + cell[1]);
    }

    final occupied = <String>{};
    final occupiedPacked = <int>{};
    final reverseArrows = <ArrowModel>[];

    final double tangleFactor;
    double baseTangle;
    if (complexPaths) {
      baseTangle = 1.0;
    } else if (levelNumber <= 14) {
      baseTangle = 0.0;
    } else if (levelNumber <= 30) {
      baseTangle = 0.10;
    } else if (levelNumber <= 60) {
      baseTangle = 0.30;
    } else if (levelNumber <= 150) {
      baseTangle = 0.60;
    } else if (levelNumber <= 300) {
      baseTangle = 0.80;
    } else {
      baseTangle = 1.0;
    }

    if (type == LevelType.boss) {
      baseTangle = (baseTangle + 0.15).clamp(0.15, 1.0);
    } else if (maskShape == MaskShape.silhouette) {
      // Silhouette shapes need straight lines to trace the outline clearly
      baseTangle = 0.10;
    } else if (type == LevelType.god) {
      baseTangle = (baseTangle + 0.25).clamp(0.40, 1.0);
    }

    if (AppConstants.isSnakeLevel(levelNumber)) {
      baseTangle = 1.0;
    }

    tangleFactor = baseTangle;

    int veryLongMin = veryLongMinOv ?? (5 + (gridSize ~/ 6));
    int longMin = longMinOv ?? (3 + (gridSize ~/ 10));
    int veryLongMax = veryLongMaxOv ?? max(
      veryLongMin + 1,
      (veryLongMin + 4).clamp(veryLongMin + 1, mask.length),
    );

    if (veryLongMinOv == null) {
      if (complexPaths) {
        veryLongMin = max(6, veryLongMin + 1);
        longMin = max(4, longMin + 1);
        veryLongMax = max(veryLongMin + 2, veryLongMax + 2);
      }
      if (maskShape != MaskShape.square) {
        veryLongMin = max(5, (veryLongMin * 0.8).round());
        longMin = max(3, (longMin * 0.8).round());
        veryLongMax = max(veryLongMin + 1, (veryLongMax * 0.8).round());
      }
    }

    int targetLenForTier(_LenTier tier) {
      switch (tier) {
        case _LenTier.veryLong:
          return veryLongMin + rng.nextInt(max(1, veryLongMax - veryLongMin + 1));
        case _LenTier.long:
          return longMin + rng.nextInt(max(1, veryLongMin - longMin));
        case _LenTier.medium:
          return (complexPaths ? 3 : 2) + rng.nextInt(max(1, longMin - (complexPaths ? 2 : 1)));
      }
    }

    int veryLongCount = 0;
    int longCount = 0;
    int medCount = 0;
    int failures = 0;
    // Was: final int maxFailures = AppConstants.isSnakeLevel(levelNumber) ? 100 : 40;
    final int maxFailures = AppConstants.isSnakeLevel(levelNumber)
        ? 100
        : (maskShape == MaskShape.silhouette ? 150 : 40);

    while (failures < maxFailures && occupiedPacked.length < mask.length) {
      final candidates = _exitCandidates(
        maskCells,
        occupiedPacked,
        gridSize,
      );

      if (candidates.isEmpty) break;

      final total = veryLongCount + longCount + medCount;
      final _LenTier wantTier;
      if (failures > 10) {
        wantTier = _LenTier.medium;
      } else if (total == 0) {
        wantTier = _LenTier.veryLong;
      } else if (complexPaths) {
        final vlRatio = veryLongCount / total;
        final lRatio = longCount / total;
        if (vlRatio < 0.45) {
          wantTier = _LenTier.veryLong;
        } else if (lRatio < 0.35) {
          wantTier = _LenTier.long;
        } else {
          wantTier = _LenTier.medium;
        }
      } else {
        final vlRatio = veryLongCount / total;
        final lRatio = longCount / total;

        // CHANGE THIS: Raise the threshold for silhouettes from 0.33 to 0.60
        final double veryLongThreshold = (maskShape == MaskShape.silhouette) ? 0.60 : 0.33;

        if (vlRatio < veryLongThreshold) {
          wantTier = _LenTier.veryLong;
        } else if (lRatio < 0.25) { // Changed from 0.33 to 0.25
          wantTier = _LenTier.long;
        } else {
          wantTier = _LenTier.medium;
        }
      }

      // Only apply the edge bias to 50% of the very long arrows.
// The other 50% will shoot straight into the center and fill it up!
      final bool edgeBias = (maskShape == MaskShape.silhouette) &&
          (wantTier == _LenTier.veryLong) &&
          (rng.nextDouble() < 0.5);
      final recentArrows = reverseArrows.length > 20
          ? reverseArrows.sublist(reverseArrows.length - 20)
          : reverseArrows;

      _shuffleCandidates(candidates, gridSize, rng, complexPaths, maskShape,
          edgeBias: edgeBias, recentArrows: recentArrows);

      int targetLen = targetLenForTier(wantTier);
      if (failures > 5) {
        targetLen = max(2, targetLen - (failures - 5));
      }

      _Cand? bestCand;
      List<List<int>>? bestPath;

      for (final cand in candidates.take(25)) {
        final path = _growPath(
          startRow: cand.row,
          startCol: cand.col,
          exitDir: cand.dir,
          maskPacked: maskPacked,
          occupiedPacked: occupiedPacked,
          targetLen: targetLen,
          rng: rng,
          gridSize: gridSize,
          tangleFactor: tangleFactor,
          complexPaths: complexPaths,
          edgeBias: edgeBias,
        );

        if (path != null && path.length >= 2) {
          bestCand = cand;
          bestPath = path;
          break;
        }
      }

      if (bestCand != null && bestPath != null) {
        final arrowId = 'a_${levelNumber}_${reverseArrows.length}';
        reverseArrows.add(ArrowModel(
          id: arrowId,
          row: bestPath[0][0],
          col: bestPath[0][1],
          direction: bestCand.dir,
          path: bestPath,
        ));

        for (final pt in bestPath) {
          occupied.add('${pt[0]},${pt[1]}');
          occupiedPacked.add(pt[0] * 1000 + pt[1]);
        }

        if (bestPath.length >= veryLongMin) {
          veryLongCount++;
        } else if (bestPath.length >= longMin) {
          longCount++;
        } else {
          medCount++;
        }
        failures = 0;
      } else {
        failures++;
      }
    }

    bool madeFillProgress = true;
    while (madeFillProgress && occupiedPacked.length < mask.length) {
      madeFillProgress = false;
      final candidates = _exitCandidates(
        maskCells,
        occupiedPacked,
        gridSize,
      );
      if (candidates.isEmpty) break;
      _shuffleCandidates(candidates, gridSize, rng, complexPaths, maskShape);

      for (final cand in candidates) {
        final path = _growPath(
          startRow: cand.row,
          startCol: cand.col,
          exitDir: cand.dir,
          maskPacked: maskPacked,
          occupiedPacked: occupiedPacked,
          targetLen: 2 + rng.nextInt(4), // Random length 2-5
          rng: rng,
          gridSize: gridSize,
          tangleFactor: 0.85, // Force it to snake into gaps
          complexPaths: complexPaths,
        );

        if (path != null && path.length >= 2) {
          final arrowId = 'a_${levelNumber}_${reverseArrows.length}';
          reverseArrows.add(ArrowModel(
            id: arrowId,
            row: path[0][0],
            col: path[0][1],
            direction: cand.dir,
            path: path,
          ));

          for (final pt in path) {
            occupied.add('${pt[0]},${pt[1]}');
            occupiedPacked.add(pt[0] * 1000 + pt[1]);
          }
          madeFillProgress = true;
          break;
        }
      }
    }

    if (occupied.length < mask.length) {
      _absorbOrphans(reverseArrows, occupied, occupiedPacked, mask, gridSize);
    }

    final arrows = <ArrowModel>[];
    for (int i = reverseArrows.length - 1; i >= 0; i--) {
      final a = reverseArrows[i];
      arrows.add(a.copyWith(id: 'a_${levelNumber}_${arrows.length}'));
    }


    // === Place mines on blocker arrows, and a slash arrow to clear them ===
    //
    // A mine replaces a blocker arrow's cell. The slash arrow is placed on
    // the blocked arrow's exit path (guaranteed clear up to the mine),
    // and its body must be at least 5 cells long.
    final rocks = <RockModel>[];
    final slashArrows = <ArrowModel>[];
    final rockCount = AppConstants.rockCountForLevel(levelNumber);

    if (rockCount > 0 && arrows.isNotEmpty) {
      final candidates =
      <({int aIdx, int qR, int qC, ArrowDirection dir})>[];

      // Pass 1: mines at cells that actually block another arrow's exit.
      for (int i = 0; i < arrows.length; i++) {
        final arrow = arrows[i];
        final head = arrow.path[0];
        final d = arrow.direction.delta;
        int nr = head[0] + d[0];
        int nc = head[1] + d[1];
        int steps = 1;
        final visited = <int>{};

        while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
          final packed = nr * 1000 + nc;
          if (visited.contains(packed)) break;
          visited.add(packed);
          if (occupiedPacked.contains(packed)) {
            if (steps >= 2) {
              candidates.add((
              aIdx: i,
              qR: nr,
              qC: nc,
              dir: arrow.direction,
              ));
            }
            break;
          }
          nr += d[0];
          nc += d[1];
          steps++;
        }
      }

      // Pass 2 (fallback): mines on empty cells along an arrow's exit path.
      if (candidates.isEmpty && rockCount > 0) {
        for (int i = 0; i < arrows.length; i++) {
          final arrow = arrows[i];
          final head = arrow.path[0];
          final d = arrow.direction.delta;
          int nr = head[0] + d[0];
          int nc = head[1] + d[1];
          int steps = 1;
          final visited = <int>{};

          while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
            final packed = nr * 1000 + nc;
            if (visited.contains(packed)) break;
            visited.add(packed);
            if (occupiedPacked.contains(packed)) break;

            if (steps >= 2) {
              candidates.add((
              aIdx: i,
              qR: nr,
              qC: nc,
              dir: arrow.direction,
              ));
            }
            nr += d[0];
            nc += d[1];
            steps++;
          }
        }
      }

      debugPrint('⚙️ LEVEL $levelNumber: ${candidates.length} valid candidates');

      int rocksPlaced = 0;
      for (final cand in candidates) {
        if (rocksPlaced >= rockCount) break;

        final rockR = cand.qR;
        final rockC = cand.qC;

        bool tooClose = false;
        for (final rock in rocks) {
          if ((rock.row - rockR).abs() + (rock.col - rockC).abs() < 4) {
            tooClose = true;
            break;
          }
        }
        if (tooClose) continue;

        final rockPackedHere = rockR * 1000 + rockC;
        final rockIsEmpty = !occupiedPacked.contains(rockPackedHere);

        int blockerIdx = -1;
        if (!rockIsEmpty) {
          for (int j = 0; j < arrows.length; j++) {
            if (arrows[j]
                .path
                .any((pt) => pt[0] == rockR && pt[1] == rockC)) {
              blockerIdx = j;
              break;
            }
          }
          if (blockerIdx == -1) continue;
        }

        final placements = <({
        int headR,
        int headC,
        List<List<int>> path,
        ArrowDirection dir,
        int score,
        int blockers,
        })>[];

        for (final tryDir in ArrowDirection.values) {
          final td = tryDir.delta;

          for (int dist = 3; dist <= 8; dist++) {
            final hR = rockR - td[0] * dist;
            final hC = rockC - td[1] * dist;

            if (hR < 0 || hR >= gridSize) continue;
            if (hC < 0 || hC >= gridSize) continue;
            if (!mask.contains('$hR,$hC')) continue;
            if (occupiedPacked.contains(hR * 1000 + hC)) continue;

            // Build a 5-cell slash arrow body: head + 4 tail cells,
            // walking backwards along -td.
// Try lengths 5 → 4 → 3 in descending preference:
for (final desiredBodyLen in [5, 4, 3]) {
final slashPath = <List<int>>[[hR, hC]];
bool bodyValid = true;
for (int step = 1; step < desiredBodyLen; step++) {
final sr = hR - td[0] * step;
final sc = hC - td[1] * step;
if (sr < 0 || sr >= gridSize || sc < 0 || sc >= gridSize ||
!mask.contains('$sr,$sc') ||
occupiedPacked.contains(sr * 1000 + sc)) {
bodyValid = false;
break;
}
slashPath.add([sr, sc]);
}
if (!bodyValid) continue;

            // Count blockers on the path from head to the mine.
            int blockers = 0;
            bool deadlock = false;

            final rocksForCheck = <RockModel>[
              ...rocks,
              RockModel(
                  id: 'future_${rocks.length}', row: rockR, col: rockC),
            ];

            final slashCells = <int>{
              for (final pt in slashPath) pt[0] * 1000 + pt[1],
            };

            for (int s = 1; s < dist; s++) {
              final pr = hR + td[0] * s;
              final pc = hC + td[1] * s;
              final packed = pr * 1000 + pc;

              if (occupiedPacked.contains(packed)) {
                int blockerArrowIdx = -1;
                for (int b = 0; b < arrows.length; b++) {
                  if (arrows[b]
                      .path
                      .any((pt) => pt[0] == pr && pt[1] == pc)) {
                    blockerArrowIdx = b;
                    break;
                  }
                }
                if (blockerArrowIdx != -1) {
                  final blockerArrow = arrows[blockerArrowIdx];
                  final clearable = _arrowPathClearOfRocks(
                    blockerArrow,
                    rocksForCheck,
                    gridSize,
                    // extraBlocked: slashCells,
                  );
                  if (clearable) {
                    blockers++;
                  } else {
                    deadlock = true;
                    break;
                  }
                }
              }
            }

            if (deadlock) continue;

            int score;
            if (blockers == 1) {
              score = 100;
            } else if (blockers == 2) {
              score = 90;
            } else if (blockers == 3) {
              score = 60;
            } else if (blockers > 3) {
              score = 20;
            } else {
              score = 5;
            }
score += desiredBodyLen * 2;

placements.add(( headR: hR, headC: hC, path: slashPath,
dir: tryDir, score: score, blockers: blockers ));
break;  // found a valid length for this direction, stop trying shorter
}
          }
        }

        if (placements.isEmpty) continue;
        placements.sort((a, b) => b.score.compareTo(a.score));
        final best = placements.first;

        final int headR = best.headR;
        final int headC = best.headC;
        final List<List<int>> slashPath = best.path;
        final ArrowDirection dir = best.dir;

        ArrowModel? removedBlocker;
        if (blockerIdx != -1) {
          removedBlocker = arrows[blockerIdx];
          for (final pt in removedBlocker.path) {
            occupiedPacked.remove(pt[0] * 1000 + pt[1]);
            occupied.remove('${pt[0]},${pt[1]}');
          }
          arrows.removeAt(blockerIdx);
        }

        final rockId = 'rock_${levelNumber}_$rocksPlaced';
        rocks.add(RockModel(id: rockId, row: rockR, col: rockC));
        occupiedPacked.add(rockR * 1000 + rockC);
        occupied.add('$rockR,$rockC');

        final slashId = 'slash_${levelNumber}_$rocksPlaced';
        slashArrows.add(ArrowModel(
          id: slashId,
          row: headR,
          col: headC,
          direction: dir,
          type: ArrowType.slash,
          path: slashPath,
        ));

        for (final pt in slashPath) {
          occupiedPacked.add(pt[0] * 1000 + pt[1]);
          occupied.add('${pt[0]},${pt[1]}');
        }

        final trialArrows = <ArrowModel>[...slashArrows, ...arrows];
        final trialLevel = LevelModel(
          levelNumber: levelNumber,
          gridSize: gridSize,
          arrows: trialArrows,
          rocks: List<RockModel>.from(rocks),
          maskShape: maskShape,
          mask: mask,
        );
        final solvable = LevelSolver.solve(trialLevel, 100000) != null;

        if (!solvable) {
          rocks.removeLast();
          slashArrows.removeLast();

          for (final pt in slashPath) {
            occupiedPacked.remove(pt[0] * 1000 + pt[1]);
            occupied.remove('${pt[0]},${pt[1]}');
          }
          occupiedPacked.remove(rockR * 1000 + rockC);
          occupied.remove('$rockR,$rockC');

          if (removedBlocker != null) {
            arrows.insert(blockerIdx, removedBlocker);
            for (final pt in removedBlocker.path) {
              occupiedPacked.add(pt[0] * 1000 + pt[1]);
              occupied.add('${pt[0]},${pt[1]}');
            }
          }

          debugPrint('⚙️ LEVEL $levelNumber: rolled back mine (deadlock)');
          continue;
        }

        rocksPlaced++;
      }

      debugPrint('⚙️ LEVEL $levelNumber: placed ${rocks.length} mines, '
          '${slashArrows.length} slash arrows');
    }

    if (arrows.isEmpty) {
      final mid = gridSize ~/ 2;
      arrows.add(ArrowModel(
        id: 'a_${levelNumber}_0',
        row: mid,
        col: mid,
        direction: ArrowDirection.right,
        path: [
          [mid, mid],
          [mid, max(0, mid - 1)]
        ],
      ));
      occupied.add('$mid,$mid');
      occupied.add('$mid,${max(0, mid - 1)}');
    }

    final emptyCount = mask.length - occupied.length;
    final orphanDots = <OrphanDot>[];


    // === Mark slash-arrow lines as off-limits for redirector dots ===
    // A slash arrow must travel straight to the first mine on its path.
    // If a redirector sits on that line, it turns and misses.
    final slashPathCells = <int>{};
    for (final slash in slashArrows) {
      final head = slash.path[0];
      final d = slash.direction.delta;
      int nr = head[0] + d[0];
      int nc = head[1] + d[1];
      while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
        slashPathCells.add(nr * 1000 + nc);
        bool hitMine = false;
        for (final rock in rocks) {
          if (rock.row == nr && rock.col == nc) {
            hitMine = true;
            break;
          }
        }
        if (hitMine) break;
        nr += d[0];
        nc += d[1];
      }
    }

    if (emptyCount > 0) {
      final emptyKeysPacked = maskCells
          .where((cell) => !occupiedPacked.contains(cell[0] * 1000 + cell[1]))
          .map((cell) => cell[0] * 1000 + cell[1])
          .toSet();
      final orphanMap = <int, OrphanDotType>{};

      double colorProb;
      if (levelNumber == 395 || levelNumber == 437) {
        colorProb = 0.0;
      } else if (type == LevelType.god) {
        if (levelNumber <= 7) {
          colorProb = 0.50;
        } else if (levelNumber <= 20) {
          colorProb = 0.65;
        } else if (levelNumber <= 50) {
          colorProb = 0.78;
        } else {
          colorProb = 0.88;
        }
      } else if (type == LevelType.boss) {
        if (levelNumber <= 7) {
          colorProb = 0.35;
        } else if (levelNumber <= 20) {
          colorProb = 0.50;
        } else if (levelNumber <= 50) {
          colorProb = 0.65;
        } else {
          colorProb = 0.80;
        }
      } else if (levelNumber == 3) {
        colorProb = 0.60;
      } else if (levelNumber <= 14) {
        colorProb = 0.0;
      } else {
        if (levelNumber <= 30) {
          colorProb = 0.10;
        } else if (levelNumber <= 60) {
          colorProb = 0.20;
        } else if (levelNumber <= 150) {
          colorProb = 0.40;
        } else if (levelNumber <= 300) {
          colorProb = 0.65;
        } else {
          colorProb = 0.80;
        }
      }

      for (int i = 0; i < arrows.length; i++) {
        final arrow = arrows[i];
        ArrowDirection currentDir = arrow.direction;
        final head = arrow.path[0];
        var d = currentDir.delta;
        int nr = head[0] + d[0];
        int nc = head[1] + d[1];
        final visited = <int>{};

        while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
          final keyPacked = nr * 1000 + nc;
          if (visited.contains(keyPacked)) break;
          visited.add(keyPacked);

          if (emptyKeysPacked.contains(keyPacked)) {
            // Never place a redirector on a bomb arrow's path
            if (slashPathCells.contains(keyPacked)) {
              orphanMap[keyPacked] = OrphanDotType.neutral;
              // Continue tracing the path — other arrows may still benefit
              d = currentDir.delta;
              nr += d[0];
              nc += d[1];
              continue;
            }
            if (!orphanMap.containsKey(keyPacked)) {
              final bool shouldColor = rng.nextDouble() < colorProb;
              if (shouldColor) {
                
                bool tooClose = false;
                for (final entry in orphanMap.entries) {
                  if (entry.value == OrphanDotType.neutral) continue;
                  final pk = entry.key;
                  final er = pk ~/ 1000, ec = pk % 1000;
                  if ((er - nr).abs() + (ec - nc).abs() < 3) {
                    tooClose = true;
                    break;
                  }
                }

                int redirectorChainCount = 0;
                for (final val in orphanMap.values) {
                  if (val != OrphanDotType.neutral) redirectorChainCount++;
                }

                final int maxRedirectorsForLevel;
                if (levelNumber <= 30) {
                  maxRedirectorsForLevel = 2;
                } else if (levelNumber <= 100) {
                  maxRedirectorsForLevel = 4;
                } else {
                  maxRedirectorsForLevel = 8;
                }

                if (!tooClose && redirectorChainCount < maxRedirectorsForLevel) {
                  final turns = rng.nextBool()
                      ? [currentDir.turnRight, currentDir.turnLeft]
                      : [currentDir.turnLeft, currentDir.turnRight];

                  bool assigned = false;
                  for (final candDir in turns) {
                    orphanMap[keyPacked] = _dotTypeForDir(candDir);

                    final isSolvable = _isValidRedirectorMap(orphanMap, gridSize, arrows) &&
                        _greedySolveWithMap(gridSize, arrows, orphanMap) !=
                            null;

                    if (isSolvable) {
                      currentDir = candDir;
                      assigned = true;
                      break;
                    } else {
                      orphanMap.remove(keyPacked); 
                    }
                  }

                  if (!assigned) {
                    orphanMap[keyPacked] = _dotTypeForDir(currentDir);
                    final isSolvable = _isValidRedirectorMap(orphanMap, gridSize, arrows) &&
                        _greedySolveWithMap(gridSize, arrows, orphanMap) !=
                            null;
                    if (!isSolvable) {
                      orphanMap[keyPacked] = OrphanDotType.neutral;
                    }
                  }
                } else {
                  orphanMap[keyPacked] = OrphanDotType.neutral;
                }
              } else {
                orphanMap[keyPacked] = OrphanDotType.neutral;
              }
            } else if (!slashPathCells.contains(keyPacked)) {
              final dotType = orphanMap[keyPacked]!;
              if (dotType == OrphanDotType.up) {
                currentDir = ArrowDirection.up;
              } else if (dotType == OrphanDotType.down) {
                currentDir = ArrowDirection.down;
              } else if (dotType == OrphanDotType.left) {
                currentDir = ArrowDirection.left;
              } else if (dotType == OrphanDotType.right) {
                currentDir = ArrowDirection.right;
              }
            }
          }

          d = currentDir.delta;
          nr += d[0];
          nc += d[1];
        }
      }

      for (final keyPacked in emptyKeysPacked) {
        if (!orphanMap.containsKey(keyPacked)) {
          orphanMap[keyPacked] = OrphanDotType.neutral;
        }
      }

      if (!_isValidRedirectorMap(orphanMap, gridSize, arrows) ||
          _greedySolveWithMap(gridSize, arrows, orphanMap) == null) {
        for (final k in emptyKeysPacked) {
          orphanMap[k] = OrphanDotType.neutral;
        }
      }

      orphanDots.addAll(orphanMap.entries.map((entry) => OrphanDot(
            row: entry.key ~/ 1000,
            col: entry.key % 1000,
            type: entry.value,
          )));

      final tempLevel = LevelModel(
        levelNumber: levelNumber,
        gridSize: gridSize,
        arrows: arrows,
        maskShape: maskShape,
        mask: mask,
        orphanDots: orphanDots,
      );

      if (LevelSolver.solve(tempLevel, 50000) == null) {
        orphanDots.clear();
        orphanDots.addAll(orphanMap.entries.map((entry) => OrphanDot(
              row: entry.key ~/ 1000,
              col: entry.key % 1000,
              type: OrphanDotType.neutral,
            )));
      }
    }

    // Prepend slash arrows so they're processed first.
    final allArrows = <ArrowModel>[...slashArrows, ...arrows];

    return LevelModel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      arrows: allArrows,
      rocks: rocks,
      maskShape: maskShape,
      mask: mask,
      orphanDots: orphanDots,
    );
  }

  static int _exitDist(int r, int c, ArrowDirection dir, int gridSize) {
    switch (dir) {
      case ArrowDirection.up:
        return r;
      case ArrowDirection.down:
        return gridSize - 1 - r;
      case ArrowDirection.left:
        return c;
      case ArrowDirection.right:
        return gridSize - 1 - c;
    }
  }


  /// Returns true if this arrow's exit path is clear of all rocks AND
  /// all cells in [extraBlocked] (used to check the future bomb arrow).
  static bool _arrowPathClearOfRocks(
      ArrowModel arrow,
      List<RockModel> rocks,
      int gridSize, {
        Set<int>? extraBlocked,
      }) {
    ArrowDirection dir = arrow.direction;
    final head = arrow.path[0];
    var d = dir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final visited = <int>{};

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final packed = nr * 1000 + nc;
      if (visited.contains(packed)) return false;
      visited.add(packed);

      if (extraBlocked != null && extraBlocked.contains(packed)) {
        return false;
      }

      for (final rock in rocks) {
        if (rock.row == nr && rock.col == nc) return false;
      }

      nr += d[0];
      nc += d[1];
    }
    return true;
  }


  /// Simulates clearing the level with arrows + rocks + bombs.
  /// Returns true if every arrow can eventually escape.
  static bool _isSolvableWithRocks(
      List<ArrowModel> arrows,
      List<RockModel> rocks,
      int gridSize,
      ) {
    final remainingArrows = List<ArrowModel>.from(arrows);
    final remainingRocks = List<RockModel>.from(rocks);
    final active = List<bool>.filled(remainingArrows.length, true);
    int remaining = remainingArrows.length;

    bool progress = true;
    while (progress && remaining > 0) {
      progress = false;
      for (int i = 0; i < remainingArrows.length; i++) {
        if (!active[i]) continue;
        final arrow = remainingArrows[i];
        final isSlash = arrow.type == ArrowType.slash;

        final head = arrow.path[0];
        final d = arrow.direction.delta;
        int nr = head[0] + d[0];
        int nc = head[1] + d[1];
        final visited = <int>{};
        bool canExit = true;
        final rocksHit = <String>[];

        while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
          final packed = nr * 1000 + nc;
          if (visited.contains(packed)) { canExit = false; break; }
          visited.add(packed);

          RockModel? hitRock;
          for (final rock in remainingRocks) {
            if (rock.row == nr && rock.col == nc) { hitRock = rock; break; }
          }
          if (hitRock != null) {
            if (isSlash) {
              rocksHit.add(hitRock.id);
            } else {
              canExit = false;
              break;
            }
          }

          bool hitArrow = false;
          for (int j = 0; j < remainingArrows.length; j++) {
            if (j == i || !active[j]) continue;
            if (remainingArrows[j].path
                .any((pt) => pt[0] == nr && pt[1] == nc)) {
              hitArrow = true;
              break;
            }
          }
          if (hitArrow) { canExit = false; break; }

          nr += d[0];
          nc += d[1];
        }

        if (canExit) {
          active[i] = false;
          remaining--;
          progress = true;
          for (final rid in rocksHit) {
            remainingRocks.removeWhere((r) => r.id == rid);
          }
        }
      }
    }
    return remaining == 0;
  }

  static void _shuffleCandidates(
      List<_Cand> candidates, int gridSize, Random rng, bool complexPaths,
      MaskShape maskShape,
          {bool edgeBias = false, List<ArrowModel> recentArrows = const []}) {

    if (maskShape == MaskShape.pyramid) {
      // Pyramid fills top-down: grow from the tip outward so the narrow
      // rows get arrows before the wide base eats all the cells.
      candidates.sort((a, b) {
        final scoreA = a.row.toDouble() + (rng.nextDouble() * 1.5);
        final scoreB = b.row.toDouble() + (rng.nextDouble() * 1.5);
        return scoreA.compareTo(scoreB);   // smaller row first
      });
      return;
    }


    if (edgeBias) {
      final centerRow = gridSize / 2.0;
      final centerCol = gridSize / 2.0;
      candidates.sort((a, b) {
        final distA = (a.row - centerRow).abs() + (a.col - centerCol).abs();
        final distB = (b.row - centerRow).abs() + (b.col - centerCol).abs();

        // Base score prioritizes edges
        double scoreA = -distA;
        double scoreB = -distB;

        // ── NEW: Direction Diversity Penalty ──
        for (final arrow in recentArrows) {
          final headR = arrow.path[0][0];
          final headC = arrow.path[0][1];

          // Check if the candidate is adjacent to an existing arrow (within 2 cells)
          if ((headR - a.row).abs() + (headC - a.col).abs() <= 2) {
            if (arrow.direction == a.dir) scoreA -= 15; // Heavy penalty for same direction
          }
          if ((headR - b.row).abs() + (headC - b.col).abs() <= 2) {
            if (arrow.direction == b.dir) scoreB -= 15;
          }
        }

        // Add random jitter
        scoreA += (rng.nextDouble() * 4.0 - 2.0);
        scoreB += (rng.nextDouble() * 4.0 - 2.0);

        // Sort descending (higher score first)
        if (scoreA > scoreB) return -1;
        if (scoreA < scoreB) return 1;
        return 0;
      });
      return;
    }

    if (complexPaths) {
      candidates.sort((a, b) {
        final exitA = _exitDist(a.row, a.col, a.dir, gridSize);
        final exitB = _exitDist(b.row, b.col, b.dir, gridSize);
        final scoreA = -exitA * 2.0 + rng.nextDouble() * 2.0;
        final scoreB = -exitB * 2.0 + rng.nextDouble() * 2.0;
        return scoreA.compareTo(scoreB);
      });
      return;
    }
    final centerRow = gridSize / 2;
    final centerCol = gridSize / 2;
    candidates.sort((a, b) {
      final distA = (a.row - centerRow).abs() + (a.col - centerCol).abs();
      final distB = (b.row - centerRow).abs() + (b.col - centerCol).abs();
      final scoreA = distA + (rng.nextDouble() * 2.0 - 1.0);
      final scoreB = distB + (rng.nextDouble() * 2.0 - 1.0);
      return scoreA.compareTo(scoreB);
    });
  }

  static List<_Cand> _exitCandidates(
    List<List<int>> maskCells,
    Set<int> occupiedPacked,
    int gridSize,
  ) {
    final out = <_Cand>[];
    for (final cell in maskCells) {
      final r = cell[0], c = cell[1];
      if (occupiedPacked.contains(r * 1000 + c)) continue;
      for (final dir in ArrowDirection.values) {
        if (_canExitClean(r, c, dir, occupiedPacked, gridSize)) {
          out.add(_Cand(r, c, dir));
        }
      }
    }
    return out;
  }

  static List<List<int>>? _growPath({
    required int startRow,
    required int startCol,
    required ArrowDirection exitDir,
    required Set<int> maskPacked,
    required Set<int> occupiedPacked,
    required int targetLen,
    required Random rng,
    required int gridSize,
    double tangleFactor = 0.0,
    bool complexPaths = false,
    bool edgeBias = false,
  }) {
    final exitPath = _getExitPathPacked(startRow, startCol, exitDir, gridSize);
    final path = <List<int>>[
      [startRow, startCol]
    ];
    final pathPacked = <int>{startRow * 1000 + startCol};
    int cr = startRow, cc = startCol;
    var growDir = exitDir.opposite;
    int straight = 0;

    final bool isSnake = complexPaths ||
        (tangleFactor >= 0.99 && !complexPaths);

    // Edge arrows go straight (0.20), Center arrows snake to fill gaps (0.50)
    final double turnBias = isSnake
        ? 0.94
        : (edgeBias ? 0.20 : 0.50);

    final int maxStraight;
    if (isSnake) {
      maxStraight = 1;
    } else if (tangleFactor >= 0.85) {
      maxStraight = 1;
    } else if (tangleFactor >= 0.50) {
      maxStraight = 2;
    } else if (tangleFactor >= 0.15) {
      maxStraight = 3;
    } else {
      // CHANGE THIS: Let edge-biased arrows run straight for up to 15 cells!
      maxStraight = edgeBias ? 15 : 6;
    }

    final centerRow = gridSize / 2.0;
    final centerCol = gridSize / 2.0;

    for (int step = 1; step < targetLen; step++) {
      final valid = <ArrowDirection>[];
      for (final d in ArrowDirection.values) {
        if (d == growDir.opposite) continue;
        final nd = d.delta;
        final nr = cr + nd[0], nc = cc + nd[1];
        final np = nr * 1000 + nc;

        if (!maskPacked.contains(np)) continue;
        if (occupiedPacked.contains(np)) continue;
        if (exitPath.contains(np)) continue;
        if (pathPacked.contains(np)) continue;

        bool wouldFormLoop = false;
        for (final nb in [
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ]) {
          final adjR = nr + nb[0], adjC = nc + nb[1];
          final adjP = adjR * 1000 + adjC;
          if (adjP != cr * 1000 + cc && pathPacked.contains(adjP)) {
            wouldFormLoop = true;
            break;
          }
        }
        if (wouldFormLoop) continue;

        // ── EDGE HUGGING PENALTY ──
        if (edgeBias) {
          final currDist = (cr - centerRow).abs() + (cc - centerCol).abs();
          final nextDist = (nr - centerRow).abs() + (nc - centerCol).abs();

          // If moving towards the center, 85% chance to reject this direction
          if (nextDist < currDist && rng.nextDouble() < 0.4) {
            continue;
          }
        }

        valid.add(d);
      }

      if (valid.isEmpty) break;

      if (step == 1 && !valid.contains(growDir)) {
        return null;
      }

      final mustTurn = straight >= maxStraight;
      final turns = valid.where((d) => d != growDir).toList();
      final straights = valid.where((d) => d == growDir).toList();

      ArrowDirection chosen;
      if (step == 1) {
        chosen = growDir;
      } else if (mustTurn && turns.isNotEmpty) {
        chosen = _packedPick(turns, cr, cc, occupiedPacked, rng);
      } else if (valid.length == 1) {
        chosen = valid[0];
      } else if (rng.nextDouble() < turnBias && turns.isNotEmpty) {
        chosen = _packedPick(turns, cr, cc, occupiedPacked, rng);
      } else if (straights.isNotEmpty) {
        chosen = straights[0];
      } else {
        chosen = _packedPick(turns, cr, cc, occupiedPacked, rng);
      }

      straight = chosen == growDir ? straight + 1 : 0;
      final nd = chosen.delta;
      cr += nd[0];
      cc += nd[1];
      path.add([cr, cc]);
      pathPacked.add(cr * 1000 + cc);
      growDir = chosen;
    }

    return path.length >= 2 ? path : null;
  }

  static ArrowDirection _packedPick(List<ArrowDirection> dirs, int cr, int cc,
      Set<int> occupiedPacked, Random rng) {
    if (dirs.length == 1) return dirs[0];
    int best = -1;
    final bestDirs = <ArrowDirection>[];
    for (final d in dirs) {
      final nd = d.delta;
      final nr = cr + nd[0], nc = cc + nd[1];
      int score = 0;
      for (final nb in [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1]
      ]) {
        if (occupiedPacked.contains((nr + nb[0]) * 1000 + (nc + nb[1]))) {
          score++;
        }
      }
      if (score > best) {
        best = score;
        bestDirs.clear();
        bestDirs.add(d);
      } else if (score == best) {
        bestDirs.add(d);
      }
    }
    return bestDirs[rng.nextInt(bestDirs.length)];
  }

  static OrphanDotType _dotTypeForDir(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
        return OrphanDotType.up;
      case ArrowDirection.down:
        return OrphanDotType.down;
      case ArrowDirection.left:
        return OrphanDotType.left;
      case ArrowDirection.right:
        return OrphanDotType.right;
    }
  }

  static ArrowDirection _dirForDotType(OrphanDotType type) {
    switch (type) {
      case OrphanDotType.up:
        return ArrowDirection.up;
      case OrphanDotType.down:
        return ArrowDirection.down;
      case OrphanDotType.left:
        return ArrowDirection.left;
      case OrphanDotType.right:
        return ArrowDirection.right;
      default:
        return ArrowDirection.up;
    }
  }

  static bool _hasRedirectorCycle(
      Map<int, OrphanDotType> orphanMap, int gridSize) {
    for (final entry in orphanMap.entries) {
      if (entry.value == OrphanDotType.neutral) continue;
      final startPacked = entry.key;
      int r = startPacked ~/ 1000;
      int c = startPacked % 1000;
      ArrowDirection dir = _dirForDotType(entry.value);

      final visited = <int>{startPacked};
      int steps = 0;
      final maxSteps = gridSize * gridSize;

      while (true) {
        final d = dir.delta;
        r += d[0];
        c += d[1];
        if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) {
          break;
        }
        steps++;
        if (steps > maxSteps) return true;

        final packed = r * 1000 + c;
        final nextType = orphanMap[packed];
        if (nextType != null && nextType != OrphanDotType.neutral) {
          if (visited.contains(packed)) {
            return true;
          }
          visited.add(packed);
          dir = _dirForDotType(nextType);
        }
      }
    }
    return false;
  }

  static bool _arrowHitsOwnBody(
      ArrowModel arrow, Map<int, OrphanDotType> orphanMap, int gridSize) {
    ArrowDirection currentDir = arrow.direction;
    final head = arrow.path[0];
    var d = currentDir.delta;
    int nr = head[0] + d[0];
    int nc = head[1] + d[1];
    final visited = <int>{};

    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      final keyPacked = nr * 1000 + nc;
      if (visited.contains(keyPacked)) return true;
      visited.add(keyPacked);

      for (int i = 1; i < arrow.path.length; i++) {
        if (nr == arrow.path[i][0] && nc == arrow.path[i][1]) {
          return true;
        }
      }

      final dotType = orphanMap[keyPacked];
      if (dotType != null && dotType != OrphanDotType.neutral) {
        currentDir = _dirForDotType(dotType);
      }

      d = currentDir.delta;
      nr += d[0];
      nc += d[1];
    }
    return false;
  }

  static bool _isValidRedirectorMap(
      Map<int, OrphanDotType> orphanMap, int gridSize, List<ArrowModel> arrows) {
    if (_hasRedirectorCycle(orphanMap, gridSize)) return false;
    for (final a in arrows) {
      if (_arrowHitsOwnBody(a, orphanMap, gridSize)) return false;
    }
    return true;
  }

  static _Params _paramsFor(
      int level, LevelType type, int gridSize, Set<String> mask,
      {bool complexPaths = false}) {
    int avgLen;
    int arrowCount;

    // Snake level — long winding arrows
    if (AppConstants.isSnakeLevel(level) && !complexPaths) {
      // Longer arrows on bigger boards
      if (gridSize <= 12) {
        avgLen = 10;
      } else if (gridSize <= 16) {
        avgLen = 14;
      } else if (gridSize <= 20) {
        avgLen = 18;
      } else if (gridSize <= 25) {
        avgLen = 22;
      } else {
        avgLen = 26;
      }

      final totalCells = mask.length;
      // Leave ~8% of cells empty for visual breathing room
      final targetOccupied = (totalCells * 0.92).round();
      arrowCount = (targetOccupied / avgLen).round().clamp(6, 60);

      return _Params(arrowCount, avgLen);
    }

    if (level <= 3 && !complexPaths) {
      avgLen = 2;
      arrowCount = 4;
    } else {
      final int cyclePhase = (level - 1) % 5;
      final bool isFlowLevel = cyclePhase == 4;

      if (level == 395 || level == 437) {
        avgLen = 6;
      } else if (isFlowLevel) {
        avgLen = (gridSize > 20) ? 4 : 3;
      } else if (level <= 15) {
        avgLen = 3;
      } else if (level <= 50) {
        avgLen = 4;
      } else if (level <= 150) {
        avgLen = 6;
      } else if (level <= 300) {
        avgLen = 7;
      } else {
        avgLen = 8;
      }

      if (complexPaths) {
        avgLen = max(avgLen, (gridSize > 20 ? 6 : 5));
      }

      final totalCells = mask.length;
      final double fillRate = isFlowLevel ? 0.88 : 1.0;

      final targetOccupiedCells = (totalCells * fillRate).round();
      arrowCount = (targetOccupiedCells / avgLen).round().clamp(4, 800);
    }

    return _Params(arrowCount, avgLen);
  }

  static Set<int> _getExitPathPacked(
      int startRow, int startCol, ArrowDirection exitDir, int gridSize) {
    final path = <int>{};
    final d = exitDir.delta;
    int nr = startRow + d[0];
    int nc = startCol + d[1];
    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      path.add(nr * 1000 + nc);
      nr += d[0];
      nc += d[1];
    }
    return path;
  }

  static MaskShape _shapeFor(LevelType type, Random rng) {
    switch (type) {
      case LevelType.normal:
      // 30% chance of a fun shape on normal levels
        if (rng.nextDouble() < 0.30) {
          const normalShapes = [
            MaskShape.heart,
            MaskShape.star,
            MaskShape.diamond,
            MaskShape.hexagon,
            MaskShape.circle,
            MaskShape.blob,
            MaskShape.frog,
            MaskShape.fish,
            MaskShape.bird,
            MaskShape.tree,
          ];
          return normalShapes[rng.nextInt(normalShapes.length)];
        }
        return MaskShape.square;
      case LevelType.boss:
        const bossShapes = [
          MaskShape.cat,
          MaskShape.dog,
          MaskShape.frog,
          MaskShape.fox,
          MaskShape.tiger,
          MaskShape.panda,
          MaskShape.fish,
          MaskShape.bird,
          MaskShape.butterfly,
          MaskShape.guitar,
          MaskShape.tree,
          MaskShape.house,
          MaskShape.crown,
        ];
        return bossShapes[rng.nextInt(bossShapes.length)];
      case LevelType.god:
        const godShapes = [
          MaskShape.heart,
          MaskShape.star,
          MaskShape.diamond,
          MaskShape.hexagon,
          MaskShape.blob,
          MaskShape.circle,
        ];
        return godShapes[rng.nextInt(godShapes.length)];
    }
  }

  static void _absorbOrphans(List<ArrowModel> arrows, Set<String> occupied,
      Set<int> occupiedPacked, Set<String> mask, int gridSize) {
    bool madeProgress = true;
    while (madeProgress) {
      madeProgress = false;
      final orphans = mask.where((k) => !occupied.contains(k)).toList();
      for (final cellKey in orphans) {
        final parts = cellKey.split(',');
        final r = int.parse(parts[0]), c = int.parse(parts[1]);
        final ptPacked = r * 1000 + c;

        for (int i = 0; i < arrows.length; i++) {
          final arrow = arrows[i];
          final tail = arrow.path.last;

          // ONLY extend the tail. Safe and prevents U-turns.
          if ((tail[0] - r).abs() + (tail[1] - c).abs() == 1) {
            final newPath = List<List<int>>.from(arrow.path)..add([r, c]);
            arrows[i] = arrow.copyWith(path: newPath);
            occupied.add(cellKey);
            occupiedPacked.add(ptPacked);
            madeProgress = true;
            break;
          }
        }
      }
    }
  }

  static bool _canExitClean(int headRow, int headCol, ArrowDirection dir,
      Set<int> occupiedPacked, int gridSize) {
    final d = dir.delta;
    int nr = headRow + d[0];
    int nc = headCol + d[1];
    while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
      if (occupiedPacked.contains(nr * 1000 + nc)) return false;
      nr += d[0];
      nc += d[1];
    }
    return true;
  }

  static List<String>? _greedySolveWithMap(int gridSize,
      List<ArrowModel> arrows, Map<int, OrphanDotType> orphanMap) {
    final board = Uint16List(gridSize * gridSize);
    for (int i = 0; i < arrows.length; i++) {
      for (final pt in arrows[i].path) {
        board[pt[0] * gridSize + pt[1]] = i + 1;
      }
    }

    final orphanTypes = Uint8List(gridSize * gridSize);
    final orphanActive = List<bool>.filled(gridSize * gridSize, false);
    orphanMap.forEach((packed, type) {
      final r = packed ~/ 1000;
      final c = packed % 1000;
      final idx = r * gridSize + c;
      orphanTypes[idx] = type.index;
      orphanActive[idx] = true;
    });

    final active = List<bool>.filled(arrows.length, true);
    final order = <String>[];
    int remaining = arrows.length;

    final exitVisited = Uint16List(gridSize * gridSize);
    int exitToken = 0;

    List<int>? tryExit(int ai) {
      exitToken++;
      ArrowDirection dir = arrows[ai].direction;
      final h = arrows[ai].path[0];
      var d = dir.delta;
      int nr = h[0] + d[0], nc = h[1] + d[1];
      final consumed = <int>[];
      while (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
        final idx = nr * gridSize + nc;
        if (exitVisited[idx] == exitToken) return null;
        exitVisited[idx] = exitToken;
        if (orphanActive[idx]) {
          consumed.add(idx);
          final t = orphanTypes[idx];
          if (t == 0) {
            dir = ArrowDirection.up;
          } else if (t == 1) {
            dir = ArrowDirection.down;
          } else if (t == 2) {
            dir = ArrowDirection.left;
          } else if (t == 3) {
            dir = ArrowDirection.right;
          }
        } else {
          final val = board[idx];
          if (val != 0 && val != ai + 1) {
            return null;
          }
        }
        d = dir.delta;
        nr += d[0];
        nc += d[1];
      }
      return consumed;
    }

    void clearArrow(int idx) {
      active[idx] = false;
      remaining--;
      for (final pt in arrows[idx].path) {
        board[pt[0] * gridSize + pt[1]] = 0;
      }
      order.add(arrows[idx].id);
    }

    bool madeProgress = true;
    while (madeProgress && remaining > 0) {
      madeProgress = false;

      for (int i = 0; i < arrows.length; i++) {
        if (!active[i]) continue;
        final c = tryExit(i);
        if (c != null) {
          for (final f in c) {
            orphanActive[f] = false;
          }
          clearArrow(i);
          madeProgress = true;
        }
      }
    }

    return remaining == 0 ? order : null;
  }

  static List<String>? greedySolve(LevelModel level) {
    final orphanMap = <int, OrphanDotType>{};
    for (final od in level.orphanDots) {
      orphanMap[od.row * 1000 + od.col] = od.type;
    }
    return _greedySolveWithMap(level.gridSize, level.arrows, orphanMap);
  }
}

enum _LenTier { veryLong, long, medium }

class _Cand {
  final int row, col;
  final ArrowDirection dir;
  _Cand(this.row, this.col, this.dir);
}

class _Params {
  final int arrowCount, avgLen;
  _Params(this.arrowCount, this.avgLen);
}