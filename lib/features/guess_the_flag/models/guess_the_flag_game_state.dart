enum GuessTheFlagStatus { waiting, playing, gameOver }

class FlagData {
  final String countryName;
  final String flagEmoji;
  final String countryCode;

  const FlagData({
    required this.countryName,
    required this.flagEmoji,
    required this.countryCode,
  });
}

class GuessTheFlagGameState {
  final GuessTheFlagStatus status;
  final bool showGameOver;
  final int score;
  final int timeLeft;
  final int livesLeft;
  final FlagData? currentFlag;
  final List<String> options;
  final String? selectedAnswer;
  final bool isCorrect;

  const GuessTheFlagGameState({
    this.status = GuessTheFlagStatus.waiting,
    this.showGameOver = false,
    this.score = 0,
    this.timeLeft = 30,
    this.livesLeft = 3,
    this.currentFlag,
    this.options = const [],
    this.selectedAnswer,
    this.isCorrect = false,
  });

  GuessTheFlagGameState copyWith({
    GuessTheFlagStatus? status,
    bool? showGameOver,
    int? score,
    int? timeLeft,
    int? livesLeft,
    FlagData? currentFlag,
    List<String>? options,
    String? selectedAnswer,
    bool? isCorrect,
    bool clearSelectedAnswer = false,
  }) {
    return GuessTheFlagGameState(
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      livesLeft: livesLeft ?? this.livesLeft,
      currentFlag: currentFlag ?? this.currentFlag,
      options: options ?? this.options,
      // Allow explicit clearing of selectedAnswer
      selectedAnswer: clearSelectedAnswer
          ? null
          : (selectedAnswer ?? this.selectedAnswer),
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  bool get isWaiting => status == GuessTheFlagStatus.waiting;
  bool get isGameActive => status == GuessTheFlagStatus.playing;
  bool get isGameOver => status == GuessTheFlagStatus.gameOver;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuessTheFlagGameState &&
        other.status == status &&
        other.showGameOver == showGameOver &&
        other.score == score &&
        other.timeLeft == timeLeft &&
        other.livesLeft == livesLeft &&
        other.currentFlag == currentFlag &&
        other.options.toString() == options.toString() &&
        other.selectedAnswer == selectedAnswer &&
        other.isCorrect == isCorrect;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      showGameOver,
      score,
      timeLeft,
      livesLeft,
      currentFlag,
      options.toString(),
      selectedAnswer,
      isCorrect,
    );
  }
}
