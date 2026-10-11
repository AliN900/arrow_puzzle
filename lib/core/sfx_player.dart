import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Lightweight sound-effect player. Uses a 3-slot pool so overlapping sounds
/// (e.g. rapid arrow clears) don't cut each other off.
class SfxPlayer {
  SfxPlayer._();
  static final SfxPlayer instance = SfxPlayer._();

  static const String _clear = 'audio/sfx/arrow_clear.wav';
  static const String _blocked = 'audio/sfx/arrow_blocked.wav';
  static const String _uiTap = 'audio/sfx/ui_tap.wav';

  final List<AudioPlayer> _pool = List.generate(3, (_) => AudioPlayer());
  int _index = 0;
  bool _enabled = true;
  bool _initialized = false;
  double _volume = 0.7;

  void setVolume(double v) => _volume = v.clamp(0.0, 1.0);

  Future<void> init() async {
    for (final p in _pool) {
      try {
        await p.setPlayerMode(PlayerMode.lowLatency);
      } catch (e) {
        debugPrint('SfxPlayer: lowLatency failed, falling back — $e');
        try {
          await p.setPlayerMode(PlayerMode.mediaPlayer);
        } catch (_) {}
      }
      try {
        await p.setReleaseMode(ReleaseMode.stop);
      } catch (_) {}
    }
    _initialized = true;
  }

  /// Wire this to the Sound Effects toggle in Settings.
  void setEnabled(bool value) => _enabled = value;

  Future<void> _play(String asset, {double volume = 0.55}) async {
    if (!_enabled || !_initialized) return;
    try {
      final p = _pool[_index];
      _index = (_index + 1) % _pool.length;
      await p.stop();
      await p.play(AssetSource(asset), volume: volume * _volume);
    } catch (e) {
      debugPrint('SfxPlayer: $asset failed — $e');
    }
  }

  Future<void> playArrowClear() => _play(_clear, volume: 0.5);
  Future<void> playArrowBlocked() => _play(_blocked, volume: 0.55);
  Future<void> playUiTap() => _play(_uiTap, volume: 0.4);
}