import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/board_themes.dart';
import '../../core/music_player.dart';
import '../../core/rush_difficulty.dart';
import '../../core/sfx_player.dart';
import '../models/level_result.dart';
import '../../core/constants.dart';
import '../../core/app_themes.dart';
import '../../core/audio_haptic_helper.dart';
import '../models/trophy.dart';

class ProgressRepository extends ChangeNotifier {
  late Box _box;
  late Box _resultsBox;
  int _lives = AppConstants.maxLives;
  int _currentLevel = 1;
  int _highestUnlockedLevel = 1;
  GameTheme _selectedTheme = GameTheme.classic;
  bool _skinsUnlocked = false;
  bool _hapticsEnabled = true;
  bool _heartRemover = false;
  bool _assistMode = false;
  bool _complexPaths = false;
  bool _soundEnabled = true;
  String _languageCode = 'system';
  bool _musicEnabled = true;
  double _soundVolume = 0.5;
  int _arrowSpeed = 0;
  int _rushDifficultyIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = const Color(0xFF6C4CF1);
  BoardTheme _selectedBoard = BoardTheme.minimal;
  final Map<int, LevelResult> _levelResults = {};
  final Set<String> _newBoards = {};        // red dot shown until user views
  final Set<String> _celebratedBoards = {}; // celebration already shown
  final Set<String> _purchasedBoards = {};
  final Set<String> _purchasedArrows = {};
  int _itemsGrantedFromStars = 0;
  bool _privacyAccepted = false;
  double _musicVolume = 0.4;

  DateTime? _lastSettingsModified;


  // ── Leaderboard ──
  bool _leaderboardOptIn = true;
  int _lbWeeklyScore = 0;
  int _lbMonthlyScore = 0;
  int _lbAllTimeScore = 0;
  DateTime? _lbWeeklyPeriodStart;
  DateTime? _lbMonthlyPeriodStart;
  DateTime? _lbWeeklyReachedAt;
  DateTime? _lbMonthlyReachedAt;


  int get lives => _lives;
  int get maxLives => AppConstants.maxLives;
  int get currentLevel => _currentLevel;
  int get highestUnlockedLevel => _highestUnlockedLevel;
  bool get hasLives => _lives > 0;
  bool get livesAreFull => _lives >= AppConstants.maxLives;
  GameTheme get selectedTheme => _selectedTheme;
  bool get skinsUnlocked => _skinsUnlocked;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get heartRemover => _heartRemover;
  bool get assistMode => _assistMode;
  bool get complexPaths => _complexPaths;
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  BoardTheme get selectedBoard => _selectedBoard;
  // NEW GETTERS (used by SettingsScreen)
  bool get soundEnabled => _soundEnabled;
  String get languageCode => _languageCode;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  int get arrowSpeed => _arrowSpeed;
  bool get privacyAccepted => _privacyAccepted;
  double get musicVolume => _musicVolume;


  bool get leaderboardOptIn => _leaderboardOptIn;
  int get lbWeeklyScore => _lbWeeklyScore;
  int get lbMonthlyScore => _lbMonthlyScore;
  int get lbAllTimeScore => _lbAllTimeScore;
  DateTime? get lbWeeklyPeriodStart => _lbWeeklyPeriodStart;
  DateTime? get lbMonthlyPeriodStart => _lbMonthlyPeriodStart;
  DateTime? get lbWeeklyReachedAt => _lbWeeklyReachedAt;
  DateTime? get lbMonthlyReachedAt => _lbMonthlyReachedAt;

  bool get isLeaderboardUnlocked =>
      isTrophyUnlocked('leaderboard_legend');

  /// Progress toward the unlock, 0.0–1.0. Returns 1.0 once unlocked.
  double get leaderboardUnlockProgress {
    if (isLeaderboardUnlocked) return 1.0;
    const target = 1000;
    return (_lbAllTimeScore / target).clamp(0.0, 1.0);
  }

  int get leaderboardUnlockTarget => 1000;

  int get totalStars =>
      _levelResults.values.fold(0, (sum, r) => sum + r.stars);



  RushDifficulty get rushDifficulty => RushDifficulty.values[
  _rushDifficultyIndex.clamp(0, RushDifficulty.values.length - 1)];

  bool isRushDifficultyUnlocked(RushDifficulty d) =>
      _highestUnlockedLevel >= d.unlockLevel;
  int getStarsForLevel(int level) => _levelResults[level]?.stars ?? 0;
  bool isLevelUnlocked(int level) {
    return level <= _highestUnlockedLevel;
  }
  bool isLevelCompleted(int level) => _levelResults.containsKey(level);
  Set<String> get newBoards => _newBoards;
  Set<String> get celebratedBoards => _celebratedBoards;
  Set<String> get purchasedBoards => _purchasedBoards;
  Set<String> get purchasedArrows => _purchasedArrows;
  int get threeStarCount =>
      _levelResults.values.where((r) => r.stars == 3).length;

