import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/leaderboard_service.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) AudioHapticHelper.playClick();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final bgColor = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    final auth = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        title: Text(
          strings.leaderboardTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: accent,
          unselectedLabelColor: textSecondary,
          indicatorColor: accent,
          indicatorWeight: 3,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          tabs: [
            Tab(text: strings.leaderboardTabWeekly),
            Tab(text: strings.leaderboardTabMonthly),
            Tab(text: strings.leaderboardTabAllTime),
          ],
        ),
      ),
      body: auth.isGuest
          ? _SignInPrompt(
        strings: strings,
        accent: accent,
        textSecondary: textSecondary,
      )
          : TabBarView(
        controller: _tabs,
        children: const [
          _LeaderboardTab(scope: LeaderboardScope.weekly),
          _LeaderboardTab(scope: LeaderboardScope.monthly),
          _LeaderboardTab(scope: LeaderboardScope.allTime),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  final LeaderboardScope scope;
  const _LeaderboardTab({required this.scope});

  int _scoreFor(LeaderboardEntry e) => switch (scope) {
    LeaderboardScope.weekly => e.weeklyScore,
    LeaderboardScope.monthly => e.monthlyScore,
    LeaderboardScope.allTime => e.allTimeScore,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final topAsync = ref.watch(leaderboardTopProvider(scope));
    final myUserId = AuthService.instance.userId;

    final accent = AppColors.accent(context);
    final cardColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return RefreshIndicator(
      color: accent,
      onRefresh: () async {
        ref.invalidate(leaderboardTopProvider(scope));
        ref.invalidate(leaderboardMineProvider);
        await ref.read(leaderboardTopProvider(scope).future);
      },
      child: topAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _EmptyState(
          strings: strings,
          textSecondary: textSecondary,
          accent: accent,
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(
              strings: strings,
              textSecondary: textSecondary,
              accent: accent,
            );
          }

          final podium = entries.take(3).toList();
          final rest =
          entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: _Podium(
                    entries: podium,
                    scoreOf: _scoreFor,
                    myUserId: myUserId,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: rest.length,
                itemBuilder: (_, i) {
                  final e = rest[i];
                  final rank = i + 4;
                  return _RankRow(
                    rank: rank,
                    entry: e,
                    score: _scoreFor(e),
                    isMe: e.userId == myUserId,
                    cardColor: cardColor,
                    accent: accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    strings: strings,
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final int Function(LeaderboardEntry) scoreOf;
  final String? myUserId;
  final Color textPrimary;
  final Color textSecondary;

  const _Podium({
    required this.entries,
    required this.scoreOf,
    required this.myUserId,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final first = entries.isNotEmpty ? entries[0] : null;
    final second = entries.length > 1 ? entries[1] : null;
    final third = entries.length > 2 ? entries[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _PodiumSlot(
            entry: second,
            rank: 2,
            score: second != null ? scoreOf(second) : 0,
            color: const Color(0xFFC0C0C0),
            height: 96,
            isMe: second?.userId == myUserId,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumSlot(
            entry: first,
            rank: 1,
            score: first != null ? scoreOf(first) : 0,
            color: const Color(0xFFFFD700),
            height: 128,
            isMe: first?.userId == myUserId,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumSlot(
            entry: third,
            rank: 3,
            score: third != null ? scoreOf(third) : 0,
            color: const Color(0xFFCD7F32),
            height: 80,
            isMe: third?.userId == myUserId,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final LeaderboardEntry? entry;
  final int rank;
  final int score;
  final Color color;
  final double height;
  final bool isMe;
  final Color textPrimary;
  final Color textSecondary;

  const _PodiumSlot({
    required this.entry,
    required this.rank,
    required this.score,
    required this.color,
    required this.height,
    required this.isMe,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final initial = entry?.avatarInitial ?? '?';
    final name = entry?.displayName ?? '—';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMe)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'YOU',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        Container(
          width: rank == 1 ? 72 : 60,
          height: rank == 1 ? 72 : 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: rank == 1 ? 3 : 2),
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: rank == 1 ? 28 : 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.4),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final int score;
  final bool isMe;
  final Color cardColor;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final AppStrings strings;

  const _RankRow({
    required this.rank,
    required this.entry,
    required this.score,
    required this.isMe,
    required this.cardColor,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? accent.withValues(alpha: 0.12) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: isMe
              ? Border.all(color: accent.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isMe ? accent : textSecondary,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.avatarInitial,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isMe ? accent : textPrimary,
                    ),
                  ),
                  Text(
                    '${strings.leaderboardLevel} ${entry.level} · '
                        '${strings.leaderboardStars} ${entry.totalStars}',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isMe ? accent : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppStrings strings;
  final Color textSecondary;
  final Color accent;

  const _EmptyState({
    required this.strings,
    required this.textSecondary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(Icons.emoji_events_rounded,
            color: accent.withValues(alpha: 0.5), size: 64),
        const SizedBox(height: 16),
        Center(
          child: Text(
            strings.leaderboardEmptyState,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  final AppStrings strings;
  final Color accent;
  final Color textSecondary;

  const _SignInPrompt({
    required this.strings,
    required this.accent,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login_rounded, color: accent, size: 48),
            const SizedBox(height: 16),
            Text(
              strings.leaderboardSignInToRank,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}