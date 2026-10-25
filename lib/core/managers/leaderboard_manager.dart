import '../utils/leaderboard_utils.dart';
import '../../shared/models/leaderboard_entry.dart';

/// Manager class to handle all leaderboard-related business logic
/// This separates leaderboard logic from UI components
class LeaderboardManager {
  /// Load leaderboard entries
  static Future<List<LeaderboardEntry>> loadLeaderboard() async {
    return await LeaderboardUtils.loadLeaderboard();
  }

  /// Update high score
  static Future<void> updateHighScore(String gameId, int score) async {
    await LeaderboardUtils.updateHighScore(gameId, score);
  }

  /// Get high score for a specific game
  static Future<int> getHighScore(String gameId) async {
    return await LeaderboardUtils.getHighScore(gameId);
  }

  /// Get leaderboard entry for a specific game
  static Future<LeaderboardEntry?> getLeaderboardEntry(String gameId) async {
    return await LeaderboardUtils.getLeaderboardEntry(gameId);
  }

  /// Clear leaderboard
  static Future<void> clearLeaderboard() async {
    await LeaderboardUtils.clearLeaderboard();
  }

  /// Remove high score for a specific game
  static Future<void> removeHighScore(String gameId) async {
    await LeaderboardUtils.removeHighScore(gameId);
  }

  /// Sort entries by score
  static List<LeaderboardEntry> sortByScore(List<LeaderboardEntry> entries) {
    return LeaderboardUtils.sortByScore(entries);
  }

  /// Sort entries by last played date
  static List<LeaderboardEntry> sortByLastPlayed(
    List<LeaderboardEntry> entries,
  ) {
    return LeaderboardUtils.sortByLastPlayed(entries);
  }

  /// Get leaderboard statistics
  static Future<LeaderboardStatistics> getLeaderboardStatistics() async {
    final entries = await loadLeaderboard();

    if (entries.isEmpty) {
      return const LeaderboardStatistics(
        totalGames: 0,
        totalScore: 0,
        averageScore: 0,
        highestScore: 0,
        lowestScore: 0,
        mostPlayedGame: null,
      );
    }

    final totalScore = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.highScore,
    );
    final averageScore = totalScore / entries.length;
    final highestScore = entries
        .map((e) => e.highScore)
        .reduce((a, b) => a > b ? a : b);
    final lowestScore = entries
        .map((e) => e.highScore)
        .reduce((a, b) => a < b ? a : b);

    // Find most played game
    final gameCounts = <String, int>{};
    for (final entry in entries) {
      gameCounts[entry.gameId] = (gameCounts[entry.gameId] ?? 0) + 1;
    }

    String? mostPlayedGame;
    int maxCount = 0;
    for (final entry in gameCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostPlayedGame = entry.key;
      }
    }

    return LeaderboardStatistics(
      totalGames: entries.length,
      totalScore: totalScore,
      averageScore: averageScore,
      highestScore: highestScore,
      lowestScore: lowestScore,
      mostPlayedGame: mostPlayedGame,
    );
  }

  /// Get top performers
  static Future<List<LeaderboardEntry>> getTopPerformers({
    int limit = 10,
  }) async {
    final entries = await loadLeaderboard();
    final sortedEntries = sortByScore(entries);
    return sortedEntries.take(limit).toList();
  }

  /// Get recent games
  static Future<List<LeaderboardEntry>> getRecentGames({int limit = 10}) async {
    final entries = await loadLeaderboard();
    final sortedEntries = sortByLastPlayed(entries);
    return sortedEntries.take(limit).toList();
  }

  /// Get games by score range
  static Future<List<LeaderboardEntry>> getGamesByScoreRange({
    required int minScore,
    required int maxScore,
  }) async {
    final entries = await loadLeaderboard();
    return entries
        .where(
          (entry) => entry.highScore >= minScore && entry.highScore <= maxScore,
        )
        .toList();
  }

  /// Get games played in date range
  static Future<List<LeaderboardEntry>> getGamesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await loadLeaderboard();
    return entries
        .where(
          (entry) =>
              entry.lastPlayed?.isAfter(startDate) == true &&
              entry.lastPlayed?.isBefore(endDate) == true,
        )
        .toList();
  }

  /// Check if score qualifies for leaderboard
  static Future<bool> isScoreQualifying(String gameId, int score) async {
    final currentHighScore = await getHighScore(gameId);
    return score > currentHighScore;
  }

  /// Get player ranking for a specific game
  static Future<int> getPlayerRanking(String gameId, int score) async {
    final entries = await loadLeaderboard();
    final gameEntries =
        entries.where((entry) => entry.gameId == gameId).toList();
    final sortedEntries = sortByScore(gameEntries);

    for (int i = 0; i < sortedEntries.length; i++) {
      if (score >= sortedEntries[i].highScore) {
        return i + 1;
      }
    }

    return sortedEntries.length + 1;
  }

  /// Export leaderboard data
  static Future<Map<String, dynamic>> exportLeaderboardData() async {
    final entries = await loadLeaderboard();
    final statistics = await getLeaderboardStatistics();

    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'statistics': {
        'totalGames': statistics.totalGames,
        'totalScore': statistics.totalScore,
        'averageScore': statistics.averageScore,
        'highestScore': statistics.highestScore,
        'lowestScore': statistics.lowestScore,
        'mostPlayedGame': statistics.mostPlayedGame,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Validate leaderboard entry
  static bool validateLeaderboardEntry(LeaderboardEntry entry) {
    return entry.gameId.isNotEmpty &&
        entry.highScore >= 0 &&
        (entry.lastPlayed?.isBefore(
              DateTime.now().add(const Duration(days: 1)),
            ) ??
            true);
  }
}

/// Data class for leaderboard statistics
class LeaderboardStatistics {
  final int totalGames;
  final int totalScore;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final String? mostPlayedGame;

  const LeaderboardStatistics({
    required this.totalGames,
    required this.totalScore,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    this.mostPlayedGame,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
      'mostPlayedGame': mostPlayedGame,
    };
  }
}
