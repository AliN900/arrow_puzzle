import 'package:flutter/material.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../core/audio_haptic_helper.dart';
import 'pop_dialog.dart';

class CustomPopDialog extends StatelessWidget {
  final String title;
  final String message;
  final Widget icon;

  /// Optional override. When null, falls back to the localized
  /// `strings.buttonCancel`.
  final String? cancelText;

  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const CustomPopDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.cancelText,
    required this.confirmText,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final bgColor = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    final resolvedCancelText = cancelText ?? strings.buttonCancel;

    return PopDialog(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      AudioHapticHelper.playClick();
                      // Pop the dialog with `false` FIRST, so the awaiting
                      // showDialog<bool> resolves correctly.
                      Navigator.pop(context, false);
                      // Then fire the callback for any side effects.
                      onCancel?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: textSecondary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      resolvedCancelText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      AudioHapticHelper.playClick();
                      // Pop with `true` FIRST.
                      Navigator.pop(context, true);
                      // Then fire the callback.
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
  }
}