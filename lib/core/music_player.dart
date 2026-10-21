import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class MusicPlayer with WidgetsBindingObserver { // <-- Added mixin
  static final MusicPlayer instance = MusicPlayer._();

  MusicPlayer._() {
    // Register the observer globally
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioPlayer _player = AudioPlayer();
  String? _currentTrack;
  bool _isPlaying = false;

  double _targetVolume = 0.4;
  bool _isMuted = false;

  Timer? _fadeTimer;
  double _currentVolume = 0.0;
  static const int _fadeDurationMs = 1000;
  static const int _fadeSteps = 20;

  // ── THE FIX: Max volume is 50% of the raw audio file ──
  static const double _maxVolumeMultiplier = 0.5;

  static const String trackMenu = 'audio/music/caller_main_menu.WAV';
  static const String trackClassic = 'audio/music/Cleyton RX_Underwater_main_level.WAV';
  static const String trackRush = 'audio/music/austeritys_friend_-_06_groove_of_timeatk_rushmode.WAV';

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0);
  }

  void setVolume(double volume) {
    _targetVolume = volume.clamp(0.0, 1.0);
    if (_isPlaying && !_isMuted) {
      _fadeTimer?.cancel();
      _fadeTimer = null;
      _currentVolume = _targetVolume;
      _player.setVolume(_currentVolume * _maxVolumeMultiplier);
    }
  }

  Future<void> play(String trackPath) async {
    if (_currentTrack == trackPath && _isPlaying) return;

    _isPlaying = true;

    if (_currentTrack != null && _currentVolume > 0) {
      await _fadeOut();
    }

    _currentTrack = trackPath;
    try {
      await _player.stop();
      await _player.play(AssetSource(trackPath));
      _currentVolume = 0.0;
      await _player.setVolume(0);
      _fadeIn();
    } catch (e) {
      debugPrint('🔴 Music error: $e');
    }
  }

  Future<void> stop() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    await _fadeOut();
    await _player.stop();
    _currentTrack = null;
  }

  // ── NEW: Pause & Resume methods ──
  void pause() {
    if (_isPlaying) {
      _player.pause();
    }
  }

  void resume() {
    if (_isPlaying) {
      _player.resume();
    }
  }

  // ── NEW: Handle App Lifecycle globally ──
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App went to background, screen locked, or notification pulled down
      pause();
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      resume();
    }
  }

  void toggleMute(bool isMuted) {
    _isMuted = isMuted;
    if (_isMuted) {
      _fadeTimer?.cancel();
      _fadeTimer = null;
      _player.setVolume(0);
      _currentVolume = 0;
    } else {
      _fadeIn();
    }
  }

  void _fadeIn() {
    _fadeTimer?.cancel();
    if (_isMuted) return;

    final stepTime = _fadeDurationMs ~/ _fadeSteps;
    final stepVolume = _targetVolume / _fadeSteps;

    _fadeTimer = Timer.periodic(Duration(milliseconds: stepTime), (timer) {
      _currentVolume += stepVolume;
      if (_currentVolume >= _targetVolume) {
        _currentVolume = _targetVolume;
        _player.setVolume(_currentVolume * _maxVolumeMultiplier);
        timer.cancel();
        _fadeTimer = null;
      } else {
        _player.setVolume(_currentVolume * _maxVolumeMultiplier);
      }
    });
  }

  Future<void> _fadeOut() async {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    if (_currentVolume <= 0) {
      await _player.setVolume(0);
      return;
    }

    final startVol = _currentVolume;
    final stepTime = _fadeDurationMs ~/ _fadeSteps;
    final stepVolume = startVol / _fadeSteps;
    final completer = Completer<void>();

    _fadeTimer = Timer.periodic(Duration(milliseconds: stepTime), (timer) {
      _currentVolume -= stepVolume;
      if (_currentVolume <= 0) {
        _currentVolume = 0;
        _player.setVolume(0);
        timer.cancel();
        _fadeTimer = null;
        if (!completer.isCompleted) completer.complete();
      } else {
        _player.setVolume(_currentVolume * _maxVolumeMultiplier);
      }
    });

    return completer.future;
  }
}