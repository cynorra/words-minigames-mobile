import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/higher_lower_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class HigherLowerProvider extends ChangeNotifier {
  HigherLowerGameState _gameState = const HigherLowerGameState();
  Timer? _animationTimer;
  final Random _random = Random();
  bool _hasBrokenRecordThisGame = false;
  bool _hasUsedContinue = false;

  HigherLowerGameState get gameState => _gameState;

  /// Rastgele sayı üretir (1-50 arası)
  int _generateRandomNumber() {
    return _random.nextInt(50) + 1;
  }

  /// Oyunu başlat
  void startGame() {
    // Önce animasyonu durdur (eğer çalışıyorsa)
    stopNumberAnimation();
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;

    _gameState = _gameState.copyWith(
      currentNumber: 0,
      previousNumber: null,
      score: 0,
      status: HigherLowerGameStatus.playing,
      showGameOver: false,
    );
    notifyListeners();

    // Sayı animasyonu başlat
    startNumberAnimation();
  }

  /// Rastgele sayı animasyonu başlat
  void startNumberAnimation() {
    SoundUtils.playSpinnerSound();
    _gameState = _gameState.copyWith(isAnimating: true);
    notifyListeners();

    // 2 saniye sonra animasyonu durdur ve final sayıyı göster
    Timer(const Duration(seconds: 2), () async {
      final finalNumber = _generateRandomNumber();
      _gameState = _gameState.copyWith(
        currentNumber: finalNumber,
        isAnimating: false,
      );
      await SoundUtils.stopSpinnerSound();
      notifyListeners();
    });
  }

  /// Rastgele sayı animasyonunu durdur
  void stopNumberAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  /// Pause the game (no timer to pause for this game)
  void pauseGame() {
    // This game doesn't have a timer, so nothing to pause
  }

  /// Resume the game (no timer to resume for this game)
  void resumeGame() {
    // This game doesn't have a timer, so nothing to resume
  }

  /// Oyunu sıfırla
  void resetGame() {
    _gameState = const HigherLowerGameState();
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;
    notifyListeners();
  }

  /// Yüksek tahmin
  void guessHigher() {
    if (!_gameState.isGameActive) return;
    SoundUtils.playTapSound();
    _makeGuess(true);
  }

  /// Düşük tahmin
  void guessLower() {
    if (!_gameState.isGameActive) return;
    SoundUtils.playTapSound();
    _makeGuess(false);
  }

  /// Tahmin yap
  void _makeGuess(bool isHigherGuess) {
    final previousNumber = _gameState.currentNumber;
    int newNumber = _generateRandomNumber();

    // Aynı sayı gelirse tekrar üret
    while (newNumber == previousNumber) {
      newNumber = _generateRandomNumber();
    }

    // Tahminin doğru olup olmadığını kontrol et
    final isCorrect =
        isHigherGuess ? newNumber > previousNumber : newNumber < previousNumber;

    if (isCorrect) {
      // Doğru tahmin - skoru artır ve yeni sayıyı göster
      _showNewNumberWithAnimation(
        previousNumber,
        newNumber,
        _gameState.score + 1,
      );
    } else {
      // Yanlış tahmin - oyun biter
      _gameOver(previousNumber, newNumber);
    }
  }

  /// Animasyonlu yeni sayı gösterimi
  void _showNewNumberWithAnimation(
    int previousNumber,
    int newNumber,
    int newScore,
  ) async {
    // Rekor kırıldıysa anında sesi çal (ilk skor hariç, bir kez, oyun aktifken)
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'higher_lower',
    );
    final previousHighScore = previousEntry?.highScore ?? 0;
    // Oyun bitti flag'i ve aktiflik kontrolü, async gap sonrası tekrar kontrol
    if (!_hasBrokenRecordThisGame &&
        previousEntry != null &&
        newScore > previousHighScore &&
        _gameState.isGameActive) {
      SoundUtils.playNewLevelSound();
      _hasBrokenRecordThisGame = true;
    }
    SoundUtils.playSpinnerSound();
    _gameState = _gameState.copyWith(
      previousNumber: previousNumber,
      isAnimating: true,
    );
    notifyListeners();

    // 2 saniye sonra animasyonu durdur ve final sayıyı göster
    Timer(const Duration(seconds: 2), () async {
      _gameState = _gameState.copyWith(
        currentNumber: newNumber,
        score: newScore,
        isAnimating: false,
      );
      await SoundUtils.stopSpinnerSound();
      notifyListeners();
    });
  }

  /// Oyun bitti
  void _gameOver(int previousNumber, int newNumber) async {
    // Önce yeni sayıyı animasyonlu göster
    SoundUtils.playSpinnerSound();
    _hasBrokenRecordThisGame = true;
    _gameState = _gameState.copyWith(
      previousNumber: previousNumber,
      isAnimating: true,
    );
    notifyListeners();

    // 2 saniye sonra animasyonu durdur ve oyun biter
    Timer(const Duration(seconds: 2), () async {
      _gameState = _gameState.copyWith(
        currentNumber: newNumber,
        status: HigherLowerGameStatus.gameOver,
        isAnimating: false,
        showGameOver: true,
      );
      await SoundUtils.stopSpinnerSound();
      notifyListeners();

      // Yüksek skoru güncelle
      _updateHighScore();
      // Save state for rewarded-continue
      await _saveGameState();
    });
  }

  /// Yüksek skoru güncelle
  void _updateHighScore() async {
    final previousHighScore = await LeaderboardUtils.getHighScore(
      'higher_lower',
    );
    if (_gameState.score > previousHighScore) {
      SoundUtils.playNewLevelSound();
    }
    await LeaderboardUtils.updateHighScore('higher_lower', _gameState.score);
  }

  Future<void> _saveGameState() async {
    final state = {
      'currentNumber': _gameState.currentNumber,
      'previousNumber': _gameState.previousNumber,
      'score': _gameState.score,
    };
    await GameStateService().saveGameState('higher_lower', state);
    await GameStateService().saveGameScore('higher_lower', _gameState.score);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('higher_lower');
    if (saved == null) return false;
    try {
      _gameState = _gameState.copyWith(
        currentNumber: (saved['currentNumber'] as int?) ?? 0,
        previousNumber: saved['previousNumber'] as int?,
        score: (saved['score'] as int?) ?? 0,
        status: HigherLowerGameStatus.playing,
        isAnimating: false,
        showGameOver: false,
      );

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
    return await GameStateService().hasGameState('higher_lower');
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('higher_lower');
  }

  /// Game over animasyonunu gizle
  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}
