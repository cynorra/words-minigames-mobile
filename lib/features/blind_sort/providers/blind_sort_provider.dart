import 'package:flutter/material.dart';
import 'dart:async';
import '../../../shared/models/game_state.dart';
import '../../../core/utils/game_utils.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/game_state_service.dart';

class BlindSortProvider extends ChangeNotifier {
  GameState _gameState = GameState();
  Timer? _numberAnimationTimer;
  int _animatedNumber = 0;
  bool _isAnimating = false;
  Set<int> _usedNumbers = {}; // Kullanılmış sayıları takip etmek için
  bool _hasBrokenRecordThisGame = false;
  bool _hasUsedContinue = false;

  GameState get gameState => _gameState;
  int get animatedNumber => _animatedNumber;
  bool get isAnimating => _isAnimating;

  /// Kullanılmamış rastgele sayı üretir
  int _generateUniqueRandomNumber() {
    final availableNumbers = <int>[];
    for (int i = 1; i <= 50; i++) {
      if (!_usedNumbers.contains(i)) {
        availableNumbers.add(i);
      }
    }

    if (availableNumbers.isEmpty) {
      // Tüm sayılar kullanılmışsa, oyunu kazandı olarak işaretle
      return -1; // Özel durum için -1 döndür
    }

    availableNumbers.shuffle();
    return availableNumbers.first;
  }

  /// Mevcut slot düzenine yerleştirilebilen ve henüz kullanılmamış aday sayıları döndürür
  List<int> _getPlaceableCandidates(List<int?> slots, {Set<int>? usedOverride}) {
    final used = usedOverride ?? _usedNumbers;
    final candidates = <int>[];
    for (int i = 1; i <= 50; i++) {
      if (!used.contains(i) && GameUtils.canPlaceNumberAnywhere(slots, i)) {
        candidates.add(i);
      }
    }
    return candidates;
  }

  /// Oyunu başlat
  void startGame() {
    // Önce animasyonu durdur (eğer çalışıyorsa)
    stopNumberAnimation();
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;

    // Kullanılmış sayıları sıfırla
    _usedNumbers.clear();

    _gameState = _gameState.copyWith(
      status: GameStatus.playing,
      slots: const <int?>[
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
      ],
      currentNumber: _generateUniqueRandomNumber(),
      score: 0,
      showGameOver: false,
    );

    // İlk sayıyı kullanılmış olarak işaretle
    if (_gameState.currentNumber != null && _gameState.currentNumber! > 0) {
      _usedNumbers.add(_gameState.currentNumber!);
    }

    notifyListeners();
  }