  ProgressRepository._();

  static Future<ProgressRepository> create() async {
    final repo = ProgressRepository._();
    await repo._init();
    return repo;
  }
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    MusicPlayer.instance.setVolume(_musicVolume);
    await _save();
    notifyListeners();
  }

  bool _lbDirty = false;
  bool get lbDirty => _lbDirty;

  Future<void> addLbPoints(int points) async {
    if (points <= 0) return;
    _rolloverLbPeriodsIfNeeded();
    final now = DateTime.now().toUtc();
    _lbWeeklyScore      += points;
    _lbMonthlyScore     += points;
    _lbAllTimeScore     += points;
    _lbWeeklyReachedAt   = now;
    _lbMonthlyReachedAt  = now;
    _lbDirty = true;

    _checkLcTrophies();

    await _save();
    notifyListeners();
  }

  /// Syncs LC-gated trophies against the current all-time LC. Mutates the
  /// unlocked set; caller is responsible for _save() + notifyListeners().
  void _checkLcTrophies() {
    for (final trophy in TrophyConstants.allTrophies) {
      if (trophy.requiredLc == null) continue;
      if (_unlockedTrophies.contains(trophy.id)) continue;
      if (_lbAllTimeScore >= trophy.requiredLc!) {
        _unlockedTrophies.add(trophy.id);
        debugPrint('🏆 Unlocked LC trophy: ${trophy.title} '
            '(${trophy.requiredLc} LC)');
      }
    }
  }

  Future<void> markLbClean() async {
    if (!_lbDirty) return;
    _lbDirty = false;
    await _save();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('progress');
    _resultsBox = await Hive.openBox('levelResults');
    await _load();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    SfxPlayer.instance.setEnabled(_soundEnabled);
    await _save();
    notifyListeners();
  }

  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    SfxPlayer.instance.setVolume(_soundVolume);
    await _save();
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    await _save();
    notifyListeners();
  }

  Future<void> acceptPrivacyPolicy() async {
    _privacyAccepted = true;
    await _save();
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    MusicPlayer.instance.toggleMute(!_musicEnabled);
    await _save();
    notifyListeners();
  }

  Future<void> setArrowSpeed(int speed) async {
    _arrowSpeed = speed;
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    _lives = _box.get('lives', defaultValue: AppConstants.maxLives);
    _currentLevel = _box.get('currentLevel', defaultValue: 1);
    _highestUnlockedLevel = _box.get('highestUnlockedLevel', defaultValue: 1);
    final themeStr = _box.get('selectedTheme', defaultValue: GameTheme.classic.name);
    _selectedTheme = GameTheme.values.firstWhere((t) => t.name == themeStr, orElse: () => GameTheme.classic);
    _skinsUnlocked = _box.get('skinsUnlocked', defaultValue: false);
    _hapticsEnabled = _box.get('hapticsEnabled', defaultValue: true);
    _heartRemover = _box.get('heartRemover', defaultValue: false);
    _assistMode = _box.get('assistMode', defaultValue: false);
    _complexPaths = _box.get('complexPaths', defaultValue: false);

    // Load Unlocked Trophies from Hive
    final trophiesList = _box.get('unlockedTrophies', defaultValue: <String>[]);
    _unlockedTrophies.addAll((trophiesList as List).cast<String>());

    // Theme mode (stored as string)
    final themeModeStr = _box.get('themeMode', defaultValue: 'light');
    _themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == themeModeStr,
      orElse: () => ThemeMode.light,
    );
    // Accent color (stored as int)
    final accentInt = _box.get('accentColor', defaultValue: 0xFF6C4CF1);
    _accentColor = Color(accentInt);
    final boardStr = _box.get('selectedBoard', defaultValue: BoardTheme.minimal.name);
    _selectedBoard = BoardTheme.values.firstWhere(
          (t) => t.name == boardStr,
      orElse: () => BoardTheme.minimal,
    );
    final newBoardsList = _box.get('newBoards', defaultValue: <String>[]);
    _newBoards.addAll((newBoardsList as List).cast<String>());
    final celebratedList = _box.get('celebratedBoards', defaultValue: <String>[]);
    _celebratedBoards.addAll((celebratedList as List).cast<String>());
    _purchasedBoards.addAll(
      (_box.get('purchasedBoards', defaultValue: <String>[]) as List).cast<String>(),
    );
    _purchasedArrows.addAll(
      (_box.get('purchasedArrows', defaultValue: <String>[]) as List).cast<String>(),
    );
    _itemsGrantedFromStars = _box.get('itemsGrantedFromStars', defaultValue: 0);
    _privacyAccepted = _box.get('privacyAccepted', defaultValue: false);

    _soundEnabled = _box.get('soundEnabled', defaultValue: true);
    _languageCode = _box.get('languageCode', defaultValue: 'system');
    _soundVolume = _box.get('soundVolume', defaultValue: 0.7);
    SfxPlayer.instance.setEnabled(_soundEnabled);
    SfxPlayer.instance.setVolume(_soundVolume);
    _musicEnabled = _box.get('musicEnabled', defaultValue: true);
    // ... existing audio loads
    _soundVolume = _box.get('soundVolume', defaultValue: 0.7);
    _musicEnabled = _box.get('musicEnabled', defaultValue: true);
    _musicVolume = _box.get('musicVolume', defaultValue: 0.4); // <--- ADD THIS

    SfxPlayer.instance.setEnabled(_soundEnabled);
    SfxPlayer.instance.setVolume(_soundVolume);

    // Apply to MusicPlayer on load
    MusicPlayer.instance.setVolume(_musicVolume);
    MusicPlayer.instance.toggleMute(!_musicEnabled);
    _soundVolume = _box.get('soundVolume', defaultValue: 0.7);
    _arrowSpeed = _box.get('arrowSpeed', defaultValue: 0);
    _rushDifficultyIndex = _box.get('rushDifficultyIndex', defaultValue: 0);

    // ── Leaderboard ──
    _leaderboardOptIn = _box.get('leaderboardOptIn', defaultValue: true);

