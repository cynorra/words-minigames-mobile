import 'dart:async';
import 'package:flutter/material.dart';

import '../models/tictactoe_game_state.dart';
import '../../../core/utils/sound_utils.dart';

class TicTacToeProvider extends ChangeNotifier {
  TicTacToeGameState _gameState = const TicTacToeGameState();
  Timer? _computerTimer;
  bool _hasUsedContinue = false; // Track if user has already used continue

  TicTacToeGameState get gameState => _gameState;

  @override
  void dispose() {
    _computerTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    // Reset scores and rounds for new game
    final startingPlayer = TicTacToePlayer.player; // Always start with player

    _gameState = _gameState.copyWith(
      board: const [
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
      currentPlayer: startingPlayer,
      status: TicTacToeStatus.playing,
      showGameOver: false,
      gameOverReason: null,
      playerScore: 0, // Reset player score
      computerScore: 0, // Reset computer score
      roundsPlayed: 0, // Start from round 0
      winningLine: null, // Clear winning line to remove colored cells
      isComputerThinking: false,
    );
    _hasUsedContinue = false; // Reset continue usage
    notifyListeners();
  }

  void resetGame() {
    _computerTimer?.cancel();
    _gameState = _gameState.copyWith(
      board: const [
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
      currentPlayer: TicTacToePlayer.player,
      status: TicTacToeStatus.waiting,
      showGameOver: false,
      gameOverReason: null,
      playerScore: 0, // Reset player score
      computerScore: 0, // Reset computer score
      roundsPlayed: 0, // Start from round 0
      winningLine: null, // Clear winning line to remove colored cells
      isComputerThinking: false,
    );
    _hasUsedContinue = false; // Reset continue usage
    notifyListeners();
  }

  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  void onPlayerMove(int index) {
    if (!_gameState.isGameActive ||
        _gameState.isComputerThinking ||
        !_gameState.isPositionEmpty(index) ||
        _gameState.currentPlayer != TicTacToePlayer.player) {
      return;
    }

    // Play sound
    SoundUtils.playTapSound();

    // Make player move
    final newBoard = List<TicTacToePlayer>.from(_gameState.board);
    newBoard[index] = TicTacToePlayer.player;

    _gameState = _gameState.copyWith(
      board: newBoard,
      currentPlayer: TicTacToePlayer.computer,
      isComputerThinking: false,
    );

    // Check for game over
    final winner = _checkWinner(newBoard);
    if (winner != null || _isBoardFull(newBoard)) {
      _handleGameOver(winner);
      return;
    }

    notifyListeners();

    // Computer makes move immediately for smooth experience
    _computerTimer = Timer(const Duration(milliseconds: 300), () {
      _makeComputerMove();
    });
  }

  void _makeComputerMove() {
    if (_gameState.status != TicTacToeStatus.playing) return;

    final move = _getBestComputerMove(_gameState.board);
    if (move == -1) return;

    final newBoard = List<TicTacToePlayer>.from(_gameState.board);
    newBoard[move] = TicTacToePlayer.computer;

    _gameState = _gameState.copyWith(
      board: newBoard,
      currentPlayer: TicTacToePlayer.player,
      isComputerThinking: false,
    );

    // Check for game over
    final winner = _checkWinner(newBoard);
    if (winner != null || _isBoardFull(newBoard)) {
      _handleGameOver(winner);
      return;
    }

    notifyListeners();
  }

  int _getBestComputerMove(List<TicTacToePlayer> board) {
    // First, check if computer can win
    for (int i = 0; i < 9; i++) {
      if (board[i] == TicTacToePlayer.none) {
        final testBoard = List<TicTacToePlayer>.from(board);
        testBoard[i] = TicTacToePlayer.computer;
        if (_checkWinner(testBoard) == TicTacToePlayer.computer) {
          return i;
        }
      }
    }

    // Then, check if player can win and block them
    for (int i = 0; i < 9; i++) {
      if (board[i] == TicTacToePlayer.none) {
        final testBoard = List<TicTacToePlayer>.from(board);
        testBoard[i] = TicTacToePlayer.player;
        if (_checkWinner(testBoard) == TicTacToePlayer.player) {
          return i;
        }
      }
    }

    // Prefer center, then corners, then edges
    const priorityMoves = [4, 0, 2, 6, 8, 1, 3, 5, 7];
    for (int move in priorityMoves) {
      if (board[move] == TicTacToePlayer.none) {
        return move;
      }
    }

    return -1; // No moves available
  }

  TicTacToePlayer? _checkWinner(List<TicTacToePlayer> board) {
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

  bool _isBoardFull(List<TicTacToePlayer> board) {
    return !board.contains(TicTacToePlayer.none);
  }

  void _handleGameOver(TicTacToePlayer? winner) {
    GameOverReason reason;
    int newPlayerScore = _gameState.playerScore;
    int newComputerScore = _gameState.computerScore;

    if (winner == TicTacToePlayer.player) {
      reason = GameOverReason.playerWon;
      newPlayerScore++;
      SoundUtils.playWinnerSound();
    } else if (winner == TicTacToePlayer.computer) {
      reason = GameOverReason.computerWon;
      newComputerScore++;
      SoundUtils.playGameOverSound();
    } else {
      reason = GameOverReason.draw;
      SoundUtils.playGameOverSound();
      // For draw, don't increment scores - both stay the same
    }

    final winningLine = winner != null ? _gameState.getWinningLine() : null;

    if (reason == GameOverReason.computerWon) {
      // Computer won - end the game and show game over dialog
      _gameState = _gameState.copyWith(
        status: TicTacToeStatus.gameOver,
        showGameOver: true,
        gameOverReason: reason,
        playerScore: newPlayerScore,
        computerScore: newComputerScore,
        roundsPlayed: _gameState.roundsPlayed + 1,
        winningLine: winningLine,
        isComputerThinking: false,
      );
    } else {
      // Player won or draw - continue to next round
      final nextStartingPlayer =
          (_gameState.roundsPlayed + 1) % 2 == 0
              ? TicTacToePlayer.player
              : TicTacToePlayer.computer;

      // Always clear the board for next round
      final newBoard = const [
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
      ];

      _gameState = _gameState.copyWith(
        board: newBoard,
        currentPlayer: nextStartingPlayer,
        status: TicTacToeStatus.playing,
        showGameOver: false,
        gameOverReason: reason,
        playerScore: newPlayerScore,
        computerScore: newComputerScore,
        roundsPlayed: _gameState.roundsPlayed + 1,
        winningLine: null,
        isComputerThinking: false,
      );

      // If computer starts next round, make the first move
      if (nextStartingPlayer == TicTacToePlayer.computer) {
        _computerTimer = Timer(const Duration(milliseconds: 200), () {
          _makeComputerMove();
        });
      }
    }

    notifyListeners();
  }

  void pauseGame() {
    // This game doesn't have a timer, so nothing to pause
  }

  void resumeGame() {
    // This game doesn't have a timer, so nothing to resume
  }

  void cleanupGame() {
    _gameState = _gameState.copyWith(
      showGameOver: false,
      winningLine: null, // Clear winning line when cleaning up
    );
    notifyListeners();
  }

  // Continue game functionality - continue to next round after computer wins
  Future<bool> continueGame() async {
    if (!_hasUsedContinue &&
        _gameState.gameOverReason == GameOverReason.computerWon) {
      _hasUsedContinue = true;

      // Continue to next round
      final nextStartingPlayer =
          (_gameState.roundsPlayed + 1) % 2 == 0
              ? TicTacToePlayer.player
              : TicTacToePlayer.computer;

      // Clear the board for next round
      final newBoard = const [
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
        TicTacToePlayer.none,
      ];

      _gameState = _gameState.copyWith(
        board: newBoard,
        currentPlayer: nextStartingPlayer,
        status: TicTacToeStatus.playing,
        showGameOver: false,
        gameOverReason: null,
        roundsPlayed: _gameState.roundsPlayed + 1,
        winningLine: null,
        isComputerThinking: false,
      );

      // If computer starts next round, make the first move
      if (nextStartingPlayer == TicTacToePlayer.computer) {
        _computerTimer = Timer(const Duration(milliseconds: 500), () {
          _makeComputerMove();
        });
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> canContinueGame() async {
    // Can continue only once per game and only when computer won
    return !_hasUsedContinue &&
        _gameState.gameOverReason == GameOverReason.computerWon;
  }

  /// Get current score for leaderboard
  int getCurrentScore() {
    // Return total rounds played as score
    return _gameState.roundsPlayed;
  }

  /// Check if current game qualifies for leaderboard
  bool doesQualifyForLeaderboard() {
    // Qualify if player has won at least one game
    return _gameState.playerScore > 0;
  }
}
