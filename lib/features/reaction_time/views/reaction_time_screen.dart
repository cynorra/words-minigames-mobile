import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../models/reaction_time_game_state.dart';
import '../providers/reaction_time_provider.dart';
import '../../../core/theme/text_theme_manager.dart';

class ReactionTimeScreen extends StatelessWidget {
  const ReactionTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReactionTimeProvider(),
      child: const _ReactionTimeView(),
    );
  }
}

class _ReactionTimeView extends StatelessWidget {
  const _ReactionTimeView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ReactionTimeProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showGameOver) {
          final isCompleted = gameState.nextTarget > 12;
          final finalScore = provider.calculateScore();

          gameResult = GameResult(
            isWin: isCompleted, // Win only if completed all targets
            score: finalScore,
            title:
                isCompleted
                    ? AppLocalizations.of(context)!.congratulations
                    : AppLocalizations.of(context)!.gameOver,
            subtitle:
                isCompleted
                    ? _getTimePerformanceMessage(
                      context,
                      provider.getTimePerformanceMessage(),
                    )
                    : AppLocalizations.of(context)!.wrongSequence,
            lossReason:
                isCompleted
                    ? null
                    : AppLocalizations.of(context)!.wrongSequence,
          );
        }

        return GameScreenBase(
          title: 'reaction_time',
          descriptionKey: 'reactionTimeDescription',
          gameId: 'reaction_time',
          gameResult: gameResult,
          showCongratsOnWin: true,
          onTryAgain: () {
            provider.hideGameOver();
            provider.resetGame();
          },
          onBackToMenu: () {
            provider.hideGameOver();
            Navigator.of(context).pop();
          },
          onStartGame: () {
            provider.startGame();
          },
          onResetGame: () {
            provider.resetGame();
          },
          onContinueGame: () async {
            return await provider.continueGame();
          },
          canContinueGame: () async {
            return await provider.canContinueGame();
          },
          isWaiting: gameState.isWaiting,
          isGameInProgress: gameState.isGameActive,
          onPauseGame: () => provider.pauseGame(),
          onResumeGame: () => provider.resumeGame(),
          onGameResultCleared: () => provider.cleanupGame(),
          child: _buildGameContent(context, gameState, provider),
        );
      },
    );
  }

  String _getTimePerformanceMessage(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'perfectTime':
        return localizations.perfectTime;
      case 'goodTime':
        return localizations.goodTime;
      case 'averageTime':
        return localizations.averageTime;
      case 'slowTime':
        return localizations.slowTime;
      case 'verySlowTime':
        return localizations.verySlowTime;
      default:
        return key;
    }
  }

  Widget _buildGameContent(
    BuildContext context,
    ReactionTimeGameState gameState,
    ReactionTimeProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final spacing = isSmallScreen ? 24.0 : 32.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status display
            _buildStatusDisplay(context, gameState, provider, isSmallScreen),

            SizedBox(height: spacing),

            // Game area with targets
            _buildGameArea(context, gameState, provider, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildStatusDisplay(
    BuildContext context,
    ReactionTimeGameState gameState,
    ReactionTimeProvider provider,
    bool isSmallScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isSmallScreen ? 6.0 : 8.0;
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final spacing = isSmallScreen ? 12.0 : 16.0;
    final runSpacing = isSmallScreen ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: runSpacing,
        children: [
          _InfoPill(
            icon: AppIcons.timer,
            label: AppLocalizations.of(context)!.time,
            value: '${gameState.elapsedTime.toStringAsFixed(1)}s',
            color: colorScheme.primary,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(
    BuildContext context,
    ReactionTimeGameState gameState,
    ReactionTimeProvider provider,
    bool isSmallScreen,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = isSmallScreen ? 12.0 : 16.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Oyun alanı boyutları
        final baseSize = min(
          screenWidth * (isSmallScreen ? 0.85 : 0.9),
          screenHeight * (isSmallScreen ? 0.65 : 0.75),
        );

        // Minimum ve maksimum boyutlar
        final minSize = min(300.0, screenWidth * 0.6);
        final maxSize = min(600.0, screenWidth * 0.9);

        // Final boyutlar
        final gameSize = baseSize.clamp(minSize, maxSize);
        final gameAreaWidth = gameSize - spacing * 2;
        final gameAreaHeight = gameSize - spacing * 2;
        final borderRadius = isSmallScreen ? 12.0 : 16.0;

        // Update provider with game area size
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.setGameAreaSize(Size(gameAreaWidth, gameAreaHeight));
        });

        return Container(
          width: gameAreaWidth,
          height: gameAreaHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: isSmallScreen ? 0.5 : 1.0,
            ),
          ),
          child: Stack(
            children: [
              // Targets - only show if game is active and not completed
              if (gameState.isGameActive &&
                  gameState.targetPositions.isNotEmpty)
                ...gameState.targetPositions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final position = entry.value;
                  final targetNumber = index + 1;
                  final isNextTarget = targetNumber == gameState.nextTarget;
                  final isCompleted = gameState.completedTargets.contains(
                    targetNumber,
                  );

                  // Don't show completed targets (they disappear)
                  if (isCompleted) return const SizedBox.shrink();

                  final targetSize = isSmallScreen ? 32.0 : 40.0;
                  final halfSize = targetSize / 2;

                  return Positioned(
                    left: position.dx - halfSize,
                    top: position.dy - halfSize,
                    child: _buildTarget(
                      context,
                      targetNumber,
                      isNextTarget,
                      provider,
                      isSmallScreen,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTarget(
    BuildContext context,
    int targetNumber,
    bool isNextTarget,
    ReactionTimeProvider provider,
    bool isSmallScreen,
  ) {
    // All targets look the same
    final targetColor = Theme.of(context).colorScheme.primary;
    final textColor = Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Hedef boyutu ekran boyutuna göre ayarlanır
    final baseSize = min(
      screenWidth * (isSmallScreen ? 0.12 : 0.14),
      screenHeight * (isSmallScreen ? 0.08 : 0.1),
    );

    // Minimum ve maksimum boyutlar
    final minSize = min(40.0, screenWidth * 0.1);
    final maxSize = min(56.0, screenWidth * 0.15);

    // Final boyut
    final size = baseSize.clamp(minSize, maxSize);

    // Font boyutu hedef boyutuna göre ayarlanır
    final baseFontSize = min(
      screenWidth * (isSmallScreen ? 0.05 : 0.06),
      screenHeight * (isSmallScreen ? 0.035 : 0.04),
    );
    final fontSize = baseFontSize.clamp(16.0, 24.0);

    // Efekt boyutları hedef boyutuna göre ayarlanır
    final blurRadius = min(size * 0.2, isSmallScreen ? 6.0 : 8.0);
    final shadowOffset = min(size * 0.05, isSmallScreen ? 1.0 : 2.0);

    return GestureDetector(
      onTap: () => provider.onTargetTap(targetNumber),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: targetColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: targetColor.withValues(alpha: 0.4),
              blurRadius: blurRadius,
              spreadRadius: 0,
              offset: Offset(0, shadowOffset),
            ),
          ],
        ),
        child: Center(
          child: Text(
            targetNumber.toString(),
            style: TextThemeManager.gameScorePrimary(context).copyWith(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isSmallScreen;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final horizontalPadding = isSmallScreen ? 8.0 : 12.0;
    final verticalPadding = isSmallScreen ? 6.0 : 8.0;
    final borderRadius = isSmallScreen ? 8.0 : 12.0;
    final iconSize = isSmallScreen ? 16.0 : 20.0;
    final spacing1 = isSmallScreen ? 4.0 : 6.0;
    final spacing2 = isSmallScreen ? 2.0 : 4.0;
    final labelFontSize = isSmallScreen ? 10.0 : 12.0;
    final valueFontSize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: isSmallScreen ? 0.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(width: spacing1),
          Text(
            '$label:',
            style: TextThemeManager.bodySmall.copyWith(
              color: onSurface.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: labelFontSize,
            ),
          ),
          SizedBox(width: spacing2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextThemeManager.subtitleMedium.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w700,
              fontSize: valueFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
