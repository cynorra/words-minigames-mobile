import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/find_difference_provider.dart';
import '../models/find_difference_game_state.dart';

// Reusable tile widget for the grid
class ColorTile extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool flashWrong;
  final bool pulse;
  final bool isGameOver;
  final bool isGameActive;

  const ColorTile({
    super.key,
    required this.color,
    required this.size,
    required this.onTap,
    this.flashWrong = false,
    this.pulse = false,
    this.isGameOver = false,
    this.isGameActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: flashWrong ? AppTheme.darkError : color,
        borderRadius: BorderRadius.circular(8),
        border:
            pulse
                ? Border.all(
                  color: AppTheme.darkSuccess,
                  width: 4,
                  style: BorderStyle.solid,
                )
                : null,
        boxShadow:
            pulse
                ? [
                  BoxShadow(
                    color: AppTheme.darkSuccess.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: AppTheme.darkSuccess.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ]
                : null,
      ),
    );

    return InkWell(
      onTap:
          (isGameOver || !isGameActive)
              ? null
              : onTap, // Disable tap when game is over or not active
      borderRadius: BorderRadius.circular(8),
      child: tile,
    );
  }
}

// Simple overlay shown when/if game over is needed in future (kept per spec)
class GameOverOverlay extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.overlayDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.gameOver,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.score}: $score',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onRestart,
                child: Text(AppLocalizations.of(context)!.restart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FindDifferencePage extends StatelessWidget {
  const FindDifferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FindDifferenceProvider(),
      child: const _FindDifferenceView(),
    );
  }
}

class _FindDifferenceView extends StatelessWidget {
  const _FindDifferenceView();

  @override
  Widget build(BuildContext context) {
    return Consumer<FindDifferenceProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showTimeUp) {
          gameResult = GameResult(
            isWin: false,
            score: gameState.score,
            title: AppLocalizations.of(context)!.timeUp,
            subtitle: AppLocalizations.of(context)!.timeRanOut,
            lossReason: AppLocalizations.of(context)!.timeUpMessage,
          );
        } else if (gameState.showContinueDialog) {
          gameResult = GameResult(
            isWin: false,
            score: gameState.score,
            title: AppLocalizations.of(context)!.gameOver,
            subtitle: AppLocalizations.of(context)!.betterLuckNextTime,
            lossReason: AppLocalizations.of(context)!.betterLuckNextTime,
          );
        }

        return GameScreenBase(
          title: 'find_difference',
          descriptionKey: 'find_difference_description',
          gameId: 'find_difference',
          gameResult: gameResult,
          onTryAgain: () {
            provider.hideTimeUp();
            provider.hideContinueDialog();
            provider.resetGame();
          },
          onGameResultCleared: () {
            provider.cleanupGame();
          },
          onContinueGame: () => provider.continueGame(),
          canContinueGame: () => provider.canContinueGame(),
          onBackToMenu: () {
            provider.hideTimeUp();
            provider.hideContinueDialog();
            Navigator.of(context).pop();
          },
          onStartGame: () {
            provider.startGame();
          },
          onResetGame: () {
            provider.resetGame();
          },
          isWaiting: gameState.isWaiting,
          isGameInProgress: gameState.isGameActive,
          onPauseGame: () => provider.pauseGame(),
          onResumeGame: () => provider.resumeGame(),
          child: _buildGameContent(context, gameState, provider),
        );
      },
    );
  }
}

Widget _buildGameContent(
  BuildContext context,
  FindDifferenceGameState gameState,
  FindDifferenceProvider provider,
) {
  final total = gameState.grid * gameState.grid;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildScoreDisplay(context, gameState),
      const SizedBox(height: AppConstants.mediumSpacing),
      Expanded(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxSide = min(
                constraints.maxWidth,
                constraints.maxHeight - 72,
              );
              const spacing = 8.0;
              final size =
                  (maxSide - spacing * (gameState.grid - 1)) / gameState.grid;
              return SizedBox(
                width: maxSide,
                height: maxSide,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gameState.grid,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                  ),
                  itemCount: total,
                  itemBuilder: (context, i) {
                    final isWrong = gameState.wrongFlashIndex == i;
                    final isPulse = gameState.pulseIndex == i;
                    final color =
                        i == gameState.oddIndex
                            ? gameState.oddColor
                            : gameState.baseColor;
                    return ColorTile(
                      color: color,
                      size: size,
                      flashWrong: isWrong,
                      pulse: isPulse,
                      onTap: () => provider.onTapTile(i),
                      isGameOver: gameState.isGameOver,
                      isGameActive: gameState.isGameActive,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: AppConstants.mediumSpacing),
    ],
  );
}

Widget _buildScoreDisplay(
  BuildContext context,
  FindDifferenceGameState gameState,
) {
  return Column(
    children: [
      // Score
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.trophy,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${AppLocalizations.of(context)!.score}: ${gameState.score}',
              style: TextThemeManager.subtitleMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: AppConstants.smallSpacing),

      // Time and Mistakes
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Time Remaining
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  gameState.timeLeft <= 5
                      ? AppTheme.darkError.withValues(alpha: 0.2)
                      : Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    gameState.timeLeft <= 5
                        ? AppTheme.darkError.withValues(alpha: 0.3)
                        : Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  color:
                      gameState.timeLeft <= 5
                          ? AppTheme.darkError
                          : Theme.of(context).colorScheme.secondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gameState.timeLeft}s',
                  style: TextThemeManager.bodyMedium.copyWith(
                    color:
                        gameState.timeLeft <= 5
                            ? AppTheme.darkError
                            : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.mediumSpacing),

          // Mistakes Left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  gameState.mistakesLeft <= 1
                      ? AppTheme.darkError.withValues(alpha: 0.2)
                      : Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    gameState.mistakesLeft <= 1
                        ? AppTheme.darkError.withValues(alpha: 0.3)
                        : Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color:
                      gameState.mistakesLeft <= 1
                          ? AppTheme.darkError
                          : Theme.of(context).colorScheme.tertiary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gameState.mistakesLeft}',
                  style: TextThemeManager.bodyMedium.copyWith(
                    color:
                        gameState.mistakesLeft <= 1
                            ? AppTheme.darkError
                            : Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
