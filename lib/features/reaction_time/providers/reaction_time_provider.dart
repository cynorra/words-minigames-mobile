import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/reaction_time_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class ReactionTimeProvider extends ChangeNotifier {
  ReactionTimeGameState _gameState = const ReactionTimeGameState();
  Timer? _timer;
  bool _hasUsedContinue = false;
  final Random _random = Random();
  Size? _gameAreaSize;

  ReactionTimeGameState get gameState => _gameState;

  /// Calculate score based on completion and time
  int calculateScore() {
    if (!_gameState.isCompleted) return 0;

    final baseScore = 0; // Points for completing all 12 targets
    final timeInSeconds = _gameState.elapsedTime;

    // Time bonus calculation:
    // - Perfect time (3.0s or less): +18 bonus points (total: 30)
    // - Good time (3.1-4.0s): +12 bonus points (total: 24)
    // - Average time (4.1-5.0s): +6 bonus points (total: 18)
    // - Slow time (5.1-6.0s): +3 bonus points (total: 15)
    // - Very slow time (6.1s+): +0 bonus points (total: 12)

    int timeBonus;
    if (timeInSeconds <= 5.0) {
      timeBonus = 24; // Perfect
    } else if (timeInSeconds <= 8.0) {
      timeBonus = 18; // Good
    } else if (timeInSeconds <= 12.0) {
      timeBonus = 12; // Average
    } else if (timeInSeconds <= 15.0) {
      timeBonus = 6; // Slow
    } else {
      timeBonus = 0; // Very slow
    }

    return baseScore + timeBonus;
  }

  /// Get time performance message
  String getTimePerformanceMessage() {
    if (!_gameState.isCompleted) return '';

    final timeInSeconds = _gameState.elapsedTime;

    if (timeInSeconds <= 5.0) {
      return 'perfectTime';
    } else if (timeInSeconds <= 8.0) {
      return 'goodTime';
    } else if (timeInSeconds <= 12.0) {
      return 'averageTime';
    } else if (timeInSeconds <= 15.0) {
      return 'slowTime';
    } else {
      return 'verySlowTime';
    }
  }

  /// Set the game area size for target positioning
  void setGameAreaSize(Size size) {
    _gameAreaSize = size;
    if (_gameState.isWaiting) {
      _generateTargetPositions();
    }
  }

  /// Start the game
  void startGame() async {
    _hasUsedContinue = false;
    _gameState = _gameState.copyWith(
      nextTarget: 1,
      elapsedTime: 0.0,
      status: ReactionTimeGameStatus.playing,
      showGameOver: false,
      isTimerRunning: false,
      completedTargets: {},
    );

    _generateTargetPositions();

    // Play game start sound
    await SoundUtils.playGameStartSound();

    notifyListeners();
  }

  /// Generate random positions for all 12 targets
  void _generateTargetPositions() {
    if (_gameAreaSize == null) return;

    const targetRadius = 20.0; // 40px diameter / 2
    const gap = 6.0;
    const minDistance = targetRadius * 2 + gap;
    const maxAttempts = 1000;

    final List<Offset> positions = [];
    final maxX = _gameAreaSize!.width - targetRadius - gap;
    final maxY = _gameAreaSize!.height - targetRadius - gap;
    final minX = targetRadius + gap;
    final minY = targetRadius + gap;

    for (int i = 0; i < 12; i++) {
      Offset? position;
      int attempts = 0;

      while (position == null && attempts < maxAttempts) {
        final candidateX = minX + _random.nextDouble() * (maxX - minX);
        final candidateY = minY + _random.nextDouble() * (maxY - minY);
        final candidate = Offset(candidateX, candidateY);

        // Check distance to all existing positions
        bool isValid = true;
        for (final existing in positions) {
          if ((candidate - existing).distance < minDistance) {
            isValid = false;
            break;
          }
        }

        if (isValid) {
          position = candidate;
        }
        attempts++;
      }

      // If we couldn't find a valid position, use a fallback
      if (position == null) {
        final fallbackX = minX + (i % 4) * (maxX - minX) / 3;
        final fallbackY = minY + (i ~/ 4) * (maxY - minY) / 2;
        position = Offset(fallbackX, fallbackY);
      }

      positions.add(position);
    }

    _gameState = _gameState.copyWith(targetPositions: positions);
  }

  /// Start the timer
  void _startTimer() {
    _timer?.cancel();
    _gameState = _gameState.copyWith(isTimerRunning: true);

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_gameState.isGameActive && _gameState.isTimerRunning) {
        _gameState = _gameState.copyWith(
          elapsedTime: _gameState.elapsedTime + 0.05,
        );
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  /// Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _gameState = _gameState.copyWith(isTimerRunning: false);
  }

  /// Pause the game (stop timer)
  void pauseGame() {
    if (_gameState.isGameActive && _gameState.isTimerRunning) {
      _timer?.cancel();
      _timer = null;
      _gameState = _gameState.copyWith(isTimerRunning: false);
    }
  }

  /// Resume the game (restart timer)
  void resumeGame() {
    if (_gameState.isGameActive && !_gameState.isTimerRunning) {
      _startTimer();
    }
  }

  /// Clean up game state when exiting
  void cleanupGame() {
    _stopTimer();
    _gameState = const ReactionTimeGameState();
    notifyListeners();
  }

  /// Handle target tap
  void onTargetTap(int targetNumber) async {
    if (!_gameState.isGameActive) return;

    // Check if this is the correct target
    if (targetNumber == _gameState.nextTarget) {
      // Start timer on first tap (target 1)
      if (targetNumber == 1) {
        _startTimer();
      }

      // Play tap sound
      SoundUtils.playTapSound();

      // Add to completed targets
      final updatedCompletedTargets = Set<int>.from(_gameState.completedTargets)
        ..add(targetNumber);

      final nextTarget = targetNumber + 1;

      // Check if game is completed
      if (nextTarget > 12) {
        _gameState = _gameState.copyWith(
          nextTarget: nextTarget,
          completedTargets: updatedCompletedTargets,
        );
        _gameOver();
      } else {
        _gameState = _gameState.copyWith(
          nextTarget: nextTarget,
          completedTargets: updatedCompletedTargets,
        );
        notifyListeners();
      }
    } else {
      // Wrong target - end the game immediately
      SoundUtils.playGameOverSound();
      _gameOverOnWrongTap();
    }
  }

  /// Game over
  void _gameOver() async {
    _stopTimer();

    final finalTime = _gameState.elapsedTime;

    _gameState = _gameState.copyWith(
      status: ReactionTimeGameStatus.gameOver,
      showGameOver: true,
      elapsedTime: finalTime,
    );

    // Play completion sound
    await SoundUtils.playWinnerSound();

    // Update high score (lower time is better)
    _updateHighScore();

    // Clear any saved state on successful completion
    await clearSavedGameState();

    notifyListeners();
  }

  /// Game over when wrong target is tapped
  void _gameOverOnWrongTap() async {
    _stopTimer();

    // Save game state for continue functionality
    await _saveGameState();

    _gameState = _gameState.copyWith(
      status: ReactionTimeGameStatus.gameOver,
      showGameOver: true,
      elapsedTime: _gameState.elapsedTime,
    );

    // Don't update high score for wrong taps
    notifyListeners();
  }

  /// Save current game state
  Future<void> _saveGameState() async {
    final gameStateService = GameStateService();
    final state = {
      'nextTarget': _gameState.nextTarget,
      'elapsedTime': _gameState.elapsedTime,
      'completedTargets': _gameState.completedTargets.toList(),
      'targetPositions':
          _gameState.targetPositions
              .map((pos) => {'dx': pos.dx, 'dy': pos.dy})
              .toList(),
    };

    await gameStateService.saveGameState('reaction_time', state);
    await gameStateService.saveGameScore('reaction_time', calculateScore());
    await gameStateService.saveGameLevel(
      'reaction_time',
      _gameState.nextTarget,
    );
  }

  /// Continue game from saved state
  Future<bool> continueGame() async {
    final gameStateService = GameStateService();
    final savedState = await gameStateService.loadGameState('reaction_time');

    if (savedState == null) return false;

    try {
      final nextTarget = savedState['nextTarget'] as int;
      final elapsedTime = savedState['elapsedTime'] as double;
      final completedTargets = Set<int>.from(
        savedState['completedTargets'] as List,
      );
      final targetPositions =
          (savedState['targetPositions'] as List)
              .map((pos) => Offset(pos['dx'] as double, pos['dy'] as double))
              .toList();

      _gameState = _gameState.copyWith(
        nextTarget: nextTarget,
        elapsedTime: elapsedTime,
        completedTargets: completedTargets,
        targetPositions: targetPositions,
        status: ReactionTimeGameStatus.playing,
        showGameOver: false,
        isTimerRunning: true,
      );

      // Mark that continue has been used
      _hasUsedContinue = true;

      _startTimer();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if game can be continued
  Future<bool> canContinueGame() async {
    if (_hasUsedContinue) return false;
    final gameStateService = GameStateService();
    return await gameStateService.hasGameState('reaction_time');
  }

  /// Clear saved game state
  Future<void> clearSavedGameState() async {
    final gameStateService = GameStateService();
    await gameStateService.clearGameState('reaction_time');
  }

  /// Update high score
  void _updateHighScore() async {
    final finalScore = calculateScore();

    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'reaction_time',
    );
    final previousBestScore = previousEntry?.highScore ?? 0;

    // Check if new record
    if (finalScore > previousBestScore) {
      SoundUtils.playNewLevelSound();
    }

    await LeaderboardUtils.updateHighScore('reaction_time', finalScore);
  }

  /// Reset the game
  void resetGame() {
    _stopTimer();
    _gameState = const ReactionTimeGameState();
    _hasUsedContinue = false;
    _generateTargetPositions();
    notifyListeners();
  }

  /// Hide game over animation
  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
