import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tictactoe_provider.dart';
import '../models/tictactoe_game_state.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../l10n/app_localizations.dart';

class TicTacToeScreen extends StatelessWidget {
  const TicTacToeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TicTacToeProvider(),
      child: Consumer<TicTacToeProvider>(
        builder: (context, provider, child) {
          final gameState = provider.gameState;

          // Create game result when computer wins
          GameResult? gameResult;
          if (gameState.showGameOver &&
              gameState.gameOverReason == GameOverReason.computerWon) {
            gameResult = GameResult(
              isWin: false,
              score: gameState.playerScore,
              title: AppLocalizations.of(context)!.gameOver,
              subtitle: AppLocalizations.of(context)!.computerWon,
              lossReason: AppLocalizations.of(context)!.betterLuckNextTime,
            );
          }

          return GameScreenBase(
            title: 'tic_tac_toe',
            descriptionKey: 'tic_tac_toe_description',
            gameId: 'tic_tac_toe',
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
            onContinueGame: () => provider.continueGame(),
            canContinueGame: () => provider.canContinueGame(),
            onGameResultCleared: () {
              provider.cleanupGame();
            },
            isWaiting: gameState.isWaiting,
            isGameInProgress: gameState.isGameActive,
            onPauseGame: () => provider.pauseGame(),
            onResumeGame: () => provider.resumeGame(),
            child: _buildGameContent(context, gameState, provider),
            customTopWidget: _buildScoreAndRoundDisplays(
              context,
              gameState,
              false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    TicTacToeGameState gameState,
    TicTacToeProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game board
            _buildGameBoard(context, gameState, provider, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildScoreAndRoundDisplays(
    BuildContext context,
    TicTacToeGameState gameState,
    bool isSmallScreen,
  ) {
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Row(
      children: [
        // Score Display
        Expanded(child: _buildScoreDisplay(context, gameState, isSmallScreen)),

        SizedBox(width: spacing),

        // Round Display
        Expanded(child: _buildRoundDisplay(context, gameState, isSmallScreen)),
      ],
    );
  }

  Widget _buildScoreDisplay(
    BuildContext context,
    TicTacToeGameState gameState,
    bool isSmallScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final fontSize = isSmallScreen ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6.0 : 8.0,
        vertical: isSmallScreen ? 6.0 : 8.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score icon with enhanced styling
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 4.0 : 5.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.stars_rounded,
              color: colorScheme.primary,
              size: fontSize + 1,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2.0 : 3.0),
          // Score content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.yourScore,
                style: TextThemeManager.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                ),
              ),
              SizedBox(height: isSmallScreen ? 1.0 : 2.0),
              Text(
                '${gameState.playerScore}',
                style: TextThemeManager.gameNumber.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize + 3,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundDisplay(
    BuildContext context,
    TicTacToeGameState gameState,
    bool isSmallScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final fontSize = isSmallScreen ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6.0 : 8.0,
        vertical: isSmallScreen ? 6.0 : 8.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Round icon
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 4.0 : 5.0),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.games_rounded,
              color: colorScheme.secondary,
              size: fontSize,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2.0 : 3.0),
          // Round content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.currentRound,
                style: TextThemeManager.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2.0 : 3.0),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6.0 : 8.0,
                  vertical: isSmallScreen ? 1.0 : 2.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.15),
                      colorScheme.secondary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${gameState.roundsPlayed}',
                  style: TextThemeManager.headlineSmall.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize + 1,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    TicTacToeGameState gameState,
    TicTacToeProvider provider,
    bool isSmallScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final boardSize = isSmallScreen ? 280.0 : 320.0;
    final cellSize = (boardSize - 8) / 3; // 8 for gaps between cells

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          12.0,
        ), // Reduced radius to show border corners
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(
            size: Size(boardSize, boardSize),
            painter: TicTacToeGridPainter(
              color: colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 2,
            ),
          ),
          // Game cells
          Positioned.fill(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return _buildGameCell(
                  context,
                  index,
                  gameState,
                  provider,
                  cellSize,
                );
              },
            ),
          ),
          // No loading overlay for smooth experience
        ],
      ),
    );
  }

  Widget _buildGameCell(
    BuildContext context,
    int index,
    TicTacToeGameState gameState,
    TicTacToeProvider provider,
    double cellSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final player = gameState.board[index];
    final isWinningCell = gameState.winningLine?.contains(index) ?? false;

    Color cellColor = colorScheme.surface;
    if (isWinningCell) {
      cellColor = colorScheme.primary.withValues(alpha: 0.2);
    }

    Widget cellContent = const SizedBox.shrink();

    if (player == TicTacToePlayer.player) {
      cellContent = Text(
        'X',
        style: TextThemeManager.headlineSmall.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: cellSize * 0.6,
        ),
      );
    } else if (player == TicTacToePlayer.computer) {
      cellContent = Text(
        'O',
        style: TextThemeManager.headlineSmall.copyWith(
          color: colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: cellSize * 0.6,
        ),
      );
    }

    return GestureDetector(
      onTap: () => provider.onPlayerMove(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          boxShadow:
              player != TicTacToePlayer.none
                  ? [
                    BoxShadow(
                      color: (player == TicTacToePlayer.player
                              ? colorScheme.primary
                              : colorScheme.secondary)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: AnimatedScale(
          scale: player != TicTacToePlayer.none ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut,
          child: Center(child: cellContent),
        ),
      ),
    );
  }
}

class TicTacToeGridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  TicTacToeGridPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final cellSize = size.width / 3;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
