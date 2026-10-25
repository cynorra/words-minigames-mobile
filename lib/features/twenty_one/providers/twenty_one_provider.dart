import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Card;

import '../models/twenty_one_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class TwentyOneProvider extends ChangeNotifier {
  final Random _random = Random();
  List<Card> _deck = [];
  TwentyOneGameState _gameState = const TwentyOneGameState();
  Timer? _dealerTimer;
  bool _hasUsedContinue = false;

  TwentyOneGameState get gameState => _gameState;

  void startGame() {
    _hasUsedContinue = false;
    _initializeDeck();
    _dealInitialCards();
    _gameState = _gameState.copyWith(
      status: TwentyOneGameStatus.playing,
      canHit: true,
      canStand: true,
      isDealerTurn: false,
      gameMessage: 'Your turn',
    );
    notifyListeners();
  }

  void resetGame() {
    _dealerTimer?.cancel();
    _gameState = const TwentyOneGameState();
    _hasUsedContinue = false;
    notifyListeners();
  }

  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  void hit() {
    if (!_gameState.canHit) return;

    SoundUtils.playTapSound();
    final newCard = _drawCard();
    final newPlayerHand = List<Card>.from(_gameState.playerHand)..add(newCard);

    _gameState = _gameState.copyWith(playerHand: newPlayerHand);

    if (_gameState.playerTotal > 21) {
      // Save state before bust to allow one-time continue to retry this hit
      _saveGameStateBeforeBust(
        playerHandBefore: List<Card>.from(_gameState.playerHand)..removeLast(),
        dealerHand: List<Card>.from(_gameState.dealerHand),
        losingCard: newCard,
        deck: List<Card>.from(_deck),
      );
      _endRound('Bust! You went over 21');
    } else if (_gameState.playerTotal == 21) {
      stand();
    } else {
      _gameState = _gameState.copyWith(
        gameMessage: 'Your total: ${_gameState.playerTotal}',
      );
    }
    notifyListeners();
  }

  void stand() {
    if (!_gameState.canStand) return;

    SoundUtils.playTapSound();
    _gameState = _gameState.copyWith(
      isDealerTurn: true,
      canHit: false,
      canStand: false,
      gameMessage: 'Dealer\'s turn',
    );
    notifyListeners();

    _dealerPlay();
  }

  void _initializeDeck() {
    _deck = [];
    final suits = ['♠', '♥', '♦', '♣'];
    final ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
    ];

    for (final suit in suits) {
      for (int i = 0; i < ranks.length; i++) {
        final rank = ranks[i];
        int value;
        if (rank == 'A') {
          value = 11;
        } else if (['J', 'Q', 'K'].contains(rank)) {
          value = 10;
        } else {
          value = i + 1;
        }

        _deck.add(Card(suit: suit, rank: rank, value: value));
      }
    }
    _deck.shuffle(_random);
  }

  void _dealInitialCards() {
    final playerHand = [_drawCard(), _drawCard()];
    final dealerHand = [_drawCard(), _drawCard(isHidden: true)];

    _gameState = _gameState.copyWith(
      playerHand: playerHand,
      dealerHand: dealerHand,
    );

    // Check for natural blackjack
    if (_gameState.playerTotal == 21) {
      _endRound('Blackjack! You win!');
    }
  }

  Card _drawCard({bool isHidden = false}) {
    if (_deck.isEmpty) {
      _initializeDeck();
    }
    final card = _deck.removeLast();
    return Card(
      suit: card.suit,
      rank: card.rank,
      value: card.value,
      isHidden: isHidden,
    );
  }

  void _dealerPlay() async {
    // Reveal dealer's hidden card
    final revealedDealerHand =
        _gameState.dealerHand.map((card) {
          if (card.isHidden) {
            return Card(suit: card.suit, rank: card.rank, value: card.value);
          }
          return card;
        }).toList();

    _gameState = _gameState.copyWith(
      dealerHand: revealedDealerHand,
      gameMessage: 'Dealer total: ${_gameState.dealerTotal}',
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Dealer hits on 16 or less, stands on 17 or more
    while (_gameState.dealerTotal < 17) {
      await Future.delayed(const Duration(milliseconds: 800));

      final newCard = _drawCard();
      final newDealerHand = List<Card>.from(_gameState.dealerHand)
        ..add(newCard);

      _gameState = _gameState.copyWith(
        dealerHand: newDealerHand,
        gameMessage: 'Dealer hits: ${_gameState.dealerTotal}',
      );
      notifyListeners();
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    _determineWinner();
  }

  void _determineWinner() {
    final playerTotal = _gameState.playerTotal;
    final dealerTotal = _gameState.dealerTotal;

    String message;
    bool isWin = false;

    if (dealerTotal > 21) {
      message = 'Dealer bust! You win!';
      isWin = true;
    } else if (playerTotal > dealerTotal) {
      message = 'You win! $playerTotal vs $dealerTotal';
      isWin = true;
    } else if (playerTotal < dealerTotal) {
      message = 'Dealer wins! $dealerTotal vs $playerTotal';
      isWin = false;
    } else {
      message = 'Push! It\'s a tie';
      isWin = false;
    }

    _endRound(message, isWin: isWin);
  }

  void _endRound(String message, {bool isWin = false}) async {
    if (isWin) {
      // Player wins - increment score and continue
      SoundUtils.playNewLevelSound();
      _gameState = _gameState.copyWith(
        score: _gameState.score + 1,
        level: _gameState.level + 1,
        gameMessage: message,
        canHit: false,
        canStand: false,
        isDealerTurn: false,
      );

      // Count match wins only: +1 per round win
      await LeaderboardUtils.updateHighScore('twenty_one', 1);

      // Clear any saved state on success
      await clearSavedGameState();

      notifyListeners();

      // Auto-start next round after a short delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Clear the game message and prepare for new game
      _gameState = _gameState.copyWith(
        gameMessage: '',
        playerHand: [],
        dealerHand: [],
      );
      notifyListeners();

      // Start the new game
      startGame();
    } else {
      // Player loses - show game over dialog
      _gameState = _gameState.copyWith(
        status: TwentyOneGameStatus.gameOver,
        showGameOver: true,
        gameMessage: message,
        canHit: false,
        canStand: false,
      );

      SoundUtils.playGameOverSound();

      await LeaderboardUtils.updateHighScore('twenty_one', _gameState.score);

      notifyListeners();

      // Save state for rewarded-continue
      await _saveGameState();
    }
  }

  Future<void> _saveGameState() async {
    final state = {'level': _gameState.level, 'score': _gameState.score};
    await GameStateService().saveGameState('twenty_one', state);
    await GameStateService().saveGameScore('twenty_one', _gameState.score);
  }

  void _saveGameStateBeforeBust({
    required List<Card> playerHandBefore,
    required List<Card> dealerHand,
    required Card losingCard,
    required List<Card> deck,
  }) async {
    final state = {
      'type': 'bust',
      'score': _gameState.score,
      'level': _gameState.level,
      'playerHandBefore':
          playerHandBefore
              .map((c) => {'suit': c.suit, 'rank': c.rank, 'value': c.value})
              .toList(),
      'dealerHand':
          dealerHand
              .map(
                (c) => {
                  'suit': c.suit,
                  'rank': c.rank,
                  'value': c.value,
                  'isHidden': c.isHidden,
                },
              )
              .toList(),
      'losingCard': {
        'suit': losingCard.suit,
        'rank': losingCard.rank,
        'value': losingCard.value,
      },
      'deck':
          deck
              .map((c) => {'suit': c.suit, 'rank': c.rank, 'value': c.value})
              .toList(),
    };
    await GameStateService().saveGameState('twenty_one', state);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('twenty_one');
    if (saved == null) return false;
    try {
      if (saved['type'] == 'bust') {
        // Restore state before bust and allow a new hit (replace losing card)
        final score = (saved['score'] as int?) ?? 0;
        final level = (saved['level'] as int?) ?? 1;

        List<Card> playerHandBefore =
            ((saved['playerHandBefore'] as List?) ?? [])
                .map(
                  (m) => Card(
                    suit: m['suit'] as String,
                    rank: m['rank'] as String,
                    value: m['value'] as int,
                  ),
                )
                .toList();

        List<Card> dealerHand =
            ((saved['dealerHand'] as List?) ?? [])
                .map(
                  (m) => Card(
                    suit: m['suit'] as String,
                    rank: m['rank'] as String,
                    value: m['value'] as int,
                    isHidden: (m['isHidden'] as bool?) ?? false,
                  ),
                )
                .toList();

        final losing = saved['losingCard'] as Map?;
        final losingSuit = losing != null ? losing['suit'] as String : null;
        final losingRank = losing != null ? losing['rank'] as String : null;
        final losingValue = losing != null ? losing['value'] as int : null;

        List<Card> deck =
            ((saved['deck'] as List?) ?? [])
                .map(
                  (m) => Card(
                    suit: m['suit'] as String,
                    rank: m['rank'] as String,
                    value: m['value'] as int,
                  ),
                )
                .toList();

        // Remove the losing card from the deck if present to avoid drawing it again
        if (losingSuit != null && losingRank != null && losingValue != null) {
          deck.removeWhere(
            (c) =>
                c.suit == losingSuit &&
                c.rank == losingRank &&
                c.value == losingValue,
          );
        }

        // Apply restored state
        _deck = deck;
        _gameState = _gameState.copyWith(
          level: level,
          score: score,
          playerHand: playerHandBefore,
          dealerHand: dealerHand,
          status: TwentyOneGameStatus.playing,
          showGameOver: false,
          canHit: true,
          canStand: true,
          isDealerTurn: false,
          gameMessage: 'Bonus hit! Try again.',
        );

        // Clear the saved state after successful restore
        await clearSavedGameState();

        // Mark that continue has been used
        _hasUsedContinue = true;

        notifyListeners();
        return true;
      } else {
        // Fallback: start a fresh hand at the same level/score
        _gameState = _gameState.copyWith(
          level: (saved['level'] as int?) ?? 1,
          score: (saved['score'] as int?) ?? 0,
          status: TwentyOneGameStatus.playing,
          showGameOver: false,
          canHit: true,
          canStand: true,
          isDealerTurn: false,
        );
        _initializeDeck();
        _dealInitialCards();
        // Ensure buttons are enabled after dealing
        _gameState = _gameState.copyWith(
          canHit: true,
          canStand: true,
          isDealerTurn: false,
        );

        await clearSavedGameState();
        _hasUsedContinue = true;
        notifyListeners();
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> canContinueGame() async {
    if (_hasUsedContinue) return false;
    return await GameStateService().hasGameState('twenty_one');
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('twenty_one');
  }

  /// Pause the game (no timer to pause for this game)
  void pauseGame() {
    // This game doesn't have a timer, so nothing to pause
  }

  /// Resume the game (no timer to resume for this game)
  void resumeGame() {
    // This game doesn't have a timer, so nothing to resume
  }
}
