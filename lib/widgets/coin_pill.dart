import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../main.dart';

class CoinPill extends ConsumerWidget {
  final VoidCallback? onTap;

  const CoinPill({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsRepositoryProvider).coins;
    const coinYellow = Color(0xFFFFD54F);

    return GestureDetector(
      onTap: onTap,
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
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: coinYellow,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '¢',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5D4A1A),
                  ),
                ),
              ),
            ),
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