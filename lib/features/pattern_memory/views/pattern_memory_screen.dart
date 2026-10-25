import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/l10n/app_localizations.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';

import '../../../shared/widgets/game_screen_base.dart';

import '../models/pattern_memory_game_state.dart';
import '../providers/pattern_memory_provider.dart';

class PatternMemoryScreen extends StatelessWidget {
  const PatternMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatternMemoryProvider(),
      child: Consumer<PatternMemoryProvider>(
        builder: (context, provider, child) {
          final gameState = provider.gameState;

          // Create game result when game is over
          GameResult? gameResult;
          if (gameState.showGameOver) {
            gameResult = GameResult(
              isWin: false,
              score: gameState.score,
              title: AppLocalizations.of(context)!.gameOver,
              subtitle: AppLocalizations.of(context)!.wrongPattern,
              lossReason: AppLocalizations.of(context)!.wrongPattern,
            );
          }

          return GameScreenBase(
            title: 'pattern_memory',
            descriptionKey: 'pattern_memory_description',
            gameId: 'pattern_memory',
            gameResult: gameResult,
            onTryAgain: () {
              provider.hideGameOver();
              provider.resetGame();
            },
            onContinueGame: () => provider.continueGame(),
            canContinueGame: () => provider.canContinueGame(),
            onGameResultCleared: () => provider.hideGameOver(),
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
            isWaiting: gameState.isWaiting,
            isGameInProgress: gameState.isGameActive,
            onPauseGame: () => provider.pauseGame(),
            onResumeGame: () => provider.resumeGame(),
            child: _buildGameContent(context, gameState, provider),
          );
        },
      ),
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    PatternMemoryGameState gameState,
    PatternMemoryProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final spacing = isSmallScreen ? 24.0 : 32.0;
        final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        final verticalPadding = isSmallScreen ? 6.0 : 8.0;
        final borderRadius = isSmallScreen ? 12.0 : 16.0;
        final iconSize = isSmallScreen ? 16.0 : 18.0;
        final iconSpacing = isSmallScreen ? 4.0 : 6.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score info (matched to Find Difference design)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.trophy,
                    color: Theme.of(context).colorScheme.primary,
                    size: iconSize,
                  ),
                  SizedBox(width: iconSpacing),
                  Text(
                    '${AppLocalizations.of(context)!.score}: ${gameState.score}',
                    style: (isSmallScreen
                            ? TextThemeManager.bodyMedium
                            : TextThemeManager.subtitleMedium)
                        .copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing),

            // Game grid
            _buildGameGrid(context, gameState, provider, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildGameGrid(
    BuildContext context,
    PatternMemoryGameState gameState,
    PatternMemoryProvider provider,
    bool isSmallScreen,
  ) {
    const gridCount = 5;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Boşluklar ekran boyutuna göre ayarlanır
    final baseTileSpacing = min(
      screenWidth * (isSmallScreen ? 0.015 : 0.02),
      screenHeight * (isSmallScreen ? 0.01 : 0.015),
    );
    final tileSpacing = baseTileSpacing.clamp(6.0, 8.0);

    // Kenar yuvarlaklığı ekran boyutuna göre ayarlanır
    final baseTileRadius = min(
      screenWidth * (isSmallScreen ? 0.015 : 0.02),
      screenHeight * (isSmallScreen ? 0.01 : 0.015),
    );
    final tileRadius = baseTileRadius.clamp(6.0, 8.0);

    // Padding ekran boyutuna göre ayarlanır
    final basePadding = min(
      screenWidth * (isSmallScreen ? 0.08 : 0.1),
      screenHeight * (isSmallScreen ? 0.06 : 0.08),
    );
    final padding = basePadding.clamp(32.0, 40.0);

    // Efekt boyutları ekran boyutuna göre ayarlanır
    final baseBlurRadius = min(
      screenWidth * (isSmallScreen ? 0.015 : 0.02),
      screenHeight * (isSmallScreen ? 0.01 : 0.015),
    );
    final blurRadius = baseBlurRadius.clamp(6.0, 8.0);

    final baseShadowOffset = min(
      screenWidth * (isSmallScreen ? 0.003 : 0.005),
      screenHeight * (isSmallScreen ? 0.002 : 0.003),
    );
    final shadowOffset = baseShadowOffset.clamp(1.0, 2.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid boyutu ekran boyutuna göre ayarlanır
        final baseSize = min(
          screenWidth * (isSmallScreen ? 0.85 : 0.9),
          screenHeight * (isSmallScreen ? 0.6 : 0.7),
        );

        // Minimum ve maksimum boyutlar
        final minSize = min(300.0, screenWidth * 0.7);
        final maxSize = min(500.0, screenWidth * 0.9);

        // Final boyut
        final gridSize = (baseSize.clamp(minSize, maxSize) - padding);

        return SizedBox(
          width: gridSize,
          height: gridSize,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              mainAxisSpacing: tileSpacing,
              crossAxisSpacing: tileSpacing,
              childAspectRatio: 1,
            ),
            itemCount: gridCount * gridCount,
            itemBuilder: (context, index) {
              final row = index ~/ gridCount;
              final col = index % gridCount;

              final isHighlighted = gameState.pattern.contains(index);
              final isSelected = gameState.userSelection.contains(index);
              final isCorrect = gameState.correctSelections.contains(index);
              final isWrong = gameState.wrongIndices.contains(index);
              final hasWrongSelection = gameState.wrongIndices.isNotEmpty;

              Color tileColor;
              if (isCorrect) {
                tileColor = AppTheme.darkSuccess; // Correct tiles stay green
              } else if (isWrong) {
                tileColor = AppTheme.darkError; // Wrong tiles are red
              } else if (isSelected) {
                tileColor = AppTheme.darkSuccess; // Selected tiles are green
              } else if (isHighlighted &&
                  (gameState.isShowingPattern || hasWrongSelection)) {
                tileColor =
                    Colors
                        .yellow; // Pattern tiles during show phase or when showing feedback
              } else {
                tileColor = Theme.of(context).colorScheme.surface;
              }

              return Semantics(
                label:
                    '${AppLocalizations.of(context)!.row} ${row + 1} ${AppLocalizations.of(context)!.column} ${col + 1}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(tileRadius),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                      width: isSmallScreen ? 0.5 : 1.0,
                    ),
                    boxShadow: [
                      if (isSelected || isHighlighted || isWrong)
                        BoxShadow(
                          color: tileColor.withValues(alpha: 0.3),
                          blurRadius: blurRadius,
                          offset: Offset(0, shadowOffset),
                        ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          (isCorrect || hasWrongSelection)
                              ? null
                              : () => provider.onTileTapped(index),
                      borderRadius: BorderRadius.circular(tileRadius),
                      child: Container(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
