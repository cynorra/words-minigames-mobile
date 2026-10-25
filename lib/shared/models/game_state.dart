import '../../core/utils/game_utils.dart';

enum GameStatus { waiting, playing, gameOver, won, nextNumberUnplayable }

class GameState {
  final GameStatus status;
  final List<int?> slots;
  final int? currentNumber;
  final int score;
  final bool isFullscreen;
  final bool showGameOver;

  GameState({
    this.status = GameStatus.waiting,
    this.slots = const <int?>[
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
    this.currentNumber,
    this.score = 0,
    this.isFullscreen = false,
    this.showGameOver = false,
  });

  GameState copyWith({
    GameStatus? status,
    List<int?>? slots,
    int? currentNumber,
    int? score,
    bool? isFullscreen,
    bool? showGameOver,
  }) {
    return GameState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      currentNumber: currentNumber ?? this.currentNumber,
      score: score ?? this.score,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      showGameOver: showGameOver ?? this.showGameOver,
    );
  }

  bool get isGameActive => status == GameStatus.playing;
  bool get isGameOver =>
      status == GameStatus.gameOver ||
      status == GameStatus.won ||
      status == GameStatus.nextNumberUnplayable;
  bool get isWaiting => status == GameStatus.waiting;
  bool get isNextNumberUnplayable => status == GameStatus.nextNumberUnplayable;
  int get filledSlots => slots.where((slot) => slot != null).length;
  bool get isBoardFull => filledSlots == 10;
  bool get isSorted => GameUtils.areAllFilledSlotsSorted(slots);
}
