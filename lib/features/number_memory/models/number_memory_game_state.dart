class NumberMemoryGameState {
  final int score;
  final int level;
  final List<int> sequence;
  final List<int> userInput;
  final bool isShowingSequence;
  final bool isWaitingForInput;
  final bool showGameOver;
  final bool showCorrectMessage;
  final List<int> wrongIndices;
  final bool isGameActive;
  final bool showContinueDialog;

  const NumberMemoryGameState({
    this.score = 0,
    this.level = 1,
    this.sequence = const [],
    this.userInput = const [],
    this.isShowingSequence = false,
    this.isWaitingForInput = false,
    this.showGameOver = false,
    this.showCorrectMessage = false,
    this.wrongIndices = const [],
    this.isGameActive = false,
    this.showContinueDialog = false,
  });

  NumberMemoryGameState copyWith({
    int? score,
    int? level,
    List<int>? sequence,
    List<int>? userInput,
    bool? isShowingSequence,
    bool? isWaitingForInput,
    bool? showGameOver,
    bool? showCorrectMessage,
    List<int>? wrongIndices,
    bool? isGameActive,
    bool? showContinueDialog,
  }) {
    return NumberMemoryGameState(
      score: score ?? this.score,
      level: level ?? this.level,
      sequence: sequence ?? this.sequence,
      userInput: userInput ?? this.userInput,
      isShowingSequence: isShowingSequence ?? this.isShowingSequence,
      isWaitingForInput: isWaitingForInput ?? this.isWaitingForInput,
      showGameOver: showGameOver ?? this.showGameOver,
      showCorrectMessage: showCorrectMessage ?? this.showCorrectMessage,
      wrongIndices: wrongIndices ?? this.wrongIndices,
      isGameActive: isGameActive ?? this.isGameActive,
      showContinueDialog: showContinueDialog ?? this.showContinueDialog,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NumberMemoryGameState &&
        other.score == score &&
        other.level == level &&
        other.sequence.length == sequence.length &&
        other.userInput.length == userInput.length &&
        other.isShowingSequence == isShowingSequence &&
        other.isWaitingForInput == isWaitingForInput &&
        other.showGameOver == showGameOver &&
        other.showCorrectMessage == showCorrectMessage &&
        other.wrongIndices.length == wrongIndices.length &&
        other.isGameActive == isGameActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      score,
      level,
      sequence.length,
      userInput.length,
      isShowingSequence,
      isWaitingForInput,
      showGameOver,
      showCorrectMessage,
      wrongIndices.length,
      isGameActive,
    );
  }
}
