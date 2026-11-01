import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../main.dart';
import '../../services/appwrite_service.dart';
import '../../widgets/global_challenge_overlay.dart';
import '../../widgets/pop_dialog.dart';
import '../../widgets/status_flash.dart';
import 'providers/challenge_provider.dart';

class RandomMatchScreen extends ConsumerStatefulWidget {
  const RandomMatchScreen({super.key});
  @override
  ConsumerState<RandomMatchScreen> createState() => _RandomMatchScreenState();
}

class _RandomMatchScreenState extends ConsumerState<RandomMatchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _globeController;
  bool _isSearching = false;
  int _searchCountdown = 30;
  Timer? _searchCountdownTimer;

  @override
  void initState() {
    super.initState();
    _globeController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengeProvider.notifier).initAppwrite(
        AppwriteService.tablesDb, Realtime(AppwriteService.client),
        ref.read(authServiceProvider).userId ?? 'guest',
        ref.read(authServiceProvider).displayName,
        ref.read(progressRepositoryProvider).currentLevel,
      );
    });
  }

  @override
  void dispose() {
    _searchCountdownTimer?.cancel();
    _globeController.dispose();
    super.dispose();
  }

  void _startChallenge(Challenger target) {
    ref.read(challengeProvider.notifier).sendChallenge(target);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(challengeProvider);
            final strings = AppStrings.of(context);

            // If accepted, close this and open rules
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

            // If cancelled or declined, close this dialog safely
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
                      strings.mpWaitingFor(target.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        AudioHapticHelper.playClick();
                        // 👈 ONLY cancel the challenge. The Consumer above handles popping the dialog.
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

  void _startRandomSearch() {
    final challengeNotifier = ref.read(challengeProvider.notifier);
    final challengeState = ref.read(challengeProvider);
    final strings = AppStrings.of(context);

    if (challengeState.availablePlayers.isNotEmpty) {
      final target = challengeState.availablePlayers.first;
      _startChallenge(target); // 👈 Use _startChallenge here
      return;
    }

    if (!challengeState.isReady) {
      challengeNotifier.toggleReady(true);
    }

    setState(() {
      _isSearching = true;
      _searchCountdown = 30;
    });
    _globeController.repeat();

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

            _searchCountdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (_searchCountdown > 1) {
                setDialogState(() => _searchCountdown--);
                final currentPlayers = ref.read(challengeProvider).availablePlayers;
                if (currentPlayers.isNotEmpty) {
                  timer.cancel();
                  _searchCountdownTimer = null;
                  if (!mounted) return;
                  setState(() => _isSearching = false);
                  _globeController.stop();
                  Navigator.pop(dialogCtx, true);
                  _startChallenge(currentPlayers.first); // 👈 Use _startChallenge here
                }
              } else {
                timer.cancel();
                _searchCountdownTimer = null;
                if (!mounted) return;
                setState(() => _isSearching = false);
                _globeController.stop();
                Navigator.pop(dialogCtx, false);
                StatusFlash.fail(context, strings.mpNoPlayersFound);
              }
            });

            return PopDialog(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 24),
                padding: EdgeInsets.all(isTablet ? 48 : 32),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.accent(context).withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _globeController,
                      child: Icon(Icons.public_rounded, size: isTablet ? 96 : 64, color: AppColors.accent(context)),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.mpSearching,
                        style: TextStyle(fontSize: isTablet ? 24 : 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_searchCountdown${strings.unitSeconds}',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _searchCountdownTimer?.cancel();
                          _searchCountdownTimer = null;
                          _globeController.stop();
                          setState(() => _isSearching = false);
                          Navigator.pop(dialogCtx, false);
                        },
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
    ).then((result) {
      _searchCountdownTimer?.cancel();
      _searchCountdownTimer = null;
      _globeController.stop();
      if (mounted) setState(() => _isSearching = false);
    });
  }

  Widget _buildSquareFindButton({ required BuildContext context, required bool isTablet }) {
    final isInMatch = ref.watch(challengeProvider.select((s) => s.isInMatch));
    final accent = AppColors.accent(context);
    final cardBg = AppColors.surface(context);
    final double btnSize = isTablet ? 115.0 : 96.0;
    final strings = AppStrings.of(context);

    return GestureDetector(
        onTap: (isInMatch || _isSearching) ? null : () {
          AudioHapticHelper.playClick();
          _startRandomSearch();
        },
        child: Opacity(
          opacity: isInMatch ? 0.5 : 1.0, // 👈 NEW: Visual feedback
          child: Container(
        width: btnSize,
        height: btnSize,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent, width: 2.5),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shuffle_rounded, size: isTablet ? 32 : 26, color: accent),
              const SizedBox(height: 4),
              FittedBox(fit: BoxFit.scaleDown, child: Text(strings.mpBtnRandom, style: TextStyle(fontSize: isTablet ? 12 : 10, fontWeight: FontWeight.w900, color: accent, letterSpacing: 0.8))),
              FittedBox(fit: BoxFit.scaleDown, child: Text(strings.mpBtnMatch, style: TextStyle(fontSize: isTablet ? 11 : 9, fontWeight: FontWeight.w900, color: AppColors.textPrimary(context), letterSpacing: 0.5))),
            ],
          ),
        ),
          ),
        ),

    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.background(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final challengeState = ref.watch(challengeProvider);
    final challengeNotifier = ref.read(challengeProvider.notifier);

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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () { AudioHapticHelper.playClick(); Navigator.pop(context); },
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 14 : 10),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, color: accent, size: isTablet ? 28 : 20),
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 14),
                        Expanded(
                          child: Text(strings.mpRandomMatch, style: TextStyle(fontSize: isTablet ? 28 : 22, fontWeight: FontWeight.w900, color: textPrimary)),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 32 : 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        color: challengeState.isReady ? const Color(0xFF00C853).withValues(alpha: 0.1) : AppColors.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: challengeState.isReady ? const Color(0xFF00C853) : textSecondary.withValues(alpha: 0.2), width: challengeState.isReady ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sensors_rounded, size: isTablet ? 36 : 28, color: challengeState.isReady ? const Color(0xFF00C853) : textSecondary),
                          SizedBox(width: isTablet ? 20 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(strings.mpListAsReady, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isTablet ? 20 : 16, color: textPrimary)),
                                const SizedBox(height: 4),
                                Text(challengeState.isReady ? strings.mpVisibleLobby : strings.mpHiddenLobby, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isTablet ? 14 : 12, color: textSecondary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: isTablet ? 1.3 : 1.0,
                            child: Switch(
                              value: challengeState.isReady,
                              activeThumbColor: Colors.white,
                              activeTrackColor: const Color(0xFF00C853),
                              // 👈 NEW: Disable if in match
                              onChanged: isInMatch ? null : (val) {
                                AudioHapticHelper.playClick();
                                challengeNotifier.toggleReady(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    Text(strings.mpChallengersNearby, style: TextStyle(fontSize: isTablet ? 20 : 16, fontWeight: FontWeight.w800, color: textSecondary)),
                    SizedBox(height: isTablet ? 16 : 12),
                    Expanded(
                      child: challengeState.availablePlayers.isEmpty
                          ? Center(child: Text(strings.mpNoPlayersFound, textAlign: TextAlign.center, style: TextStyle(color: textSecondary)))
                          : ListView.builder(
                        padding: EdgeInsets.only(bottom: isTablet ? 120 : 100),
                        itemCount: challengeState.availablePlayers.length,
                        itemBuilder: (context, index) {
                          final player = challengeState.availablePlayers[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: isTablet ? 16 : 10),
                            padding: EdgeInsets.all(isTablet ? 16 : 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: textSecondary.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: isTablet ? 24 : 18,
                                  backgroundColor: accent.withValues(alpha: 0.15),
                                  child: Text(player.name.isNotEmpty ? player.name[0].toUpperCase() : '?', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 14)),
                                ),
                                SizedBox(width: isTablet ? 16 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(player.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 18 : 14, color: textPrimary)),
                                      Text(strings.trophiesLevelBadge(player.level), style: TextStyle(fontSize: isTablet ? 14 : 12, color: textSecondary)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: isInMatch ? null : () {
                                    AudioHapticHelper.playClick();
                                    _startChallenge(player);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 12 : 8),
                                  ),
                                  child: Text(strings.mpChallengeBtn, style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: isTablet ? 30 : 16,
                bottom: isTablet ? 30 : 16,
                child: _buildSquareFindButton(context: context, isTablet: isTablet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}