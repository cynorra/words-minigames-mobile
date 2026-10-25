// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/color_hunt_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class ColorHuntProvider extends ChangeNotifier {
  ColorHuntGameState _gameState = const ColorHuntGameState();
  Timer? _timer;
  final Random _random = Random();
  bool _hasBrokenRecordThisGame = false;
  bool _hasUsedContinue = false;

  ColorHuntGameState get gameState => _gameState;

  // Enhanced color keys with more distinct and easily differentiable colors
  final Map<String, Color> _colorMap = {
    'red': const Color(0xFFE53E3E), // Red
    'orange': const Color(0xFFFF6B35), // Orange
    'yellow': const Color(0xFFFFD700), // Yellow (Gold)
    'green': const Color(0xFF38A169), // Green
    'blue': const Color(0xFF3182CE), // Blue
    'indigo': const Color(0xFF3F51B5), // Indigo
    'purple': const Color(0xFF805AD5), // Violet/Purple
  };

  // Only use the 7 main colors above as selectable options
  final List<Color> _availableColors = [
    const Color(0xFFE53E3E), // Red
    const Color(0xFFFF6B35), // Orange
    const Color(0xFFFFD700), // Yellow (Gold)
    const Color(0xFF38A169), // Green
    const Color(0xFF3182CE), // Blue
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF805AD5), // Violet/Purple
  ];

  /// Oyunu başlat
  void startGame() {
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;
    _gameState = _gameState.copyWith(
      score: 0,
      timeLeft: 30,
      status: ColorHuntGameStatus.playing,
      showGameOver: false,
      wrongTapIndex: null,
    );

    _generateNewTarget();
    _startTimer();
    notifyListeners();
  }

  /// Timer'ı başlat
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.timeLeft > 0) {
        _gameState = _gameState.copyWith(timeLeft: _gameState.timeLeft - 1);

        // Son 4 saniyede geri sayım sesi çal
        if (_gameState.timeLeft <= 3 && _gameState.timeLeft > 0) {
          SoundUtils.playCountDownSound();
        }

        notifyListeners();
      } else {
        _gameOver();
      }
    });
  }

  /// Timer'ı durdur
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Pause the game (stop timer)
  void pauseGame() {
    if (_gameState.isGameActive) {
      _timer?.cancel();
      _timer = null;
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
    _stopTimer();
    _gameState = const ColorHuntGameState();
    _hasBrokenRecordThisGame = false;
    notifyListeners();
  }

  /// Yeni hedef oluştur
  void _generateNewTarget() {
    final colorKeys = _colorMap.keys.toList();
    final targetColorKey = colorKeys[_random.nextInt(colorKeys.length)];
    final targetColor = _colorMap[targetColorKey]!;

    // Create more interesting text color combinations
    // Always use a different color for the text to increase confusion (Stroop effect)
    Color textColor;
    int attempts = 0;
    do {
      textColor = _availableColors[_random.nextInt(_availableColors.length)];
      attempts++;
      if (attempts > 20) {
        // Failsafe: break to avoid a potential infinite loop in extreme cases
        break;
      }
    } while (textColor == targetColor ||
        _isColorTooSimilar(textColor, targetColor));

    // Ensure target color is always in the available options
    final availableColorsForDisplay = <Color>[];

    // First, add the target color
    availableColorsForDisplay.add(targetColor);

    // Then add 3 other distinct colors (excluding target color and similar colors)
    final otherColors =
        _availableColors.where((color) => color != targetColor).toList();
    otherColors.shuffle();

    // Add 3 distinct colors, avoiding colors that are too similar
    for (int i = 0; i < 3 && i < otherColors.length; i++) {
      final candidateColor = otherColors[i];

      // Check if this color is too similar to any already selected color
      bool isTooSimilar = false;
      for (final selectedColor in availableColorsForDisplay) {
        if (_isColorTooSimilar(candidateColor, selectedColor)) {
          isTooSimilar = true;
          break;
        }
      }

      if (!isTooSimilar) {
        availableColorsForDisplay.add(candidateColor);
      } else {
        // Try to find a more distinct color
        for (int j = i + 1; j < otherColors.length; j++) {
          final alternativeColor = otherColors[j];
          bool isAlternativeTooSimilar = false;

          for (final selectedColor in availableColorsForDisplay) {
            if (_isColorTooSimilar(alternativeColor, selectedColor)) {
              isAlternativeTooSimilar = true;
              break;
            }
          }

          if (!isAlternativeTooSimilar) {
            availableColorsForDisplay.add(alternativeColor);
            break;
          }
        }

        // If we still don't have enough colors, just add the original
        if (availableColorsForDisplay.length < 4) {
          availableColorsForDisplay.add(candidateColor);
        }
      }
    }

    // Ensure invariants:
    // 1) targetColor MUST be present among options
    // 2) Exactly 4 distinct colors
    // 3) Avoid colors that are too similar
    // Remove duplicates first
    final distinctSet = <int, Color>{};
    for (final c in availableColorsForDisplay) {
      distinctSet[c.value] = c;
    }
    availableColorsForDisplay
      ..clear()
      ..addAll(distinctSet.values);

    // Ensure targetColor present
    if (!availableColorsForDisplay.contains(targetColor)) {
      availableColorsForDisplay.insert(0, targetColor);
    }

    // Fill up to 4 with distinct, not-too-similar colors
    if (availableColorsForDisplay.length < 4) {
      for (final candidate in _availableColors) {
        if (availableColorsForDisplay.length >= 4) break;
        if (candidate == targetColor) continue;
        bool similarToAny = false;
        for (final existing in availableColorsForDisplay) {
          if (_isColorTooSimilar(candidate, existing)) {
            similarToAny = true;
            break;
          }
        }
        if (!similarToAny && !availableColorsForDisplay.contains(candidate)) {
          availableColorsForDisplay.add(candidate);
        }
      }
    }

    // If still fewer than 4, append any remaining distinct colors
    while (availableColorsForDisplay.length < 4) {
      final fallback =
          _availableColors[_random.nextInt(_availableColors.length)];
      if (!availableColorsForDisplay.contains(fallback)) {
        availableColorsForDisplay.add(fallback);
      }
    }

    // Trim to exactly 4 while keeping targetColor
    if (availableColorsForDisplay.length > 4) {
      // Keep target and first 3 others
      final trimmed = <Color>[];
      trimmed.add(targetColor);
      for (final c in availableColorsForDisplay) {
        if (trimmed.length >= 4) break;
        if (c == targetColor) continue;
        if (!trimmed.contains(c)) trimmed.add(c);
      }
      availableColorsForDisplay
        ..clear()
        ..addAll(trimmed);
    }

    // Shuffle the final list to randomize positions
    availableColorsForDisplay.shuffle();

    _gameState = _gameState.copyWith(
      targetColorKey: targetColorKey,
      targetColor: targetColor,
      textColor: textColor,
      availableColors: availableColorsForDisplay,
    );
  }

  /// Check if two colors are too similar to each other
  bool _isColorTooSimilar(Color color1, Color color2) {
    // Convert colors to HSV for better similarity comparison
    final hsv1 = HSVColor.fromColor(color1);
    final hsv2 = HSVColor.fromColor(color2);

    // Calculate hue difference (considering circular nature of hue)
    double hueDiff = (hsv1.hue - hsv2.hue).abs();
    if (hueDiff > 180) hueDiff = 360 - hueDiff;

    // Calculate saturation and value differences
    final satDiff = (hsv1.saturation - hsv2.saturation).abs();
    final valDiff = (hsv1.value - hsv2.value).abs();

    // Colors are too similar if:
    // - Hue difference is less than 30 degrees AND
    // - Saturation difference is less than 0.3 AND
    // - Value difference is less than 0.3
    return hueDiff < 30 && satDiff < 0.3 && valDiff < 0.3;
  }

  /// Renk kutusuna tıklandığında
  void onColorTap(int index) {
    if (!_gameState.isGameActive) return;

    final tappedColor = _gameState.availableColors[index];
    final targetColor = _gameState.targetColor;

    if (tappedColor == targetColor) {
      // Doğru renk seçildi
      _correctAnswer();
    } else {
      // Yanlış renk seçildi
      _wrongAnswer(index);
    }
  }

  /// Doğru cevap
  void _correctAnswer() async {
    // Rekor kırıldıysa anında sesi çal (ilk skor hariç, bir kez, oyun aktifken)
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'color_hunt',
    );
    final previousHighScore = previousEntry?.highScore ?? 0;
    final newScore = _gameState.score + 1;
    // Oyun bitti flag'i ve aktiflik kontrolü, async gap sonrası tekrar kontrol
    if (!_hasBrokenRecordThisGame &&
        previousEntry != null &&
        newScore > previousHighScore &&
        _gameState.isGameActive) {
      SoundUtils.playNewLevelSound();
      _hasBrokenRecordThisGame = true;
    }
    // Blink sesi çal (asenkron, await yok)
    SoundUtils.playBlinkSound();

    _gameState = _gameState.copyWith(score: newScore, wrongTapIndex: null);

    _generateNewTarget();

    // Clear any saved state since user is continuing successfully
    await clearSavedGameState();

    notifyListeners();
  }

  /// Yanlış cevap
  void _wrongAnswer(int wrongIndex) async {
    _stopTimer();
    _hasBrokenRecordThisGame = true;

    // Ensure we capture the final score before setting game over
    final finalScore = _gameState.score;

    // Save state BEFORE setting game over status
    await _saveGameState();

    _gameState = _gameState.copyWith(
      wrongTapIndex: wrongIndex,
      status: ColorHuntGameStatus.gameOver,
      showGameOver: true,
      score: finalScore, // Explicitly set the final score
    );

    notifyListeners();

    // Yüksek skoru güncelle
    _updateHighScore();
  }

  /// Oyun bitti
  void _gameOver() async {
    _stopTimer();
    _hasBrokenRecordThisGame = true;

    // Ensure we capture the final score before setting game over
    final finalScore = _gameState.score;

    // Save state BEFORE setting game over status
    await _saveGameState();

    _gameState = _gameState.copyWith(
      status: ColorHuntGameStatus.gameOver,
      showGameOver: true,
      score: finalScore, // Explicitly set the final score
    );

    // Yüksek skoru güncelle
    _updateHighScore();
    notifyListeners();
  }

  /// Yüksek skoru güncelle
  void _updateHighScore() async {
    final previousHighScore = await LeaderboardUtils.getHighScore('color_hunt');
    if (_gameState.score > previousHighScore) {
      SoundUtils.playNewLevelSound();
    }
    await LeaderboardUtils.updateHighScore('color_hunt', _gameState.score);
  }

  /// Oyunu sıfırla
  void resetGame() {
    _stopTimer();
    _gameState = const ColorHuntGameState();
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;
    notifyListeners();
  }

  Future<void> _saveGameState() async {
    final state = {'score': _gameState.score, 'timeLeft': _gameState.timeLeft};

    await GameStateService().saveGameState('color_hunt', state);
    await GameStateService().saveGameScore('color_hunt', _gameState.score);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('color_hunt');
    if (saved == null) {
      return false;
    }

    try {
      final savedScore = (saved['score'] as int?) ?? 0;
      final savedTimeLeft = (saved['timeLeft'] as int?) ?? 30;

      // Restore game state with both score and time from where user left off
      _gameState = _gameState.copyWith(
        score: savedScore,
        timeLeft: savedTimeLeft, // Restore the actual time left
        status: ColorHuntGameStatus.playing,
        showGameOver: false,
        wrongTapIndex: null,
      );

      // Generate a new target as if user never made a mistake
      _generateNewTarget();

      // Restart the timer with the saved time (not reset to 30)
      _startTimer();

      // Clear the saved state after successful restore
      await clearSavedGameState();

      // Mark that continue has been used
      _hasUsedContinue = true;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canContinueGame() async {
    if (_hasUsedContinue) return false;
    final hasState = await GameStateService().hasGameState('color_hunt');
    return hasState;
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('color_hunt');
  }

  /// Game over animasyonunu gizle
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
