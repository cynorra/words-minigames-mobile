import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../models/number_memory_game_state.dart';
import '../providers/number_memory_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';

class NumberMemoryScreen extends StatelessWidget {
  const NumberMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NumberMemoryProvider(),
      child: const _NumberMemoryView(),
    );
  }
}

class _NumberMemoryView extends StatelessWidget {
  const _NumberMemoryView();

  @override
  Widget build(BuildContext context) {
    return Consumer<NumberMemoryProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showGameOver) {
          final isWin = gameState.showCorrectMessage;
          gameResult = GameResult(
            isWin: isWin,
            score: gameState.score,
            title:
                isWin
                    ? AppLocalizations.of(context)!.congratulations
                    : AppLocalizations.of(context)!.gameOver,
            subtitle:
                isWin
                    ? AppLocalizations.of(context)!.youRememberedAllNumbers
                    : AppLocalizations.of(context)!.wrongNumber,
            lossReason:
                isWin ? null : AppLocalizations.of(context)!.wrongNumber,
          );
        } else if (gameState.showContinueDialog) {
          gameResult = GameResult(
            isWin: false,
            score: gameState.score,
            title: AppLocalizations.of(context)!.gameOver,
            subtitle: AppLocalizations.of(context)!.betterLuckNextTime,
            lossReason: AppLocalizations.of(context)!.wrongNumber,
          );
        }

