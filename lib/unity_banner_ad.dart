import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityBannerAdWidget extends StatelessWidget {
  final String placementId;
  final double height;

  const UnityBannerAdWidget({
    super.key,
    required this.placementId,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: UnityBannerAd(
        placementId: placementId,
        onLoad: (id) => debugPrint('Banner loaded: $id'),
        onFailed: (id, error, message) =>
            debugPrint('Banner failed: $id · $error · $message'),
        onShown: (id) => debugPrint('Banner shown: $id'),
        onClick: (id) => debugPrint('Banner clicked: $id'),
      ),
    );
  }
}