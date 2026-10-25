import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pattern_memory_game_state.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/services/game_state_service.dart';

class PatternMemoryProvider extends ChangeNotifier {
  PatternMemoryGameState _gameState = const PatternMemoryGameState();
  Timer? _showTimer;
  Timer? _successTimer;
  bool _hasBrokenRecordThisGame = false;
  bool _hasUsedContinue = false;

  PatternMemoryGameState get gameState => _gameState;

  @override
  void dispose() {
    _showTimer?.cancel();
    _successTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    _hasBrokenRecordThisGame = false; // Reset record breaking flag
    _hasUsedContinue = false;

    _gameState = _gameState.copyWith(
      level: 1,
      score: 0,
      status: PatternMemoryGameStatus.waiting,
      showGameOver: false,
      pattern: [],
      userSelection: [],
      correctSelections: [],
      wrongIndices: [],
    );
    notifyListeners();

    // Start the game immediately after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      generateNewPattern();
    });
  }

  void generateNewPattern() {
    final random = Random();
    final pattern = <int>{};
    const gridSize = 25; // 5x5 grid

    // Generate unique random indices for the pattern
    while (pattern.length < _gameState.patternLength) {
      pattern.add(random.nextInt(gridSize));
    }

    _gameState = _gameState.copyWith(
      pattern: pattern.toList(),
      userSelection: [],
      correctSelections: [],
      status: PatternMemoryGameStatus.show,
      wrongIndices: [],
    );

    // Show pattern for 3 seconds
    _showTimer = Timer(const Duration(seconds: 3), () {
      _gameState = _gameState.copyWith(status: PatternMemoryGameStatus.input);
      notifyListeners();
    });

    notifyListeners();
  }

  void onTileTapped(int index) {
    if (_gameState.status != PatternMemoryGameStatus.input) {
      return;
    }

    // Play sound
    SoundUtils.playTapSound();

    // Check if this tile is already correctly selected
    if (_gameState.correctSelections.contains(index)) {
      return; // Don't allow deselecting correct tiles
    }

    final newSelection = List<int>.from(_gameState.userSelection);

    if (newSelection.contains(index)) {
      // Deselect tile
      newSelection.remove(index);
    } else {
      // Select tile
      newSelection.add(index);

      // Check if this selection is correct
      if (_gameState.pattern.contains(index)) {
        // Correct selection - add to correct selections
        final newCorrectSelections = List<int>.from(
          _gameState.correctSelections,
        )..add(index);
        _gameState = _gameState.copyWith(
          userSelection: newSelection,
          correctSelections: newCorrectSelections,
        );

        // Check if all pattern tiles are found
        if (newCorrectSelections.length == _gameState.patternLength) {
          _onSuccess();
          return;
        }
      } else {
        // Wrong selection - add to wrong indices and show feedback
        final newWrongIndices = List<int>.from(_gameState.wrongIndices)
          ..add(index);
        _gameState = _gameState.copyWith(
          userSelection: newSelection,
          wrongIndices: newWrongIndices,
        );

        // Show feedback for 2 seconds then game over
        Timer(const Duration(seconds: 2), () {
          _onFail();
        });

        notifyListeners();
        return;
      }
    }

    _gameState = _gameState.copyWith(userSelection: newSelection);
    notifyListeners();
  }

  void _onSuccess() async {
    // Simple score system: +1 point per level (consistent with other games)
    final newScore = _gameState.score + 1;
    final newLevel = _gameState.level + 1;

    // Check for record breaking before updating state
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'pattern_memory',
    );
    final previousHighScore = previousEntry?.highScore ?? 0;

    // Play record breaking sound if applicable
    if (!_hasBrokenRecordThisGame &&
        previousEntry != null &&
        newScore > previousHighScore) {
      SoundUtils.playNewLevelSound();
      _hasBrokenRecordThisGame = true;
    }

    _gameState = _gameState.copyWith(
      score: newScore,
      level: newLevel,
      status: PatternMemoryGameStatus.success,
    );

    // Save score to leaderboard
    LeaderboardUtils.updateHighScore('pattern_memory', newScore);

    // Clear any saved state on success
    await clearSavedGameState();

    // Play success sound
    SoundUtils.playWinnerSound();

    // Start next level after 500ms delay
    _successTimer = Timer(const Duration(milliseconds: 500), () {
      generateNewPattern();
    });

    notifyListeners();
  }

  /// Get performance message based on level
  String getPerformanceMessage() {
    final level = _gameState.level;

    if (level <= 3) {
      return 'beginner';
    } else if (level <= 6) {
      return 'intermediate';
    } else if (level <= 10) {
      return 'advanced';
    } else if (level <= 15) {
      return 'expert';
    } else {
      return 'master';
    }
  }

  void _onFail() {
    _hasBrokenRecordThisGame =
        true; // Set flag to prevent further record sounds

    _gameState = _gameState.copyWith(
      status: PatternMemoryGameStatus.fail,
      showGameOver: true,
      wrongIndices: [], // Clear wrong indices when showing game over
    );

    // Play game over sound
    SoundUtils.playGameOverSound();

    notifyListeners();

    // Save state for rewarded-continue
    _saveGameState();
  }

  void hideGameOver() {
    _gameState = _gameState.copyWith(
      showGameOver: false,
      wrongIndices: [], // Clear wrong indices when hiding game over
    );
    notifyListeners();
  }

  void resetGame() {
    _showTimer?.cancel();
    _successTimer?.cancel();
    _gameState = const PatternMemoryGameState();
    _hasUsedContinue = false;
    notifyListeners();
  }

  Future<void> _saveGameState() async {
    final state = {
      'level': _gameState.level,
      'score': _gameState.score,
      'patternLength': _gameState.patternLength,
    };
    await GameStateService().saveGameState('pattern_memory', state);
    await GameStateService().saveGameScore('pattern_memory', _gameState.score);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('pattern_memory');
    if (saved == null) return false;
    try {
      _gameState = _gameState.copyWith(
        level: (saved['level'] as int?) ?? 1,
        score: (saved['score'] as int?) ?? 0,
        status: PatternMemoryGameStatus.waiting,
        showGameOver: false,
      );
      // regenerate next pattern
      generateNewPattern();

      // Clear the saved state after successful restore
      await clearSavedGameState();

      // Mark that continue has been used
      _hasUsedContinue = true;

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> canContinueGame() async {
    if (_hasUsedContinue) return false;
    return await GameStateService().hasGameState('pattern_memory');
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('pattern_memory');
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
