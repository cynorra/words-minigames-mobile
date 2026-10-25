import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../../../shared/models/game_state.dart';
import '../models/twenty_one_game_state.dart';
import '../providers/twenty_one_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';

class TwentyOneScreen extends StatelessWidget {
  const TwentyOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TwentyOneProvider(),
      child: const _TwentyOneView(),
    );
  }
}

class _TwentyOneView extends StatelessWidget {
  const _TwentyOneView();

  @override
  Widget build(BuildContext context) {
    return Consumer<TwentyOneProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showGameOver) {
          // ignore: unrelated_type_equality_checks
          final isWin = gameState.status == GameStatus.won;
          gameResult = GameResult(
            isWin: isWin,
            score: gameState.score,
            title:
                isWin
                    ? AppLocalizations.of(context)!.congratulations
                    : AppLocalizations.of(context)!.gameOver,
            subtitle:
                isWin
                    ? AppLocalizations.of(context)!.youReached21
                    : AppLocalizations.of(context)!.youWentOver21,
            lossReason:
                isWin ? null : AppLocalizations.of(context)!.youWentOver21,
          );
        }

        return GameScreenBase(
          title: 'twenty_one',
          descriptionKey: 'twenty_one_description',
          gameId: 'twenty_one',
          gameResult: gameResult,
          showCongratsOnWin: true,
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
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    TwentyOneGameState gameState,
    TwentyOneProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final spacing =
            isSmallScreen
                ? AppConstants.smallSpacing
                : AppConstants.mediumSpacing;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Top section: Score
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score display
                  _buildScoreDisplay(context, gameState, isSmallScreen),
                ],
              ),
            ),

            // Middle section: Player and Dealer side by side
            Expanded(
              flex: isSmallScreen ? 3 : 4,
              child: Row(
                children: [
                  // You section (left)
                  Expanded(
                    child: _buildPlayerSection(
                      context,
                      gameState,
                      isSmallScreen,
                    ),
                  ),
                  SizedBox(width: spacing),
                  // Dealer section (right)
                  Expanded(
                    child: _buildDealerSection(
                      context,
                      gameState,
                      isSmallScreen,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section: Action buttons
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Action buttons
                  if (gameState.isGameActive && !gameState.isDealerTurn)
                    _buildActionButtons(
                      context,
                      gameState,
                      provider,
                      isSmallScreen,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreDisplay(
    BuildContext context,
    TwentyOneGameState gameState,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
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
            size: isSmallScreen ? 16 : 18,
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
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

  Widget _buildDealerSection(
    BuildContext context,
    TwentyOneGameState gameState,
    bool isSmallScreen,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.dealer,
          style: (isSmallScreen
                  ? TextThemeManager.bodyMedium
                  : TextThemeManager.subtitleMedium)
              .copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(
          height:
              isSmallScreen
                  ? AppConstants.smallSpacing / 2
                  : AppConstants.smallSpacing,
        ),
        _buildHandDisplay(
          context,
          gameState.dealerHand,
          gameState.dealerVisibleTotal,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildPlayerSection(
    BuildContext context,
    TwentyOneGameState gameState,
    bool isSmallScreen,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.you,
          style: (isSmallScreen
                  ? TextThemeManager.bodyMedium
                  : TextThemeManager.subtitleMedium)
              .copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(
          height:
              isSmallScreen
                  ? AppConstants.smallSpacing / 2
                  : AppConstants.smallSpacing,
        ),
        _buildHandDisplay(
          context,
          gameState.playerHand,
          gameState.playerTotal,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildHandDisplay(
    BuildContext context,
    List<Card> hand,
    int total,
    bool isSmallScreen,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: min(
          MediaQuery.of(context).size.width * (isSmallScreen ? 0.6 : 0.7),
          MediaQuery.of(context).size.height * (isSmallScreen ? 0.4 : 0.5),
        ),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cards
          Wrap(
            spacing: isSmallScreen ? 2 : 4,
            runSpacing: isSmallScreen ? 2 : 4,
            alignment: WrapAlignment.center,
            children:
                hand
                    .map((card) => _buildCard(context, card, isSmallScreen))
                    .toList(),
          ),
          SizedBox(
            height:
                isSmallScreen
                    ? AppConstants.smallSpacing / 2
                    : AppConstants.smallSpacing,
          ),
          // Total
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.darkPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
              border: Border.all(
                color: AppTheme.darkPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.total}: $total',
              style: (isSmallScreen
                      ? TextThemeManager.bodySmall
                      : TextThemeManager.bodyMedium)
                  .copyWith(
                    color: AppTheme.darkPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Card card, bool isSmallScreen) {
    return Container(
      width: min(
        MediaQuery.of(context).size.width * (isSmallScreen ? 0.11 : 0.13),
        MediaQuery.of(context).size.height * (isSmallScreen ? 0.08 : 0.1),
      ),
      height: min(
        MediaQuery.of(context).size.width * (isSmallScreen ? 0.16 : 0.18),
        MediaQuery.of(context).size.height * (isSmallScreen ? 0.12 : 0.14),
      ),
      decoration: BoxDecoration(
        color: card.isHidden ? AppTheme.overlayDark : Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          card.displayName,
          style: TextStyle(
            fontSize: min(
              MediaQuery.of(context).size.width *
                  (card.isHidden
                      ? (isSmallScreen ? 0.04 : 0.045)
                      : (isSmallScreen ? 0.03 : 0.035)),
              MediaQuery.of(context).size.height *
                  (card.isHidden
                      ? (isSmallScreen ? 0.03 : 0.035)
                      : (isSmallScreen ? 0.02 : 0.025)),
            ),
            fontWeight: FontWeight.bold,
            color: card.isHidden ? Colors.white : _getCardColor(card.suit),
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String suit) {
    if (suit == '♥' || suit == '♦') {
      return Colors.red;
    }
    return Colors.black;
  }

  Widget _buildActionButtons(
    BuildContext context,
    TwentyOneGameState gameState,
    TwentyOneProvider provider,
    bool isSmallScreen,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: min(
          MediaQuery.of(context).size.width * (isSmallScreen ? 0.8 : 0.9),
          MediaQuery.of(context).size.height * (isSmallScreen ? 0.5 : 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            AppLocalizations.of(context)!.hit,
            Icons.add,
            AppTheme.darkSuccess,
            gameState.canHit ? () => provider.hit() : null,
            isSmallScreen,
          ),
          _buildActionButton(
            context,
            AppLocalizations.of(context)!.stand,
            Icons.stop,
            AppTheme.darkError,
            gameState.canStand ? () => provider.stand() : null,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
    bool isSmallScreen,
  ) {
    return Container(
      width: min(
        MediaQuery.of(context).size.width * (isSmallScreen ? 0.25 : 0.3),
        MediaQuery.of(context).size.height * (isSmallScreen ? 0.15 : 0.18),
      ),
      height: min(
        MediaQuery.of(context).size.width * (isSmallScreen ? 0.12 : 0.15),
        MediaQuery.of(context).size.height * (isSmallScreen ? 0.08 : 0.1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: isSmallScreen ? 6 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: min(
                MediaQuery.of(context).size.width *
                    (isSmallScreen ? 0.05 : 0.06),
                MediaQuery.of(context).size.height *
                    (isSmallScreen ? 0.035 : 0.04),
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              text,
              style: TextStyle(
                fontSize: min(
                  MediaQuery.of(context).size.width *
                      (isSmallScreen ? 0.03 : 0.035),
                  MediaQuery.of(context).size.height *
                      (isSmallScreen ? 0.02 : 0.025),
                ),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
