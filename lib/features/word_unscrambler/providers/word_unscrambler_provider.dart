import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/word_model.dart';

class WordUnscramblerProvider extends ChangeNotifier {
  int _score = 0;
  int _round = 1;
  int _timeLeft = 30;
  Timer? _timer;

  WordItem? _currentWordItem;
  List<String> _scrambledLetters = [];
  List<int> _selectedIndices = [];
  bool _isGameOver = false;
  bool _showHint = false;
  bool _isSuccessAnim = false;
  String _locale = 'tr';

  int get score => _score;
  int get round => _round;
  int get timeLeft => _timeLeft;
  bool get isGameOver => _isGameOver;
  bool get showHint => _showHint;
  bool get isSuccessAnim => _isSuccessAnim;
  WordItem? get currentWordItem => _currentWordItem;
  List<String> get scrambledLetters => _scrambledLetters;
  List<int> get selectedIndices => _selectedIndices;

  String get currentGuess {
    return _selectedIndices.map((i) => _scrambledLetters[i]).join('');
  }

  void init(String languageCode) {
    _locale = languageCode.startsWith('tr') ? 'tr' : 'en';
    reset();
  }

  void reset() {
    _timer?.cancel();
    _score = 0;
    _round = 1;
    _isGameOver = false;
    _showHint = false;
    _isSuccessAnim = false;
    _nextWord();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isGameOver = true;
        notifyListeners();
      }
    });
  }

  void _nextWord() {
    final list = _locale == 'tr' ? WordScrambleModel.wordsTr : WordScrambleModel.wordsEn;
    final random = Random();
    
    // Pick random word
    _currentWordItem = list[random.nextInt(list.length)];
    
    // Scramble letters until it differs from original
    final letters = _currentWordItem!.word.split('');
    List<String> scrambled;
    int attempts = 0;
    do {
      scrambled = List<String>.from(letters)..shuffle(random);
      attempts++;
    } while (scrambled.join('') == _currentWordItem!.word && attempts < 10);

    _scrambledLetters = scrambled;
    _selectedIndices = [];
    _showHint = false;
    _isSuccessAnim = false;

    _startTimer();
    notifyListeners();
  }

  void selectLetter(int index) {
    if (_isGameOver || _selectedIndices.contains(index)) return;

    _selectedIndices.add(index);
    notifyListeners();

    // Check if word completed
    if (currentGuess.length == (_currentWordItem?.word.length ?? 0)) {
      _checkAnswer();
    }
  }

  void removeLastLetter() {
    if (_selectedIndices.isNotEmpty) {
      _selectedIndices.removeLast();
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedIndices.clear();
    notifyListeners();
  }

  void revealHint() {
    if (!_showHint && !_isGameOver) {
      _showHint = true;
      _timeLeft = max(5, _timeLeft - 5); // Hint costs 5 seconds
      notifyListeners();
    }
  }

  void _checkAnswer() {
    if (_currentWordItem != null && currentGuess == _currentWordItem!.word) {
      _isSuccessAnim = true;
      _score += 10 + (_timeLeft ~/ 3);
      _round++;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!_isGameOver) {
          _nextWord();
        }
      });
    } else {
      // Wrong word: clear selection after brief delay
      Future.delayed(const Duration(milliseconds: 300), () {
        clearSelection();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
