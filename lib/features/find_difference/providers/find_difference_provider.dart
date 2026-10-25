// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

import '../models/find_difference_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';
import '../../../core/theme/app_theme.dart';

class FindDifferenceProvider extends ChangeNotifier {
  final Random _random = Random();
  FindDifferenceGameState _gameState = const FindDifferenceGameState();
  Timer? _timeTimer;
  bool _hasUsedContinue = false;

  FindDifferenceGameState get gameState => _gameState;

  void startGame() {
    _hasUsedContinue = false;
    _gameState = const FindDifferenceGameState(
      status: FindDifferenceStatus.playing,
      mistakesLeft: 3, // Start with 3 mistakes allowed
      timeLeft: 30, // Total game time: 30 seconds
    );
    _generateRound();
    _startTimer();
    notifyListeners();
  }

  void resetGame() {
    _timeTimer?.cancel();
    _gameState = const FindDifferenceGameState();
    _hasUsedContinue = false;
    notifyListeners();
  }

  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  void hideTimeUp() {
    _gameState = _gameState.copyWith(showTimeUp: false);
    notifyListeners();
  }

  void hideContinueDialog() {
    _gameState = _gameState.copyWith(showContinueDialog: false);
    notifyListeners();
  }

  void _startTimer() {
    _timeTimer?.cancel();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.timeLeft > 0) {
        _gameState = _gameState.copyWith(timeLeft: _gameState.timeLeft - 1);

        // Play countdown sound when 3 seconds or less remain
        if (_gameState.timeLeft <= 3 && _gameState.timeLeft > 0) {
          SoundUtils.playCountDownSound();
        }

        notifyListeners();
      } else {
        _timeUp(); // Call time up instead of game over
      }
    });
  }

  /// Pause the game (stop timer)
  void pauseGame() {
    if (_gameState.isGameActive) {
      _timeTimer?.cancel();
      _timeTimer = null;
    }
  }

  /// Resume the game (restart timer)
  void resumeGame() {
    if (_gameState.isGameActive) {
      _startTimer();
    }
  }

  /// Clean up game state when exiting
  void cleanupGame() {
    _timeTimer?.cancel();
    _timeTimer = null;
    _gameState = const FindDifferenceGameState();
    notifyListeners();
  }

  void _gameOverWithMistakes() {
    _timeTimer?.cancel();
    _gameState = _gameState.copyWith(
      status: FindDifferenceStatus.gameOver,
      showGameOver: false, // Don't show dialog
      showContinueDialog: true, // Show continue game dialog
      // Keep the correct answer highlighted permanently
      pulseIndex: _gameState.oddIndex,
    );
    notifyListeners();
    _saveGameState();
  }

  void _timeUp() {
    _timeTimer?.cancel();
    _gameState = _gameState.copyWith(
      status: FindDifferenceStatus.gameOver,
      showTimeUp: false, // Don't show time up dialog
      showContinueDialog: true, // Show continue game dialog
      // Keep the correct answer highlighted permanently
      pulseIndex: _gameState.oddIndex,
    );
    notifyListeners();
    _saveGameState();
  }

  int _gridForLevel(int level) {
    // Much faster grid size increase for higher difficulty
    if (level <= 2) return 2; // Levels 1-2: 2x2 (4 squares)
    if (level <= 4) return 3; // Levels 3-4: 3x3 (9 squares)
    if (level <= 6) return 4; // Levels 5-6: 4x4 (16 squares)
    if (level <= 8) return 5; // Levels 7-8: 5x5 (25 squares)
    if (level <= 10) return 6; // Levels 9-10: 6x6 (36 squares)
    if (level <= 12) return 7; // Levels 11-12: 7x7 (49 squares)
    if (level <= 14) return 8; // Levels 13-14: 8x8 (64 squares)
    if (level <= 16) return 9; // Levels 15-16: 9x9 (81 squares)
    return 10; // Level 17+: 10x10 (100 squares)
  }

  double _deltaForLevel(int level) {
    // Much more aggressive difficulty increase
    if (level <= 3) {
      // Levels 1-3: Very challenging visibility (0.12-0.08)
      final delta = 0.12 - (level - 1) * 0.02;
      return delta.clamp(0.05, 1.0);
    }
    if (level <= 6) {
      // Levels 4-6: Extremely challenging visibility (0.08-0.05)
      final delta = 0.08 - (level - 4) * 0.01;
      return delta.clamp(0.03, 1.0);
    }
    if (level <= 9) {
      // Levels 7-9: Very difficult visibility (0.05-0.03)
      final delta = 0.05 - (level - 7) * 0.01;
      return delta.clamp(0.02, 1.0);
    }
    if (level <= 12) {
      // Levels 10-12: Extremely difficult visibility (0.03-0.02)
      final delta = 0.03 - (level - 10) * 0.005;
      return delta.clamp(0.015, 1.0);
    }
    if (level <= 15) {
      // Levels 13-15: Ultimate difficulty visibility (0.02-0.015)
      final delta = 0.02 - (level - 13) * 0.0025;
      return delta.clamp(0.01, 1.0);
    }
    // Levels 16+: Maximum difficulty
    return 0.01;
  }

  void _generateRound() {
    final grid = _gridForLevel(_gameState.level);
    final total = grid * grid;
    final oddIndex = _random.nextInt(total);

    // Completely random color selection from a diverse palette
    final basePalette = <HSVColor>[
      HSVColor.fromColor(const Color(0xFF64DD17)), // vivid green
      HSVColor.fromColor(AppTheme.darkPrimary), // purple
      HSVColor.fromColor(AppTheme.darkSuccess), // success green
      HSVColor.fromColor(AppTheme.darkWarning), // yellow
      HSVColor.fromColor(AppTheme.darkError), // soft red
      HSVColor.fromColor(AppTheme.darkSecondary), // soft purple
      HSVColor.fromColor(const Color(0xFF2196F3)), // blue
      HSVColor.fromColor(const Color(0xFFFF9800)), // orange
      HSVColor.fromColor(const Color(0xFF9C27B0)), // deep purple
      HSVColor.fromColor(const Color(0xFF00BCD4)), // cyan
      HSVColor.fromColor(const Color(0xFF795548)), // brown
      HSVColor.fromColor(const Color(0xFF607D8B)), // blue grey
    ];

    // Randomly select base color instead of using level-based rotation
    final baseHSV = basePalette[_random.nextInt(basePalette.length)];
    final delta = _deltaForLevel(_gameState.level);
    final bool darker = _random.nextBool();
    final double baseV = baseHSV.value;

    double tryValueShift(bool preferDarker) {
      double v = preferDarker ? (baseV - delta) : (baseV + delta);
      // If shift collapses due to bounds or becomes too tiny, flip direction
      if (v < 0.0 || v > 1.0 || (baseV - v).abs() < 0.01) {
        v = preferDarker ? (baseV + delta) : (baseV - delta);
      }
      // Clamp and return
      return v.clamp(0.0, 1.0);
    }

    // First attempt: adjust value (brightness)
    double oddV = tryValueShift(darker);
    HSVColor oddHSV = baseHSV.withValue(oddV);

    // Convert to concrete colors
    Color baseColor = baseHSV.toColor();
    Color oddColor = oddHSV.toColor();

    // Safety fallbacks: ensure oddColor differs from baseColor even after rounding
    if (oddColor.value == baseColor.value) {
      // Try slightly stronger value shift
      final double epsilon = 0.02;
      final double altV = (oddV + (oddV > baseV ? epsilon : -epsilon)).clamp(
        0.0,
        1.0,
      );
      oddHSV = baseHSV.withValue(altV);
      oddColor = oddHSV.toColor();
    }
    if (oddColor.value == baseColor.value) {
      // Try saturation tweak while keeping shade perception
      final double sat = baseHSV.saturation;
      final double altS = (sat * 0.9).clamp(0.0, 1.0);
      oddHSV = oddHSV.withSaturation(altS);
      oddColor = oddHSV.toColor();
    }
    if (oddColor.value == baseColor.value) {
      // Last resort: minor hue nudge (very small to keep visual consistency)
      final double altH = (baseHSV.hue + 1.5) % 360;
      oddHSV = oddHSV.withHue(altH);
      oddColor = oddHSV.toColor();
    }

    _gameState = _gameState.copyWith(
      grid: grid,
      oddIndex: oddIndex,
      baseColor: baseColor,
      oddColor: oddColor,
      wrongFlashIndex: null,
      pulseIndex: null,
      // Don't reset time - keep the total game time running
    );
  }

  Future<void> onTapTile(int index) async {
    if (!_gameState.isGameActive) return;

    if (index == _gameState.oddIndex) {
      // Correct - no border animation, just proceed to next level
      SoundUtils.playTapSound();
      _gameState = _gameState.copyWith(
        // Score equals passed levels count
        score: _gameState.score + 1,
        level: _gameState.level + 1,
      );
      _generateRound();
      notifyListeners();

      // Best effort leaderboard update
      await LeaderboardUtils.updateHighScore(
        'find_difference',
        _gameState.score,
      );
    } else {
      // Wrong tap - reduce mistakes left
      final newMistakesLeft = _gameState.mistakesLeft - 1;

      if (newMistakesLeft <= 0) {
        // No mistakes left - game over with permanent highlight
        SoundUtils.playGameOverSound();
        _gameState = _gameState.copyWith(
          wrongFlashIndex: index,
          mistakesLeft: 0,
        );
        notifyListeners();

        // Show wrong flash for 200ms
        await Future.delayed(const Duration(milliseconds: 200));

        // Game over with permanent correct answer highlight
        _gameOverWithMistakes();

        // Update leaderboard
        await LeaderboardUtils.updateHighScore(
          'find_difference',
          _gameState.score,
        );
      } else {
        // Still have mistakes left - continue game
        SoundUtils.playGameOverSound();
        _gameState = _gameState.copyWith(
          wrongFlashIndex: index,
          mistakesLeft: newMistakesLeft,
        );
        notifyListeners();

        // Show wrong flash for 200ms
        await Future.delayed(const Duration(milliseconds: 200));

        // Clear flash and continue
        _gameState = _gameState.copyWith(wrongFlashIndex: null);
        notifyListeners();
      }
    }
  }

  Future<void> _saveGameState() async {
    final state = {
      'level': _gameState.level,
      'score': _gameState.score,
      'timeLeft': _gameState.timeLeft,
      'mistakesLeft': _gameState.mistakesLeft,
    };
    await GameStateService().saveGameState('find_difference', state);
    await GameStateService().saveGameScore('find_difference', _gameState.score);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('find_difference');
    if (saved == null) return false;
    try {
      // When continuing after watching ad, restore time from where user left off
      // but keep the current score, advance to next level, and give full 3 lives
      final currentScore = (saved['score'] as int?) ?? 0;
      final currentLevel = (saved['level'] as int?) ?? 1;
      final savedTimeLeft = (saved['timeLeft'] as int?) ?? 30;

      _gameState = _gameState.copyWith(
        level: currentLevel + 1, // Continue from next level
        score: currentScore, // Keep current score
        timeLeft: savedTimeLeft, // Restore actual time left
        mistakesLeft: 3, // Give full 3 lives on continue
        status: FindDifferenceStatus.playing,
        showGameOver: false,
        showTimeUp: false,
        showContinueDialog: false,
        pulseIndex: null,
        wrongFlashIndex: null,
      );
      _startTimer();
      _generateRound();

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
    return await GameStateService().hasGameState('find_difference');
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('find_difference');
  }
}
