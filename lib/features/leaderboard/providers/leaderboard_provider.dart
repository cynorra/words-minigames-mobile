import 'package:flutter/material.dart';
import '../../../shared/models/leaderboard_entry.dart';
import '../../../core/utils/leaderboard_utils.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  String _sortBy = 'score'; // 'score' or 'lastPlayed'

  List<LeaderboardEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String get sortBy => _sortBy;

  /// Liderlik tablosunu yükle
  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await LeaderboardUtils.loadLeaderboard();
      _sortEntries();
    } catch (e) {
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yüksek skoru güncelle
  Future<void> updateHighScore(String gameId, int score) async {
    await LeaderboardUtils.updateHighScore(gameId, score);
    await loadLeaderboard(); // Liderlik tablosunu yeniden yükle
  }

  /// Sıralama türünü değiştir
  void changeSortBy(String sortBy) {
    _sortBy = sortBy;
    _sortEntries();
    notifyListeners();
  }

  /// Girişleri sırala
  void _sortEntries() {
    if (_sortBy == 'score') {
      _entries = LeaderboardUtils.sortByScore(_entries);
    } else if (_sortBy == 'lastPlayed') {
      _entries = LeaderboardUtils.sortByLastPlayed(_entries);
    }
  }

  /// Belirli bir oyun için yüksek skoru al
  Future<int> getHighScore(String gameId) async {
    return await LeaderboardUtils.getHighScore(gameId);
  }

  /// Liderlik tablosunu temizle
  Future<void> clearLeaderboard() async {
    await LeaderboardUtils.clearLeaderboard();
    _entries = [];
    notifyListeners();
  }

  /// Liderlik tablosunda giriş var mı kontrol et
  bool get hasEntries => _entries.isNotEmpty;

  /// Toplam giriş sayısı
  int get totalEntries => _entries.length;

  /// Ortalama skor
  double get averageScore {
    if (_entries.isEmpty) return 0.0;
    final total = _entries.fold<int>(0, (sum, entry) => sum + entry.highScore);
    return total / _entries.length;
  }

  /// En yüksek skor
  int get highestScore {
    if (_entries.isEmpty) return 0;
    return _entries
        .map((entry) => entry.highScore)
        .reduce((a, b) => a > b ? a : b);
  }

  /// En düşük skor
  int get lowestScore {
    if (_entries.isEmpty) return 0;
    return _entries
        .map((entry) => entry.highScore)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Belirli bir oyunun yüksek skorunu sil
  Future<void> removeHighScore(String gameId) async {
    await LeaderboardUtils.removeHighScore(gameId);
    await loadLeaderboard();
  }
}
