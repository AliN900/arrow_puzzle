import 'dart:math';
import 'dart:math' as math;

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../services/appwrite_service.dart';
import '../services/leaderboard_service.dart';

/// DEV ONLY — seeds 100 fake leaderboard rows so you can preview the UI
/// without real players. Call from the debug menu; wipe when done.
///
/// Appwrite free tier rate-limits rapid writes, so this throttles between
/// calls. Expect ~60-90 seconds for 100 rows.
class LeaderboardSeeder {
  LeaderboardSeeder._();
  static final LeaderboardSeeder instance = LeaderboardSeeder._();

  static const String _prefix = 'fake_player_';
  static const Duration _throttle = Duration(milliseconds: 900);

  static const List<String> _namePool = [
    'ShadowFox', 'NeonBlade', 'PixelNinja', 'VectorWolf', 'EchoStrike',
    'CosmicRay', 'ZenArrow', 'RiftWalker', 'HexMage', 'VoidRunner',
    'CipherX', 'LunaTic', 'IronPulse', 'SwiftQuill', 'ByteStorm',
    'Aurora_X', 'GhostLine', 'OnyxBee', 'FrostByte', 'SolarFlare',
    'NovaKid', 'SilentOrbit', 'ThunderCat', 'AmberWave', 'JadeHawk',
    'CrimsonRay', 'MonoChrome', 'TwinSpark', 'KiteWing', 'CopperFox',
    'BlueRune', 'AshFall', 'DeepCurrent', 'BrightFang', 'QuietStorm',
    'GlassTiger', 'PaleRider', 'MoonLark', 'RedComet', 'TerraNova',
    'WispHunter', 'GreyWolf', 'AmberFox', 'StormBloom', 'IceViper',
    'PrimeEcho', 'WarpKnot', 'ZenKit', 'RuneCast', 'NeonChase',
    'StarDrift', 'CloudNine', 'ShiftKey', 'PrismWolf', 'StaticRay',
    'HyperCell', 'QuantumFox', 'NebulaJay', 'PulseWave', 'ApexLine',
    'SnowDrift', 'ArcLight', 'BrightEcho', 'SilkRaven', 'DarkLoom',
    'SkyForge', 'DeepEcho', 'RippleX', 'PixelWolf', 'ChromeFin',
    'MonoLark', 'NeonQuill', 'MythKite', 'RiftWolf', 'VectorJay',
    'TwilightCo', 'EmberFang', 'VoidCat', 'RuneWing', 'StormRune',
    'SilverArc', 'CopperJay', 'PrismFox', 'GhostBloom', 'AzureLine',
    'CipherWave', 'AuroraFin', 'OnyxQuill', 'SolarKnot', 'LunaBlade',
    'HexRaven', 'CosmicFin', 'IronQuill', 'DeepKnot', 'ZenWolf',
    'FrostRaven', 'NeonBloom', 'WaveFin', 'OnyxJay', 'NovaLark',
  ];

  /// Seed N fake rows. Throttled to stay under Appwrite's rate limit.
  Future<int> seed({
    int count = 100,
    void Function(int)? onProgress,
  }) async {
    final now = DateTime.now().toUtc();
    final weekStart = LeaderboardService.currentWeekStartUtc();
    final monthStart = LeaderboardService.currentMonthStartUtc();
    final rng = Random(42);

    int created = 0;
    int failed = 0;

    for (int i = 0; i < count && i < _namePool.length; i++) {
      final data = _generateRow(
        index: i,
        total: count,
        now: now,
        weekStart: weekStart,
        monthStart: monthStart,
        rng: rng,
      );

      final rowId = '$_prefix${(i + 1).toString().padLeft(3, '0')}';

      final ok = await _upsertRow(rowId, data);
      if (ok) {
        created++;
      } else {
        failed++;
      }

      // Notify UI of progress
      onProgress?.call(created + failed);

      // Throttle between calls.
      if (i < count - 1) {
        await Future.delayed(_throttle);
      }
    }

    debugPrint('🏆 Seeded $created / $count fake LB rows ($failed failed)');
    return created;
  }

