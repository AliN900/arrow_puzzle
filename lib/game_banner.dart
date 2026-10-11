import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

/// Unity Ads banner wrapper. Reserves its full height from the first build
/// so the game board never re-lays-out when the ad loads. Fades the ad in
/// when it arrives, and shows a blank area if it fails.
class GameBanner extends StatefulWidget {
  final String placementId;
  final double height;

  const GameBanner({
    super.key,
    this.placementId = 'BP_Banner_Android',
    this.height = 50,
  });

  @override
  State<GameBanner> createState() => _GameBannerState();
}

class _GameBannerState extends State<GameBanner> {
  bool _loaded = false;
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    // Height is constant — never changes when the ad loads or fails.
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: _failed
          ? const SizedBox.shrink()
          : AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        opacity: _loaded ? 1.0 : 0.0,
        child: UnityBannerAd(
          placementId: widget.placementId,
          onLoad: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onFailed: (_, _, _) {
            if (mounted) setState(() => _failed = true);
          },
          onClick: (_) {},
        ),
      ),
    );
  }
}