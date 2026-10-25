import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/aim_trainer_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class AimTrainerProvider extends ChangeNotifier {
  AimTrainerGameState _gameState = const AimTrainerGameState();
  Timer? _timer;
  Timer? _civilianTimer;
  final Random _random = Random();
  Size? _gameAreaSize;
  bool _hasBrokenRecordThisGame = false;
  bool _hasUsedContinue = false;

  AimTrainerGameState get gameState => _gameState;

  /// Set the game area size for target positioning
  void setGameAreaSize(Size size) {
    _gameAreaSize = size;
    if (_gameState.isGameActive) {
      _generateNewTarget();
    }
  }

  /// Start the game
  void startGame() async {
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;
    _gameState = _gameState.copyWith(
      score: 0,
      timeLeft: 20,
      status: AimTrainerGameStatus.playing,
      showGameOver: false,
      showCivilian: false,
      civilianPosition: null,
      gameOverReason: null,
    );

    _generateNewTarget();
    _startTimer();
    _startCivilianTimer();

    // Oyun başlama sesi çal
    await SoundUtils.playGameStartSound();

    notifyListeners();
  }

  /// Start the timer
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
        _gameOver(GameOverReason.timeUp);
      }
    });
  }

  /// Start civilian timer to randomly show civilians
  void _startCivilianTimer() {
    _civilianTimer?.cancel();
    _civilianTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_gameState.isGameActive && !_gameState.showCivilian) {
        // 30% chance to show civilian
        if (_random.nextDouble() < 0.3) {
          _showCivilian();
        }
      }
    });
  }

  /// Show civilian target
  void _showCivilian() {
    if (_gameAreaSize == null) return;

    const civilianRadius = 18.0; // Reduced from 24px
    final maxX = _gameAreaSize!.width - civilianRadius;
    final maxY = _gameAreaSize!.height - civilianRadius;
    final minX = civilianRadius;
    final minY = civilianRadius;

    final newX = minX + _random.nextDouble() * (maxX - minX);
    final newY = minY + _random.nextDouble() * (maxY - minY);

    _gameState = _gameState.copyWith(
      civilianPosition: Offset(newX, newY),
      showCivilian: true,
    );

    // Hide civilian after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (_gameState.isGameActive) {
        _gameState = _gameState.copyWith(showCivilian: false);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _civilianTimer?.cancel();
    _civilianTimer = null;
  }

  /// Pause the game (stop timers)
  void pauseGame() {
    if (_gameState.isGameActive) {
      _timer?.cancel();
      _timer = null;
      _civilianTimer?.cancel();
      _civilianTimer = null;
    }
  }

  /// Resume the game (restart timers)
  void resumeGame() {
    if (_gameState.isGameActive) {
      _startTimer();
      _startCivilianTimer();
    }
  }

  /// Clean up game state when exiting
  void cleanupGame() {
    _stopTimer();
    _gameState = const AimTrainerGameState();
    _hasBrokenRecordThisGame = false;
    notifyListeners();
  }

  /// Generate a new target at a random position
  void _generateNewTarget() {
    if (_gameAreaSize == null) return;

    // Target radius is 18px, so we need to account for that in positioning
    const targetRadius = 18.0;
    final maxX = _gameAreaSize!.width - targetRadius;
    final maxY = _gameAreaSize!.height - targetRadius;
    final minX = targetRadius;
    final minY = targetRadius;

    final newX = minX + _random.nextDouble() * (maxX - minX);
    final newY = minY + _random.nextDouble() * (maxY - minY);

    _gameState = _gameState.copyWith(targetPosition: Offset(newX, newY));
  }

  /// Handle target tap
  void onTargetTap() async {
    if (!_gameState.isGameActive) return;

    final newScore = _gameState.score + 1;
    // Rekor kırıldıysa anında sesi çal (ilk skor hariç, bir kez, oyun aktifken)
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'aim_trainer',
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
    _gameState = _gameState.copyWith(score: newScore);

    // Laser sesi çal (asenkron, await yok)
    SoundUtils.playLaserSound();

    _generateNewTarget();
    notifyListeners();
  }

  /// Handle civilian tap
  void onCivilianTap() async {
    if (!_gameState.isGameActive) return;

    // Game over when civilian is hit
    _gameOver(GameOverReason.civilianHit);
  }

  /// Game over
  void _gameOver(GameOverReason reason) async {
    _stopTimer();
    _hasBrokenRecordThisGame = true;

    // Ensure we capture the final score before setting game over
    final finalScore = _gameState.score;

    _gameState = _gameState.copyWith(
      status: AimTrainerGameStatus.gameOver,
      showGameOver: true,
      score: finalScore, // Explicitly set the final score
      gameOverReason: reason,
      showCivilian: false, // Hide civilian when game ends
    );

    // Oyun bitiş sesi çal
    await SoundUtils.playGameOverSound();

    // Update high score
    _updateHighScore();
    notifyListeners();

    // Save state for rewarded-continue
    await _saveGameState();
  }

  /// Update high score
  void _updateHighScore() async {
    final previousHighScore = await LeaderboardUtils.getHighScore(
      'aim_trainer',
    );
    if (_gameState.score > previousHighScore) {
      SoundUtils.playNewLevelSound();
    }
    await LeaderboardUtils.updateHighScore('aim_trainer', _gameState.score);
  }

  /// Reset the game
  void resetGame() {
    _stopTimer();
    _gameState = const AimTrainerGameState();
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;
    notifyListeners();
  }

  Future<void> _saveGameState() async {
    final state = {'score': _gameState.score, 'timeLeft': _gameState.timeLeft};
    await GameStateService().saveGameState('aim_trainer', state);
    await GameStateService().saveGameScore('aim_trainer', _gameState.score);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('aim_trainer');
    if (saved == null) return false;
    try {
      final restoredScore = (saved['score'] as int?) ?? 0;
      final restoredTimeLeft = (saved['timeLeft'] as int?) ?? 0;
      final resumedTimeLeft = restoredTimeLeft + 10; // +10s bonus on continue



      _gameState = _gameState.copyWith(
        score: restoredScore,
        timeLeft: resumedTimeLeft,
        status: AimTrainerGameStatus.playing,
        showGameOver: false,
      );
      _startTimer();
      _startCivilianTimer();

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
    final hasState = await GameStateService().hasGameState('aim_trainer');
    return hasState;
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('aim_trainer');
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