// One-time migration: force opt-in to true for all existing users who
// still have the old default saved. Runs once per install. After the
// first launch, the stored value is respected normally.
    if (_box.get('leaderboardOptInMigrated_v1') != true) {
      _leaderboardOptIn = true;
      await _box.put('leaderboardOptIn', true);
      await _box.put('leaderboardOptInMigrated_v1', true);
      debugPrint('🏆 LC migration: opted in');
    }
    _lbWeeklyScore = _box.get('lbWeeklyScore', defaultValue: 0);
    _lbMonthlyScore = _box.get('lbMonthlyScore', defaultValue: 0);
    _lbAllTimeScore = _box.get('lbAllTimeScore', defaultValue: 0);
    _lbDirty = _box.get('lbDirty', defaultValue: false);

    final settingsModStr = _box.get('lastSettingsModified') as String?;
    _lastSettingsModified = settingsModStr != null
        ? DateTime.tryParse(settingsModStr)
        : null;

    final lbWeeklyStartStr = _box.get('lbWeeklyPeriodStart') as String?;
    _lbWeeklyPeriodStart = lbWeeklyStartStr != null
        ? DateTime.tryParse(lbWeeklyStartStr)
        : null;
    final lbMonthlyStartStr = _box.get('lbMonthlyPeriodStart') as String?;
    _lbMonthlyPeriodStart = lbMonthlyStartStr != null
        ? DateTime.tryParse(lbMonthlyStartStr)
        : null;
    final lbWeeklyReachedStr = _box.get('lbWeeklyReachedAt') as String?;
    _lbWeeklyReachedAt = lbWeeklyReachedStr != null
        ? DateTime.tryParse(lbWeeklyReachedStr)
        : null;
    final lbMonthlyReachedStr = _box.get('lbMonthlyReachedAt') as String?;
    _lbMonthlyReachedAt = lbMonthlyReachedStr != null
        ? DateTime.tryParse(lbMonthlyReachedStr)
        : null;

    _rolloverLbPeriodsIfNeeded();



    AudioHapticHelper.hapticsEnabled = _hapticsEnabled;

    for (final key in _resultsBox.keys) {
      final level = int.tryParse(key.toString());
      if (level != null) {
        final jsonStr = _resultsBox.get(key);
        if (jsonStr != null) {
          try {
            _levelResults[level] = LevelResult.fromJson(jsonDecode(jsonStr));
          } catch (e) {
            debugPrint('Error loading level result: $e');
          }
        }
      }
    }

    // Retroactive check: Grant any trophies earned based on past level progress
    await _syncTrophiesWithProgress();
  }

  bool isBoardNew(BoardTheme board) => _newBoards.contains(board.name);

  // Future<void> _saveWithSettingsStamp() async {
  //   _lastSettingsModified = DateTime.now().toUtc();
  //   await _save();
  // }

  Future<void> _save() async {
    await _box.putAll({
      'lives': _lives,
      'currentLevel': _currentLevel,
      'highestUnlockedLevel': _highestUnlockedLevel,
      'selectedTheme': _selectedTheme.name,
      'skinsUnlocked': _skinsUnlocked,
      'hapticsEnabled': _hapticsEnabled,
      'heartRemover': _heartRemover,
      'assistMode': _assistMode,
      'complexPaths': _complexPaths,
      'themeMode': _themeMode.name,
      'accentColor': _accentColor.toARGB32(),
      'selectedBoard': _selectedBoard.name,
      'newBoards': _newBoards.toList(),
      'celebratedBoards': _celebratedBoards.toList(),
      'purchasedBoards': _purchasedBoards.toList(),
      'purchasedArrows': _purchasedArrows.toList(),
      'itemsGrantedFromStars': _itemsGrantedFromStars,
      // Save new fields
      'soundEnabled': _soundEnabled,
      'musicEnabled': _musicEnabled,
      'musicVolume': _musicVolume,
      'soundVolume': _soundVolume,
      'languageCode': _languageCode,
      'arrowSpeed': _arrowSpeed,
      'privacyAccepted': _privacyAccepted,
      'rushDifficultyIndex': _rushDifficultyIndex,
      'lastSettingsModified': _lastSettingsModified?.toUtc().toIso8601String(),


      'leaderboardOptIn': _leaderboardOptIn,
      'lbDirty': _lbDirty,                                          // ← ADD
      'lbWeeklyScore': _lbWeeklyScore,
      'lbMonthlyScore': _lbMonthlyScore,
      'lbAllTimeScore': _lbAllTimeScore,
      'lbWeeklyPeriodStart': _lbWeeklyPeriodStart?.toUtc().toIso8601String(),
      'lbMonthlyPeriodStart': _lbMonthlyPeriodStart?.toUtc().toIso8601String(),
      'lbWeeklyReachedAt': _lbWeeklyReachedAt?.toUtc().toIso8601String(),
      'lbMonthlyReachedAt': _lbMonthlyReachedAt?.toUtc().toIso8601String(),


      // ── ADDED: Save Unlocked Trophies to Hive ──
      'unlockedTrophies': _unlockedTrophies.toList(),
    });

    for (final entry in _levelResults.entries) {
      await _resultsBox.put(entry.key.toString(), jsonEncode(entry.value.toJson()));
    }
    await _box.flush();
    await _resultsBox.flush();
    debugPrint('💾 SAVED: theme=${_themeMode.name} '
        'accent=0x${_accentColor.toARGB32().toRadixString(16)} '
        'vol=$_soundVolume haptics=$_hapticsEnabled');
  }

  Future<void> setRushDifficulty(RushDifficulty d) async {
    _rushDifficultyIndex = d.index;
    await _save();
    notifyListeners();
  }

  Future<void> _syncTrophiesWithProgress() async {
    bool hasNewUnlock = false;
    for (final trophy in TrophyConstants.allTrophies) {
      if (_unlockedTrophies.contains(trophy.id)) continue;

      final bool isEarned;
      if (trophy.requiredLc != null) {
        isEarned = _lbAllTimeScore >= trophy.requiredLc!;
      } else {
        isEarned = _highestUnlockedLevel > trophy.unlockLevel ||
            isLevelCompleted(trophy.unlockLevel) ||
            _currentLevel > trophy.unlockLevel;
      }

      if (isEarned) {
        _unlockedTrophies.add(trophy.id);
        hasNewUnlock = true;
        if (trophy.requiredLc != null) {
          debugPrint('🏆 LC migration: unlocked ${trophy.title} '
              '($_lbAllTimeScore LC)');
        }
      }
    }
    if (hasNewUnlock) {
      await _save();
    }
  }

  final Set<String> _unlockedTrophies = {};

  Set<String> get unlockedTrophies => _unlockedTrophies;

  bool isTrophyUnlocked(String trophyId) => _unlockedTrophies.contains(trophyId);

  // Dynamic heart limit: Checks all possible trophy ID variations & perk types
  int getMaxLivesForLevel(int levelNumber) {
    if (levelNumber <= 25) {
      return 2;
    }

    final isUnlocked = isTrophyUnlocked('survivalist') ||
        isTrophyUnlocked('survivalist_badge') ||
        isTrophyUnlocked('survivalist_trophy') ||
        _unlockedTrophies.any((id) {
          final match = TrophyConstants.allTrophies.where((t) => t.id == id);
          return match.isNotEmpty && match.first.type == TrophyType.benefit;
        });

    if (isUnlocked) {
      return 3;
    }

    return 2;
  }

  Future<void> checkAndUnlockTrophies(int completedLevel) async {
    for (final trophy in TrophyConstants.allTrophies) {
      if (trophy.requiredLc != null) continue;
      if (completedLevel >= trophy.unlockLevel &&
          !_unlockedTrophies.contains(trophy.id)) {
        _unlockedTrophies.add(trophy.id);
        debugPrint('🏆 Unlocked Trophy: ${trophy.title}');
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> setTheme(GameTheme theme) async {
    _selectedTheme = theme;
    await _save();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _save();
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await _save();
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    _hapticsEnabled = !_hapticsEnabled;
    AudioHapticHelper.hapticsEnabled = _hapticsEnabled;
    await _save();
    notifyListeners();
  }

  Future<void> toggleHeartRemover() async {
    _heartRemover = !_heartRemover;
    await _save();
    notifyListeners();
  }

  Future<void> toggleAssistMode() async {
    _assistMode = !_assistMode;
    await _save();
    notifyListeners();
  }

  Future<void> toggleComplexPaths() async {
    _complexPaths = !_complexPaths;
    await _save();
    notifyListeners();
  }

  bool unlockSkins(String code) {
    if (code.trim().toUpperCase() == 'THANKYOU') {
      _skinsUnlocked = true;
      _save();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> recordLevelComplete(LevelResult result) async {
    final existing = _levelResults[result.levelNumber];
    if (existing == null || result.stars > existing.stars) {
      _levelResults[result.levelNumber] = result;
    }
    if (result.levelNumber >= _currentLevel) {
      _currentLevel = result.levelNumber + 1;
    }
    if (result.levelNumber >= _highestUnlockedLevel) {
      _highestUnlockedLevel = result.levelNumber + 1;
    }

    // ── ADDED: Check and unlock trophies on every level completion ──
    await checkAndUnlockTrophies(result.levelNumber);

    await _save();
    notifyListeners();
  }

  Future<int> consumePendingItemMilestones() async {
    final expected = threeStarCount ~/ 5;
    final delta = expected - _itemsGrantedFromStars;
    if (delta <= 0) return 0;
    _itemsGrantedFromStars = expected;
    await _save();
    notifyListeners();
    return delta;
  }

  /// DEV ONLY — unlocks every level for testing.
  Future<void> unlockAllLevels() async {
    _highestUnlockedLevel = 999;
    await _save();
    notifyListeners();
  }

  /// Directly overwrites the player's current level. Also bumps
  /// `highestUnlockedLevel` when jumping forward, so a debug-set level
  /// doesn't accidentally lock the level-select screen behind it.
  Future<void> setCurrentLevel(int level) async {
    if (level < 1) return;
    _currentLevel = level;
    if (level > _highestUnlockedLevel) {
      _highestUnlockedLevel = level;
    }
    await _save();
    notifyListeners();
  }

  /// Unlocks every level up to and including [targetLevel], and advances
  /// `currentLevel` to [targetLevel] if it was behind.
  Future<void> unlockUpToLevel(int targetLevel) async {
    if (targetLevel < 1) return;
    if (targetLevel > _highestUnlockedLevel) {
      _highestUnlockedLevel = targetLevel;
    }
    if (targetLevel > _currentLevel) {
      _currentLevel = targetLevel;
    }
    await _save();
    notifyListeners();
  }

  /// DEV ONLY — wipes all progress back to level 1.
  Future<void> resetProgress() async {
    _lives = AppConstants.maxLives;
    _currentLevel = 1;
    _highestUnlockedLevel = 1;
    _levelResults.clear();
    await _save();
    notifyListeners();
  }

  static int calculateStars(int livesLost) {
    if (livesLost == 0) return 3;
    if (livesLost == 1) return 2;
    return 1;
  }

  Future<void> setBoard(BoardTheme board) async {
    _selectedBoard = board;
    await _save();
    notifyListeners();
  }

  /// Returns true if the player purchased this board with coins.
  bool isBoardPurchased(BoardTheme board) =>
      _purchasedBoards.contains(board.name);

  /// Returns true if the player purchased this arrow skin with coins.
  bool isArrowPurchased(GameTheme theme) =>
      _purchasedArrows.contains(theme.name);

  /// Mark a board as purchased. Caller must have already deducted coins.
  Future<void> markBoardPurchased(BoardTheme board) async {
    _purchasedBoards.add(board.name);
    _selectedBoard = board;
    await _save();
    notifyListeners();
  }

  /// Mark an arrow skin as purchased. Caller must have already deducted coins.
  Future<void> markArrowPurchased(GameTheme theme) async {
    _purchasedArrows.add(theme.name);
    _selectedTheme = theme;
    await _save();
    notifyListeners();
  }

  /// A board is unlocked if the player has reached its unlock level
  /// OR if they used the unlock code.
  bool isBoardUnlocked(BoardTheme board) {
    if (_skinsUnlocked) return true;
    if (_purchasedBoards.contains(board.name)) return true;
    final required = BoardThemes.get(board).unlockLevel;
    return _highestUnlockedLevel >= required || required == 0;
  }

  bool isArrowUnlocked(GameTheme theme) {
    const freeThemes = {
      GameTheme.classic,
      GameTheme.neon,
      GameTheme.retro,
      GameTheme.cyber,
    };
    if (freeThemes.contains(theme)) return true;
    if (_skinsUnlocked) return true;
    if (_purchasedArrows.contains(theme.name)) return true;
    return false;
  }

  /// Returns boards that just became available since [previousLevel].
  List<BoardTheme> newlyUnlockedBoards(int previousLevel, int newLevel) {
    final result = <BoardTheme>[];
    for (final b in BoardTheme.values) {
      final req = BoardThemes.get(b).unlockLevel;
      if (req > previousLevel && req <= newLevel) {
        result.add(b);
      }
    }
    return result;
  }

  /// Returns newly unlocked boards that haven't had a celebration yet.
  List<BoardTheme> getPendingCelebration() {
    return BoardTheme.values.where((t) {
      final unlockLevel = BoardThemes.get(t).unlockLevel;
      if (unlockLevel <= 0) return false;
      if (unlockLevel > _highestUnlockedLevel) return false;
      return !_celebratedBoards.contains(t.name);
    }).toList();
  }

  /// Returns boards the user has unlocked but not yet tapped in Inventory.
  List<BoardTheme> getUnviewedBoards() {
    return BoardTheme.values.where((t) => _newBoards.contains(t.name)).toList();
  }

  Future<void> markCelebrationShown(BoardTheme board) async {
    _celebratedBoards.add(board.name);
    _newBoards.add(board.name); // also add to red dot set
    await _save();
    notifyListeners();
  }


  // ─────────────────────────────────────────────────────────────────
// Leaderboard
// ─────────────────────────────────────────────────────────────────

  Future<void> setLeaderboardOptIn(bool value) async {
    _leaderboardOptIn = value;
    await _save();
    notifyListeners();
  }

  /// Roll over stale weekly/monthly periods on launch.
  void _rolloverLbPeriodsIfNeeded() {
    final now = DateTime.now().toUtc();
    final currentWeekStart = _mondayUtc(now);
    final currentMonthStart = DateTime.utc(now.year, now.month, 1);

    if (_lbWeeklyPeriodStart == null ||
        _lbWeeklyPeriodStart!.isBefore(currentWeekStart)) {
      _lbWeeklyScore = 0;
      _lbWeeklyPeriodStart = currentWeekStart;
      _lbWeeklyReachedAt = null;
    }
    if (_lbMonthlyPeriodStart == null ||
        _lbMonthlyPeriodStart!.isBefore(currentMonthStart)) {
      _lbMonthlyScore = 0;
      _lbMonthlyPeriodStart = currentMonthStart;
      _lbMonthlyReachedAt = null;
    }
  }

  static DateTime _mondayUtc(DateTime utc) {
    final daysSinceMonday = utc.weekday - 1;
    return DateTime.utc(utc.year, utc.month, utc.day)
        .subtract(Duration(days: daysSinceMonday));
  }


  Map<String, dynamic> exportState() {
    return {
      'currentLevel': _currentLevel,
      'highestUnlockedLevel': _highestUnlockedLevel,
      'skinsUnlocked': _skinsUnlocked,
      'purchasedBoards': _purchasedBoards.toList(),
      'purchasedArrows': _purchasedArrows.toList(),
      'unlockedTrophies': _unlockedTrophies.toList(),
      'itemsGrantedFromStars': _itemsGrantedFromStars,
      'newBoards': _newBoards.toList(),
      'celebratedBoards': _celebratedBoards.toList(),
      'settings': {
        'themeMode': _themeMode.name,
        'accentColor': _accentColor.toARGB32(),
        'soundEnabled': _soundEnabled,
        'soundVolume': _soundVolume,
        'musicEnabled': _musicEnabled,
        'musicVolume': _musicVolume,
        'hapticsEnabled': _hapticsEnabled,
        'languageCode': _languageCode,
        'arrowSpeed': _arrowSpeed,
        'selectedTheme': _selectedTheme.name,
        'selectedBoard': _selectedBoard.name,
        'heartRemover': _heartRemover,
        'assistMode': _assistMode,
        'complexPaths': _complexPaths,
        'privacyAccepted': _privacyAccepted,
        'rushDifficultyIndex': _rushDifficultyIndex,
        'lastModified': _lastSettingsModified?.toUtc().toIso8601String(),
      },
      'lb': {
        'optIn': _leaderboardOptIn,
        'weeklyScore': _lbWeeklyScore,
        'monthlyScore': _lbMonthlyScore,
        'allTimeScore': _lbAllTimeScore,
        'weeklyPeriodStart': _lbWeeklyPeriodStart?.toUtc().toIso8601String(),
        'monthlyPeriodStart': _lbMonthlyPeriodStart?.toUtc().toIso8601String(),
        'weeklyReachedAt': _lbWeeklyReachedAt?.toUtc().toIso8601String(),
        'monthlyReachedAt': _lbMonthlyReachedAt?.toUtc().toIso8601String(),
      },
      'levelResults': _levelResults.map(
            (k, v) => MapEntry(k.toString(), v.toJson()),
      ),
    };
  }


  Future<bool> importState(Map<String, dynamic> data) async {
    bool changed = false;

    final remoteLevel =
        (data['currentLevel'] as num?)?.toInt() ?? _currentLevel;
    if (remoteLevel > _currentLevel) {
      _currentLevel = remoteLevel;
      changed = true;
    }

    final remoteHigh =
        (data['highestUnlockedLevel'] as num?)?.toInt() ?? _highestUnlockedLevel;
    if (remoteHigh > _highestUnlockedLevel) {
      _highestUnlockedLevel = remoteHigh;
      changed = true;
    }

    if ((data['skinsUnlocked'] as bool?) == true && !_skinsUnlocked) {
      _skinsUnlocked = true;
      changed = true;
    }

    final beforeBoards = _purchasedBoards.length;
    _purchasedBoards
        .addAll(((data['purchasedBoards'] as List?) ?? []).cast<String>());
    if (_purchasedBoards.length != beforeBoards) changed = true;

    final beforeArrows = _purchasedArrows.length;
    _purchasedArrows
        .addAll(((data['purchasedArrows'] as List?) ?? []).cast<String>());
    if (_purchasedArrows.length != beforeArrows) changed = true;

    final beforeTrophies = _unlockedTrophies.length;
    _unlockedTrophies
        .addAll(((data['unlockedTrophies'] as List?) ?? []).cast<String>());
    if (_unlockedTrophies.length != beforeTrophies) changed = true;

    _newBoards.addAll(((data['newBoards'] as List?) ?? []).cast<String>());
    _celebratedBoards
        .addAll(((data['celebratedBoards'] as List?) ?? []).cast<String>());

    final remoteGranted =
        (data['itemsGrantedFromStars'] as num?)?.toInt() ?? 0;
    if (remoteGranted > _itemsGrantedFromStars) {
      _itemsGrantedFromStars = remoteGranted;
      changed = true;
    }

    final remoteResults =
        data['levelResults'] as Map<String, dynamic>? ?? const {};
    for (final entry in remoteResults.entries) {
      final level = int.tryParse(entry.key);
      if (level == null) continue;
      try {
        final remote =
        LevelResult.fromJson(entry.value as Map<String, dynamic>);
        final local = _levelResults[level];
        if (local == null || remote.stars > local.stars) {
          _levelResults[level] = remote;
          changed = true;
        }
      } catch (e) {
        debugPrint('Skipped bad level result $level: $e');
      }
    }

    final settingsChanged = _applySettingsFromRemote(
      data['settings'] as Map<String, dynamic>? ?? const {},
    );
    if (settingsChanged) changed = true;

    // ── Leaderboard merge ──
    final lb = data['lb'] as Map<String, dynamic>? ?? const {};

    final remoteOptIn = lb['optIn'] as bool?;
    final migrationDone =
        _box.get('leaderboardOptInMigrated_v1') == true;
    if (remoteOptIn != null &&
        remoteOptIn != _leaderboardOptIn &&
        migrationDone) {
      _leaderboardOptIn = remoteOptIn;
      changed = true;
    }

    final remoteWeeklyStart =
    DateTime.tryParse((lb['weeklyPeriodStart'] as String?) ?? '');
    final remoteMonthlyStart =
    DateTime.tryParse((lb['monthlyPeriodStart'] as String?) ?? '');
    final remoteWeeklyScore = (lb['weeklyScore'] as num?)?.toInt() ?? 0;
    final remoteMonthlyScore = (lb['monthlyScore'] as num?)?.toInt() ?? 0;
    final remoteAllTimeScore = (lb['allTimeScore'] as num?)?.toInt() ?? 0;

    final localWeeklyStart = _lbWeeklyPeriodStart;
    if (remoteWeeklyStart != null &&
        (localWeeklyStart == null ||
            remoteWeeklyStart.isAfter(localWeeklyStart))) {
      _lbWeeklyScore = remoteWeeklyScore;
      _lbWeeklyPeriodStart = remoteWeeklyStart;
      _lbWeeklyReachedAt =
          DateTime.tryParse((lb['weeklyReachedAt'] as String?) ?? '');
      changed = true;
    } else if (remoteWeeklyStart != null &&
        localWeeklyStart != null &&
        remoteWeeklyStart.isAtSameMomentAs(localWeeklyStart) &&
        remoteWeeklyScore > _lbWeeklyScore) {
      _lbWeeklyScore = remoteWeeklyScore;
      changed = true;
    }

    final localMonthlyStart = _lbMonthlyPeriodStart;
    if (remoteMonthlyStart != null &&
        (localMonthlyStart == null ||
            remoteMonthlyStart.isAfter(localMonthlyStart))) {
      _lbMonthlyScore = remoteMonthlyScore;
      _lbMonthlyPeriodStart = remoteMonthlyStart;
      _lbMonthlyReachedAt =
          DateTime.tryParse((lb['monthlyReachedAt'] as String?) ?? '');
      changed = true;
    } else if (remoteMonthlyStart != null &&
        localMonthlyStart != null &&
        remoteMonthlyStart.isAtSameMomentAs(localMonthlyStart) &&
        remoteMonthlyScore > _lbMonthlyScore) {
      _lbMonthlyScore = remoteMonthlyScore;
      changed = true;
    }

    if (remoteAllTimeScore > _lbAllTimeScore) {
      _lbAllTimeScore = remoteAllTimeScore;
      changed = true;
    }

    // If, after merging, local is still ahead of the cloud on any bucket,
// flag the LB dirty so the next sync (or app start) pushes local up.
    if (_lbWeeklyScore  > remoteWeeklyScore  ||
        _lbMonthlyScore > remoteMonthlyScore ||
        _lbAllTimeScore > remoteAllTimeScore) {
      _lbDirty = true;
      changed  = true;
    }

    if (changed) {
      await _save();
      notifyListeners();
    }
    return changed;
  }

  bool _applySettingsFromRemote(Map<String, dynamic> s) {
    final remoteModified =
    DateTime.tryParse((s['lastModified'] as String?) ?? '');
    if (remoteModified == null) return false;

    final localModified = _lastSettingsModified;
    if (localModified != null && localModified.isAfter(remoteModified)) {
      return false;
    }

    bool changed = false;

    T? enumByName<T extends Enum>(List<T> values, String? name) {
      if (name == null) return null;
      for (final v in values) {
        if (v.name == name) return v;
      }
      return null;
    }

    final themeMode = enumByName(ThemeMode.values, s['themeMode'] as String?);
    if (themeMode != null && themeMode != _themeMode) {
      _themeMode = themeMode;
      changed = true;
    }

    final accent = (s['accentColor'] as num?)?.toInt();
    if (accent != null && accent != _accentColor.toARGB32()) {
      _accentColor = Color(accent);
      changed = true;
    }

    bool? b(String key) => s[key] as bool?;
    double? d(String key) => (s[key] as num?)?.toDouble();
    int? i(String key) => (s[key] as num?)?.toInt();
    String? str(String key) => s[key] as String?;

    if (b('soundEnabled') != null && b('soundEnabled') != _soundEnabled) {
      _soundEnabled = b('soundEnabled')!;
      changed = true;
    }
    if (d('soundVolume') != null && d('soundVolume') != _soundVolume) {
      _soundVolume = d('soundVolume')!;
      changed = true;
    }
    if (b('musicEnabled') != null && b('musicEnabled') != _musicEnabled) {
      _musicEnabled = b('musicEnabled')!;
      MusicPlayer.instance.setVolume(_musicVolume);
      changed = true;
    }
    if (b('hapticsEnabled') != null && b('hapticsEnabled') != _hapticsEnabled) {
      _hapticsEnabled = b('hapticsEnabled')!;
      changed = true;
    }
    if (str('languageCode') != null && str('languageCode') != _languageCode) {
      _languageCode = str('languageCode')!;
      changed = true;
    }
    if (i('arrowSpeed') != null && i('arrowSpeed') != _arrowSpeed) {
      _arrowSpeed = i('arrowSpeed')!;
      changed = true;
    }

    final selTheme =
    enumByName(GameTheme.values, s['selectedTheme'] as String?);
    if (selTheme != null && selTheme != _selectedTheme) {
      _selectedTheme = selTheme;
      changed = true;
    }

    final selBoard =
    enumByName(BoardTheme.values, s['selectedBoard'] as String?);
    if (selBoard != null && selBoard != _selectedBoard) {
      _selectedBoard = selBoard;
      changed = true;
    }

    if (b('heartRemover') != null && b('heartRemover') != _heartRemover) {
      _heartRemover = b('heartRemover')!;
      changed = true;
    }
    if (b('assistMode') != null && b('assistMode') != _assistMode) {
      _assistMode = b('assistMode')!;
      changed = true;
    }
    if (b('complexPaths') != null && b('complexPaths') != _complexPaths) {
      _complexPaths = b('complexPaths')!;
      changed = true;
    }
    if (b('privacyAccepted') != null &&
        b('privacyAccepted') != _privacyAccepted) {
      _privacyAccepted = b('privacyAccepted')!;
      changed = true;
    }
    if (i('rushDifficultyIndex') != null &&
        i('rushDifficultyIndex') != _rushDifficultyIndex) {
      _rushDifficultyIndex = i('rushDifficultyIndex')!;
      changed = true;
    }

    if (changed) {
      SfxPlayer.instance.setEnabled(_soundEnabled);
      SfxPlayer.instance.setVolume(_soundVolume);
      AudioHapticHelper.hapticsEnabled = _hapticsEnabled;
      _lastSettingsModified = remoteModified;
    }
    return changed;
  }

  Future<void> markBoardViewed(BoardTheme board) async {
    if (_newBoards.remove(board.name)) {
      await _save();
      notifyListeners();
    }
  }
}