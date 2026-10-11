import 'package:arrow_puzzle/core/sfx_player.dart';
import 'package:flutter/services.dart';

class AudioHapticHelper {
  static bool hapticsEnabled = true;

  static void init() {}

  static void playClick() {
    SfxPlayer.instance.playUiTap();
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }

  static Future<void> playSuccess({int combo = 1, bool isLast = false}) async {
    if (!hapticsEnabled) return;
    if (isLast) {
      await HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 120), () => HapticFeedback.mediumImpact());
    } else if (combo >= 4) {
      await HapticFeedback.heavyImpact();
    } else if (combo >= 2) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> playFailure() async {
    if (hapticsEnabled) {
      await HapticFeedback.vibrate();
    }
  }
}
