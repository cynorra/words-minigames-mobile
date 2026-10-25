import 'package:flutter/material.dart';
import '../../shared/models/game_model.dart';
import '../theme/app_theme.dart';
import '../utils/game_icon_utils.dart';

class GamesConfig {
  // Tüm oyunların merkezi konfigürasyonu
  // Ordered by popularity, user experience, and engagement
  static const List<GameModel> allGames = [
    // Tier 1: Most Popular & Easy Games (Entry Level)
    GameModel(
      id: 'rps',
      titleKey: 'rock_paper_scissors',
      descriptionKey: 'rock_paper_scissors_description',
      route: '/rps',
      icon: 'rock-paper-scissors',
      category: 'Reflex',
      order: 9,
    ),
    GameModel(
      id: 'higher_lower',
      titleKey: 'higher_lower',
      descriptionKey: 'higher_lower_description',
      route: '/higher-lower',
      icon: 'thermostat',
      category: 'Numbers',
      order: 1,
    ),
    GameModel(
      id: 'color_hunt',
      titleKey: 'color_hunt',
      descriptionKey: 'color_hunt_description',
      route: '/color-hunt',
      icon: 'color-palette',
      category: 'Vision',
      order: 2,
    ),

    // Tier 2: Engaging & Medium Difficulty Games
    GameModel(
      id: 'find_difference',
      titleKey: 'find_difference',
      descriptionKey: 'find_difference_description',
      route: '/find-difference',
      icon: 'color-circle',
      category: 'Vision',
      order: 1,
    ),
    GameModel(
      id: 'blind_sort',
      titleKey: 'blind_sort',
      descriptionKey: 'blind_sort_description',
      route: '/blind-sort',
      icon: 'order',
      category: 'Logic',
      order: 4,
    ),
    GameModel(
      id: 'aim_trainer',
      titleKey: 'aim_trainer',
      descriptionKey: 'aim_trainer_description',
      route: '/aim-trainer',
      icon: 'target',
      category: 'Reflex',
      order: 5,
    ),

    // Tier 3: Advanced & Challenging Games
    GameModel(
      id: 'number_memory',
      titleKey: 'number_memory',
      descriptionKey: 'number_memory_description',
      route: '/number-memory',
      icon: 'lottery',
      category: 'Memory',
      order: 6,
    ),
    GameModel(
      id: 'reaction_time',
      titleKey: 'reactionTime',
      descriptionKey: 'reactionTimeDescription',
      route: '/reaction-time',
      icon: 'quick-response',
      category: 'Reflex',
      order: 7,
    ),
    GameModel(
      id: 'pattern_memory',
      titleKey: 'patternMemory',
      descriptionKey: 'patternMemoryDescription',
      route: '/pattern-memory',
      icon: 'pattern',
      category: 'Memory',
      order: 8,
    ),
    GameModel(
      id: 'twenty_one',
      titleKey: 'twenty_one',
      descriptionKey: 'twenty_one_description',
      route: '/twenty-one',
      icon: 'blackjack',
      category: 'Cards',
      order: 9,
    ),
    GameModel(
      id: 'guess_the_flag',
      titleKey: 'guess_the_flag',
      descriptionKey: 'guess_the_flag_description',
      route: '/guess-the-flag',
      icon: 'flag',
      category: 'Knowledge',
      order: 0, // Yeni oyun - en üstte görünmesi için
    ),
    GameModel(
      id: 'tic_tac_toe',
      titleKey: 'tic_tac_toe',
      descriptionKey: 'tic_tac_toe_description',
      route: '/tic-tac-toe',
      icon: 'tic-tac-toe',
      category: 'Logic',
      order: 0, // İkinci sırada
    ),
    GameModel(
      id: 'word_unscrambler',
      titleKey: 'word_unscrambler',
      descriptionKey: 'word_unscrambler_description',
      route: '/word-unscrambler',
      icon: 'winner',
      category: 'Words',
      order: 0,
    ),
    GameModel(
      id: 'word_guess',
      titleKey: 'word_guess',
      descriptionKey: 'word_guess_description',
      route: '/word-guess',
      icon: 'order',
      category: 'Words',
      order: 0,
    ),
  ];

  // Oyun renkleri
  // Color palette optimized for new game order and user experience
  static const Map<String, Color> gameColors = {
    'word_unscrambler': AppTheme.darkSecondary, // cyan / cyber mint
    'word_guess': AppTheme.darkPrimary, // neon violet
    // Tier 1: Most Popular & Easy Games (Entry Level)
    'rps': AppTheme.darkPrimary, // purple - most popular
    'higher_lower': AppTheme.darkWarning, // yellow - engaging
    'color_hunt': AppTheme.darkSuccess, // green - visual appeal
    // Tier 2: Engaging & Medium Difficulty Games
    'find_difference': AppTheme.darkSecondary, // soft purple - engaging
    'blind_sort': AppTheme.darkPrimary, // purple - logic
    'aim_trainer': AppTheme.darkError, // red - action
    // Tier 3: Advanced & Challenging Games
    'number_memory': AppTheme.vividGreen, // vivid green - memory
    'reaction_time': AppTheme.darkPrimary, // purple - reflex
    'pattern_memory': AppTheme.darkSecondary, // soft purple - advanced memory
    'twenty_one': AppTheme.goldYellow, // gold - casino style
    'guess_the_flag': AppTheme.darkSuccess, // green - knowledge
    'tic_tac_toe': AppTheme.vividGreen, // blue - strategy
  };

  /// Belirli bir oyunu ID'ye göre bul
  static GameModel? getGameById(String gameId) {
    try {
      return allGames.firstWhere((game) => game.id == gameId);
    } catch (e) {
      return null;
    }
  }

  /// Oyunun rengini al
  static Color getGameColor(String gameId) {
    return gameColors[gameId] ?? AppTheme.darkPrimary;
  }

  /// Oyunun icon'unu al
  static String getGameIconPath(String iconName) {
    return GameIconUtils.getIconPath(iconName);
  }

  /// Tüm oyun ID'lerini al
  static List<String> getAllGameIds() {
    return allGames.map((game) => game.id).toList();
  }

  /// Map route path to game id
  static String? getGameIdByRoute(String? route) {
    if (route == null) return null;
    try {
      return allGames.firstWhere((g) => g.route == route).id;
    } catch (_) {
      return null;
    }
  }
}
