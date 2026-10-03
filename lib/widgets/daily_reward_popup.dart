import 'package:flutter/material.dart';
import 'daily_reward_card.dart';

class DailyRewardPopup extends StatelessWidget {
  const DailyRewardPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: DailyRewardCard(
          showDismissButton: true,
          onDone: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}