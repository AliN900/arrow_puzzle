import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'appwrite_service.dart';

/// One row from the leaderboard table.
class LeaderboardEntry {
  final String userId;        // Appwrite row $id
  final String displayName;
  final String? avatarUrl;
  final int weeklyScore;
  final int monthlyScore;
  final int allTimeScore;
  final int level;
  final int totalStars;
  final int trophies;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.weeklyScore,
    required this.monthlyScore,
    required this.allTimeScore,
    required this.level,
    required this.totalStars,
    required this.trophies,
  });

  /// Computed on the fly — no column needed.
  String get avatarInitial {
    final n = displayName.trim();
    return n.isEmpty ? 'P' : n[0].toUpperCase();
  }

  /// Constructed from an Appwrite row. `$id` is the userId.
  factory LeaderboardEntry.fromRow(dynamic row) {
    final data = row.data as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: row.$id as String,
      displayName: data['display_name'] as String? ?? 'Player',
      avatarUrl: data['avatarUrl'] as String?,
      weeklyScore: (data['weeklyScore'] as num?)?.toInt() ?? 0,
      monthlyScore: (data['monthlyScore'] as num?)?.toInt() ?? 0,
      allTimeScore: (data['allTimeScore'] as num?)?.toInt() ?? 0,
      level: (data['level'] as num?)?.toInt() ?? 1,
      totalStars: (data['totalStars'] as num?)?.toInt() ?? 0,
      trophies: (data['trophies'] as num?)?.toInt() ?? 0,
    );
  }
}

enum LeaderboardScope { weekly, monthly, allTime }

class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();

  // ── UTC period helpers ───────────────────────────────────────────

  static DateTime currentWeekStartUtc() {
    final now = DateTime.now().toUtc();
    final daysSinceMonday = now.weekday - 1;
    return DateTime.utc(now.year, now.month, now.day)
        .subtract(Duration(days: daysSinceMonday));
  }

  static DateTime currentMonthStartUtc() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, 1);
  }

  // ── Push ─────────────────────────────────────────────────────────

  Future<void> pushScore({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required int weeklyScore,
    required int monthlyScore,
    required int allTimeScore,
    required int level,
    required int totalStars,
    required int trophies,
    required DateTime weeklyPeriodStart,
    required DateTime monthlyPeriodStart,
    required DateTime weeklyReachedAt,
    required DateTime monthlyReachedAt,
  }) async {
    final data = <String, dynamic>{
      'display_name': displayName,
      'avatarUrl': ?avatarUrl,
      'weeklyScore': weeklyScore,
      'weeklyPeriodStart': weeklyPeriodStart.toUtc().toIso8601String(),
      'weeklyReachedAt': weeklyReachedAt.toUtc().toIso8601String(),
      'monthlyScore': monthlyScore,
      'monthlyPeriodStart': monthlyPeriodStart.toUtc().toIso8601String(),
      'monthlyReachedAt': monthlyReachedAt.toUtc().toIso8601String(),
      'allTimeScore': allTimeScore,
      'level': level,
      'totalStars': totalStars,
      'trophies': trophies,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await AppwriteService.tablesDb.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.leaderboardTableId,
        rowId: userId,
        data: data,
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
      debugPrint('🏆 LB push OK');
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        try {
          await AppwriteService.tablesDb.createRow(
            databaseId: AppwriteService.databaseId,
            tableId: AppwriteService.leaderboardTableId,
            rowId: userId,
            data: data,
            permissions: [
              Permission.read(Role.any()),
              Permission.update(Role.user(userId)),
              Permission.delete(Role.user(userId)),
            ],
          );
          debugPrint('🏆 LB create OK');
        } catch (createErr) {
          debugPrint('🔴 LB create failed: $createErr');
        }
      } else {
        debugPrint('🔴 LB update failed (${e.code}): ${e.message}');
      }
    } catch (e) {
      debugPrint('🔴 LB push error: $e');
    }
  }

  // ── Fetch top N ──────────────────────────────────────────────────

  Future<List<LeaderboardEntry>> fetchTop({
    required LeaderboardScope scope,
    int limit = 100,
  }) async {
    try {
      final queries = <String>[
        Query.orderDesc(_scoreColumn(scope)),
        if (scope != LeaderboardScope.allTime)
          Query.equal(_periodColumn(scope), _currentPeriodIso(scope)),
        Query.limit(limit),
      ];

      final result = await AppwriteService.tablesDb.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.leaderboardTableId,
        queries: queries,
      );

      return result.rows.map(LeaderboardEntry.fromRow).toList();
    } catch (e) {
      debugPrint('🔴 LB fetchTop error: $e');
      return const [];
    }
  }

  // ── Fetch mine ───────────────────────────────────────────────────

  Future<LeaderboardEntry?> fetchMine(String userId) async {
    try {
      final row = await AppwriteService.tablesDb.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.leaderboardTableId,
        rowId: userId,
      );
      return LeaderboardEntry.fromRow(row);
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
      debugPrint('🔴 LB fetchMine error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('🔴 LB fetchMine error: $e');
      return null;
    }
  }

  // ── Column name helpers ──────────────────────────────────────────

  static String _scoreColumn(LeaderboardScope s) => switch (s) {
    LeaderboardScope.weekly => 'weeklyScore',
    LeaderboardScope.monthly => 'monthlyScore',
    LeaderboardScope.allTime => 'allTimeScore',
  };

  static String _periodColumn(LeaderboardScope s) => switch (s) {
    LeaderboardScope.weekly => 'weeklyPeriodStart',
    LeaderboardScope.monthly => 'monthlyPeriodStart',
    LeaderboardScope.allTime => '',
  };

  static String _currentPeriodIso(LeaderboardScope s) => switch (s) {
    LeaderboardScope.weekly => currentWeekStartUtc().toIso8601String(),
    LeaderboardScope.monthly => currentMonthStartUtc().toIso8601String(),
    LeaderboardScope.allTime => '',
  };
}