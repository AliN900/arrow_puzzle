import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/audio_haptic_helper.dart';
import '../main.dart';
import 'coin_icon.dart';

class CoinPill extends ConsumerWidget {
  final VoidCallback? onTap;

  const CoinPill({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsRepositoryProvider).coins;
    const coinYellow = Color(0xFFFFD54F);

    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
        AudioHapticHelper.playClick();
        onTap!();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: coinYellow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: coinYellow.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoinIcon(size: 20),
            const SizedBox(width: 8),
            Text(
              '$coins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}