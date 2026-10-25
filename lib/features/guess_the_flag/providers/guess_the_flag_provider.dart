import 'dart:async';
import 'package:flutter/material.dart';

import '../models/guess_the_flag_game_state.dart';
import '../data/flag_data.dart';
import '../../../core/utils/sound_utils.dart';

class GuessTheFlagProvider extends ChangeNotifier {
  GuessTheFlagGameState _gameState = const GuessTheFlagGameState();
  Timer? _gameTimer;
  bool _isSessionActive = false;
  bool _hasUsedAdContinue = false; // Track if rewarded-continue used once

  GuessTheFlagGameState get gameState => _gameState;

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    _gameTimer?.cancel();

    // Generate initial flag and options
    final flag = FlagDataService.getRandomFlag();
    final options = FlagDataService.getRandomOptions(flag, 4);

    _gameState = _gameState.copyWith(
      status: GuessTheFlagStatus.playing,
      showGameOver: false,
      score: 0,
      timeLeft: 30,
      livesLeft: 3,
      currentFlag: flag,
      options: options,
      clearSelectedAnswer: true,
      isCorrect: false,
    );

    _isSessionActive = true;
    _hasUsedAdContinue = false;
    _startTimer();
    notifyListeners();
  }

  void resetGame() {
    _gameTimer?.cancel();
    _isSessionActive = false;
    _gameState = const GuessTheFlagGameState();
    _hasUsedAdContinue = false;
    notifyListeners();
  }

  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (!_gameState.isGameActive || _gameState.selectedAnswer != null) {
      return;
    }

    // Normalize comparison to avoid issues with casing/whitespace
    bool _equalsNormalized(String? a, String? b) {
      if (a == null || b == null) return false;
      return a.trim().toLowerCase() == b.trim().toLowerCase();
    }

    final isCorrect = _equalsNormalized(
      answer,
      _gameState.currentFlag?.countryName,
    );

    _gameState = _gameState.copyWith(
      selectedAnswer: answer,
      isCorrect: isCorrect,
    );

    // Play sound
    if (isCorrect) {
      SoundUtils.playWinnerSound();
    } else {
      SoundUtils.playGameOverSound();
    }

    notifyListeners();

    // Proceed to next question quickly for flow
    Timer(const Duration(milliseconds: 400), () {
      _handleAnswerResult(isCorrect);
    });
  }

  void _handleAnswerResult(bool isCorrect) {
    if (!_isSessionActive) return;
    if (isCorrect) {
      _nextFlag(incrementScore: true);
      return;
    }

    // Wrong answer: decrement life and check game over
    final remainingLives = (_gameState.livesLeft - 1).clamp(0, 3);
    if (remainingLives <= 0) {
      _gameState = _gameState.copyWith(livesLeft: 0);
      _endGame();
      return;
    }

    // Continue with next flag with updated lives
    _nextFlag(incrementScore: false, livesLeft: remainingLives);
  }

  void _nextFlag({required bool incrementScore, int? livesLeft}) {
    // Generate new flag and options
    final flag = FlagDataService.getRandomFlag();
    final options = FlagDataService.getRandomOptions(flag, 4);

    // Apply next question state in one update to avoid transient stale values
    _gameState = _gameState.copyWith(
      score: incrementScore ? _gameState.score + 1 : _gameState.score,
      // Do not reset timer; session-wide 30s applies to whole game
      currentFlag: flag,
      options: options,
      livesLeft: livesLeft ?? _gameState.livesLeft,
      clearSelectedAnswer: true,
      isCorrect: false,
    );

    notifyListeners();
  }

  // Lives mechanic removed in session mode

  void _endGame() {
    _gameTimer?.cancel();
    _isSessionActive = false;
    _gameState = _gameState.copyWith(
      status: GuessTheFlagStatus.gameOver,
      showGameOver: true,
    );
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.timeLeft <= 1) {
        timer.cancel();
        _endGame();
        return;
      }

      _gameState = _gameState.copyWith(timeLeft: _gameState.timeLeft - 1);
      notifyListeners();
    });
  }

  void pauseGame() {
    _gameTimer?.cancel();
  }

  void resumeGame() {
    if (_gameState.isGameActive) {
      _startTimer();
    }
  }

  void cleanupGame() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  // Continue mechanic removed in session mode
  Future<bool> continueGame() async {
    // Allow continue only if game is over and not used before
    if (!_gameState.isGameOver || _hasUsedAdContinue) return false;

    // Resume session
    _isSessionActive = true;
    _hasUsedAdContinue = true;

    // Add +20s and +1 life (max 3)
    final newTime = _gameState.timeLeft + 20;
    final newLives = (_gameState.livesLeft + 1).clamp(0, 3);

    // Prepare next flag
    final flag = FlagDataService.getRandomFlag();
    final options = FlagDataService.getRandomOptions(flag, 4);

    _gameState = _gameState.copyWith(
      status: GuessTheFlagStatus.playing,
      showGameOver: false,
      timeLeft: newTime,
      livesLeft: newLives,
      currentFlag: flag,
      options: options,
      clearSelectedAnswer: true,
      isCorrect: false,
    );

    // Restart timer
    _startTimer();
    notifyListeners();
    return true;
  }

  // For this game, we don't offer one-time continue to ad-free users
  Future<bool> canContinueGame() async => false;

  /// Get current score for leaderboard
  int getCurrentScore() {
    return _gameState.score;
  }

  /// Check if current game qualifies for leaderboard
  bool doesQualifyForLeaderboard() {
    return _gameState.score > 0;
  }
}
