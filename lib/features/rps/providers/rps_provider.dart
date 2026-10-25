import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/rps_game_state.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class RpsProvider extends ChangeNotifier {
  final Random _rng = Random();
  Timer? _cpuAnimTimer;
  RpsGameState _state = const RpsGameState();
  bool _hasUsedContinue = false;
  // Shuffle-bag for fair CPU choices (ensures near-equal distribution)
  final List<RpsChoice> _cpuBag = [];

  RpsGameState get state => _state;

  void start() {
    _hasUsedContinue = false;
    _state = _state.copyWith(isWaiting: false);
    if (_cpuBag.isEmpty) _refillCpuBag();
    notifyListeners();
  }

  void reset() {
    _cpuAnimTimer?.cancel();
    _state = const RpsGameState();
    _hasUsedContinue = false;
    _cpuBag.clear();
    notifyListeners();
  }

  void hideDialog() {
    _state = _state.copyWith(showGameOver: false);
    notifyListeners();
  }

  void onPick(RpsChoice pick) {
    if (_state.showGameOver ||
        _state.isWaiting ||
        _state.isPlayerSelectionLocked) {
      return;
    }

    SoundUtils.playTapSound();
    _state = _state.copyWith(
      playerPick: pick,
      cpuPick: null,
      isPlayerSelectionLocked: true,
    );
    notifyListeners();

    // start cpu animation
    const emojis = ['✊', '✋', '✌️'];
    int idx = 0;
    _cpuAnimTimer?.cancel();
    SoundUtils.playSpinnerSound();
    _state = _state.copyWith(isCpuAnimating: true);
    notifyListeners();

    _cpuAnimTimer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      _state = _state.copyWith(cpuAnimEmoji: emojis[idx % emojis.length]);
      idx++;
      notifyListeners();
    });

    Future.delayed(const Duration(milliseconds: 650), () async {
      _cpuAnimTimer?.cancel();
      await SoundUtils.stopSpinnerSound();
      final cpu = _drawCpuChoice();
      _state = _state.copyWith(
        isCpuAnimating: false,
        cpuPick: cpu,
        isPlayerSelectionLocked: false,
      );

      final res = _roundResult(pick, cpu);
      if (res > 0) {
        _state = _state.copyWith(
          bannerTextKey: 'youWin',
          youScore: _state.youScore + 1,
        );
        SoundUtils.playNewLevelSound();
      } else if (res < 0) {
        _state = _state.copyWith(
          bannerTextKey: 'youLose',
          cpuScore: _state.cpuScore + 1,
        );
        SoundUtils.playLaserSound();
      } else {
        _state = _state.copyWith(bannerTextKey: 'tie');
      }
      _state = _state.copyWith(showBanner: true);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 900));
      _state = _state.copyWith(
        showBanner: false,
        isPlayerSelectionLocked: false,
      );
      notifyListeners();

      if (_state.youScore >= 5 || _state.cpuScore >= 5) {
        final youWon = _state.youScore >= 5;
        _state = _state.copyWith(showGameOver: true, youWon: youWon);
        notifyListeners();
        // Count match wins only: +1 per match won
        if (youWon) {
          await LeaderboardUtils.updateHighScore('rps', 1);
        }
        // Save state for rewarded-continue
        await _saveGameState();
      }
    });
  }

  // Draw a CPU choice from a shuffled bag to ensure fairness over short runs
  RpsChoice _drawCpuChoice() {
    if (_cpuBag.isEmpty) {
      _refillCpuBag();
    }
    return _cpuBag.removeLast();
  }

  void _refillCpuBag() {
    // 5 copies of each ensures 15-length cycle with equal counts
    const int repeats = 5;
    _cpuBag
      ..clear()
      ..addAll(List<RpsChoice>.filled(repeats, RpsChoice.rock))
      ..addAll(List<RpsChoice>.filled(repeats, RpsChoice.paper))
      ..addAll(List<RpsChoice>.filled(repeats, RpsChoice.scissors));
    // Shuffle
    for (int i = _cpuBag.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = _cpuBag[i];
      _cpuBag[i] = _cpuBag[j];
      _cpuBag[j] = tmp;
    }
  }

  int _roundResult(RpsChoice a, RpsChoice b) {
    if (a == b) return 0;
    if ((a == RpsChoice.rock && b == RpsChoice.scissors) ||
        (a == RpsChoice.paper && b == RpsChoice.rock) ||
        (a == RpsChoice.scissors && b == RpsChoice.paper)) {
      return 1;
    }
    return -1;
  }

  Future<void> _saveGameState() async {
    final state = {'youScore': _state.youScore, 'cpuScore': _state.cpuScore};
    await GameStateService().saveGameState('rps', state);
    await GameStateService().saveGameScore('rps', _state.youScore);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('rps');
    if (saved == null) return false;
    try {
      // Reduce CPU score by 1 as a reward for watching the ad
      final savedCpuScore = (saved['cpuScore'] as int?) ?? 0;
      final reducedCpuScore = savedCpuScore > 0 ? savedCpuScore - 1 : 0;

      _state = _state.copyWith(
        youScore: (saved['youScore'] as int?) ?? 0,
        cpuScore: reducedCpuScore,
        showGameOver: false,
        isCpuAnimating: false,
        cpuPick: null,
        playerPick: null,
        isPlayerSelectionLocked: false,
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
    return await GameStateService().hasGameState('rps');
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('rps');
  }

  /// Hide game over flag
  void hideGameOver() {
    _state = _state.copyWith(showGameOver: false);
    notifyListeners();
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
