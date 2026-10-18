import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../widgets/coin_pill.dart';
import '../../widgets/daily_reward_card.dart';
import '../../widgets/status_flash.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final auth = ref.watch(authServiceProvider);

    final bg = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);

    final currentLevel = progress.currentLevel;
    final starsEarned = List.generate(currentLevel, (i) => i + 1)
        .fold(0, (sum, l) => sum + progress.getStarsForLevel(l));
    final trophyCount = progress.unlockedTrophies.length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () {
            AudioHapticHelper.playClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          strings.profileTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: CoinPill()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(
                auth: auth,
                onSignInTap: () {
                  AudioHapticHelper.playClick();
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _GuestUpgradeCard(
                      onSuccess: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── LC + Leaderboard rank card ──
              _LeaderboardCard(
                onSignInTap: () {
                  AudioHapticHelper.playClick();
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _GuestUpgradeCard(
                      onSuccess: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              _StatsRow(
                level: currentLevel,
                stars: starsEarned,
                trophies: trophyCount,
              ),

              const SizedBox(height: 20),
              const DailyRewardCard(),
              const SizedBox(height: 24),

              // ── Account actions (sign out / delete) — moved to bottom ──
              if (auth.isSignedIn) _SignedInCard(auth: auth),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LC + leaderboard rank card
// ─────────────────────────────────────────────────────────────────────────

class _LeaderboardCard extends ConsumerWidget {
  const _LeaderboardCard({this.onSignInTap});
  final VoidCallback? onSignInTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final progress = ref.watch(progressRepositoryProvider);
    final auth = ref.watch(authServiceProvider);
    final ranksAsync = ref.watch(myRanksProvider);

    final card = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    // ── Guest: greyed-out locked card ──
    if (auth.isGuest) {
      return _buildGuestLockedCard(
        context,
        card: card,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        onSignInTap: onSignInTap,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: LC icon + title + total ──
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LC',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      auth.isGuest
                          ? 'Sign in to earn LC'
                          : 'Earned from daily challenges',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                _formatNumber(progress.lbAllTimeScore),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: textSecondary.withValues(alpha: 0.15)),
          const SizedBox(height: 12),

          // ── Three rank rows ──
          ranksAsync.when(
            loading: () => Column(
              children: [
                _rankRow(strings.leaderboardTabWeekly, null, accent,
                    textPrimary, textSecondary),
                const SizedBox(height: 10),
                _rankRow(strings.leaderboardTabMonthly, null, accent,
                    textPrimary, textSecondary),
                const SizedBox(height: 10),
                _rankRow(strings.leaderboardTabAllTime, null, accent,
                    textPrimary, textSecondary),
              ],
            ),
            error: (_, _) => Column(
              children: [
                _rankRow(strings.leaderboardTabWeekly, null, accent,
                    textPrimary, textSecondary),
                const SizedBox(height: 10),
                _rankRow(strings.leaderboardTabMonthly, null, accent,
                    textPrimary, textSecondary),
                const SizedBox(height: 10),
                _rankRow(strings.leaderboardTabAllTime, null, accent,
                    textPrimary, textSecondary),
              ],
            ),
            data: (r) => Column(
              children: [
                _rankRow(
                  strings.leaderboardTabWeekly,
                  (score: progress.lbWeeklyScore, rank: r.weekly),
                  accent,
                  textPrimary,
                  textSecondary,
                ),
                const SizedBox(height: 10),
                _rankRow(
                  strings.leaderboardTabMonthly,
                  (score: progress.lbMonthlyScore, rank: r.monthly),
                  accent,
                  textPrimary,
                  textSecondary,
                ),
                const SizedBox(height: 10),
                _rankRow(
                  strings.leaderboardTabAllTime,
                  (score: progress.lbAllTimeScore, rank: r.allTime),
                  accent,
                  textPrimary,
                  textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankRow(
      String label,
      ({int score, int? rank})? data,
      Color accent,
      Color textPrimary,
      Color textSecondary,
      ) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            data == null ? '—' : _formatNumber(data.score),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            data?.rank == null ? '—' : '#${data!.rank}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Profile header (unchanged)
// ─────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends ConsumerStatefulWidget {
  const _ProfileHeader({required this.auth, this.onSignInTap});
  final AuthService auth;
  final VoidCallback? onSignInTap;

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

enum _SyncState { idle, syncing, success, error }

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  _SyncState _syncState = _SyncState.idle;

  Future<void> _forceSync() async {
    if (_syncState == _SyncState.syncing) return;
    setState(() => _syncState = _SyncState.syncing);

    try {
      await forceCloudSync(
        ref.read(progressRepositoryProvider),
        ref.read(coinsRepositoryProvider),
      );
      if (!mounted) return;
      setState(() => _syncState = _SyncState.success);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _syncState = _SyncState.idle);
    } catch (e) {
      debugPrint('Force sync failed: $e');
      if (!mounted) return;
      setState(() => _syncState = _SyncState.error);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _syncState = _SyncState.idle);
    }
  }

  String _statusLabel(AppStrings strings) {
    switch (_syncState) {
      case _SyncState.syncing:
        return strings.profileSyncing;
      case _SyncState.success:
        return strings.profileSynced;
      case _SyncState.error:
        return strings.profileSyncFailed;
      case _SyncState.idle:
        return strings.profileSynced;
    }
  }

  Color _statusColor(Color accent) {
    switch (_syncState) {
      case _SyncState.error:
        return const Color(0xFFFF5252);
      default:
        return accent;
    }
  }

  Future<void> _showEditNameSheet() async {
    final strings = AppStrings.of(context);
    final controller = TextEditingController(text: widget.auth.displayName);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final keyboard = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + keyboard,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.profileEditName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: strings.profileNameHint,
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: accent.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(strings.profileCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        AudioHapticHelper.playClick();
                        Navigator.pop(ctx, controller.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        strings.profileSave,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (newName == null || newName.isEmpty) return;
    if (newName == widget.auth.displayName) return;

    try {
      await AuthService.instance.updateDisplayName(newName);
      if (!mounted) return;
      StatusFlash.success(context, strings.profileUpdated);
    } catch (e) {
      debugPrint('Update name failed: $e');
      if (!mounted) return;
      StatusFlash.fail(context, strings.profileSomethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final auth = ref.watch(authServiceProvider);

    final card = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  image: auth.avatarUrl != null && auth.avatarUrl!.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(auth.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: auth.avatarUrl == null || auth.avatarUrl!.isEmpty
                    ? Center(
                  child: Text(
                    auth.avatarInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : null,
              ),
              if (!auth.isGuest)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: _showEditNameSheet,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface(context),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  auth.isGuest
                      ? strings.profilePlayingAsGuest
                      : auth.providerLabel,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
          if (auth.isGuest && widget.onSignInTap != null)
            GestureDetector(
              onTap: widget.onSignInTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 16, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      strings.profileSaveToCloud,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (!auth.isGuest)
            SizedBox(
              width: 78,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap:
                    _syncState == _SyncState.syncing ? null : _forceSync,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _statusColor(accent)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _syncState == _SyncState.syncing
                                ? 0.0
                                : 1.0,
                            child: Icon(
                              _syncState == _SyncState.success
                                  ? Icons.check_rounded
                                  : _syncState == _SyncState.error
                                  ? Icons.error_outline_rounded
                                  : Icons.sync_rounded,
                              color: _statusColor(accent),
                              size: 22,
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _syncState == _SyncState.syncing
                                ? 1.0
                                : 0.0,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: _statusColor(accent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusLabel(strings),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _statusColor(accent),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Guest upgrade card (unchanged)
// ─────────────────────────────────────────────────────────────────────────

class _GuestUpgradeCard extends ConsumerStatefulWidget {
  const _GuestUpgradeCard({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_GuestUpgradeCard> createState() => _GuestUpgradeCardState();
}

class _GuestUpgradeCardState extends ConsumerState<_GuestUpgradeCard> {
  final bool _busy = false;

  Future<void> _showEmailSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmailAuthSheet(
        onSuccess: () {
          Navigator.pop(context);
          widget.onSuccess?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight =
        MediaQuery.of(context).size.height - keyboard - 40;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.profileSaveYourProgress,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                strings.profileGuestBody,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              _AuthOptionButton(
                label: strings.profileContinueWithEmail,
                icon: Icons.email_outlined,
                filled: true,
                accent: accent,
                onTap: _busy ? null : _showEmailSheet,
              ),
              if (_busy) ...[
                const SizedBox(height: 14),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Signed in card — now rendered at the bottom of the screen
// ─────────────────────────────────────────────────────────────────────────

class _SignedInCard extends ConsumerStatefulWidget {
  const _SignedInCard({required this.auth});
  final AuthService auth;

  @override
  ConsumerState<_SignedInCard> createState() => _SignedInCardState();
}

class _SignedInCardState extends ConsumerState<_SignedInCard> {
  bool _busy = false;

  IconData get _providerIcon {
    switch (widget.auth.method) {
      case AuthMethod.email:
        return Icons.email_outlined;
      case AuthMethod.google:
        return Icons.g_mobiledata_rounded;
      case AuthMethod.apple:
        return Icons.apple_rounded;
      case AuthMethod.guest:
        return Icons.person_outline;
    }
  }

  Future<void> _signOut() async {
    final strings = AppStrings.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text(
          strings.profileSignOutTitle,
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        content: Text(
          strings.profileSignOutBody,
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioHapticHelper.playClick();
              Navigator.pop(ctx, false);
            },
            child: Text(strings.profileCancel),
          ),
          TextButton(
            onPressed: () {
              AudioHapticHelper.playClick();
              Navigator.pop(ctx, true);
            },
            child: Text(
              strings.profileSignOut,
              style: const TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await AuthService.instance.signOut();
      await ref.read(progressRepositoryProvider).resetProgress();
      await ref.read(coinsRepositoryProvider).resetAll();
      await mergeCloudAndLocal(
        ref.read(progressRepositoryProvider),
        ref.read(coinsRepositoryProvider),
      );
    } catch (e) {
      if (mounted) {
        final s = AppStrings.of(context);
        StatusFlash.fail(context, s.profileSignOutFailed('$e'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final strings = AppStrings.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text(
          strings.profileDeleteAccountTitle,
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        content: Text(
          strings.profileDeleteAccountBody,
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioHapticHelper.playClick();
              Navigator.pop(ctx, false);
            },
            child: Text(strings.profileCancel),
          ),
          TextButton(
            onPressed: () {
              AudioHapticHelper.playClick();
              Navigator.pop(ctx, true);
            },
            child: Text(
              strings.profileDelete,
              style: const TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await AuthService.instance.deleteAccount();
      await ref.read(progressRepositoryProvider).resetProgress();
      await ref.read(coinsRepositoryProvider).resetAll();
      await mergeCloudAndLocal(
        ref.read(progressRepositoryProvider),
        ref.read(coinsRepositoryProvider),
      );
    } catch (e) {
      if (mounted) {
        final s = AppStrings.of(context);
        StatusFlash.fail(context, s.profileDeleteFailed('$e'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(_providerIcon, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.profileSignedIn,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.auth.email ?? widget.auth.providerLabel,
                        style: TextStyle(
                            fontSize: 12, color: textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: accent, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.profileSignedInBody,
            style: TextStyle(
              fontSize: 12.5,
              color: textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () {
              AudioHapticHelper.playClick();
              _signOut();
            },
            icon: _busy
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout_rounded, size: 18),
            label: Text(
              strings.profileSignOut,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF5252),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(
                  color: Color(0xFFFF5252), width: 1.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: _busy
                ? null
                : () {
              AudioHapticHelper.playClick();
              _deleteAccount();
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text(
              strings.profileDeleteAccount,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5252),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Auth option button (unchanged)
// ─────────────────────────────────────────────────────────────────────────

class _AuthOptionButton extends StatelessWidget {
  const _AuthOptionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap == null
            ? null
            : () {
          AudioHapticHelper.playClick();
          onTap!();
        },
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap == null
          ? null
          : () {
        AudioHapticHelper.playClick();
        onTap!();
      },
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w800,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: accent.withValues(alpha: 0.4),
          width: 1.3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Stats row (unchanged)
// ─────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.level,
    required this.stars,
    required this.trophies,
  });

  final int level;
  final int stars;
  final int trophies;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final card = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.flag_rounded,
            label: strings.profileStatLevel,
            value: '$level',
            accent: accent,
            card: card,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.star_rounded,
            label: strings.profileStatStars,
            value: '$stars',
            accent: accent,
            card: card,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.emoji_events_rounded,
            label: strings.profileStatTrophies,
            value: '$trophies',
            accent: accent,
            card: card,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Email auth sheet (unchanged)
// ─────────────────────────────────────────────────────────────────────────

class _EmailAuthSheet extends ConsumerStatefulWidget {
  const _EmailAuthSheet({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  ConsumerState<_EmailAuthSheet> createState() => _EmailAuthSheetState();
}

enum _EmailMode { signIn, signUp }

class _EmailAuthSheetState extends ConsumerState<_EmailAuthSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _emailExistsPrompt = false;
  bool _obscurePassword = true;

  _EmailMode _mode = _EmailMode.signUp;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  String? _validatePassword(AppStrings strings, String password) {
    if (password.length < 8) return strings.profilePasswordMinLength;
    return null;
  }

  int _passwordStrength(String p) {
    if (p.isEmpty) return 0;
    if (p.length < 8) return 1;
    int score = 0;
    if (p.length >= 12) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    if (p.length >= 8 && score <= 2) return 2;
    if (score == 3) return 3;
    if (score == 4) return 4;
    return 2;
  }

  String _generatePassword() {
    const lower = 'abcdefghijkmnpqrstuvwxyz';
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const digits = '23456789';
    const symbols = '!@#\$%^&*-_=+';
    final rng = Random.secure();
    final chars = <String>[
      lower[rng.nextInt(lower.length)],
      upper[rng.nextInt(upper.length)],
      digits[rng.nextInt(digits.length)],
      symbols[rng.nextInt(symbols.length)],
    ];
    const all = '$lower$upper$digits$symbols';
    for (int i = chars.length; i < 12; i++) {
      chars.add(all[rng.nextInt(all.length)]);
    }
    chars.shuffle(rng);
    return chars.join();
  }

  String _friendlyError(AppStrings strings, AppwriteException e) {
    final msg = (e.message ?? '').toLowerCase();
    final type = (e.type ?? '').toLowerCase();
    final code = e.code ?? 0;

    if (type.contains('user_email_already_exists') ||
        msg.contains('already exists') ||
        msg.contains('already registered')) {
      return _mode == _EmailMode.signUp
          ? strings.profileErrorEmailSignUp
          : strings.profileErrorEmailSignIn;
    }
    if (type.contains('user_invalid_credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('invalid email or password')) {
      return strings.profileErrorInvalidCredentials;
    }
    if (type.contains('user_password') ||
        msg.contains('password') ||
        msg.contains('bad_request')) {
      return strings.profileErrorPassword;
    }
    if (type.contains('user_invalid_email') ||
        msg.contains('invalid email')) {
      return strings.profileErrorInvalidEmail;
    }
    if (code == 401 || msg.contains('unauthorized')) {
      return strings.profileErrorSessionExpired;
    }
    if (code == 429 || msg.contains('rate limit')) {
      return strings.profileErrorRateLimit;
    }
    if (code >= 500) return strings.profileErrorServerBusy;
    return _mode == _EmailMode.signUp
        ? strings.profileErrorSignUpGeneric
        : strings.profileErrorSignInGeneric;
  }

  Future<void> _submit() async {
    AudioHapticHelper.playClick();
    final strings = AppStrings.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() {
        _error = strings.profileEnterValidEmail;
        _emailExistsPrompt = false;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _error = strings.profileEnterPassword;
        _emailExistsPrompt = false;
      });
      return;
    }
    if (_mode == _EmailMode.signUp) {
      final passwordProblem = _validatePassword(strings, password);
      if (passwordProblem != null) {
        setState(() {
          _error = passwordProblem;
          _emailExistsPrompt = false;
        });
        return;
      }
    }

    setState(() {
      _busy = true;
      _error = null;
      _emailExistsPrompt = false;
    });

    try {
      if (_mode == _EmailMode.signUp) {
        await AuthService.instance.upgradeToEmail(
          email: email,
          password: password,
          name: name.isEmpty ? null : name,
        );
      } else {
        await AuthService.instance.signInWithEmail(
          email: email,
          password: password,
        );
      }
      await mergeCloudAndLocal(
        ref.read(progressRepositoryProvider),
        ref.read(coinsRepositoryProvider),
      );
      if (mounted) widget.onSuccess();
    } on AppwriteException catch (e) {
      final type = (e.type ?? '').toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      final emailExists = type.contains('user_email_already_exists') ||
          msg.contains('already exists') ||
          msg.contains('already registered');
      if (emailExists && _mode == _EmailMode.signUp) {
        if (mounted) {
          setState(() {
            _mode = _EmailMode.signIn;
            _error = strings.profileEmailAlreadyPrompt;
            _emailExistsPrompt = true;
            _name.clear();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = _friendlyError(strings, e);
            _emailExistsPrompt = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = strings.profileSomethingWrong;
          _emailExistsPrompt = false;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final card = AppColors.surface(context);
    final accent = AppColors.accent(context);

    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight =
        MediaQuery.of(context).size.height - keyboard - 40;
    final isSignUp = _mode == _EmailMode.signUp;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _modeButton(strings.profileTabSignIn,
                          _EmailMode.signIn, accent, textSecondary),
                    ),
                    Expanded(
                      child: _modeButton(strings.profileTabCreateAccount,
                          _EmailMode.signUp, accent, textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSignUp
                    ? strings.profileCreateAccountTitle
                    : strings.profileWelcomeBack,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSignUp
                    ? strings.profileGuestProgressCarries
                    : strings.profileSignInRestoreBody,
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 20),
              if (isSignUp) ...[
                _Field(
                  controller: _name,
                  hint: strings.profileNameHint,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
              ],
              _Field(
                controller: _email,
                hint: strings.profileEmailHint,
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _password,
                hint: strings.profilePasswordHint,
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: textSecondary,
                      ),
                      onPressed: () {
                        AudioHapticHelper.playClick();
                        setState(
                                () => _obscurePassword = !_obscurePassword);
                      },
                      tooltip: _obscurePassword
                          ? strings.profileShowPassword
                          : strings.profileHidePassword,
                    ),
                    IconButton(
                      icon: Icon(Icons.casino_outlined,
                          size: 18, color: accent),
                      onPressed: () {
                        AudioHapticHelper.playClick();
                        setState(() {
                          _password.text = _generatePassword();
                          _obscurePassword = false;
                        });
                      },
                      tooltip: strings.profileGeneratePassword,
                    ),
                  ],
                ),
              ),
              if (isSignUp && _password.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _PasswordStrengthBar(
                  strength: _passwordStrength(_password.text),
                  strings: strings,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _emailExistsPrompt
                        ? accent.withValues(alpha: 0.1)
                        : const Color(0xFFFF5252).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _emailExistsPrompt
                          ? accent.withValues(alpha: 0.4)
                          : const Color(0xFFFF5252)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _emailExistsPrompt
                            ? Icons.info_outline_rounded
                            : Icons.error_outline_rounded,
                        size: 16,
                        color: _emailExistsPrompt
                            ? accent
                            : const Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: _emailExistsPrompt
                                ? accent
                                : const Color(0xFFFF5252),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  isSignUp
                      ? strings.profileCreateAccountButton
                      : strings.profileSignInButton,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () {
                    AudioHapticHelper.playClick();
                    setState(() {
                      _mode = isSignUp
                          ? _EmailMode.signIn
                          : _EmailMode.signUp;
                      _error = null;
                      _emailExistsPrompt = false;
                    });
                  },
                  child: Text(
                    isSignUp
                        ? strings.profileAlreadyHaveAccount
                        : strings.profileDontHaveAccount,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, _EmailMode mode, Color accent,
      Color textSecondary) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: _busy
          ? null
          : () {
        AudioHapticHelper.playClick();
        setState(() {
          _mode = mode;
          _error = null;
          _emailExistsPrompt = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard,
    this.obscure = false,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboard;
  final bool obscure;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: textSecondary, size: 20),
        suffixIcon: trailing,
        suffixIconConstraints:
        const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: accent.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({
    required this.strength,
    required this.strings,
  });

  final int strength;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (strength) {
      0 => (Colors.transparent, ''),
      1 => (const Color(0xFFFF5252), strings.profileStrengthTooShort),
      2 => (const Color(0xFFFF9800), strings.profileStrengthOkay),
      3 => (const Color(0xFFFFC107), strings.profileStrengthGood),
      _ => (const Color(0xFF4CAF50), strings.profileStrengthStrong),
    };

    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength
                    ? color
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildGuestLockedCard(
    BuildContext context, {
      required Color card,
      required Color textPrimary,
      required Color textSecondary,
      VoidCallback? onSignInTap,
    }) {
  final muted = textSecondary.withValues(alpha: 0.55);

  final body = Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: textSecondary.withValues(alpha: 0.15),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock_rounded, color: muted, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LC',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: muted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Leaderboard locked',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.visibility_off_rounded, color: muted, size: 22),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: textSecondary.withValues(alpha: 0.12)),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: muted, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sign in to unlock the Leaderboard',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary.withValues(alpha: 0.55),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _lockedRow('Weekly', textSecondary),
        const SizedBox(height: 10),
        _lockedRow('Monthly', textSecondary),
        const SizedBox(height: 10),
        _lockedRow('All-Time', textSecondary),
      ],
    ),
  );

  if (onSignInTap == null) return body;
  return GestureDetector(
    onTap: onSignInTap,
    behavior: HitTestBehavior.opaque,
    child: body,
  );
}

Widget _lockedRow(String label, Color textSecondary) {
  final muted = textSecondary.withValues(alpha: 0.4);
  return Row(
    children: [
      SizedBox(
        width: 88,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: muted,
          ),
        ),
      ),
      Expanded(
        child: Text(
          '—',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: muted,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: muted.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '—',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: muted,
          ),
        ),
      ),
    ],
  );
}