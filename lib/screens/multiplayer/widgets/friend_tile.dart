import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/audio_haptic_helper.dart';
import '../../../l10n/app_localizations.dart';

class FriendTile extends StatelessWidget {
  final String name;
  final int level;
  final bool isOnline;
  final bool hasUnread;
  final VoidCallback onInvite;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final bool showActions;

  const FriendTile({
    super.key,
    required this.name,
    required this.level,
    required this.isOnline,
    this.hasUnread = false,
    required this.onInvite,
    required this.onRemove,
    required this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);
    final strings = AppStrings.of(context);

    final Color statusColor = isOnline ? const Color(0xFF00C853) : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasUnread ? Colors.green.withValues(alpha: 0.5) : textSecondary.withValues(alpha: 0.15), // Highlight border if unread
            width: hasUnread ? 1.5 : 1.2,
          ),
        ),
        child: Column(
          children: [
            // ── Top Row: Avatar & Info ──
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.mpCampaignLevel(level),
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 👈 REPLACED CHAT ICON WITH BIG GREEN DOT
                if (hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E676),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6600E676), // Glowing effect
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),

            // ── Bottom Action Buttons Row (Optional) ──
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          AudioHapticHelper.playClick();
                          onInvite();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          strings.mpBtnInvite,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () {
                          AudioHapticHelper.playClick();
                          onRemove();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          side: BorderSide(
                            color: Colors.red.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          strings.buttonRemove,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}