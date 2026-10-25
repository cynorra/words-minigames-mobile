enum TwentyOneGameStatus { waiting, playing, gameOver, won }

class Card {
  final String suit;
  final String rank;
  final int value;
  final bool isHidden;

  const Card({
    required this.suit,
    required this.rank,
    required this.value,
    this.isHidden = false,
  });

  String get displayName => isHidden ? '🂠' : '$rank$suit';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card &&
        other.suit == suit &&
        other.rank == rank &&
        other.value == value &&
        other.isHidden == isHidden;
  }

  @override
  int get hashCode => Object.hash(suit, rank, value, isHidden);
}

class TwentyOneGameState {
  final int score;
  final int level;
  final List<Card> playerHand;
  final List<Card> dealerHand;
  final TwentyOneGameStatus status;
  final bool showGameOver;
  final String gameMessage;
  final bool isDealerTurn;
  final bool canHit;
  final bool canStand;

  const TwentyOneGameState({
    this.score = 0,
    this.level = 1,
    this.playerHand = const [],
    this.dealerHand = const [],
    this.status = TwentyOneGameStatus.waiting,
    this.showGameOver = false,
    this.gameMessage = '',
    this.isDealerTurn = false,
    this.canHit = false,
    this.canStand = false,
  });

  TwentyOneGameState copyWith({
    int? score,
    int? level,
    List<Card>? playerHand,
    List<Card>? dealerHand,
    TwentyOneGameStatus? status,
    bool? showGameOver,
    String? gameMessage,
    bool? isDealerTurn,
    bool? canHit,
    bool? canStand,
  }) {
    return TwentyOneGameState(
      score: score ?? this.score,
      level: level ?? this.level,
      playerHand: playerHand ?? this.playerHand,
      dealerHand: dealerHand ?? this.dealerHand,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      gameMessage: gameMessage ?? this.gameMessage,
      isDealerTurn: isDealerTurn ?? this.isDealerTurn,
      canHit: canHit ?? this.canHit,
      canStand: canStand ?? this.canStand,
    );
  }

  bool get isWaiting => status == TwentyOneGameStatus.waiting;
  bool get isGameActive => status == TwentyOneGameStatus.playing;
  bool get isGameOver => status == TwentyOneGameStatus.gameOver;
  bool get isWon => status == TwentyOneGameStatus.won;

  int get playerTotal => _calculateHandTotal(playerHand);
  int get dealerTotal => _calculateHandTotal(dealerHand);
  int get dealerVisibleTotal =>
      _calculateHandTotal(dealerHand.where((card) => !card.isHidden).toList());

  int _calculateHandTotal(List<Card> hand) {
    int total = 0;
    int aces = 0;

    for (final card in hand) {
      if (card.isHidden) continue;
      if (card.rank == 'A') {
        aces++;
        total += 11;
      } else {
        total += card.value;
      }
    }

    // Adjust aces if needed
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }

    return total;
  }
}
