import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rps_provider.dart';
import '../models/rps_game_state.dart';

class RpsPage extends StatelessWidget {
  const RpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RpsProvider(),
      child: const _RpsView(),
    );
  }
}

class _RpsView extends StatelessWidget {
  const _RpsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<RpsProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Create game result when game is over
        GameResult? gameResult;
        if (state.showGameOver) {
          gameResult = GameResult(
            isWin: state.youWon,
            score: state.youScore,
            title:
                state.youWon
                    ? AppLocalizations.of(context)!.congratulations
                    : AppLocalizations.of(context)!.gameOver,
            subtitle:
                state.youWon
                    ? AppLocalizations.of(context)!.youWonTheGame
                    : AppLocalizations.of(context)!.betterLuckNextTime,
            lossReason:
                state.youWon
                    ? null
                    : AppLocalizations.of(context)!.betterLuckNextTime,
          );
        }

        return GameScreenBase(
          title: 'rock_paper_scissors',
          descriptionKey: 'rock_paper_scissors_description',
          gameId: 'rps',
          gameResult: gameResult,
          showCongratsOnWin: true,
          onTryAgain: () {
            provider.reset();
          },
          onContinueGame: () => provider.continueGame(),
          canContinueGame: () => provider.canContinueGame(),
          onGameResultCleared: () => provider.hideGameOver(),
          onBackToMenu: () {
            Navigator.of(context).pop();
          },
          onStartGame: () {
            provider.start();
          },
          onResetGame: () {
            provider.reset();
          },
          isWaiting: state.isWaiting,
          isGameInProgress: !state.isWaiting && !state.showGameOver,
          onPauseGame: () => provider.pauseGame(),
          onResumeGame: () => provider.resumeGame(),
          child: _buildGameContent(context, state, provider),
        );
      },
    );
  }

  String _getLocalizedBannerText(BuildContext context, String? bannerTextKey) {
    final localizations = AppLocalizations.of(context)!;
    switch (bannerTextKey) {
      case 'youWin':
        return localizations.youWin;
      case 'youLose':
        return localizations.youLose;
      case 'tie':
        return localizations.tie;
      default:
        return '';
    }
  }

  Widget _buildGameContent(
    BuildContext context,
    RpsGameState state,
    RpsProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final horizontalPadding = isSmallScreen ? 8.0 : 12.0;
        final spacing = isSmallScreen ? 8.0 : 12.0;
        final largeSpacing = isSmallScreen ? 24.0 : 32.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      title: AppLocalizations.of(context)!.you,
                      emoji: _emojiFor(
                        state.playerPick,
                        false,
                        state.cpuAnimEmoji,
                      ),
                      score: state.youScore,
                      accent: AppTheme.darkSuccess,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _ScoreCard(
                      title: AppLocalizations.of(context)!.cpu,
                      emoji:
                          state.isCpuAnimating
                              ? state.cpuAnimEmoji
                              : _emojiFor(state.cpuPick, true, '❓'),
                      score: state.cpuScore,
                      accent: AppTheme.darkError,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: largeSpacing),

            // Banner message
            if (state.showBanner)
              AnimatedOpacity(
                opacity: state.showBanner ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : 20.0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : 20.0,
                    vertical: isSmallScreen ? 8.0 : 12.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.darkPrimary.withValues(alpha: 0.15),
                        AppTheme.darkPrimary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 12.0 : 16.0,
                    ),
                    border: Border.all(
                      color: AppTheme.darkPrimary.withValues(alpha: 0.3),
                      width: isSmallScreen ? 1.0 : 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkPrimary.withValues(alpha: 0.2),
                        blurRadius: isSmallScreen ? 8.0 : 12.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.bannerTextKey == 'youWin'
                            ? Icons.celebration_rounded
                            : state.bannerTextKey == 'youLose'
                            ? Icons.sentiment_dissatisfied_rounded
                            : Icons.handshake_rounded,
                        color: AppTheme.darkPrimary,
                        size: isSmallScreen ? 16.0 : 20.0,
                      ),
                      SizedBox(width: isSmallScreen ? 6.0 : 8.0),
                      Text(
                        _getLocalizedBannerText(context, state.bannerTextKey),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14.0 : 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: largeSpacing),

            // Choice buttons
            if (!state.isWaiting)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ChoiceButton(
                    emoji: '✊',
                    onTap:
                        state.isPlayerSelectionLocked
                            ? null
                            : () => provider.onPick(RpsChoice.rock),
                    isDisabled: state.isPlayerSelectionLocked,
                    isSmallScreen: isSmallScreen,
                  ),
                  _ChoiceButton(
                    emoji: '✋',
                    onTap:
                        state.isPlayerSelectionLocked
                            ? null
                            : () => provider.onPick(RpsChoice.paper),
                    isDisabled: state.isPlayerSelectionLocked,
                    isSmallScreen: isSmallScreen,
                  ),
                  _ChoiceButton(
                    emoji: '✌️',
                    onTap:
                        state.isPlayerSelectionLocked
                            ? null
                            : () => provider.onPick(RpsChoice.scissors),
                    isDisabled: state.isPlayerSelectionLocked,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  String _emojiFor(RpsChoice? choice, bool isCpu, String animEmoji) {
    if (choice == null) return '❓';
    switch (choice) {
      case RpsChoice.rock:
        return '✊';
      case RpsChoice.paper:
        return '✋';
      case RpsChoice.scissors:
        return '✌️';
    }
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final String emoji;
  final int score;
  final Color accent;
  final bool isSmallScreen;

  const _ScoreCard({
    required this.title,
    required this.emoji,
    required this.score,
    required this.accent,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        min(
          MediaQuery.of(context).size.width * (isSmallScreen ? 0.04 : 0.05),
          MediaQuery.of(context).size.height * (isSmallScreen ? 0.03 : 0.04),
        ).clamp(16.0, 20.0),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16.0 : 20.0),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: isSmallScreen ? 1.0 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: isSmallScreen ? 8.0 : 12.0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: isSmallScreen ? 16.0 : 20.0,
            offset: Offset(0, isSmallScreen ? 6.0 : 8.0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: min(
                    MediaQuery.of(context).size.width *
                        (isSmallScreen ? 0.035 : 0.045),
                    MediaQuery.of(context).size.height *
                        (isSmallScreen ? 0.025 : 0.03),
                  ).clamp(14.0, 18.0),
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : 12.0,
                  vertical: isSmallScreen ? 4.0 : 6.0,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 8.0 : 12.0,
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: min(
                      MediaQuery.of(context).size.width *
                          (isSmallScreen ? 0.04 : 0.05),
                      MediaQuery.of(context).size.height *
                          (isSmallScreen ? 0.03 : 0.035),
                    ).clamp(16.0, 20.0),
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          // Emoji with enhanced styling
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
              border: Border.all(
                color: accent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: min(
                  MediaQuery.of(context).size.width *
                      (isSmallScreen ? 0.07 : 0.09),
                  MediaQuery.of(context).size.height *
                      (isSmallScreen ? 0.05 : 0.06),
                ).clamp(28.0, 36.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatefulWidget {
  final String emoji;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isSmallScreen;

  const _ChoiceButton({
    required this.emoji,
    required this.onTap,
    this.isDisabled = false,
    this.isSmallScreen = false,
  });

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  // Removed unused _isPressed to satisfy linter

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: min(
              MediaQuery.of(context).size.width *
                  (widget.isSmallScreen ? 0.2 : 0.25),
              MediaQuery.of(context).size.height *
                  (widget.isSmallScreen ? 0.15 : 0.18),
            ).clamp(80.0, 100.0),
            height: min(
              MediaQuery.of(context).size.width *
                  (widget.isSmallScreen ? 0.2 : 0.25),
              MediaQuery.of(context).size.height *
                  (widget.isSmallScreen ? 0.15 : 0.18),
            ).clamp(80.0, 100.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    widget.isDisabled
                        ? [
                          Colors.grey.withValues(alpha: 0.1),
                          Colors.grey.withValues(alpha: 0.05),
                        ]
                        : [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.05),
                        ],
              ),
              borderRadius: BorderRadius.circular(
                widget.isSmallScreen ? 16.0 : 20.0,
              ),
              border: Border.all(
                color:
                    widget.isDisabled
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                width: widget.isSmallScreen ? 1.0 : 2.0,
              ),
              boxShadow:
                  widget.isDisabled
                      ? [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: widget.isSmallScreen ? 2.0 : 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius:
                              widget.isSmallScreen
                                  ? _elevationAnimation.value * 0.75
                                  : _elevationAnimation.value,
                          offset: Offset(
                            0,
                            widget.isSmallScreen
                                ? _elevationAnimation.value / 3
                                : _elevationAnimation.value / 2,
                          ),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: widget.isSmallScreen ? 16.0 : 20.0,
                          offset: Offset(0, widget.isSmallScreen ? 6.0 : 8.0),
                        ),
                      ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isDisabled ? null : widget.onTap,
                onTapDown: widget.isDisabled ? null : _onTapDown,
                onTapUp: widget.isDisabled ? null : _onTapUp,
                onTapCancel: widget.isDisabled ? null : _onTapCancel,
                borderRadius: BorderRadius.circular(
                  widget.isSmallScreen ? 16.0 : 20.0,
                ),
                splashColor:
                    widget.isDisabled
                        ? Colors.transparent
                        : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                highlightColor:
                    widget.isDisabled
                        ? Colors.transparent
                        : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                child: Container(
                  padding: EdgeInsets.all(widget.isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.emoji,
                        style: TextStyle(
                          fontSize: min(
                            MediaQuery.of(context).size.width *
                                (widget.isSmallScreen ? 0.07 : 0.09),
                            MediaQuery.of(context).size.height *
                                (widget.isSmallScreen ? 0.05 : 0.06),
                          ).clamp(28.0, 36.0),
                          color:
                              widget.isDisabled
                                  ? Colors.grey.withValues(alpha: 0.5)
                                  : null,
                        ),
                      ),
                      SizedBox(height: widget.isSmallScreen ? 2.0 : 4.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
