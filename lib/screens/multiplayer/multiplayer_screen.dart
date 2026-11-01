import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:arrow_puzzle/screens/multiplayer/providers/challenge_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../main.dart';
import '../../services/appwrite_service.dart';
import '../../widgets/pop_dialog.dart';
import 'friend_match_screen.dart';
import 'providers/friends_provider.dart';
import 'random_match_screen.dart';
import 'screens/friend_chat_screen.dart';
import 'widgets/mp_mode_card.dart';

class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  Timer? _searchDebounce;

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
        ref.read(challengeProvider.notifier).initAppwrite(
          AppwriteService.tablesDb, Realtime(AppwriteService.client),
          auth.userId!, auth.displayName, ref.read(progressRepositoryProvider).currentLevel,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    if (mounted) {
    }
    super.dispose();
  }


  void _showGlobalSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final screenSize = MediaQuery.of(dialogCtx).size;
        final isTablet = screenSize.shortestSide >= 600;
        final strings = AppStrings.of(dialogCtx);

        // 1. CONSUMER: Listens for Appwrite updates (like the "REQUESTED" state)
        return Consumer(
          builder: (context, ref, child) {
            final friendsState = ref.watch(friendsProvider);

            // 2. STATEFUL BUILDER: Allows instant text updates as you type
            return StatefulBuilder(
              builder: (context, setDialogState) {
                final query = searchController.text.trim();

                // Combine local friends and Appwrite search results
                final allKnownPlayers = <_SearchUser>[];

                // 1. Add Friends
                for (final friend in friendsState.friends) {
                  allKnownPlayers.add(_SearchUser(
                    id: friend.id,
                    name: friend.name,
                    level: friend.level,
                    isFriend: true,
                    isOnline: friend.isOnline,
                    isRequested: false,
                  ));
                }

                // 2. Add Appwrite Search Results
                for (final player in friendsState.searchResults) {
                  if (!allKnownPlayers.any((u) => u.id == player.id)) {
                    final hasSentRequest = friendsState.sentRequests.containsKey(player.id);
                    allKnownPlayers.add(_SearchUser(
                      id: player.id,
                      name: player.name,
                      level: player.level,
                      isFriend: false,
                      isOnline: player.isOnline,
                      isRequested: hasSentRequest,
                    ));
                  }
                }

                final matched = query.isEmpty
                    ? <_SearchUser>[]
                    : allKnownPlayers
                    .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();

                final matchedFriends = matched.where((u) => u.isFriend).toList();
                final matchedNonFriends = matched.where((u) => !u.isFriend).toList();

                return PopDialog(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 640 : 520,
                        maxHeight: screenSize.height * 0.85,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.accent(context).withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    strings.mpSearchTitle,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(dialogCtx),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.textPrimary(context).withValues(alpha: 0.25),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textPrimary(context),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: searchController,
                              autofocus: true,
                              autofillHints: null,
                              keyboardType: TextInputType.text,
                              enableSuggestions: false,
                              autocorrect: false,
                              textInputAction: TextInputAction.search,
                              onChanged: (val) {
                                setDialogState(() {}); // Updates text instantly

                                // Debounce Appwrite Search
                                _searchDebounce?.cancel();
                                _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                                  if (val.trim().isNotEmpty) {
                                    ref.read(friendsProvider.notifier).searchUsers(val.trim());
                                  }
                                });
                              },
                              style: TextStyle(color: AppColors.textPrimary(context)),
                              decoration: InputDecoration(
                                hintText: strings.mpSearchHint,
                                prefixIcon: friendsState.isSearching
                                    ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                                    : const Icon(Icons.search_rounded),
                                filled: true,
                                fillColor: AppColors.background(context),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: query.isEmpty
                                  ? const SizedBox.shrink()
                                  : matched.isEmpty && !friendsState.isSearching
                                  ? const SizedBox.shrink()
                                  : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (matchedFriends.isNotEmpty) ...[
                                      _buildSectionHeader(context, strings.mpFriendsSection),
                                      const SizedBox(height: 8),
                                      ...matchedFriends.map((user) =>
                                          _buildUserTile(context, user, isFriendSection: true)),
                                      const SizedBox(height: 16),
                                    ],
                                    if (matchedNonFriends.isNotEmpty) ...[
                                      _buildSectionHeader(context, strings.mpOtherPlayersSection),
                                      const SizedBox(height: 8),
                                      ...matchedNonFriends.map((user) =>
                                          _buildUserTile(context, user, isFriendSection: false)),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.accent(context),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, _SearchUser user, {required bool isFriendSection}) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textSecondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.15),
            radius: 18,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                ),
                Text(
                  strings.trophiesLevelBadge(user.level),
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          if (isFriendSection) ...[
            IconButton(
              icon: Icon(Icons.chat_bubble_outline_rounded, color: accent, size: 20),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendChatScreen(
                      friend: FriendModel(
                        id: user.id,
                        name: user.name,
                        level: user.level,
                        isOnline: user.isOnline,
                        friendshipId: '',
                      ),
                    ),
                  ),
                );
              },
            ),
          ] else if (user.isRequested) ...[
            // 👈 UI FOR CANCELING A SENT REQUEST
            ElevatedButton(
              onPressed: () {
                AudioHapticHelper.playClick();
                ref.read(friendsProvider.notifier).cancelSentRequest(user.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: const Text('CANCEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            // 👈 UI FOR NEW ADD FRIEND
            ElevatedButton(
              onPressed: () {
                AudioHapticHelper.playClick();
                ref.read(friendsProvider.notifier).sendRequestToUser(
                  user.id,
                  user.name,
                  user.level,
                );
                // No need for a snackbar anymore, the UI updates instantly!
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('ADD FRIEND', style: TextStyle(fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.background(context);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    final progress = ref.watch(progressRepositoryProvider);
    final auth = ref.watch(authServiceProvider);
    final int localLevel = progress.currentLevel;


    final isInMatch = ref.watch(challengeProvider.select((s) => s.isInMatch));


    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop();
          }
        },
        child: ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              final isGuest = auth.isGuest;
              final isLocked = isGuest || isInMatch;

              return Scaffold(
                backgroundColor: bg,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                AudioHapticHelper.playClick();
                                Navigator.maybePop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.35),
                                    width: 1.2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: accent,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                strings.mpTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _showGlobalSearchDialog,
                              icon: Icon(Icons.search_rounded, color: accent,
                                  size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            strings.mpSubtitle,
                            style: TextStyle(
                                fontSize: 14, color: textSecondary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cardShadow(context),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  image: auth.avatarUrl != null &&
                                      auth.avatarUrl!.isNotEmpty
                                      ? DecorationImage(
                                    image: NetworkImage(auth.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: auth.avatarUrl == null ||
                                    auth.avatarUrl!.isEmpty
                                    ? Center(
                                  child: Text(
                                    auth.avatarInitial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auth.displayName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      strings.mpCampaignLevel(localLevel),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          strings.mpSelectMode,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        IgnorePointer(
                          ignoring: isLocked,
                          // Blocks ALL taps if guest or in match
                          child: Opacity(
                            opacity: isLocked ? 0.5 : 1.0,
                            child: MpModeCard(
                              title: strings.mpRandomMatch,
                              // Change text if guest
                              subtitle: isGuest
                                  ? 'Sign in / Sign up to play'
                                  : strings.mpRandomMatchSub,
                              badgeText: isGuest ? 'LOCKED' : 'SKILL MATCH',
                              badgeColor: isGuest ? Colors.grey : accent,
                              icon: isGuest ? Icons.lock_rounded : Icons
                                  .shuffle_rounded,
                              color: isGuest ? Colors.grey : accent,
                              onTap: () {
                                AudioHapticHelper.playClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (
                                      _) => const RandomMatchScreen()),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 👈 UPDATED: Challenge Friend Card
                        IgnorePointer(
                          ignoring: isLocked,
                          // Blocks ALL taps if guest or in match
                          child: Opacity(
                            opacity: isLocked ? 0.5 : 1.0,
                            child: MpModeCard(
                              title: strings.mpChallengeFriend,
                              // Change text if guest
                              subtitle: isGuest
                                  ? 'Sign in / Sign up to challenge friends'
                                  : strings.mpChallengeFriendSub,
                              badgeText: isGuest ? 'LOCKED' : 'UNRESTRICTED',
                              badgeColor: isGuest ? Colors.grey : const Color(
                                  0xFF00C853),
                              icon: isGuest ? Icons.lock_rounded : Icons
                                  .people_alt_rounded,
                              color: isGuest ? Colors.grey : const Color(
                                  0xFF00C853),
                              hasUnread: !isGuest && ref.watch(
                                  friendsProvider.select((s) =>
                                  s
                                      .unreadFriendIds.isNotEmpty)),
                              onTap: () {
                                AudioHapticHelper.playClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (
                                      _) => const FriendMatchScreen()),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            }
            )
    );
  }
}

class _SearchUser {
  final String id;
  final String name;
  final int level;
  final bool isFriend;
  final bool isOnline;
  final bool isRequested;

  _SearchUser({
    required this.id,
    required this.name,
    required this.level,
    required this.isFriend,
    required this.isOnline,
    required this.isRequested,
  });
}