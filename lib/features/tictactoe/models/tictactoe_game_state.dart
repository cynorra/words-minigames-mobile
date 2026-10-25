enum TicTacToeStatus { waiting, playing, gameOver, won, draw }

enum TicTacToePlayer { player, computer, none }

enum GameOverReason { playerWon, computerWon, draw }

class TicTacToeGameState {
  final List<TicTacToePlayer> board;
  final TicTacToePlayer currentPlayer;
  final TicTacToeStatus status;
  final bool showGameOver;
  final GameOverReason? gameOverReason;
  final int playerScore;
  final int computerScore;
  final int roundsPlayed;
  final bool isComputerThinking;
  final List<int>? winningLine;

  const TicTacToeGameState({
    this.board = const [
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
      TicTacToePlayer.none,
    ],
    this.currentPlayer = TicTacToePlayer.player,
    this.status = TicTacToeStatus.waiting,
    this.showGameOver = false,
    this.gameOverReason,
    this.playerScore = 0,
    this.computerScore = 0,
    this.roundsPlayed = 0,
    this.isComputerThinking = false,
    this.winningLine,
  });

  TicTacToeGameState copyWith({
    List<TicTacToePlayer>? board,
    TicTacToePlayer? currentPlayer,
    TicTacToeStatus? status,
    bool? showGameOver,
    GameOverReason? gameOverReason,
    int? playerScore,
    int? computerScore,
    int? roundsPlayed,
    bool? isComputerThinking,
    List<int>? winningLine,
  }) {
    return TicTacToeGameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      playerScore: playerScore ?? this.playerScore,
      computerScore: computerScore ?? this.computerScore,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      isComputerThinking: isComputerThinking ?? this.isComputerThinking,
      winningLine: winningLine ?? this.winningLine,
    );
  }

  bool get isWaiting => status == TicTacToeStatus.waiting;
  bool get isGameActive => status == TicTacToeStatus.playing;
  bool get isGameOver => status == TicTacToeStatus.gameOver;
  bool get isWon => status == TicTacToeStatus.won;
  bool get isDraw => status == TicTacToeStatus.draw;

  /// Check if the board is full
  bool get isBoardFull => !board.contains(TicTacToePlayer.none);

  /// Check if a position is empty
  bool isPositionEmpty(int index) => board[index] == TicTacToePlayer.none;

  /// Get the winner of the current game
  TicTacToePlayer? get winner {
    // Check rows
    for (int i = 0; i < 3; i++) {
      final rowStart = i * 3;
      if (board[rowStart] != TicTacToePlayer.none &&
          board[rowStart] == board[rowStart + 1] &&
          board[rowStart] == board[rowStart + 2]) {
        return board[rowStart];
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] != TicTacToePlayer.none &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return board[i];
      }
    }

    // Check diagonals
    if (board[0] != TicTacToePlayer.none &&
        board[0] == board[4] &&
        board[0] == board[8]) {
      return board[0];
    }

    if (board[2] != TicTacToePlayer.none &&
        board[2] == board[4] &&
        board[2] == board[6]) {
      return board[2];
    }

    return null;
  }

  /// Get the winning line positions
  List<int>? getWinningLine() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      final rowStart = i * 3;
      if (board[rowStart] != TicTacToePlayer.none &&
          board[rowStart] == board[rowStart + 1] &&
          board[rowStart] == board[rowStart + 2]) {
        return [rowStart, rowStart + 1, rowStart + 2];
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] != TicTacToePlayer.none &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return [i, i + 3, i + 6];
      }
    }

    // Check diagonals
    if (board[0] != TicTacToePlayer.none &&
        board[0] == board[4] &&
        board[0] == board[8]) {
      return [0, 4, 8];
    }

    if (board[2] != TicTacToePlayer.none &&
        board[2] == board[4] &&
        board[2] == board[6]) {
      return [2, 4, 6];
    }

    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicTacToeGameState &&
        other.board.toString() == board.toString() &&
        other.currentPlayer == currentPlayer &&
        other.status == status &&
        other.showGameOver == showGameOver &&
        other.gameOverReason == gameOverReason &&
        other.playerScore == playerScore &&
        other.computerScore == computerScore &&
        other.roundsPlayed == roundsPlayed &&
        other.isComputerThinking == isComputerThinking &&
        other.winningLine.toString() == winningLine.toString();
  }

  @override
  int get hashCode {
    return Object.hash(
      board.toString(),
      currentPlayer,
      status,
      showGameOver,
      gameOverReason,
      playerScore,
      computerScore,
      roundsPlayed,
      isComputerThinking,
      winningLine.toString(),
    );
  }
}