        return GameScreenBase(
          title: 'number_memory',
          descriptionKey: 'number_memory_description',
          gameId: 'number_memory',
          gameResult: gameResult,
          onTryAgain: () {
            provider.hideGameOver();
            provider.hideContinueDialog();
            provider.resetGame();
          },
          onContinueGame: () => provider.continueGame(),
          canContinueGame: () => provider.canContinueGame(),
          onGameResultCleared: () {
            provider.hideGameOver();
            provider.hideContinueDialog();
          },
          onBackToMenu: () {
            provider.hideGameOver();
            provider.hideContinueDialog();
            Navigator.of(context).pop();
          },
          onStartGame: () {
            provider.startGame();
          },
          onResetGame: () {
            provider.resetGame();
          },
          isWaiting: !gameState.isGameActive,
          isGameInProgress: gameState.isGameActive,
          onPauseGame: () => provider.pauseGame(),
          onResumeGame: () => provider.resumeGame(),
          child: _buildGameContent(context, gameState, provider),
        );
      },
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    NumberMemoryGameState gameState,
    NumberMemoryProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = constraints.maxHeight;

        // Dinamik boşluklar
        final spacing = min(isSmallScreen ? 12.0 : 24.0, screenHeight * 0.03);

        // Dikey offset'i ekran yüksekliğine göre ayarla
        final verticalOffset = min(
          isSmallScreen ? -8.0 : -20.0,
          -screenHeight * 0.02,
        );

        // İçeriğin maksimum genişliği
        // Ekran boyutuna göre içerik genişliği
        final maxContentWidth = screenWidth * (isSmallScreen ? 0.9 : 0.85);

        // Ekran boyutuna göre minimum ve maksimum genişlikler
        final minWidth = screenWidth * 0.6;
        final maxWidth = screenWidth * 0.9;

        // İçerik genişliğini sınırla
        final contentWidth = maxContentWidth.clamp(minWidth, maxWidth);

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Transform.translate(
              offset: Offset(0, verticalOffset),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score + Level display (modern badge)
                  _buildScoreLevelDisplay(context, gameState, isSmallScreen),

                  SizedBox(height: spacing),

                  // Sequence display area
                  _buildSequenceDisplay(
                    context,
                    gameState,
                    provider,
                    isSmallScreen,
                  ),

                  SizedBox(height: spacing),

                  // Keypad with opacity animation
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: gameState.isShowingSequence ? 0.3 : 1.0,
                    child: IgnorePointer(
                      ignoring: gameState.isShowingSequence,
                      child: _buildKeypad(
                        context,
                        gameState,
                        provider,
                        isSmallScreen,
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreLevelDisplay(
    BuildContext context,
    NumberMemoryGameState gameState,
    bool isSmallScreen,
  ) {
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isSmallScreen ? 6.0 : 8.0;
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 16.0 : 18.0;
    final spacing = isSmallScreen ? 4.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
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
            size: iconSize,
          ),
          SizedBox(width: spacing),
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
    );
  }

  Widget _buildSequenceDisplay(
    BuildContext context,
    NumberMemoryGameState gameState,
    NumberMemoryProvider provider,
    bool isSmallScreen,
  ) {
    // Ekran boyutuna göre maksimum genişlik
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxWidth = min(
      screenWidth * (isSmallScreen ? 0.6 : 0.7),
      screenHeight * 0.4,
    );
    final horizontalMargin = screenWidth * 0.01;
    final spacing = isSmallScreen ? 6.0 : 12.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(gameState.level, (index) {
                String displayText;
                Color textColor;

                if (gameState.isShowingSequence) {
                  displayText = gameState.sequence[index].toString();
                  textColor = AppTheme.goldYellow;
                } else {
                  if (index < gameState.userInput.length) {
                    displayText = gameState.userInput[index].toString();
                    if (gameState.wrongIndices.contains(index)) {
                      textColor = AppTheme.darkError;
                    } else {
                      textColor = AppTheme.goldYellow;
                    }
                  } else {
                    displayText = '—';
                    textColor = AppTheme.goldYellow;
                  }
                }

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Text(
                    displayText,
                    style: TextThemeManager.gameNumber.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: _getDigitFontSize(
                        gameState.level,
                        isSmallScreen,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(width: spacing),
        if (gameState.isWaitingForInput)
          _buildInlineDeleteButton(context, gameState, provider, isSmallScreen),
      ],
    );
  }

  double _getDigitFontSize(int level, bool isSmallScreen) {
    final baseSize = isSmallScreen ? 0.7 : 1.0;
    if (level <= 3) return 42 * baseSize;
    if (level <= 5) return 36 * baseSize;
    if (level <= 7) return 32 * baseSize;
    if (level <= 9) return 28 * baseSize;
    if (level <= 12) return 24 * baseSize;
    return 20 * baseSize;
  }

  Widget _buildKeypad(
    BuildContext context,
    NumberMemoryGameState gameState,
    NumberMemoryProvider provider,
    bool isSmallScreen,
  ) {
    // Ekran boyutuna göre maksimum genişlik
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxWidth = min(
      screenWidth * (isSmallScreen ? 0.6 : 0.7),
      screenHeight * 0.4,
    );
    final spacing = min(screenWidth * 0.02, screenHeight * 0.015);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [1, 2, 3]
                    .map(
                      (number) => _buildKeypadButton(
                        context,
                        number,
                        gameState,
                        provider,
                        isSmallScreen,
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: spacing),
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [4, 5, 6]
                    .map(
                      (number) => _buildKeypadButton(
                        context,
                        number,
                        gameState,
                        provider,
                        isSmallScreen,
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: spacing),
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [7, 8, 9]
                    .map(
                      (number) => _buildKeypadButton(
                        context,
                        number,
                        gameState,
                        provider,
                        isSmallScreen,
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(
    BuildContext context,
    int number,
    NumberMemoryGameState gameState,
    NumberMemoryProvider provider,
    bool isSmallScreen,
  ) {
    final isEnabled =
        gameState.isWaitingForInput &&
        gameState.userInput.length < gameState.level;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ekran boyutuna göre kenar boşluğu
    final horizontalMargin = min(screenWidth * 0.01, screenHeight * 0.008);

    // Tuş boyutu ekran boyutuna göre ayarlanır
    final baseSize = min(
      screenWidth * (isSmallScreen ? 0.12 : 0.15),
      screenHeight * (isSmallScreen ? 0.08 : 0.1),
    );

    // Minimum ve maksimum boyutlar
    final minSize = min(42.0, screenWidth * 0.1);
    final maxSize = min(58.0, screenWidth * 0.15);

    // Final boyut
    final size = baseSize.clamp(minSize, maxSize);
    final borderRadius = min(isSmallScreen ? 10.0 : 16.0, size * 0.25);
    final blurRadius = min(isSmallScreen ? 6.0 : 12.0, size * 0.2);
    final fontSize = min(isSmallScreen ? 14.0 : 20.0, size * 0.35);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () => provider.onNumberPressed(number) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkPrimary,
                  AppTheme.darkPrimary.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkPrimary.withValues(alpha: 0.4),
                  blurRadius: blurRadius,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextThemeManager.gameNumber.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineDeleteButton(
    BuildContext context,
    NumberMemoryGameState gameState,
    NumberMemoryProvider provider,
    bool isSmallScreen,
  ) {
    final bool isEnabled =
        gameState.isWaitingForInput && gameState.userInput.isNotEmpty;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tuş boyutu ekran boyutuna göre ayarlanır
    final baseSize = min(
      screenWidth * (isSmallScreen ? 0.1 : 0.12),
      screenHeight * (isSmallScreen ? 0.06 : 0.08),
    );

    // Minimum ve maksimum boyutlar
    final minSize = min(32.0, screenWidth * 0.08);
    final maxSize = min(44.0, screenWidth * 0.12);

    // Final boyut
    final size = baseSize.clamp(minSize, maxSize);
    final borderRadius = min(isSmallScreen ? 10.0 : 16.0, size * 0.3);
    final blurRadius = min(isSmallScreen ? 6.0 : 12.0, size * 0.2);
    final iconSize = min(isSmallScreen ? 16.0 : 22.0, size * 0.5);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 1.0, end: isEnabled ? 1.0 : 0.6),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child!);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () => provider.onDeletePressed() : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkError,
                  AppTheme.darkError.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkError.withValues(alpha: 0.4),
                  blurRadius: blurRadius,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                AppIcons.backspace,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
