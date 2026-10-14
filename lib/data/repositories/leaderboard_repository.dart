import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/leaderboard_service.dart';

/// Pure calculation helpers + push orchestration.
class LeaderboardRepository {
  LeaderboardRepository._();
  static final LeaderboardRepository instance = LeaderboardRepository._();

  /// Points awarded for a first clear.
  /// Base 100 + 20 per star → 120 / 140 / 160.
  static int pointsForFirstClear(int stars) => 100 + stars * 20;

  /// Push the current user's LB row to Appwrite.
  Future<void> pushCurrentUser({
    required int level,
    required int totalStars,
    required int trophies,
    required int weeklyScore,
    required int monthlyScore,
    required int allTimeScore,
    required DateTime weeklyPeriodStart,
    required DateTime monthlyPeriodStart,
    required DateTime? weeklyReachedAt,
    required DateTime? monthlyReachedAt,
  }) async {
    final auth = AuthService.instance;
    final userId = auth.userId;
    if (userId == null) {
      debugPrint('🏆 LB push skipped: no userId');
      return;
    }
    if (auth.isGuest) {
      debugPrint('🏆 LB push skipped: guest account');
      return;
    }

    final now = DateTime.now().toUtc();
    debugPrint(
        '🏆 LB push: level=$level w=$weeklyScore m=$monthlyScore a=$allTimeScore');

    await LeaderboardService.instance.pushScore(
      userId: userId,
      displayName: auth.displayName,
      avatarUrl: auth.avatarUrl,
      weeklyScore: weeklyScore,
      monthlyScore: monthlyScore,
      allTimeScore: allTimeScore,
      level: level,
      totalStars: totalStars,
      trophies: trophies,
      weeklyPeriodStart: weeklyPeriodStart,
      monthlyPeriodStart: monthlyPeriodStart,
      weeklyReachedAt: weeklyReachedAt ?? now,
      monthlyReachedAt: monthlyReachedAt ?? now,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────

/// My rank in each of the three scopes. Null if not in the top 100.
final myRanksProvider =
FutureProvider<({int? weekly, int? monthly, int? allTime})>((ref) async {
  final userId = AuthService.instance.userId;
  if (userId == null) return (weekly: null, monthly: null, allTime: null);

  final lists = await Future.wait([
    LeaderboardService.instance.fetchTop(scope: LeaderboardScope.weekly),
    LeaderboardService.instance.fetchTop(scope: LeaderboardScope.monthly),
    LeaderboardService.instance.fetchTop(scope: LeaderboardScope.allTime),
  ]);

  int? rankOf(List<LeaderboardEntry> list) {
    final i = list.indexWhere((e) => e.userId == userId);
    return i >= 0 ? i + 1 : null;
  }

  return (
  weekly: rankOf(lists[0]),
  monthly: rankOf(lists[1]),
  allTime: rankOf(lists[2]),
  );
});

final leaderboardTopProvider =
FutureProvider.family<List<LeaderboardEntry>, LeaderboardScope>(
      (ref, scope) async {
    // Depend on auth so the provider invalidates on sign-in/out.
    ref.watch(authServiceProvider);
    return LeaderboardService.instance.fetchTop(scope: scope);
  },
);

final leaderboardMineProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  ref.watch(authServiceProvider);
  final userId = AuthService.instance.userId;
  if (userId == null) return null;
  return LeaderboardService.instance.fetchMine(userId);
});