import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';
import '../../services/appwrite_service.dart';
import '../../widgets/global_challenge_overlay.dart';
import '../../widgets/pop_dialog.dart';
import '../../widgets/status_flash.dart';
import 'providers/challenge_provider.dart';
import 'providers/friends_provider.dart';
import 'screens/friend_chat_screen.dart';
import 'widgets/friend_tile.dart';
import 'widgets/mp_diagonal_player_card.dart';

class FriendMatchScreen extends ConsumerStatefulWidget {
  const FriendMatchScreen({super.key});

  @override
  ConsumerState<FriendMatchScreen> createState() => _FriendMatchScreenState();
}

class _FriendMatchScreenState extends ConsumerState<FriendMatchScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authServiceProvider);
      if (!auth.isGuest && auth.userId != null) {
        ref.read(friendsProvider.notifier).initAppwrite(
          AppwriteService.tablesDb, Realtime(AppwriteService.client),
          auth.userId!, auth.displayName, ref.read(progressRepositoryProvider).currentLevel,
        );
      }
    });
  }

  // ── REMOVE FRIEND POPUP ─────────────────────────────────────────────
  void _confirmRemoveFriend(FriendModel friend) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final strings = AppStrings.of(context);
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final onSurface = cs.onSurface;
        final cardFillAlpha = isDark ? 0.08 : 0.12;
        final cardBorderAlpha = isDark ? 0.35 : 0.45;

        return PopDialog(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accent(context).withValues(alpha: 0.4), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.removeFriendQuestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 210,
                    child: MpDiagonalPlayerCard(
                      name: friend.name,
                      subtitle: strings.trophiesLevelBadge(friend.level),
                      showReadyBadge: false,
                      color: Colors.red.shade400,
                      avatarRadius: 22,
                      padH: 16,
                      padV: 16,
                      cutSize: 42,
                      cutCorner: MpCardCutCorner.topLeft,
                      fillAlpha: cardFillAlpha,
                      borderAlpha: cardBorderAlpha,
                      onSurface: onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary(context),
                            side: BorderSide(color: AppColors.textPrimary(context).withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.buttonCancel.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(friendsProvider.notifier).removeFriend(friend.id, friend.friendshipId);
                            Navigator.pop(dialogCtx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.buttonRemove,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── FRIEND REQUESTS POPUP ─────────────────────────────────────────
  void _showRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final strings = AppStrings.of(context);
            final requests = ref.watch(friendsProvider).requests;

            final theme = Theme.of(context);
            final cs = theme.colorScheme;
            final isDark = theme.brightness == Brightness.dark;
            final accent = AppColors.accent(context);
            final onSurface = cs.onSurface;
            final cardFillAlpha = isDark ? 0.08 : 0.12;
            final cardBorderAlpha = isDark ? 0.35 : 0.45;

            return PopDialog(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.friendRequests,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 16),
                    if (requests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          strings.noPendingRequests,
                          style: TextStyle(color: AppColors.textSecondary(context)),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 380),
                        child: ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (_, _) => const SizedBox(height: 20),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final req = requests[index];
                            return Column(
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 220,
                                    child: MpDiagonalPlayerCard(
                                      name: req.name,
                                      subtitle: strings.trophiesLevelBadge(req.level),
                                      showReadyBadge: false,
                                      color: accent,
                                      avatarRadius: 22,
                                      padH: 16,
                                      padV: 16,
                                      cutSize: 45,
                                      cutCorner: MpCardCutCorner.bottomRight,
                                      fillAlpha: cardFillAlpha,
                                      borderAlpha: cardBorderAlpha,
                                      onSurface: onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: () => ref.read(friendsProvider.notifier).rejectRequest(req.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.withValues(alpha: 0.15),
                                            foregroundColor: Colors.red.shade400,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
                                            ),
                                          ),
                                          child: const Icon(Icons.close_rounded, size: 28),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: () => ref.read(friendsProvider.notifier).acceptRequest(req.id, req.senderId, req.name, req.level),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00C853),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                          child: const Icon(Icons.check_rounded, size: 28),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary(context),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.textPrimary(context).withValues(alpha: 0.2)),
                        ),
                        child: Text(strings.mpClose),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openChatScreen(FriendModel friend) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FriendChatScreen(friend: friend)));
  }

  void _startInviteFlow(FriendModel friend) {
    if (!friend.isOnline) {
      StatusFlash.fail(context, 'Player is offline');
      return;
    }

    // 1. Send challenge (sets isChallenging to true)
    ref.read(challengeProvider.notifier).sendChallenge(Challenger(
      id: friend.id, name: friend.name, level: friend.level,
    ));

    // 2. Show Waiting Dialog IMMEDIATELY
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(challengeProvider);
            final strings = AppStrings.of(context);

            // 👈 If accepted: Close dialog and open Rules Screen
            if (state.isMatchAccepted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(dialogCtx)) Navigator.pop(dialogCtx);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const MpMatchSettingsDialogWrapper(isHost: true),
                );
              });
            }

            // 👈 If cancelled/rejected: Close dialog
            if (!state.isChallenging && !state.isMatchAccepted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(dialogCtx)) Navigator.pop(dialogCtx);
                StatusFlash.fail(context, 'Challenge declined or cancelled');
              });
            }

            return PopDialog(
              child: Container(
                padding: const EdgeInsets.all(28),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.accent(context).withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF00C853)),
                    const SizedBox(height: 20),
                    Text(
                      strings.invitingFriend(friend.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 24),
                    // X BUTTON TO CANCEL
                    GestureDetector(
                      onTap: () {
                        AudioHapticHelper.playClick();
                        // 👈 ONLY cancel the challenge. The Consumer will pop the dialog.
                        ref.read(challengeProvider.notifier).cancelChallenge();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.red, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final bg = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    final friendsState = ref.watch(friendsProvider);
    final unreadSet = friendsState.unreadFriendIds;

    final isInMatch = ref.watch(challengeProvider.select((s) => s.isInMatch));

    return PopScope(
      canPop: false,                              // 👈 was true
      onPopInvokedWithResult: (didPop, result) {  // 👈 NEW
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        AudioHapticHelper.playClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: accent, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        strings.friends,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary),
                      ),
                    ),
                    Badge(
                      isLabelVisible: friendsState.requests.isNotEmpty,
                      label: Text('${friendsState.requests.length}'),
                      child: IconButton(
                        onPressed: _showRequestsDialog,
                        icon: Icon(Icons.notifications_active_rounded, color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  strings.yourFriendsList,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: friendsState.friends.isEmpty
                      ? Center(child: Text(strings.noFriendsYet, style: TextStyle(color: textSecondary)))
                      : ListView.builder(
                    itemCount: friendsState.friends.length,
                    itemBuilder: (context, index) {
                      final friend = friendsState.friends[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        // 👈 NEW: Wrap with Opacity and IgnorePointer
                        child: Opacity(
                          opacity: isInMatch ? 0.5 : 1.0,
                          child: IgnorePointer(
                            ignoring: isInMatch,
                            child: FriendTile(
                              name: friend.name,
                              level: friend.level,
                              isOnline: friend.isOnline,
                              hasUnread: unreadSet.contains(friend.id),
                              onInvite: () => _startInviteFlow(friend),
                              onTap: () => _openChatScreen(friend),
                              onRemove: () => _confirmRemoveFriend(friend),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}