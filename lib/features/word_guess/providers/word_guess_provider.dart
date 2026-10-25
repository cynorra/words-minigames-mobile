import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/word_guess_model.dart';

class WordGuessProvider extends ChangeNotifier {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  String _targetWord = '';
  final List<String> _guesses = [];
  String _currentInput = '';
  bool _isGameOver = false;
  bool _isWin = false;
  int _score = 0;
  String _locale = 'tr';

  String get targetWord => _targetWord;
  List<String> get guesses => _guesses;
  String get currentInput => _currentInput;
  bool get isGameOver => _isGameOver;
  bool get isWin => _isWin;
  int get score => _score;
  int get currentAttempt => _guesses.length;

  void init(String languageCode) {
    _locale = languageCode.startsWith('tr') ? 'tr' : 'en';
    reset();
  }

  void reset() {
    final list = _locale == 'tr' ? WordGuessDictionary.trWords : WordGuessDictionary.enWords;
    _targetWord = list[Random().nextInt(list.length)].toUpperCase();
    _guesses.clear();
    _currentInput = '';
    _isGameOver = false;
    _isWin = false;
    notifyListeners();
  }

  void inputLetter(String letter) {
    if (_isGameOver || _currentInput.length >= wordLength) return;
    _currentInput += letter.toUpperCase();
    notifyListeners();
  }

  void backspace() {
    if (_isGameOver || _currentInput.isEmpty) return;
    _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    notifyListeners();
  }

  void submitGuess() {
    if (_isGameOver || _currentInput.length != wordLength) return;

    _guesses.add(_currentInput);
    if (_currentInput == _targetWord) {
      _isWin = true;
      _isGameOver = true;
      // Score based on remaining attempts
      _score += (maxAttempts - _guesses.length + 1) * 20;
    } else if (_guesses.length >= maxAttempts) {
      _isGameOver = true;
      _isWin = false;
    }

    _currentInput = '';
    notifyListeners();
  }

  LetterState getLetterState(int rowIndex, int colIndex) {
    if (rowIndex >= _guesses.length) {
      return LetterState.empty;
    }

    final guess = _guesses[rowIndex];
    final letter = guess[colIndex];

    if (_targetWord[colIndex] == letter) {
      return LetterState.correct;
    } else if (_targetWord.contains(letter)) {
      return LetterState.present;
    } else {
      return LetterState.absent;
    }
  }

  LetterState getKeyState(String key) {
    LetterState state = LetterState.initial;
    for (final guess in _guesses) {
      for (int i = 0; i < guess.length; i++) {
        if (guess[i] == key) {
          if (_targetWord[i] == key) {
            return LetterState.correct; // Highest priority
          } else if (_targetWord.contains(key) && state != LetterState.correct) {
            state = LetterState.present;
          } else if (state == LetterState.initial) {
            state = LetterState.absent;
          }
        }
      }
    }
    return state;
  }
}
