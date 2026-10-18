import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../levels/art_shapes.dart';
import '../models/level.dart';
import '../level_generator/level_generator.dart';


@pragma('vm:entry-point')
LevelModel generateArtLevelIsolate(Map<String, dynamic> args) {
  // We recreate the necessary logic inside the isolate so it doesn't touch the UI thread
  final rawMask = args['mask'] as Set<String>;
  final gridSize = args['gridSize'] as int;
  final levelNumber = args['levelNumber'] as int;
  final avgLen = args['avgLen'] as int;

  return LevelGenerator.generateFromMask(
    levelNumber: levelNumber,
    mask: rawMask,
    gridSize: gridSize,
    maskShape: MaskShape.silhouette,
    seed: levelNumber * 7919,
    avgLengthOverride: avgLen,
  );
}

@pragma('vm:entry-point')
LevelModel generateLevelIsolate(int levelNumber) {
  return LevelGenerator.generateLevel(levelNumber);
}

@pragma('vm:entry-point')
LevelModel generateComplexLevelIsolate(int levelNumber) {
  return LevelGenerator.generateLevel(levelNumber, complexPaths: true);
}

@pragma('vm:entry-point')
LevelModel generateSeededLevelIsolate(List<int> args) {
  return LevelGenerator.generateLevel(args[0], seed: args[1]);
}

class LevelRepository {
  static const int cacheVersion = LevelModel.currentVersion;

  late Box _cacheBox;
  final Map<int, LevelModel> _cache = {};
  final Set<int> _generating = {};

  LevelRepository._();

  static Future<LevelRepository> create() async {
    final repo = LevelRepository._();
    await repo._init();
    return repo;
  }

  Future<void> _init() async {
    _cacheBox = await Hive.openBox('levelCache');

    // ── FIX: Only clear the cache if the generator version changed ──
    final savedVersion = _cacheBox.get('generator_version');
    if (savedVersion != cacheVersion) {
      await _cacheBox.clear();
      await _cacheBox.put('generator_version', cacheVersion);
      debugPrint('🧹 Generator version changed. Cache cleared.');
    } else {
      debugPrint('⚡ Cache loaded from previous session.');
    }
  }

