import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum ColorHuntGameStatus { waiting, playing, gameOver }

class ColorHuntGameState {
  final int score;
  final int timeLeft;
  final String targetColorName;
  final String? targetColorKey;
  final Color targetColor;
  final Color textColor;
  final List<Color> availableColors;
  final ColorHuntGameStatus status;
  final bool showGameOver;
  final int? wrongTapIndex;

  const ColorHuntGameState({
    this.score = 0,
    this.timeLeft = 30,
    this.targetColorName = '',
    this.targetColorKey,
    this.targetColor = Colors.green,
    this.textColor = AppTheme.darkError,
    this.availableColors = const [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ],
    this.status = ColorHuntGameStatus.waiting,
    this.showGameOver = false,
    this.wrongTapIndex,
  });

  ColorHuntGameState copyWith({
    int? score,
    int? timeLeft,
    String? targetColorName,
    String? targetColorKey,
    Color? targetColor,
    Color? textColor,
    List<Color>? availableColors,
    ColorHuntGameStatus? status,
    bool? showGameOver,
    int? wrongTapIndex,
  }) {
    return ColorHuntGameState(
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      targetColorName: targetColorName ?? this.targetColorName,
      targetColorKey: targetColorKey ?? this.targetColorKey,
      targetColor: targetColor ?? this.targetColor,
      textColor: textColor ?? this.textColor,
      availableColors: availableColors ?? this.availableColors,
      status: status ?? this.status,
      showGameOver: showGameOver ?? this.showGameOver,
      wrongTapIndex: wrongTapIndex ?? this.wrongTapIndex,
    );
  }

  bool get isGameActive => status == ColorHuntGameStatus.playing;
  bool get isWaiting => status == ColorHuntGameStatus.waiting;
  bool get isGameOver => status == ColorHuntGameStatus.gameOver;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorHuntGameState &&
        other.score == score &&
        other.timeLeft == timeLeft &&
        other.targetColorName == targetColorName &&
        other.targetColorKey == targetColorKey &&
        other.targetColor == targetColor &&
        other.textColor == textColor &&
        other.availableColors == availableColors &&
        other.status == status &&
        other.showGameOver == showGameOver &&
        other.wrongTapIndex == wrongTapIndex;
  }

  @override
  int get hashCode {
    return Object.hash(
      score,
      timeLeft,
      targetColorName,
      targetColorKey,
      targetColor,
      textColor,
      availableColors,
      status,
      showGameOver,
      wrongTapIndex,
    );
  }
}
