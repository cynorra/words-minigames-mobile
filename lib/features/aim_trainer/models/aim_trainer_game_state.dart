import 'package:flutter/material.dart';

enum AimTrainerGameStatus { waiting, playing, gameOver }

enum GameOverReason { timeUp, civilianHit }

class AimTrainerGameState {
  final int score;
  final int timeLeft;
  final Offset targetPosition;
  final Offset? civilianPosition;
  final bool showCivilian;
  final AimTrainerGameStatus status;
  final bool showGameOver;
  final GameOverReason? gameOverReason;

  const AimTrainerGameState({
    this.score = 0,
    this.timeLeft = 20,
    this.targetPosition = const Offset(0, 0),
    this.civilianPosition,
    this.showCivilian = false,
    this.status = AimTrainerGameStatus.waiting,
    this.showGameOver = false,
    this.gameOverReason,
  });

  AimTrainerGameState copyWith({
    int? score,
    int? timeLeft,
    Offset? targetPosition,
    Offset? civilianPosition,
    bool? showCivilian,
    AimTrainerGameStatus? status,
    bool? showGameOver,
    GameOverReason? gameOverReason,
  }) {
    return AimTrainerGameState(
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      targetPosition: targetPosition ?? this.targetPosition,
      civilianPosition: civilianPosition ?? this.civilianPosition,
      showCivilian: showCivilian ?? this.showCivilian,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
    );
  }

  bool get isGameActive => status == AimTrainerGameStatus.playing;
  bool get isWaiting => status == AimTrainerGameStatus.waiting;
  bool get isGameOver => status == AimTrainerGameStatus.gameOver;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AimTrainerGameState &&
        other.score == score &&
        other.timeLeft == timeLeft &&
        other.targetPosition == targetPosition &&
        other.civilianPosition == civilianPosition &&
        other.showCivilian == showCivilian &&
        other.status == status &&
        other.showGameOver == showGameOver &&
        other.gameOverReason == gameOverReason;
  }

  @override
  int get hashCode {
    return Object.hash(
      score,
      timeLeft,
      targetPosition,
      civilianPosition,
      showCivilian,
      status,
      showGameOver,
      gameOverReason,
    );
  }
}
