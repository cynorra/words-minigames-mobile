enum PatternMemoryGameStatus { waiting, show, input, success, fail }

class PatternMemoryGameState {
  final int score;
  final int level;
  final List<int> pattern;
  final List<int> userSelection;
  final List<int> correctSelections;
  final PatternMemoryGameStatus status;
  final bool showGameOver;
  final List<int> wrongIndices;

  const PatternMemoryGameState({
    this.score = 0,
    this.level = 1,
    this.pattern = const [],
    this.userSelection = const [],
    this.correctSelections = const [],
    this.status = PatternMemoryGameStatus.waiting,
    this.showGameOver = false,
    this.wrongIndices = const [],
  });

  PatternMemoryGameState copyWith({
    int? score,
    int? level,
    List<int>? pattern,
    List<int>? userSelection,
    List<int>? correctSelections,
    PatternMemoryGameStatus? status,
    bool? showGameOver,
    List<int>? wrongIndices,
  }) {
    return PatternMemoryGameState(
      score: score ?? this.score,
      level: level ?? this.level,
      pattern: pattern ?? this.pattern,
      userSelection: userSelection ?? this.userSelection,
      correctSelections: correctSelections ?? this.correctSelections,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      wrongIndices: wrongIndices ?? this.wrongIndices,
    );
  }

  int get patternLength => 3 + (level - 1);
  bool get isGameActive => status == PatternMemoryGameStatus.input;
  bool get isShowingPattern => status == PatternMemoryGameStatus.show;
  bool get isWaiting => status == PatternMemoryGameStatus.waiting;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatternMemoryGameState &&
        other.score == score &&
        other.level == level &&
        other.pattern.length == pattern.length &&
        other.userSelection.length == userSelection.length &&
        other.correctSelections.length == correctSelections.length &&
        other.status == status &&
        other.showGameOver == showGameOver &&
        other.wrongIndices.length == wrongIndices.length;
  }

  @override
  int get hashCode {
    return Object.hash(
      score,
      level,
      pattern.length,
      userSelection.length,
      correctSelections.length,
      status,
      showGameOver,
      wrongIndices.length,
    );
  }
}
