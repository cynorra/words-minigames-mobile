import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameStateService {
  static final GameStateService _instance = GameStateService._internal();
  factory GameStateService() => _instance;
  GameStateService._internal();

  static const String _gameStatePrefix = 'game_state_';
  static const String _gameScorePrefix = 'game_score_';
  static const String _gameLevelPrefix = 'game_level_';

  /// Save game state for continue functionality
  Future<void> saveGameState(String gameId, Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameStatePrefix$gameId';
      final jsonString = jsonEncode(state);
      await prefs.setString(key, jsonString);
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Load game state for continue functionality
  Future<Map<String, dynamic>?> loadGameState(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameStatePrefix$gameId';
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle error silently in production
    }
    return null;
  }

  /// Clear game state (when game is completed or restarted)
  Future<void> clearGameState(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_gameStatePrefix$gameId';
      final scoreKey = '$_gameScorePrefix$gameId';
      final levelKey = '$_gameLevelPrefix$gameId';

      await prefs.remove(stateKey);
      await prefs.remove(scoreKey);
      await prefs.remove(levelKey);
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Save game score for continue functionality
  Future<void> saveGameScore(String gameId, int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameScorePrefix$gameId';
      await prefs.setInt(key, score);
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Load game score for continue functionality
  Future<int?> loadGameScore(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameScorePrefix$gameId';
      return prefs.getInt(key);
    } catch (e) {
      // Handle error silently in production
    }
    return null;
  }

  /// Save game level for continue functionality
  Future<void> saveGameLevel(String gameId, int level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameLevelPrefix$gameId';
      await prefs.setInt(key, level);
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Load game level for continue functionality
  Future<int?> loadGameLevel(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameLevelPrefix$gameId';
      return prefs.getInt(key);
    } catch (e) {
      // Handle error silently in production
    }
    return null;
  }

  /// Check if game has saved state for continue
  Future<bool> hasGameState(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_gameStatePrefix$gameId';
      return prefs.containsKey(key);
    } catch (e) {
      // Handle error silently in production
    }
    return false;
  }

  /// Get all saved game states
  Future<Map<String, Map<String, dynamic>>> getAllGameStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final gameStates = <String, Map<String, dynamic>>{};

      for (final key in keys) {
        if (key.startsWith(_gameStatePrefix)) {
          final gameId = key.substring(_gameStatePrefix.length);
          final jsonString = prefs.getString(key);
          if (jsonString != null) {
            gameStates[gameId] = jsonDecode(jsonString) as Map<String, dynamic>;
          }
        }
      }

      return gameStates;
    } catch (e) {
      // Handle error silently in production
    }
    return {};
  }
}
