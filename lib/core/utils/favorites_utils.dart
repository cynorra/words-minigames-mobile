import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesUtils {
  static const String _favoritesKey = 'favorite_games';

  /// Favori oyunları kaydet
  static Future<void> saveFavorites(List<String> gameIds) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(gameIds);
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  /// Favori oyunları yükle
  static Future<List<String>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        return favoritesList.cast<String>();
      }
    } catch (e) {
      // Handle error silently in production
    }

    return [];
  }

  /// Oyunu favorilere ekle
  static Future<void> addToFavorites(String gameId) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(gameId)) {
      favorites.add(gameId);
      await saveFavorites(favorites);
    }
  }

  /// Oyunu favorilerden çıkar
  static Future<void> removeFromFavorites(String gameId) async {
    final favorites = await loadFavorites();
    favorites.remove(gameId);
    await saveFavorites(favorites);
  }

  /// Oyun favori mi kontrol et
  static Future<bool> isFavorite(String gameId) async {
    final favorites = await loadFavorites();
    return favorites.contains(gameId);
  }

  /// Tüm favorileri temizle
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
