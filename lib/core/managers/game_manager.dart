import '../services/game_state_service.dart';
import '../utils/leaderboard_utils.dart';
import '../utils/sound_utils.dart';

/// Manager class to handle all game-related business logic
/// This separates game logic from UI components
class GameManager {
  /// Save game state for continue functionality
  static Future<void> saveGameState(
    String gameId,
    Map<String, dynamic> state,
  ) async {
    await GameStateService().saveGameState(gameId, state);
  }

  /// Load game state for continue functionality
  static Future<Map<String, dynamic>?> loadGameState(String gameId) async {
    return await GameStateService().loadGameState(gameId);
  }

  /// Clear game state
  static Future<void> clearGameState(String gameId) async {
    await GameStateService().clearGameState(gameId);
  }

  /// Save game score
  static Future<void> saveGameScore(String gameId, int score) async {
    await GameStateService().saveGameScore(gameId, score);
  }

  /// Load game score
  static Future<int?> loadGameScore(String gameId) async {
    return await GameStateService().loadGameScore(gameId);
  }

  /// Save game level
  static Future<void> saveGameLevel(String gameId, int level) async {
    await GameStateService().saveGameLevel(gameId, level);
  }

  /// Load game level
  static Future<int?> loadGameLevel(String gameId) async {
    return await GameStateService().loadGameLevel(gameId);
  }

  /// Check if game has saved state
  static Future<bool> hasGameState(String gameId) async {
    return await GameStateService().hasGameState(gameId);
  }

  /// Update high score and play sound if new record
  static Future<void> updateHighScoreWithSound(String gameId, int score) async {
    final previousHighScore = await LeaderboardUtils.getHighScore(gameId);

    if (score > previousHighScore) {
      SoundUtils.playNewLevelSound();
    }

    await LeaderboardUtils.updateHighScore(gameId, score);
  }

  /// Calculate game score based on various factors
  static int calculateGameScore({
    required int baseScore,
    required int timeBonus,
    required int accuracyBonus,
    required int speedBonus,
  }) {
    return baseScore + timeBonus + accuracyBonus + speedBonus;
  }

  /// Calculate time bonus based on remaining time
  static int calculateTimeBonus(int remainingTimeSeconds) {
    return (remainingTimeSeconds * 10).clamp(0, 1000);
  }

  /// Calculate accuracy bonus based on correct answers and total questions
  static int calculateAccuracyBonus(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    final accuracy = correctAnswers / totalQuestions;
    return (accuracy * 500).round();
  }

  /// Calculate speed bonus based on average response time
  static int calculateSpeedBonus(double averageResponseTimeMs) {
    if (averageResponseTimeMs <= 500) return 200;
    if (averageResponseTimeMs <= 1000) return 100;
    if (averageResponseTimeMs <= 2000) return 50;
    return 0;
  }

  /// Check if score is a new record
  static Future<bool> isNewRecord(String gameId, int score) async {
    final currentHighScore = await LeaderboardUtils.getHighScore(gameId);
    return score > currentHighScore;
  }

  /// Get game statistics
  static Future<GameStatistics> getGameStatistics(String gameId) async {
    final entry = await LeaderboardUtils.getLeaderboardEntry(gameId);
    final allEntries = await LeaderboardUtils.loadLeaderboard();

    return GameStatistics(
      highScore: entry?.highScore ?? 0,
      totalGames: allEntries.length,
      averageScore:
          allEntries.isEmpty
              ? 0
              : allEntries.fold<int>(0, (sum, e) => sum + e.highScore) /
                  allEntries.length,
      lastPlayed: entry?.lastPlayed,
    );
  }

  /// Validate game data
  static bool validateGameData(Map<String, dynamic> data) {
    return data.containsKey('score') &&
        data.containsKey('level') &&
        data['score'] is int &&
        data['level'] is int;
  }

  /// Format game time for display
  static String formatGameTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Format score for display
  static String formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}

/// Data class for game statistics
class GameStatistics {
  final int highScore;
  final int totalGames;
  final double averageScore;
  final DateTime? lastPlayed;

  const GameStatistics({
    required this.highScore,
    required this.totalGames,
    required this.averageScore,
    this.lastPlayed,
  });
}
