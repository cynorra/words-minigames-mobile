import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class GameModel {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String route;
  final String icon;
  final String category;
  final int order;

  const GameModel({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.route,
    required this.icon,
    this.category = 'General',
    this.order = 0,
  });

  /// Get localized title with context (preferred method when context is available)
  String getTitle(BuildContext context) =>
      _getLocalizedTitle(context, titleKey);

  /// Get localized description with context (preferred method when context is available)
  String getDescription(BuildContext context) =>
      _getLocalizedDescription(context, descriptionKey);

  /// Get localized title from key
  static String _getLocalizedTitle(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'blind_sort':
        return localizations.blindSort;
      case 'higher_lower':
        return localizations.higherLower;
      case 'color_hunt':
        return localizations.colorHunt;
      case 'aim_trainer':
        return localizations.aimTrainer;
      case 'number_memory':
        return localizations.numberMemory;
      case 'find_difference':
        return localizations.findDifference;
      case 'rock_paper_scissors':
        return localizations.rockPaperScissors;
      case 'twenty_one':
        return localizations.twentyOne;
      case 'reactionTime':
        return localizations.reactionTime;
      case 'patternMemory':
        return localizations.patternMemory;
      case 'tic_tac_toe':
        return localizations.ticTacToe;
      case 'guess_the_flag':
        return localizations.guessTheFlag;
      case 'word_unscrambler':
        final isTr = Localizations.localeOf(context).languageCode.startsWith('tr');
        return isTr ? 'Kelime Çözücü' : 'Word Unscrambler';
      case 'word_guess':
        final isTr = Localizations.localeOf(context).languageCode.startsWith('tr');
        return isTr ? 'Kelime Tahmini' : 'Word Guess';
      default:
        return key;
    }
  }

  /// Get localized description from key
  static String _getLocalizedDescription(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'blind_sort_description':
        return localizations.blindSortDescription;
      case 'higher_lower_description':
        return localizations.higherLowerDescription;
      case 'color_hunt_description':
        return localizations.colorHuntDescription;
      case 'aim_trainer_description':
        return localizations.aimTrainerDescription;
      case 'number_memory_description':
        return localizations.numberMemoryDescription;
      case 'find_difference_description':
        return localizations.findDifferenceDescription;
      case 'rock_paper_scissors_description':
        return localizations.rockPaperScissorsDescription;
      case 'twenty_one_description':
        return localizations.twentyOneDescription;
      case 'reactionTimeDescription':
        return localizations.reactionTimeDescription;
      case 'patternMemoryDescription':
        return localizations.patternMemoryDescription;
      case 'tic_tac_toe_description':
        return localizations.ticTacToeDescription;
      case 'guess_the_flag_description':
        return localizations.guessTheFlagDescription;
      case 'word_unscrambler_description':
        final isTr = Localizations.localeOf(context).languageCode.startsWith('tr');
        return isTr
            ? 'Karışık verilen harflerden doğru kelimeyi süre bitmeden türetin!'
            : 'Unscramble letters to find the hidden word before time runs out!';
      case 'word_guess_description':
        final isTr = Localizations.localeOf(context).languageCode.startsWith('tr');
        return isTr
            ? '6 denemede 5 harfli gizli kelimeyi harf ipuçlarıyla tahmin edin!'
            : 'Guess the hidden 5-letter word in 6 attempts with color clues!';
      default:
        return key;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GameModel(id: $id, titleKey: $titleKey, route: $route)';
  }
}
