import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum FindDifferenceStatus { waiting, playing, gameOver }

class FindDifferenceGameState {
  final int level;
  final int score; // equals number of completed rounds
  final int grid; // grid dimension
  final int oddIndex;
  final Color baseColor;
  final Color oddColor;
  final int? wrongFlashIndex;
  final int? pulseIndex;
  final int mistakesLeft;
  final int timeLeft; // Time remaining in seconds
  final FindDifferenceStatus status;
  final bool showGameOver;
  final bool showTimeUp; // Show time up dialog
  final bool showContinueDialog; // Show continue game dialog

  const FindDifferenceGameState({
    this.level = 1,
    this.score = 0,
    this.grid = 2,
    this.oddIndex = 0,
    this.baseColor = AppTheme.vividGreen,
    this.oddColor = AppTheme.vividGreenAlt,
    this.wrongFlashIndex,
    this.pulseIndex,
    this.mistakesLeft = 3,
    this.timeLeft = 30,
    this.status = FindDifferenceStatus.waiting,
    this.showGameOver = false,
    this.showTimeUp = false,
    this.showContinueDialog = false,
  });

  bool get isWaiting => status == FindDifferenceStatus.waiting;
  bool get isGameActive => status == FindDifferenceStatus.playing;
  bool get isGameOver => status == FindDifferenceStatus.gameOver;

  FindDifferenceGameState copyWith({
    int? level,
    int? score,
    int? grid,
    int? oddIndex,
    Color? baseColor,
    Color? oddColor,
    int? wrongFlashIndex,
    int? pulseIndex,
    int? mistakesLeft,
    int? timeLeft,
    FindDifferenceStatus? status,
    bool? showGameOver,
    bool? showTimeUp,
    bool? showContinueDialog,
  }) {
    return FindDifferenceGameState(
      level: level ?? this.level,
      score: score ?? this.score,
      grid: grid ?? this.grid,
      oddIndex: oddIndex ?? this.oddIndex,
      baseColor: baseColor ?? this.baseColor,
      oddColor: oddColor ?? this.oddColor,
      wrongFlashIndex: wrongFlashIndex,
      pulseIndex: pulseIndex,
      mistakesLeft: mistakesLeft ?? this.mistakesLeft,
      timeLeft: timeLeft ?? this.timeLeft,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      showTimeUp: showTimeUp ?? this.showTimeUp,
      showContinueDialog: showContinueDialog ?? this.showContinueDialog,
    );
  }
}
