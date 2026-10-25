enum HigherLowerGameStatus { waiting, playing, gameOver, won }

class HigherLowerGameState {
  final int currentNumber;
  final int? previousNumber;
  final int score;
  final HigherLowerGameStatus status;
  final bool isAnimating;
  final int animatedNumber;
  final bool showGameOver;

  const HigherLowerGameState({
    this.currentNumber = 0,
    this.previousNumber,
    this.score = 0,
    this.status = HigherLowerGameStatus.waiting,
    this.isAnimating = false,
    this.animatedNumber = 0,
    this.showGameOver = false,
  });

  HigherLowerGameState copyWith({
    int? currentNumber,
    int? previousNumber,
    int? score,
    HigherLowerGameStatus? status,
    bool? isAnimating,
    int? animatedNumber,
    bool? showGameOver,
  }) {
    return HigherLowerGameState(
      currentNumber: currentNumber ?? this.currentNumber,
      previousNumber: previousNumber ?? this.previousNumber,
      score: score ?? this.score,
      status: status ?? this.status,
      isAnimating: isAnimating ?? this.isAnimating,
      animatedNumber: animatedNumber ?? this.animatedNumber,
      showGameOver: showGameOver ?? this.showGameOver,
    );
  }

  bool get isGameActive => status == HigherLowerGameStatus.playing;
  bool get isWaiting => status == HigherLowerGameStatus.waiting;
  bool get isGameOver => status == HigherLowerGameStatus.gameOver;
  bool get isWon => status == HigherLowerGameStatus.won;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HigherLowerGameState &&
        other.currentNumber == currentNumber &&
        other.previousNumber == previousNumber &&
        other.score == score &&
        other.status == status &&
        other.isAnimating == isAnimating &&
        other.animatedNumber == animatedNumber &&
        other.showGameOver == showGameOver;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentNumber,
      previousNumber,
      score,
      status,
      isAnimating,
      animatedNumber,
      showGameOver,
    );
  }
}