  Future<bool> _upsertRow(String rowId, Map<String, dynamic> data) async {
    // Fake rows can't grant per-user permissions — the ID isn't a real
    // user. `Role.users()` = any authenticated user can update/delete.
    final perms = [
      Permission.read(Role.any()),
      Permission.update(Role.users()),
      Permission.delete(Role.users()),
    ];

    try {
      await AppwriteService.tablesDb.createRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.leaderboardTableId,
        rowId: rowId,
        data: data,
        permissions: perms,
      );
      return true;
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        // Already exists — update the data, skip perms.
        try {
          await AppwriteService.tablesDb.updateRow(
            databaseId: AppwriteService.databaseId,
            tableId: AppwriteService.leaderboardTableId,
            rowId: rowId,
            data: data,
          );
          return true;
        } catch (updateErr) {
          debugPrint('🔴 seed update $rowId failed: $updateErr');
          return false;
        }
      }
      debugPrint('🔴 seed create $rowId failed (${e.code}): ${e.message}');
      return false;
    } catch (e) {
      debugPrint('🔴 seed error $rowId: $e');
      return false;
    }
  }

  /// Remove all seeded fake rows. Also throttled.
  Future<int> clear() async {
    int removed = 0;
    List<String> ids = [];

    // List first — one call, no throttle needed.
    try {
      final result = await AppwriteService.tablesDb.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.leaderboardTableId,
        queries: [Query.limit(500)],
      );
      ids = result.rows
          .where((r) => r.$id.startsWith(_prefix))
          .map((r) => r.$id)
          .toList();
    } catch (e) {
      debugPrint('🔴 clear list error: $e');
      return 0;
    }

    for (int i = 0; i < ids.length; i++) {
      try {
        await AppwriteService.tablesDb.deleteRow(
          databaseId: AppwriteService.databaseId,
          tableId: AppwriteService.leaderboardTableId,
          rowId: ids[i],
        );
        removed++;
      } catch (e) {
        debugPrint('🔴 delete ${ids[i]} failed: $e');
      }
      if (i < ids.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    debugPrint('🏆 Cleared $removed fake LB rows');
    return removed;
  }


  Map<String, dynamic> _generateRow({
    required int index,
    required int total,
    required DateTime now,
    required DateTime weekStart,
    required DateTime monthStart,
    required Random rng,
  }) {
    // pct = 0.0 for #1, 1.0 for #N. Curve = (1 - pct)^exp.
    // Higher exponent = steeper drop-off.
    final pct = total > 1 ? index / (total - 1) : 0.0;

    // All-time: slow decay — seasoned players cluster up top.
    final allTimeCurve = math.pow(1 - pct, 2.2).toDouble();
    final allTimeScore = (120000 * allTimeCurve).round();

    // Weekly: fast decay — a fresh grind rewards the top spot heavily.
    final weeklyCurve = math.pow(1 - pct, 3.0).toDouble();
    final weeklyScore = (18000 * weeklyCurve).round();

    // Monthly: middle ground.
    final monthlyCurve = math.pow(1 - pct, 2.5).toDouble();
    final monthlyScore = (55000 * monthlyCurve).round();

    // Level/stars/trophies follow the same curve with small jitter.
    final levelCurve = math.pow(1 - pct, 1.4).toDouble();
    final level = (30 + 470 * levelCurve).round().clamp(1, 500);

    final starsCurve = math.pow(1 - pct, 1.3).toDouble();
    final totalStars = (20 + 1300 * starsCurve).round().clamp(0, 1500);

    final trophiesCurve = math.pow(1 - pct, 1.2).toDouble();
    final trophies = (2 + 48 * trophiesCurve).round().clamp(0, 51);

    // Tiny jitter so ties don't happen, but small enough to preserve order.
    final jitter = rng.nextInt(120) - 60;
    final reachedOffsetW = Duration(minutes: rng.nextInt(60 * 24 * 6));
    final reachedOffsetM = Duration(minutes: rng.nextInt(60 * 24 * 20));

    return {
      'display_name': _namePool[index % _namePool.length],
      'weeklyScore': (weeklyScore + jitter).clamp(0, 999999),
      'weeklyPeriodStart': weekStart.toIso8601String(),
      'weeklyReachedAt': weekStart.add(reachedOffsetW).toIso8601String(),
      'monthlyScore': (monthlyScore + jitter).clamp(0, 999999),
      'monthlyPeriodStart': monthStart.toIso8601String(),
      'monthlyReachedAt': monthStart.add(reachedOffsetM).toIso8601String(),
      'allTimeScore': (allTimeScore + jitter).clamp(0, 999999),
      'level': level,
      'totalStars': totalStars,
      'trophies': trophies,
      'updatedAt': now.toIso8601String(),
    };
  }
}