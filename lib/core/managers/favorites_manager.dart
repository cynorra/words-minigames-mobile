import '../utils/favorites_utils.dart';

/// Manager class to handle all favorites-related business logic
/// This separates favorites logic from UI components
class FavoritesManager {
  /// Load all favorite games
  static Future<List<String>> loadFavorites() async {
    return await FavoritesUtils.loadFavorites();
  }

  /// Add game to favorites
  static Future<void> addToFavorites(String gameId) async {
    await FavoritesUtils.addToFavorites(gameId);
  }

  /// Remove game from favorites
  static Future<void> removeFromFavorites(String gameId) async {
    await FavoritesUtils.removeFromFavorites(gameId);
  }

  /// Check if game is favorite
  static Future<bool> isFavorite(String gameId) async {
    return await FavoritesUtils.isFavorite(gameId);
  }

  /// Toggle favorite status
  static Future<void> toggleFavorite(String gameId) async {
    final isCurrentlyFavorite = await isFavorite(gameId);
    if (isCurrentlyFavorite) {
      await removeFromFavorites(gameId);
    } else {
      await addToFavorites(gameId);
    }
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    await FavoritesUtils.clearFavorites();
  }

  /// Get favorites count
  static Future<int> getFavoritesCount() async {
    final favorites = await loadFavorites();
    return favorites.length;
  }

  /// Check if user has any favorites
  static Future<bool> hasFavorites() async {
    final favorites = await loadFavorites();
    return favorites.isNotEmpty;
  }

  /// Get favorite games with additional data
  static Future<List<FavoriteGameData>> getFavoriteGamesWithData() async {
    final favorites = await loadFavorites();
    return favorites
        .map((gameId) => FavoriteGameData(gameId: gameId, isFavorite: true))
        .toList();
  }

  /// Validate game ID
  static bool isValidGameId(String gameId) {
    return gameId.isNotEmpty && gameId.length <= 50;
  }

  /// Get favorite games by category
  static Future<List<String>> getFavoritesByCategory(String category) async {
    final allFavorites = await loadFavorites();
    // This is a placeholder - you can implement category filtering logic here
    return allFavorites.where((gameId) => gameId.startsWith(category)).toList();
  }

  /// Export favorites data
  static Future<Map<String, dynamic>> exportFavoritesData() async {
    final favorites = await loadFavorites();
    return {
      'favorites': favorites,
      'count': favorites.length,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import favorites data
  static Future<void> importFavoritesData(Map<String, dynamic> data) async {
    if (data.containsKey('favorites') && data['favorites'] is List) {
      final favorites = List<String>.from(data['favorites']);
      await clearFavorites();
      for (final gameId in favorites) {
        if (isValidGameId(gameId)) {
          await addToFavorites(gameId);
        }
      }
    }
  }
}

/// Data class for favorite game information
class FavoriteGameData {
  final String gameId;
  final bool isFavorite;
  final DateTime? addedAt;

  const FavoriteGameData({
    required this.gameId,
    required this.isFavorite,
    this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'isFavorite': isFavorite,
      'addedAt': addedAt?.toIso8601String(),
    };
  }

  factory FavoriteGameData.fromJson(Map<String, dynamic> json) {
    return FavoriteGameData(
      gameId: json['gameId'] as String,
      isFavorite: json['isFavorite'] as bool,
      addedAt:
          json['addedAt'] != null
              ? DateTime.parse(json['addedAt'] as String)
              : null,
    );
  }
}