  LevelModel? _tryLoadCached(int levelNumber) {
    if (_cache.containsKey(levelNumber)) {
      final cached = _cache[levelNumber]!;
      if (cached.version == cacheVersion) return cached;
      _cache.remove(levelNumber);
    }

    final jsonStr = _cacheBox.get('cached_level_$levelNumber');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          final level = LevelModel.fromJson(decoded);
          if (level.version == cacheVersion) {
            _cache[levelNumber] = level;
            return level;
          }
        }
      } catch (e) {
        debugPrint('Error decoding cached level: $e');
      }
      _cacheBox.delete('cached_level_$levelNumber');
    }
    return null;
  }

  /// Sync getter — respects art levels.
  LevelModel getLevel(int levelNumber) {
    final cached = _tryLoadCached(levelNumber);
    if (cached != null) return cached;

    final level = shouldBeArtLevel(levelNumber)
        ? buildArtLevel(levelNumber)
        : LevelGenerator.generateLevel(levelNumber);

    _cache[levelNumber] = level;
    _saveToDisk(levelNumber, level);
    return level;
  }

  Future<void> preGenerateAsync(int levelNumber) async {
    if (isCached(levelNumber)) return;
    if (_generating.contains(levelNumber)) return;
    _generating.add(levelNumber);

    try {
      final cached = _tryLoadCached(levelNumber);
      if (cached != null) return;

      // Art levels build on the main isolate (fast, no need for compute).
      // In preGenerateAsync:
      if (shouldBeArtLevel(levelNumber)) {
        final shapeIndex = ((levelNumber - 20) ~/ 10) % ArtShapes.all.length;
        final shape = ArtShapes.all[shapeIndex];
        final croppedMask = _cropMask(shape.toMask());
        final bounds = _maskBounds(croppedMask);
        final maxDim = math.max(bounds.width, bounds.height);
        final t = ((levelNumber - 20) / 180).clamp(0.0, 1.0);
        final maxGrid = (24 + (t * 14)).round();
        final targetGrid = math.min(maxDim, maxGrid) + 4;
        final scaledMask = _scaleMask(croppedMask, bounds.width, bounds.height, targetGrid);
        final avgLen = (8 - (t * 3)).round().clamp(5, 8);

        final level = await compute(generateArtLevelIsolate, {
          'mask': scaledMask,
          'gridSize': targetGrid,
          'levelNumber': levelNumber,
          'avgLen': avgLen,
        });

        _cache[levelNumber] = level;
        _saveToDisk(levelNumber, level);
        return;
      }

      final level = await compute(generateLevelIsolate, levelNumber)
          .timeout(const Duration(seconds: 12));
      _cache[levelNumber] = level;
      _saveToDisk(levelNumber, level);
    } catch (e) {
      debugPrint('Async pre-generation error for level $levelNumber: $e');
    } finally {
      _generating.remove(levelNumber);
    }
  }

  Future<void> preGenerateRangeAsync(int from, int count) async {
    for (int i = from; i < from + count; i++) {
      unawaited(preGenerateAsync(i));
    }
  }

  Future<LevelModel> getLevelAsync(
      int levelNumber, {
        bool preGenerateNext = true,
      }) async {
    // 1. Cache first — art levels are cached too.
    final cached = _tryLoadCached(levelNumber);
    if (cached != null) {
      if (preGenerateNext) {
        preGenerateRangeAsync(levelNumber + 1, 3);
      }
      return cached;
    }

    // 2. Art level branch (cache miss).
    // In getLevelAsync:
    if (shouldBeArtLevel(levelNumber)) {
      // Generate the mask setup on the main thread (it's fast)
      final shapeIndex = ((levelNumber - 20) ~/ 10) % ArtShapes.all.length;
      final shape = ArtShapes.all[shapeIndex];
      final croppedMask = _cropMask(shape.toMask());
      final bounds = _maskBounds(croppedMask);
      final maxDim = math.max(bounds.width, bounds.height);
      final t = ((levelNumber - 20) / 180).clamp(0.0, 1.0);
      final maxGrid = (24 + (t * 14)).round();
      final targetGrid = math.min(maxDim, maxGrid) + 4;
      final scaledMask = _scaleMask(croppedMask, bounds.width, bounds.height, targetGrid);
      final avgLen = (8 - (t * 3)).round().clamp(5, 8);

      // ── FIX: Move the heavy solver logic to an Isolate ──
      final level = await compute(generateArtLevelIsolate, {
        'mask': scaledMask,
        'gridSize': targetGrid,
        'levelNumber': levelNumber,
        'avgLen': avgLen,
      });

      _cache[levelNumber] = level;
      _saveToDisk(levelNumber, level);
      if (preGenerateNext) {
        preGenerateRangeAsync(levelNumber + 1, 1);
      }
      return level;
    }

    // 3. Normal isolate generation.
    try {
      final level = await compute(generateLevelIsolate, levelNumber)
          .timeout(const Duration(seconds: 15));
      _cache[levelNumber] = level;
      _saveToDisk(levelNumber, level);

      if (preGenerateNext) {
        preGenerateRangeAsync(levelNumber + 1, 3);
      }
      return level;
    } catch (e) {
      debugPrint(
          'Isolate generation failed/timed out, generating synchronously: $e');
      final syncLevel = getLevel(levelNumber);
      if (preGenerateNext) {
        preGenerateRangeAsync(levelNumber + 1, 3);
      }
      return syncLevel;
    }
  }

  Future<LevelModel> getRandomLevelAsync(
      int levelNumber, {
        bool complexPaths = false,
      }) async {
    if (!complexPaths) {
      return getLevelAsync(levelNumber, preGenerateNext: false);
    }
    try {
      return await compute(generateComplexLevelIsolate, levelNumber)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Complex level generation error: $e');
      return LevelGenerator.generateLevel(levelNumber, complexPaths: true);
    }
  }

  Future<LevelModel> getBlitzLevelAsync(
      int levelNumber, {
        required int seed,
      }) async {
    try {
      return await compute(generateSeededLevelIsolate, [levelNumber, seed])
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Seeded generation failed, using sync: $e');
      return LevelGenerator.generateLevel(levelNumber, seed: seed);
    }
  }

  bool isCached(int levelNumber) {
    return _tryLoadCached(levelNumber) != null;
  }

  /// DEV ONLY — clears the cached levels so they regenerate.
  Future<void> clearCache() async {
    await _cacheBox.clear();
    await _cacheBox.put('generator_version', cacheVersion);
    _cache.clear();
  }

  void _saveToDisk(int levelNumber, LevelModel level) {
    try {
      _cacheBox.put('cached_level_$levelNumber', jsonEncode(level.toJson()));
    } catch (e) {
      debugPrint('Error saving level to disk: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Art (silhouette) levels
  // ─────────────────────────────────────────────────────────────────

  /// Art levels start at level 20, and appear every 10 levels: 20, 30, 40...
  bool shouldBeArtLevel(int levelNumber) {
    if (levelNumber < 20) return false;
    return (levelNumber - 20) % 10 == 0;
  }

  LevelModel buildArtLevel(int levelNumber) {
    final shapeIndex = ((levelNumber - 20) ~/ 10) % ArtShapes.all.length;
    final shape = ArtShapes.all[shapeIndex];

    final rawMask = shape.toMask();
    final croppedMask = _cropMask(rawMask);
    final bounds = _maskBounds(croppedMask);

    final maxDim = math.max(bounds.width, bounds.height);

    // 1. INCREASE THE GRID SIZE (Up to 38x38)
    // This gives the generator enough room to trace the curves perfectly.
    final t = ((levelNumber - 20) / 180).clamp(0.0, 1.0);
    final maxGrid = (24 + (t * 14)).round(); // Starts at 24, grows to 38

    final targetGrid = math.min(maxDim, maxGrid) + 4;

    final scaledMask = _scaleMask(
      croppedMask, bounds.width, bounds.height, targetGrid,
    );

    // 2. INCREASE ARROW LENGTH (From 5->3 to 8->5)
    // Longer arrows = better tracing of the outline.
    final avgLen = (8 - (t * 3)).round().clamp(5, 8);

    final level = LevelGenerator.generateFromMask(
      levelNumber: levelNumber,
      mask: scaledMask,
      gridSize: targetGrid,
      maskShape: MaskShape.silhouette,
      seed: levelNumber * 7919,
      avgLengthOverride: avgLen,
    );

    return level;
  }

  // Helper: Trims empty rows and columns from the mask
  static Set<String> _cropMask(Set<String> mask) {
    if (mask.isEmpty) return mask;
    int minR = 9999, maxR = -1, minC = 9999, maxC = -1;
    for (final key in mask) {
      final p = key.split(',');
      final r = int.parse(p[0]), c = int.parse(p[1]);
      if (r < minR) minR = r;
      if (r > maxR) maxR = r;
      if (c < minC) minC = c;
      if (c > maxC) maxC = c;
    }
    final out = <String>{};
    for (final key in mask) {
      final p = key.split(',');
      final r = int.parse(p[0]) - minR;
      final c = int.parse(p[1]) - minC;
      out.add('$r,$c');
    }
    return out;
  }

  // Helper: Calculates exact width and height of active mask
  static ({int width, int height}) _maskBounds(Set<String> mask) {
    if (mask.isEmpty) return (width: 1, height: 1);
    int maxR = 0, maxC = 0;
    for (final key in mask) {
      final p = key.split(',');
      final r = int.parse(p[0]), c = int.parse(p[1]);
      if (r > maxR) maxR = r;
      if (c > maxC) maxC = c;
    }
    return (width: maxC + 1, height: maxR + 1);
  }

  LevelModel buildArtLevelForZen({
    required ArtShape shape,
    required int seed,
  }) {
    const targetGrid = 18;
    final scaledMask = _scaleMask(
      shape.toMask(), shape.width, shape.height, targetGrid,
    );

    return LevelGenerator.generateFromMask(
      levelNumber: 9000 + seed,
      mask: scaledMask,
      gridSize: targetGrid,
      maskShape: MaskShape.silhouette,
      seed: seed * 7919,
      avgLengthOverride: 4,
    );
  }

  /// Nearest-neighbour scale of a mask to fit a [dstSize]×[dstSize] grid,
  /// preserving aspect ratio and centering the result.
  static Set<String> _scaleMask(
      Set<String> mask, int srcW, int srcH, int dstSize,
      ) {
    final scale = math.min(dstSize / srcW, dstSize / srcH);
    final scaledW = (srcW * scale).round().clamp(1, dstSize);
    final scaledH = (srcH * scale).round().clamp(1, dstSize);

    final colOff = (dstSize - scaledW) ~/ 2;
    final rowOff = (dstSize - scaledH) ~/ 2;

    final out = <String>{};
    for (int dr = 0; dr < scaledH; dr++) {
      for (int dc = 0; dc < scaledW; dc++) {
        final sr = (dr * srcH / scaledH).floor().clamp(0, srcH - 1);
        final sc = (dc * srcW / scaledW).floor().clamp(0, srcW - 1);
        if (mask.contains('$sr,$sc')) {
          out.add('${dr + rowOff},${dc + colOff}');
        }
      }
    }
    return out;
  }
}