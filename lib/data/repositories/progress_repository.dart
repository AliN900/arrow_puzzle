import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/board_themes.dart';
import '../models/level_result.dart';
import '../../core/constants.dart';
import '../../core/app_themes.dart';
import '../../core/audio_haptic_helper.dart';

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
  bool _musicEnabled = true;
  int _arrowSpeed = 0;
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = const Color(0xFF6C4CF1);
  BoardTheme _selectedBoard = BoardTheme.minimal;
  final Map<int, LevelResult> _levelResults = {};
  final Set<String> _newBoards = {};        // red dot shown until user views
  final Set<String> _celebratedBoards = {}; // celebration already shown
  final Set<String> _purchasedBoards = {};
  final Set<String> _purchasedArrows = {};
  int _itemsGrantedFromStars = 0;

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
  bool get musicEnabled => _musicEnabled;
  int get arrowSpeed => _arrowSpeed;
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

  Future<void> _init() async {
    _box = await Hive.openBox('progress');
    _resultsBox = await Hive.openBox('levelResults');
    _load();
  }

  // NEW METHODS (used by SettingsScreen)
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _save();
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await _save();
    notifyListeners();
  }

  Future<void> setArrowSpeed(int speed) async {
    _arrowSpeed = speed;
    await _save();
    notifyListeners();
  }

  void _load() {
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

    // Load new fields
    _soundEnabled = _box.get('soundEnabled', defaultValue: true);
    _musicEnabled = _box.get('musicEnabled', defaultValue: true);
    _arrowSpeed = _box.get('arrowSpeed', defaultValue: 0);

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
  }

  bool isBoardNew(BoardTheme board) => _newBoards.contains(board.name);

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
      'arrowSpeed': _arrowSpeed,
    });

    for (final entry in _levelResults.entries) {
      await _resultsBox.put(entry.key.toString(), jsonEncode(entry.value.toJson()));
    }
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

  Future<void> setCurrentLevel(int level) async {
    _currentLevel = level;
    await _save();
    notifyListeners();
  }

  /// DEV ONLY — unlocks every level for testing.
  Future<void> unlockAllLevels() async {
    _highestUnlockedLevel = 999;
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

  Future<void> markBoardViewed(BoardTheme board) async {
    if (_newBoards.remove(board.name)) {
      await _save();
      notifyListeners();
    }
  }
}