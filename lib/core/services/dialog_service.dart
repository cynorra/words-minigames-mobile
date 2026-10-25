// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../shared/widgets/dialog/congrats_dialog.dart';
import '../../shared/widgets/dialog/continue_game_dialog.dart';
import '../../shared/widgets/dialog/game_in_progress_dialog.dart';
import '../../shared/widgets/dialog/leaderboard_register_dialog.dart';
import '../../shared/widgets/dialog/modern_remove_ads_dialog.dart';
import '../../shared/widgets/dialog/ad_free_success_dialog.dart';

/// Service class for managing all dialog interactions
class DialogService {
  static final DialogService _instance = DialogService._internal();
  factory DialogService() => _instance;
  DialogService._internal();

  /// Show congratulations dialog
  static Future<void> showCongratsDialog({
    required BuildContext context,
    required String gameId,
    required String gameTitle,
    required int currentScore,
    required VoidCallback onRestart,
    required VoidCallback onExit,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CongratsDialog(
            gameId: gameId,
            gameTitle: gameTitle,
            currentScore: currentScore,
            onRestart: onRestart,
            onExit: onExit,
          ),
    );
  }

  /// Show continue game dialog
  static Future<void> showContinueGameDialog({
    required BuildContext context,
    required String gameId,
    required String gameTitle,
    required int currentScore,
    required VoidCallback onContinue,
    required VoidCallback onRestart,
    required VoidCallback onExit,
    required bool canOneTimeContinue,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ContinueGameDialog(
            gameId: gameId,
            gameTitle: gameTitle,
            currentScore: currentScore,
            onContinue: onContinue,
            onRestart: onRestart,
            onExit: onExit,
            canOneTimeContinue: canOneTimeContinue,
          ),
    );
  }

  /// Combined UX flow: After the continue dialog closes, and the final score is known,
  /// optionally prompt the user to register for leaderboard.
  /// If the user continued the game, we skip registration here (game is ongoing).
  /// If user restarted or exited (i.e., game ended with a final score), show register dialog.
  static Future<void> showContinueThenRegisterFlow({
    required BuildContext context,
    required String gameId,
    required String gameTitle,
    required int finalScore,
    required bool canOneTimeContinue,
    required void Function({required String name, required String countryCode})
    onRegisterSubmit,
    required VoidCallback onContinue,
    required VoidCallback onRestart,
    required VoidCallback onExit,
  }) async {
    final result = await showDialog<ContinueGameResult>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ContinueGameDialog(
            gameId: gameId,
            gameTitle: gameTitle,
            currentScore: finalScore,
            onContinue: onContinue,
            onRestart: onRestart,
            onExit: onExit,
            canOneTimeContinue: canOneTimeContinue,
          ),
    );

    // If the user continued, do not show registration yet
    if (result == ContinueGameResult.continued) return;

    // If dialog was dismissed without explicit action, also do nothing
    if (result == null || result == ContinueGameResult.dismissed) return;

    // For restarted or exited, we now have a terminal score: prompt registration
    await showLeaderboardRegisterDialog(
      context: context,
      gameTitle: gameTitle,
      score: finalScore,
      onSubmit: onRegisterSubmit,
    );
  }

  /// Show game in progress dialog
  static Future<void> showGameInProgressDialog({
    required BuildContext context,
    required VoidCallback onStayInGame,
    required VoidCallback onExitGame,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => GameInProgressDialog(
            onStayInGame: onStayInGame,
            onExitGame: onExitGame,
          ),
    );
  }

  /// Show leaderboard register dialog
  static Future<void> showLeaderboardRegisterDialog({
    required BuildContext context,
    required String gameTitle,
    required int score,
    required void Function({required String name, required String countryCode})
    onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => LeaderboardRegisterDialog(
            gameTitle: gameTitle,
            score: score,
            onSubmit: onSubmit,
          ),
    );
  }

  /// Show remove ads dialog
  static Future<void> showRemoveAdsDialog({required BuildContext context}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ModernRemoveAdsDialog(),
    );
  }

  /// Show confirmation dialog with custom content
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText ?? 'Confirm'),
              ),
            ],
          ),
    );
  }

  /// Show ad-free success dialog
  static Future<void> showAdFreeSuccessDialog({
    required BuildContext context,
    required VoidCallback onContinue,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdFreeSuccessDialog(onContinue: onContinue),
    );
  }
}
