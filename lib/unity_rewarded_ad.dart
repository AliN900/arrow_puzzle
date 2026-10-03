import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityRewardedAd {
  static String get _placementId => Platform.isAndroid
      ? 'BP_Rewarded_Android'
      : 'BP_Rewarded_iOS';

  static bool _isLoaded = false;
  static bool _isLoading = false;

  static void preload() {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;

    UnityAds.load(
      placementId: _placementId,
      onComplete: (id) {
        _isLoaded = true;
        _isLoading = false;
        debugPrint('✅ Rewarded loaded: $id');
      },
      onFailed: (id, error, message) {
        _isLoaded = false;
        _isLoading = false;
        debugPrint('❌ Rewarded load failed: $id · $error · $message');
      },
    );
  }

  static Future<void> show({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) async {
    if (!_isLoaded) {
      debugPrint('Rewarded not loaded — loading now...');
      UnityAds.load(
        placementId: _placementId,
        onComplete: (id) {
          _isLoaded = true;
          _isLoading = false;
          debugPrint('✅ Rewarded loaded (late): $id');
          _showNow(
            onRewarded: onRewarded,
            onDismissed: onDismissed,
            onFailed: onFailed,
          );
        },
        onFailed: (id, error, message) {
          _isLoaded = false;
          _isLoading = false;
          debugPrint('❌ Rewarded load failed: $id · $error · $message');
          onFailed?.call();
          onDismissed?.call();
        },
      );
      return;
    }

    _showNow(
      onRewarded: onRewarded,
      onDismissed: onDismissed,
      onFailed: onFailed,
    );
  }

  static void _showNow({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) {
    bool rewarded = false;

    UnityAds.showVideoAd(
      placementId: _placementId,
      onComplete: (id) {
        debugPrint('✅ Rewarded complete: $id');
        if (!rewarded) {
          rewarded = true;
          onRewarded();
        }
        _isLoaded = false;
        preload();
        onDismissed?.call();
      },
      onFailed: (id, error, message) {
        debugPrint('❌ Rewarded show failed: $id · $error · $message');
        _isLoaded = false;
        onFailed?.call();
        onDismissed?.call();
      },
      onSkipped: (id) {
        debugPrint('⚠️ Rewarded skipped: $id');
        _isLoaded = false;
        preload();
        onDismissed?.call();
      },
      onStart: (id) => debugPrint('▶️ Rewarded shown: $id'),
      onClick: (id) => debugPrint('👆 Rewarded clicked: $id'),
    );
  }
}