  /// Rastgele sayı animasyonu başlat
  void startNumberAnimation() {
    SoundUtils.playSpinnerSound();
    _isAnimating = true;
    _animatedNumber = _generateUniqueRandomNumber();
    notifyListeners();

    _numberAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      _animatedNumber = _generateUniqueRandomNumber();
      notifyListeners();
    });

    // 2 saniye sonra animasyonu durdur ve final sayıyı göster
    Timer(const Duration(seconds: 2), () async {
      stopNumberAnimation();
      final finalNumber = _generateUniqueRandomNumber();

      if (finalNumber == -1) {
        // Tüm sayılar kullanılmış, oyunu kazandı olarak işaretle
        await SoundUtils.stopSpinnerSound();
        _gameWon(_gameState.score);
        return;
      }

      _gameState = _gameState.copyWith(currentNumber: finalNumber);
      _animatedNumber = finalNumber;
      _isAnimating = false;

      // Final sayıyı kullanılmış olarak işaretle
      _usedNumbers.add(finalNumber);

      await SoundUtils.stopSpinnerSound();
      notifyListeners();
    });
  }

  /// Rastgele sayı animasyonunu durdur
  void stopNumberAnimation() {
    _numberAnimationTimer?.cancel();
    _numberAnimationTimer = null;
  }

  /// Pause the game (no timer to pause for this game)
  void pauseGame() {
    // This game doesn't have a timer, so nothing to pause
  }

  /// Resume the game (no timer to resume for this game)
  void resumeGame() {
    // This game doesn't have a timer, so nothing to resume
  }

  /// Clean up game state when exiting
  void cleanupGame() {
    stopNumberAnimation();
    _gameState = GameState();
    _usedNumbers.clear();
    _hasBrokenRecordThisGame = false;
    notifyListeners();
  }

  /// Oyunu sıfırla
  void resetGame() {
    _gameState = GameState();
    _usedNumbers.clear(); // Kullanılmış sayıları da sıfırla
    _hasBrokenRecordThisGame = false;
    _hasUsedContinue = false;
    notifyListeners();
  }

  /// Game over animasyonunu gizle
  void hideGameOver() {
    _gameState = _gameState.copyWith(showGameOver: false);
    notifyListeners();
  }

  /// Sayıyı belirtilen pozisyona yerleştir
  void placeNumber(int position) async {
    if (!_gameState.isGameActive || _gameState.currentNumber == null) return;

    final currentNumber = _gameState.currentNumber!;
    final currentSlots = List<int?>.from(_gameState.slots);

    // Save state before making the move (in case it's a losing move)
    await _saveGameStateBeforeMove(currentSlots, currentNumber);

    // Sayının yerleştirilebilir olup olmadığını kontrol et
    if (!GameUtils.canPlaceNumber(currentSlots, currentNumber, position)) {
      _gameOver();
      return;
    }

    // Tap sesi çal (başarıyla yerleştiriliyorsa)
    SoundUtils.playTapSound();

    // Skor artışı öncesi rekor kontrolü
    final newScore = GameUtils.calculateScore(
      (() {
        final tempSlots = List<int?>.from(currentSlots);
        tempSlots[position] = currentNumber;
        return tempSlots;
      })(),
    );
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'blind_sort',
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

    // Sayıyı yerleştir
    currentSlots[position] = currentNumber;

    // Yerleştirilen sayıyı kullanılmış olarak işaretle
    _usedNumbers.add(currentNumber);

    // Yerleştirilen sayıdan sonra sıralamanın doğru olup olmadığını kontrol et
    if (!GameUtils.isSortingValidAfterPlacement(
      currentSlots,
      currentNumber,
      position,
    )) {
      _gameOver();
      return;
    }

    // Oyun kazanıldı mı kontrol et
    if (GameUtils.isGameWon(currentSlots)) {
      _gameWon(newScore);
      return;
    }

    // Önce mevcut durumu güncelle (sayı yerleştirildi)
    _gameState = _gameState.copyWith(slots: currentSlots, score: newScore);
    notifyListeners();

    // Kısa bir bekleme sonrası yeni sayı animasyonu başlat
    Timer(const Duration(milliseconds: 500), () {
      _startNewNumberAnimation(currentSlots, newScore);
    });
  }

  /// Yeni sayı animasyonu başlat
  void _startNewNumberAnimation(List<int?> currentSlots, int currentScore) {
    SoundUtils.playSpinnerSound();
    _isAnimating = true;
    _animatedNumber = _generateUniqueRandomNumber();
    notifyListeners();

    _numberAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      _animatedNumber = _generateUniqueRandomNumber();
      notifyListeners();
    });

    // 2 saniye sonra animasyonu durdur ve final sayıyı göster
    Timer(const Duration(seconds: 2), () async {
      stopNumberAnimation();
      final finalNumber = _generateUniqueRandomNumber();

      if (finalNumber == -1) {
        // Tüm sayılar kullanılmış, oyunu kazandı olarak işaretle
        await SoundUtils.stopSpinnerSound();
        _gameWon(currentScore);
        return;
      }

      // Save state before showing the new number (in case it's unplayable)
      await _saveGameStateBeforeNewNumber(currentSlots, finalNumber);

      // Eğer yeni sayı hiçbir yere yerleştirilemiyorsa oyun biter
      if (!GameUtils.canPlaceNumberAnywhere(currentSlots, finalNumber)) {
        await SoundUtils.stopSpinnerSound();
        _nextNumberUnplayable(finalNumber, currentScore);
        return;
      }

      _gameState = _gameState.copyWith(currentNumber: finalNumber);
      _animatedNumber = finalNumber;
      _isAnimating = false;

      // Final sayıyı kullanılmış olarak işaretle
      _usedNumbers.add(finalNumber);

      await SoundUtils.stopSpinnerSound();
      notifyListeners();
    });
  }

  /// Oyun bitti
  void _gameOver() async {
    _isAnimating = false;
    // State is already saved before the losing move
    final finalScore = _gameState.score;
    _hasBrokenRecordThisGame = true;
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'blind_sort',
    );
    final previousHighScore = previousEntry?.highScore ?? 0;
    if (!_hasBrokenRecordThisGame &&
        previousEntry != null &&
        finalScore > previousHighScore &&
        _gameState.isGameActive) {
      SoundUtils.playNewLevelSound();
      _hasBrokenRecordThisGame = true;
    }
    _gameState = _gameState.copyWith(
      status: GameStatus.gameOver,
      showGameOver: true,
    );

    // Yüksek skoru güncelle
    await LeaderboardUtils.updateHighScore('blind_sort', finalScore);

    notifyListeners();
  }

  /// Oyun kazanıldı
  void _gameWon(int finalScore) async {
    _isAnimating = false;
    _hasBrokenRecordThisGame = true;
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'blind_sort',
    );
    final previousHighScore = previousEntry?.highScore ?? 0;
    if (!_hasBrokenRecordThisGame &&
        previousEntry != null &&
        finalScore > previousHighScore &&
        _gameState.isGameActive) {
      SoundUtils.playNewLevelSound();
      _hasBrokenRecordThisGame = true;
    }
    await SoundUtils.stopSpinnerSound();
    _gameState = _gameState.copyWith(
      status: GameStatus.won,
      score: finalScore,
      showGameOver: true,
    );

    // Yüksek skoru güncelle
    await LeaderboardUtils.updateHighScore('blind_sort', finalScore);

    // Clear any saved state on success
    await clearSavedGameState();

    notifyListeners();
  }

  /// Yeni sayı hiçbir yere sığmıyor
  void _nextNumberUnplayable(int unplayableNumber, int finalScore) async {
    _isAnimating = false;
    // State is already saved before showing the unplayable number
    _hasBrokenRecordThisGame = true;
    final previousEntry = await LeaderboardUtils.getLeaderboardEntry(
      'blind_sort',
    );
    final previousHighScore = previousEntry?.highScore ?? 0;
    if (!_hasBrokenRecordThisGame &&
        previousEntry != null &&
        finalScore > previousHighScore &&
        _gameState.isGameActive) {
      SoundUtils.playNewLevelSound();
      _hasBrokenRecordThisGame = true;
    }
    await SoundUtils.stopSpinnerSound();
    // Oynanamayan sayıyı da kullanılmış olarak işaretle
    _usedNumbers.add(unplayableNumber);

    _gameState = _gameState.copyWith(
      status: GameStatus.nextNumberUnplayable,
      currentNumber: unplayableNumber,
      score: finalScore,
      showGameOver: true,
    );

    // Yüksek skoru güncelle
    await LeaderboardUtils.updateHighScore('blind_sort', finalScore);

    notifyListeners();
  }

  Future<void> _saveGameStateBeforeMove(
    List<int?> currentSlots,
    int currentNumber,
  ) async {
    final state = {
      'slots': currentSlots,
      'currentNumber': currentNumber,
      'score': _gameState.score,
      'usedNumbers': _usedNumbers.toList(),
      'lastAction': 'before_move', // Indicate this is the state before a move
    };
    await GameStateService().saveGameState('blind_sort', state);
  }

  Future<void> _saveGameStateBeforeNewNumber(
    List<int?> currentSlots,
    int newNumber,
  ) async {
    final state = {
      'slots': currentSlots,
      'currentNumber': newNumber,
      'score': _gameState.score,
      'usedNumbers': _usedNumbers.toList(),
      'lastAction':
          'before_new_number', // Indicate this is the state before a new number
    };
    await GameStateService().saveGameState('blind_sort', state);
  }

  Future<bool> continueGame() async {
    final saved = await GameStateService().loadGameState('blind_sort');
    if (saved == null) return false;
    try {
      // Ensure interaction is enabled when restoring
      _isAnimating = false;
      final slots = (saved['slots'] as List).map((e) => e as int?).toList();
      final currentNumber = saved['currentNumber'] as int?;
      final score = (saved['score'] as int?) ?? 0;
      final used = Set<int>.from((saved['usedNumbers'] as List?) ?? []);
      final lastAction = saved['lastAction'] as String?;

      _usedNumbers = used; // restore used numbers

      // If the last action was before a new unplayable number,
      // we need to generate a new playable number
      if (lastAction == 'before_new_number' && currentNumber != null) {
        // Remove the unplayable number from used numbers
        _usedNumbers.remove(currentNumber);

        // Generate a new playable number that fits into current slots
        final candidates = _getPlaceableCandidates(slots);
        if (candidates.isNotEmpty) {
          candidates.shuffle();
          final newPlayableNumber = candidates.first;
          _usedNumbers.add(newPlayableNumber);

          _gameState = _gameState.copyWith(
            slots: slots,
            currentNumber: newPlayableNumber,
            score: score,
            status: GameStatus.playing,
            showGameOver: false,
          );
        } else {
          // No playable number exists; treat as completed/won scenario for safety
          _gameState = _gameState.copyWith(
            slots: slots,
            score: score,
            status: GameStatus.won,
            showGameOver: true,
          );
        }

        // Clear the saved state after successful restore
        await clearSavedGameState();

        // Mark that continue has been used
        _hasUsedContinue = true;

        notifyListeners();
        return true;
      } else if (lastAction == 'before_move' && currentNumber != null) {
        // Normal continue from before a losing move
        // Remove the losing number from used numbers and advance to next level
        _usedNumbers.remove(currentNumber);

        // Advance to next level (current score + 1)
        final nextLevelScore = score + 1;

        // Start number animation to generate a new shuffled number
        _gameState = _gameState.copyWith(
          slots: slots,
          score: nextLevelScore,
          status: GameStatus.playing,
          showGameOver: false,
        );

        _startNewNumberAnimationAfterContinue(slots, nextLevelScore);
        return true; // Return early since we're starting animation
      } else {
        // Fallback case - should not happen in normal flow
        _gameState = _gameState.copyWith(
          slots: slots,
          score: score,
          status: GameStatus.playing,
          showGameOver: false,
        );

        // Start number animation to generate a new shuffled number
        _startNewNumberAnimationAfterContinue(slots, score);
        return true; // Return early since we're starting animation
      }
    } catch (_) {
      return false;
    }
  }

  /// Start new number animation after continuing game (for ad reward)
  /// This method ensures that the losing number is not used again and advances to next level
  void _startNewNumberAnimationAfterContinue(
    List<int?> currentSlots,
    int currentScore,
  ) {
    SoundUtils.playSpinnerSound();
    _isAnimating = true;
    // For animation, cycle through placeable candidates if available
    final initialCandidates = _getPlaceableCandidates(currentSlots);
    _animatedNumber =
        initialCandidates.isNotEmpty ? (initialCandidates..shuffle()).first : _generateUniqueRandomNumber();
    notifyListeners();

    _numberAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      // During animation, show random numbers from placeable candidates if available
      final candidates = _getPlaceableCandidates(currentSlots);
      if (candidates.isNotEmpty) {
        candidates.shuffle();
        _animatedNumber = candidates.first;
      } else {
        _animatedNumber = _generateUniqueRandomNumber();
      }
      notifyListeners();
    });

    // 2 saniye sonra animasyonu durdur ve final sayıyı göster
    Timer(const Duration(seconds: 2), () async {
      stopNumberAnimation();

      // Generate final number ensuring it can be placed somewhere
      final candidates = _getPlaceableCandidates(currentSlots);
      final finalNumber =
          candidates.isNotEmpty ? (candidates..shuffle()).first : _generateUniqueRandomNumber();

      if (finalNumber == -1) {
        // Tüm sayılar kullanılmış, oyunu kazandı olarak işaretle
        await SoundUtils.stopSpinnerSound();
        _gameWon(currentScore);
        return;
      }

      // Save state before showing the new number (for consistency)
      await _saveGameStateBeforeNewNumber(currentSlots, finalNumber);

      // Safeguard: if somehow not placeable, try to pick a candidate again
      if (!GameUtils.canPlaceNumberAnywhere(currentSlots, finalNumber)) {
        final retryCandidates = _getPlaceableCandidates(currentSlots);
        if (retryCandidates.isNotEmpty) {
          retryCandidates.shuffle();
          final safeNumber = retryCandidates.first;
          _gameState = _gameState.copyWith(currentNumber: safeNumber);
          _animatedNumber = safeNumber;
          _isAnimating = false;
          _usedNumbers.add(safeNumber);
          await clearSavedGameState();
          await SoundUtils.stopSpinnerSound();
          notifyListeners();
          return;
        } else {
          await SoundUtils.stopSpinnerSound();
          _nextNumberUnplayable(finalNumber, currentScore);
          return;
        }
      }

      _gameState = _gameState.copyWith(currentNumber: finalNumber);
      _animatedNumber = finalNumber;
      _isAnimating = false;

      // Final sayıyı kullanılmış olarak işaretle
      _usedNumbers.add(finalNumber);

      // Clear the saved state after successful animation completion
      await clearSavedGameState();

      await SoundUtils.stopSpinnerSound();
      notifyListeners();
    });
  }

  Future<bool> canContinueGame() async {
    if (_hasUsedContinue) return false;
    final has = await GameStateService().hasGameState('blind_sort');
    if (!has) return false;

    // Peek into saved state to ensure a placeable number exists after continue
    final saved = await GameStateService().loadGameState('blind_sort');
    if (saved == null) return false;
    try {
      final slots = (saved['slots'] as List).map((e) => e as int?).toList();
      final currentNumber = saved['currentNumber'] as int?;
      final used = Set<int>.from((saved['usedNumbers'] as List?) ?? []);
      final lastAction = saved['lastAction'] as String?;

      // Simulate used set after continue
      if (currentNumber != null && (lastAction == 'before_new_number' || lastAction == 'before_move')) {
        used.remove(currentNumber);
      }

      final candidates = _getPlaceableCandidates(slots, usedOverride: used);
      return candidates.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSavedGameState() async {
    await GameStateService().clearGameState('blind_sort');
  }

  /// Tam ekran modunu değiştir
  void toggleFullscreen() {
    _gameState = _gameState.copyWith(isFullscreen: !_gameState.isFullscreen);
    notifyListeners();
  }

  @override
  void dispose() {
    _numberAnimationTimer?.cancel();
    super.dispose();
  }
}
