import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/leaderboard_entry.dart';

class LeaderboardUtils {
  static const String _leaderboardKey = 'leaderboard_entries';
  // Games that should accumulate total points instead of keeping highest score
  static const Set<String> _cumulativeGames = {'blind_sort'};

  /// Liderlik tablosu verilerini kaydet
  static Future<void> saveLeaderboard(List<LeaderboardEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((entry) => entry.toJson()).toList();
    final leaderboardJson = jsonEncode(entriesJson);
    await prefs.setString(_leaderboardKey, leaderboardJson);
  }

  /// Liderlik tablosu verilerini yükle
  static Future<List<LeaderboardEntry>> loadLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leaderboardJson = prefs.getString(_leaderboardKey);

      if (leaderboardJson != null) {
        final List<dynamic> entriesList = jsonDecode(leaderboardJson);
        return entriesList
            .map((entryJson) => LeaderboardEntry.fromJson(entryJson))
            .toList();
      }
    } catch (e) {
      // Handle error silently in production
    }

    return [];
  }

  /// Oyun için yüksek skoru güncelle (context-free version)
  static Future<void> updateHighScore(String gameId, int score) async {
    // Score 0 ise leaderboard'a ekleme
    if (score <= 0) return;

    final entries = await loadLeaderboard();
    final existingIndex = entries.indexWhere((entry) => entry.gameId == gameId);

    if (existingIndex != -1) {
      // Mevcut girişi güncelle
      if (_cumulativeGames.contains(gameId)) {
        // Accumulate total points
        final newTotal = entries[existingIndex].highScore + score;
        entries[existingIndex] = entries[existingIndex].copyWith(
          highScore: newTotal,
          lastPlayed: DateTime.now(),
        );
      } else {
        // Keep highest score behavior
        if (score > entries[existingIndex].highScore) {
          entries[existingIndex] = entries[existingIndex].copyWith(
            highScore: score,
            lastPlayed: DateTime.now(),
          );
        } else {
          // Sadece son oynama tarihini güncelle
          entries[existingIndex] = entries[existingIndex].copyWith(
            lastPlayed: DateTime.now(),
          );
        }
      }
    } else {
      // Yeni giriş ekle
      entries.add(
        LeaderboardEntry(
          gameId: gameId,
          highScore: score,
          lastPlayed: DateTime.now(),
        ),
      );
    }

    await saveLeaderboard(entries);
  }

  /// Oyun için yüksek skoru güncelle (with context version - for backward compatibility)
  static Future<void> updateHighScoreWithContext(
    String gameId,
    String gameTitle,
    int score,
  ) async {
    // Score 0 ise leaderboard'a ekleme
    if (score <= 0) return;

    final entries = await loadLeaderboard();
    final existingIndex = entries.indexWhere((entry) => entry.gameId == gameId);

    if (existingIndex != -1) {
      // Mevcut girişi güncelle
      if (_cumulativeGames.contains(gameId)) {
        // Accumulate total points
        final newTotal = entries[existingIndex].highScore + score;
        entries[existingIndex] = entries[existingIndex].copyWith(
          highScore: newTotal,
          lastPlayed: DateTime.now(),
        );
      } else {
        // Keep highest score behavior
        if (score > entries[existingIndex].highScore) {
          entries[existingIndex] = entries[existingIndex].copyWith(
            highScore: score,
            lastPlayed: DateTime.now(),
          );
        } else {
          // Sadece son oynama tarihini güncelle
          entries[existingIndex] = entries[existingIndex].copyWith(
            lastPlayed: DateTime.now(),
          );
        }
      }
    } else {
      // Yeni giriş ekle
      entries.add(
        LeaderboardEntry(
          gameId: gameId,
          highScore: score,
          lastPlayed: DateTime.now(),
        ),
      );
    }

    await saveLeaderboard(entries);
  }

  /// Belirli bir oyun için yüksek skoru al
  static Future<int> getHighScore(String gameId) async {
    final entries = await loadLeaderboard();
    final entry = entries.firstWhere(
      (entry) => entry.gameId == gameId,
      orElse:
          () => const LeaderboardEntry(
            gameId: '',
            highScore: 0,
            lastPlayed: null,
          ),
    );
    return entry.highScore;
  }

  /// Belirli bir oyun için liderlik tablosu girişini al
  static Future<LeaderboardEntry?> getLeaderboardEntry(String gameId) async {
    final entries = await loadLeaderboard();
    try {
      return entries.firstWhere((entry) => entry.gameId == gameId);
    } catch (e) {
      return null;
    }
  }

  /// Tüm liderlik tablosu verilerini temizle
  static Future<void> clearLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_leaderboardKey);
  }

  /// Liderlik tablosunu skora göre sırala
  static List<LeaderboardEntry> sortByScore(List<LeaderboardEntry> entries) {
    final sortedEntries = List<LeaderboardEntry>.from(entries);
    sortedEntries.sort((a, b) => b.highScore.compareTo(a.highScore));
    return sortedEntries;
  }

  /// Liderlik tablosunu son oynama tarihine göre sırala
  static List<LeaderboardEntry> sortByLastPlayed(
    List<LeaderboardEntry> entries,
  ) {
    final sortedEntries = List<LeaderboardEntry>.from(entries);
    sortedEntries.sort((a, b) {
      if (a.lastPlayed == null && b.lastPlayed == null) return 0;
      if (a.lastPlayed == null) return 1;
      if (b.lastPlayed == null) return -1;
      return b.lastPlayed!.compareTo(a.lastPlayed!);
    });
    return sortedEntries;
  }

  /// Belirli bir oyunun yüksek skorunu sil
  static Future<void> removeHighScore(String gameId) async {
    final entries = await loadLeaderboard();
    entries.removeWhere((entry) => entry.gameId == gameId);
    await saveLeaderboard(entries);
  }
}
