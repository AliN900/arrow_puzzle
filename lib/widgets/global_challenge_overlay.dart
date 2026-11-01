import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../main.dart';
import '../../screens/multiplayer/mp_game_screen.dart';
import '../../screens/multiplayer/providers/challenge_provider.dart';
import '../../screens/multiplayer/models/mp_match_config.dart';

import '../l10n/app_localizations.dart';
import '../screens/multiplayer/widgets/mp_match_settings_dialog.dart';

class GlobalChallengeOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalChallengeOverlay({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  ConsumerState<GlobalChallengeOverlay> createState() => _GlobalChallengeOverlayState();
}

class _GlobalChallengeOverlayState extends ConsumerState<GlobalChallengeOverlay> {
  Challenger? _activeCaller;
  bool _isPopupOpen = false;
  bool _isDismissing = false;

  Offset _position = Offset.zero;
  Offset _savedPosition = Offset.zero;
  bool _isDragging = false;
  Duration _snapDuration = const Duration(milliseconds: 300);
  final double _bubbleSize = 72.0;
  final GlobalKey _popupKey = GlobalKey();

  void _handleIncomingCall(Challenger caller) {
    if (_activeCaller?.name == caller.name) return;
    setState(() {
      _activeCaller = caller;
      _isPopupOpen = false;
      _isDismissing = false;
      if (_savedPosition != Offset.zero) _position = _savedPosition;
    });
    AudioHapticHelper.playClick();
  }

  void _dismissOverlay() {
    setState(() {
      _isPopupOpen = false;
      _isDismissing = true;
    });
    ref.read(challengeProvider.notifier).declineIncomingCall();
  }

  void _acceptChallenge() async {
    final caller = _activeCaller;
    if (caller == null) return;

    setState(() {
      _isPopupOpen = false;
      _isDismissing = true;
    });

    // 1. Accept in Appwrite
    final opponent = await ref.read(challengeProvider.notifier).acceptIncomingCall();

    // 2. Show the Rules Screen using the navigatorKey to avoid the crash
    if (opponent != null && mounted) {
      final navContext = widget.navigatorKey.currentContext;
      if (navContext != null) {
        showDialog(
          context: navContext,
          barrierDismissible: false,
          builder: (ctx) => const MpMatchSettingsDialogWrapper(isHost: false),
        );
      }
    }
  }

  void _togglePopup() {
    if (_isPopupOpen) {
      setState(() {
        _isPopupOpen = false;
        _position = _savedPosition;
      });
    } else {
      setState(() => _isPopupOpen = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final box = _popupKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final offset = box.localToGlobal(Offset.zero);
          final size = box.size;
          setState(() {
            _savedPosition = _position;
            _position = Offset(
              offset.dx + (size.width / 2) - (_bubbleSize / 2),
              offset.dy - (_bubbleSize / 2) - 10,
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👈 LISTEN FOR INCOMING INVITES ONLY
    ref.listen<Challenger?>(challengeProvider.select((s) => s.incomingCaller), (prev, next) {
      if (next != null) {
        _handleIncomingCall(next);
      } else if (_activeCaller != null && !_isDismissing) {
        _dismissOverlay();
      }
    });

    // ❌ REMOVED THE CRASHING LISTENER HERE

    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenSize = MediaQuery.of(context).size;

    if (_position == Offset.zero && screenSize.width > 0) {
      _position = Offset(
        screenSize.width - _bubbleSize - 20,
        screenSize.height - _bubbleSize - 100,
      );
      _savedPosition = _position;
    }

    return Stack(
      children: [
        widget.child,
        if (_activeCaller != null && _isPopupOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePopup,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
        if (_activeCaller != null && _isPopupOpen)
          Center(child: _buildPopupCard(context, _activeCaller!)),
        if (_activeCaller != null)
          AnimatedPositioned(
            duration: _isDragging ? Duration.zero : _snapDuration,
            curve: Curves.easeOutCubic,
            left: _position.dx,
            top: _position.dy,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _isDismissing ? 0.0 : 1.0),
              duration: Duration(milliseconds: _isDismissing ? 250 : 400),
              curve: _isDismissing ? Curves.easeInBack : Curves.elasticOut,
              onEnd: () {
                if (_isDismissing) {
                  setState(() {
                    _activeCaller = null;
                    _isDismissing = false;
                  });
                }
              },
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: GestureDetector(
                onPanStart: (_) {
                  setState(() {
                    _isDragging = true;
                    _isPopupOpen = false;
                    _snapDuration = Duration.zero;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    final newY = (_position.dy + details.delta.dy).clamp(60.0, screenSize.height - _bubbleSize - 60.0);
                    _position = Offset(_position.dx + details.delta.dx, newY);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDragging = false;
                    _snapDuration = const Duration(milliseconds: 300);
                    const double edgeThreshold = 60.0;
                    double snapX = _position.dx;
                    if (_position.dx < edgeThreshold) {
                      snapX = -_bubbleSize * 0.5;
                    } else if (_position.dx > screenSize.width - _bubbleSize - edgeThreshold) {
                      snapX = screenSize.width - _bubbleSize * 0.5;
                    } else {
                      snapX = _position.dx.clamp(0.0, screenSize.width - _bubbleSize);
                    }
                    _position = Offset(snapX, _position.dy);
                    _savedPosition = _position;
                  });
                },
                onTap: () {
                  if (!_isDragging && !_isDismissing) _togglePopup();
                },
                child: _buildChatHeadContent(isTablet),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatHeadContent(bool isTablet) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _bubbleSize,
          height: _bubbleSize,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFF5252).withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: const Center(child: Icon(Icons.sports_mma_rounded, color: Colors.white, size: 36)),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
            child: Text('1', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: isTablet ? 14 : 12)),
          ),
        )
      ],
    );
  }

  Widget _buildPopupCard(BuildContext context, Challenger caller) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final textPrimary = AppColors.textPrimary(context);
    final strings = AppStrings.of(context);

    return Container(
      key: _popupKey,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 24),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00C853), width: 2.5),
        boxShadow: [BoxShadow(color: const Color(0xFF00C853).withValues(alpha: 0.2), blurRadius: 32)],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_rounded, size: isTablet ? 80 : 64, color: const Color(0xFF00C853)),
            SizedBox(height: isTablet ? 24 : 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(strings.mpMatchCall, style: TextStyle(fontSize: isTablet ? 32 : 24, fontWeight: FontWeight.w900, color: const Color(0xFF00C853), letterSpacing: 1.2)),
            ),
            SizedBox(height: isTablet ? 16 : 8),
            Text(strings.mpIsChallengingYou(caller.name, caller.level), textAlign: TextAlign.center, style: TextStyle(fontSize: isTablet ? 18 : 16, color: textPrimary, fontWeight: FontWeight.bold)),
            SizedBox(height: isTablet ? 32 : 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _dismissOverlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.15),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(strings.mpDecline, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isTablet ? 16 : 14)),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptChallenge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(strings.mpAccept, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isTablet ? 16 : 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MpMatchSettingsDialogWrapper extends ConsumerWidget {
  final bool isHost;
  const MpMatchSettingsDialogWrapper({super.key, required this.isHost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeProvider);
    final auth = ref.read(authServiceProvider);
    final progress = ref.read(progressRepositoryProvider);

    // 👈 1. If the other player cancels, close this popup automatically
    ref.listenManual(challengeProvider.select((s) => s.isMatchAccepted), (prev, next) {
      // 👈 Removed '&& mounted' because ConsumerWidget doesn't have it
      if (next == false) {
        // The challenge was cancelled or deleted by the other player
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });
      }
    });

    // 👈 2. Launch the game
    if (state.isLaunching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MpGameScreen(
              config: MpMatchConfig(
                hostId: isHost ? auth.userId! : state.matchOpponent?.id ?? 'guest',
                guestId: isHost ? state.matchOpponent?.id ?? 'guest' : auth.userId!,
                hostLevel: isHost ? progress.currentLevel : state.matchOpponent?.level ?? 1,
                guestLevel: isHost ? state.matchOpponent?.level ?? 1 : progress.currentLevel,
                difficulty: state.difficulty == 'easy' ? MpDifficulty.easy : state.difficulty == 'hard' ? MpDifficulty.hard : MpDifficulty.extreme,
                matchSeed: state.matchSeed,
              ),
              p1Name: isHost ? auth.displayName : state.matchOpponent?.name ?? 'Player',
              p2Name: isHost ? state.matchOpponent?.name ?? 'Player' : auth.displayName,
            ),
          ),
        );
      });
    }

    final p1Name = isHost ? auth.displayName : state.matchOpponent?.name ?? 'Player';
    final p1Level = isHost ? progress.currentLevel : state.matchOpponent?.level ?? 1;
    final p2Name = isHost ? state.matchOpponent?.name ?? 'Player' : auth.displayName;
    final p2Level = isHost ? state.matchOpponent?.level ?? 1 : progress.currentLevel;

    // 👈 3. Wrap in PopScope to catch the back button
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        ref.read(challengeProvider.notifier).cancelChallenge();
        // Navigator.pop(context);
      },
      child: MpMatchSettingsDialog(
        isLeader: isHost,
        p1Name: p1Name,
        p1Level: p1Level,
        p1Ready: state.p1Ready,
        p2Name: p2Name,
        p2Level: p2Level,
        p2Ready: state.p2Ready,
        selectedDifficulty: state.difficulty == 'easy' ? MpDifficulty.easy : state.difficulty == 'hard' ? MpDifficulty.hard : MpDifficulty.extreme,
        onDifficultyChanged: (diff) => ref.read(challengeProvider.notifier).updateDifficulty(diff.name, isHost),
        onToggleReady: () => ref.read(challengeProvider.notifier).toggleMatchReady(isHost),
        onStartMatch: () {
          if (state.p1Ready && state.p2Ready) ref.read(challengeProvider.notifier).startMatch(isHost);
        },
        onClose: () {
          ref.read(challengeProvider.notifier).cancelChallenge();
        },
      ),
    );
  }
}