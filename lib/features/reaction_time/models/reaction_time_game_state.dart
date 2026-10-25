import 'package:flutter/material.dart';

enum ReactionTimeGameStatus { waiting, playing, gameOver }

class ReactionTimeGameState {
  final int nextTarget;
  final double elapsedTime;
  final ReactionTimeGameStatus status;
  final bool showGameOver;
  final List<Offset> targetPositions;
  final bool isTimerRunning;
  final Set<int> completedTargets;

  const ReactionTimeGameState({
    this.nextTarget = 1,
    this.elapsedTime = 0.0,
    this.status = ReactionTimeGameStatus.waiting,
    this.showGameOver = false,
    this.targetPositions = const [],
    this.isTimerRunning = false,
    this.completedTargets = const {},
  });

  ReactionTimeGameState copyWith({
    int? nextTarget,
    double? elapsedTime,
    ReactionTimeGameStatus? status,
    bool? showGameOver,
    List<Offset>? targetPositions,
    bool? isTimerRunning,
    Set<int>? completedTargets,
  }) {
    return ReactionTimeGameState(
      nextTarget: nextTarget ?? this.nextTarget,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      targetPositions: targetPositions ?? this.targetPositions,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      completedTargets: completedTargets ?? this.completedTargets,
    );
  }

  bool get isGameActive => status == ReactionTimeGameStatus.playing;
  bool get isWaiting => status == ReactionTimeGameStatus.waiting;
  bool get isGameOver => status == ReactionTimeGameStatus.gameOver;
  bool get isCompleted => nextTarget > 12;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReactionTimeGameState &&
        other.nextTarget == nextTarget &&
        other.elapsedTime == elapsedTime &&
        other.status == status &&
        other.showGameOver == showGameOver &&
        other.targetPositions == targetPositions &&
        other.isTimerRunning == isTimerRunning &&
        other.completedTargets == completedTargets;
  }

  @override
  int get hashCode {
    return Object.hash(
      nextTarget,
      elapsedTime,
      status,
      showGameOver,
      targetPositions,
      isTimerRunning,
      completedTargets,
    );
  }
}
