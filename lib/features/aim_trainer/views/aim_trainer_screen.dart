import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../models/aim_trainer_game_state.dart';
import '../providers/aim_trainer_provider.dart';
import '../../../core/theme/text_theme_manager.dart';

class AimTrainerScreen extends StatelessWidget {
  const AimTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AimTrainerProvider(),
      child: const _AimTrainerView(),
    );
  }
}

class _AimTrainerView extends StatelessWidget {
  const _AimTrainerView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AimTrainerProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showGameOver) {
          final isWin =
              gameState.gameOverReason == GameOverReason.timeUp &&
              gameState.score > 0;
          final isCivilianHit =
              gameState.gameOverReason == GameOverReason.civilianHit;

          gameResult = GameResult(
            isWin: isWin,
            score: gameState.score,
            title:
                isCivilianHit
                    ? AppLocalizations.of(context)!.missionFailed
                    : (isWin
                        ? AppLocalizations.of(context)!.congratulations
                        : AppLocalizations.of(context)!.gameOver),

            lossReason:
                isCivilianHit
                    ? AppLocalizations.of(context)!.greenTargetHit
                    : (isWin ? null : AppLocalizations.of(context)!.timeRanOut),
          );
        }

        return GameScreenBase(
          title: 'aim_trainer',
          descriptionKey: 'aim_trainer_description',
          gameId: 'aim_trainer',
          gameResult: gameResult,
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
          isWaiting: gameState.isWaiting,
          isGameInProgress: gameState.isGameActive,
          onPauseGame: () => provider.pauseGame(),
          onResumeGame: () => provider.resumeGame(),
          onGameResultCleared: () => provider.hideGameOver(),
          onContinueGame: () => provider.continueGame(),
          canContinueGame: () => provider.canContinueGame(),
          child: _buildGameContent(context, gameState, provider),
        );
      },
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    AimTrainerGameState gameState,
    AimTrainerProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final spacing = isSmallScreen ? 24.0 : 32.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score and time display
            _buildScoreTimeDisplay(context, gameState, isSmallScreen),

            SizedBox(height: spacing),

            // Game area with target
            _buildGameArea(context, gameState, provider, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildScoreTimeDisplay(
    BuildContext context,
    AimTrainerGameState gameState,
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
          width: isSmallScreen ? 0.5 : 1.0,
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
            value: '${gameState.timeLeft}s',
            color: colorScheme.primary,
            isSmallScreen: isSmallScreen,
          ),
          _InfoPill(
            icon: AppIcons.score,
            label: AppLocalizations.of(context)!.score,
            value: '${gameState.score}',
            color: colorScheme.primary,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(
    BuildContext context,
    AimTrainerGameState gameState,
    AimTrainerProvider provider,
    bool isSmallScreen,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Boşluklar ekran boyutuna göre ayarlanır
        final baseSpacing = min(
          screenWidth * (isSmallScreen ? 0.03 : 0.04),
          screenHeight * (isSmallScreen ? 0.02 : 0.03),
        );
        final spacing = baseSpacing.clamp(12.0, 16.0);

        // Oyun alanı boyutları ekran boyutuna göre ayarlanır
        final baseGameAreaWidth = min(
          screenWidth * (isSmallScreen ? 0.85 : 0.9),
          screenHeight * (isSmallScreen ? 0.6 : 0.7),
        );
        final gameAreaWidth = (baseGameAreaWidth - spacing * 2).clamp(
          240.0,
          screenWidth * 0.9,
        );

        final baseGameAreaHeight = min(
          screenHeight * (isSmallScreen ? 0.4 : 0.5),
          screenWidth * (isSmallScreen ? 0.6 : 0.7),
        );
        final gameAreaHeight = baseGameAreaHeight.clamp(240.0, 300.0);

        // Kenar yuvarlaklığı ekran boyutuna göre ayarlanır
        final baseBorderRadius = min(
          screenWidth * (isSmallScreen ? 0.03 : 0.04),
          screenHeight * (isSmallScreen ? 0.02 : 0.03),
        );
        final borderRadius = baseBorderRadius.clamp(12.0, 16.0);

        // Hedef boyutu ekran boyutuna göre ayarlanır
        final baseTargetSize = min(
          screenWidth * (isSmallScreen ? 0.07 : 0.09),
          screenHeight * (isSmallScreen ? 0.05 : 0.07),
        );
        final targetSize = baseTargetSize.clamp(28.0, 36.0);
        final halfTargetSize = targetSize / 2;

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
              // Target
              if (gameState.isGameActive)
                Positioned(
                  left: gameState.targetPosition.dx - halfTargetSize,
                  top: gameState.targetPosition.dy - halfTargetSize,
                  child: _buildTarget(
                    context,
                    gameState,
                    provider,
                    isSmallScreen,
                  ),
                ),

              // Civilian target (green circle)
              if (gameState.isGameActive &&
                  gameState.showCivilian &&
                  gameState.civilianPosition != null)
                Positioned(
                  left: gameState.civilianPosition!.dx - halfTargetSize,
                  top: gameState.civilianPosition!.dy - halfTargetSize,
                  child: _buildCivilianTarget(
                    context,
                    gameState,
                    provider,
                    isSmallScreen,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTarget(
    BuildContext context,
    AimTrainerGameState gameState,
    AimTrainerProvider provider,
    bool isSmallScreen,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Hedef boyutu ekran boyutuna göre ayarlanır
    final baseSize = min(
      screenWidth * (isSmallScreen ? 0.07 : 0.09),
      screenHeight * (isSmallScreen ? 0.05 : 0.07),
    );
    final size = baseSize.clamp(28.0, 36.0);

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

    return GestureDetector(
      onTap: () => provider.onTargetTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.darkError,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkError.withValues(alpha: 0.4),
              blurRadius: blurRadius,
              spreadRadius: 0,
              offset: Offset(0, shadowOffset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCivilianTarget(
    BuildContext context,
    AimTrainerGameState gameState,
    AimTrainerProvider provider,
    bool isSmallScreen,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Hedef boyutu ekran boyutuna göre ayarlanır
    final baseSize = min(
      screenWidth * (isSmallScreen ? 0.07 : 0.09),
      screenHeight * (isSmallScreen ? 0.05 : 0.07),
    );
    final size = baseSize.clamp(28.0, 36.0);

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

    return GestureDetector(
      onTap: () => provider.onCivilianTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.4),
              blurRadius: blurRadius,
              spreadRadius: 0,
              offset: Offset(0, shadowOffset),
            ),
          ],
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
