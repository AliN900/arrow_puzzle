import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/audio_haptic_helper.dart';
import '../../../../widgets/pop_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../models/mp_match_config.dart';
import 'mp_diagonal_player_card.dart';

class MpMatchSettingsDialog extends StatefulWidget {
  final bool isLeader;
  final String p1Name;
  final int p1Level;
  final bool p1Ready;
  final String p2Name;
  final int p2Level;
  final bool p2Ready;
  final MpDifficulty selectedDifficulty;
  final ValueChanged<MpDifficulty> onDifficultyChanged;
  final VoidCallback onToggleReady;
  final VoidCallback onStartMatch;
  final VoidCallback? onClose;

  const MpMatchSettingsDialog({
    super.key,
    required this.isLeader,
    required this.p1Name,
    required this.p1Level,
    required this.p1Ready,
    required this.p2Name,
    required this.p2Level,
    required this.p2Ready,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.onToggleReady,
    required this.onStartMatch,
    this.onClose,
  });

  @override
  State<MpMatchSettingsDialog> createState() => _MpMatchSettingsDialogState();
}

class _MpMatchSettingsDialogState extends State<MpMatchSettingsDialog> {
  void _handleClose(BuildContext context) {
    AudioHapticHelper.playClick();
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    final surface = isDark ? const Color(0xFF1E1E1E) : cs.surface;
    final onSurface = cs.onSurface;
    final textMuted = onSurface.withValues(alpha: 0.54);
    final textSubtle = onSurface.withValues(alpha: 0.38);
    final textDim = onSurface.withValues(alpha: 0.70);
    final outlineFaint = onSurface.withValues(alpha: 0.15);
    final fillFaint = onSurface.withValues(alpha: 0.05);
    final cardFillAlpha = isDark ? 0.08 : 0.12;
    final cardBorderAlpha = isDark ? 0.35 : 0.45;

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    final maxDialogWidth = isTablet ? screenSize.width * 0.85 : screenSize.width * 0.97;
    final maxDialogHeight = screenSize.height * 0.95;

    final outerMargin = isTablet ? 20.0 : 6.0;
    final innerPadding = isTablet ? 32.0 : 20.0;
    final titleSize = isTablet ? 32.0 : 26.0;
    final closeIconSize = isTablet ? 32.0 : 26.0;
    final vsFontSize = isTablet ? 24.0 : 20.0;
    final btnHeight = isTablet ? 72.0 : 64.0;
    final btnFontSize = isTablet ? 20.0 : 18.0;
    final avatarRadius = isTablet ? 28.0 : 22.0;
    final sectionGap = isTablet ? 24.0 : 18.0;
    final labelSize = isTablet ? 14.0 : 12.0;
    final diffTileHeight = isTablet ? 96.0 : 76.0;

    // 👈 NEW BUTTON LOGIC
    final bool isHost = widget.isLeader;
    final bool iAmReady = isHost ? widget.p1Ready : widget.p2Ready;
    final bool bothReady = widget.p1Ready && widget.p2Ready;

    String buttonText;
    VoidCallback? onButtonPressed;
    Color buttonColor = accent;

    if (!iAmReady) {
      buttonText = 'READY';
      onButtonPressed = widget.onToggleReady;
      buttonColor = const Color(0xFF00C853);
    } else if (!bothReady) {
      buttonText = 'WAITING...';
      onButtonPressed = null;
      buttonColor = textSubtle;
    } else {
      if (isHost) {
        buttonText = 'START MATCH';
        onButtonPressed = widget.onStartMatch;
      } else {
        buttonText = 'WAITING FOR HOST...';
        onButtonPressed = null;
        buttonColor = textSubtle;
      }
    }

    return PopDialog(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxDialogWidth, maxHeight: maxDialogHeight),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: outerMargin, vertical: outerMargin),
              padding: EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: accent.withValues(alpha: 0.5), width: 2.5),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.18), blurRadius: 32)],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(strings.mpMatchRules, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: onSurface, letterSpacing: 0.5)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _handleClose(context),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 8 : 6),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: textDim.withValues(alpha: 0.35), width: 2.5)),
                            child: Icon(Icons.close_rounded, color: textDim, size: closeIconSize * 0.95),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth * 0.72;
                        final cutSize = (cardWidth * 0.18).clamp(38.0, 60.0);

                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: cardWidth,
                                child: MpDiagonalPlayerCard(
                                  name: widget.p1Name, subtitle: 'Level ${widget.p1Level}',
                                  isReady: widget.p1Ready, color: const Color(0xFF00C853),
                                  avatarRadius: avatarRadius, padH: isTablet ? 28 : 12, padV: isTablet ? 20 : 6,
                                  cutSize: cutSize, cutCorner: MpCardCutCorner.bottomRight,
                                  fillAlpha: cardFillAlpha, borderAlpha: cardBorderAlpha, onSurface: onSurface,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 6),
                              child: Text(strings.mpVs, style: TextStyle(fontSize: vsFontSize, fontWeight: FontWeight.w900, color: textSubtle, letterSpacing: 2.0)),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: cardWidth,
                                child: MpDiagonalPlayerCard(
                                  name: widget.p2Name, subtitle: 'Level ${widget.p2Level}',
                                  isReady: widget.p2Ready, color: const Color(0xFFFF5252),
                                  avatarRadius: avatarRadius, padH: isTablet ? 18 : 12, padV: isTablet ? 20 : 6,
                                  cutSize: cutSize, cutCorner: MpCardCutCorner.topLeft,
                                  fillAlpha: cardFillAlpha, borderAlpha: cardBorderAlpha, onSurface: onSurface,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: sectionGap),

                    if (widget.isLeader) ...[
                      Text(strings.mpDifficultySetting, style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w800, color: textMuted, letterSpacing: 1.5)),
                      const SizedBox(height: 10),
                      Row(
                        children: MpDifficulty.values.map((diff) {
                          final selected = diff == widget.selectedDifficulty;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () { AudioHapticHelper.playClick(); widget.onDifficultyChanged(diff); },
                                child: Container(
                                  height: diffTileHeight,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: selected ? accent : fillFaint,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: selected ? accent : outlineFaint, width: selected ? 2.0 : 1.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(diff.name.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: selected ? Colors.white : textDim, letterSpacing: 0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: sectionGap),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: btnHeight,
                      child: ElevatedButton(
                        onPressed: onButtonPressed == null ? null : () { AudioHapticHelper.playClick(); onButtonPressed!(); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(buttonText, style: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}