import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../models/higher_lower_game_state.dart';
import '../providers/higher_lower_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';

class HigherLowerScreen extends StatelessWidget {
  const HigherLowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HigherLowerProvider(),
      child: const _HigherLowerView(),
    );
  }
}

class _HigherLowerView extends StatelessWidget {
  const _HigherLowerView();

  @override
  Widget build(BuildContext context) {
    return Consumer<HigherLowerProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showGameOver) {
          final isWin = gameState.status == HigherLowerGameStatus.won;
          gameResult = GameResult(
            isWin: isWin,
            score: gameState.score,
            title:
                isWin
                    ? AppLocalizations.of(context)!.congratulations
                    : AppLocalizations.of(context)!.gameOver,
            subtitle:
                isWin
                    ? AppLocalizations.of(context)!.youGuessedCorrectly
                    : null,
            lossReason:
                isWin ? null : AppLocalizations.of(context)!.betterLuckNextTime,
          );
        }

        return GameScreenBase(
          title: 'higher_lower',
          descriptionKey: 'higher_lower_description',
          gameId: 'higher_lower',
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
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    HigherLowerGameState gameState,
    HigherLowerProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
        final spacing = isSmallScreen ? 24.0 : 32.0;
        final largeSpacing = isSmallScreen ? 32.0 : 48.0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // Score Display
              _buildScoreDisplay(context, gameState, isSmallScreen),

              SizedBox(height: spacing),

              // Main Number Display
              _buildMainNumberDisplay(context, gameState, isSmallScreen),

              SizedBox(height: largeSpacing),

              // Game Buttons
              _buildGameButtons(context, gameState, provider, isSmallScreen),

              SizedBox(height: spacing),

              // Game Status Info
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreDisplay(
    BuildContext context,
    HigherLowerGameState gameState,
    bool isSmallScreen,
  ) {
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;
    final borderRadius = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 16.0 : 20.0;
    final iconPadding = isSmallScreen ? 6.0 : 8.0;
    final iconBorderRadius = isSmallScreen ? 8.0 : 12.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: isSmallScreen ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(iconBorderRadius),
            ),
            child: Icon(AppIcons.trophy, size: iconSize, color: Colors.white),
          ),
          SizedBox(width: spacing),
          Text(
            '${AppLocalizations.of(context)!.score}: ${gameState.score}',
            style: (isSmallScreen
                    ? TextThemeManager.titleSmall
                    : TextThemeManager.titleMedium)
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMainNumberDisplay(
    BuildContext context,
    HigherLowerGameState gameState,
    bool isSmallScreen,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Sayı gösterimi boyutu ekran boyutuna göre ayarlanır
    final baseSize = min(
      screenWidth * (isSmallScreen ? 0.3 : 0.35),
      screenHeight * (isSmallScreen ? 0.2 : 0.25),
    );
    final size = baseSize.clamp(120.0, 160.0);
    final borderRadius = size / 2;
    // Efekt boyutları ekran boyutuna göre ayarlanır
    final baseBlurRadius1 = min(
      screenWidth * (isSmallScreen ? 0.04 : 0.05),
      screenHeight * (isSmallScreen ? 0.03 : 0.04),
    );
    final blurRadius1 = baseBlurRadius1.clamp(16.0, 20.0);

    final baseBlurRadius2 = min(
      screenWidth * (isSmallScreen ? 0.08 : 0.1),
      screenHeight * (isSmallScreen ? 0.06 : 0.08),
    );
    final blurRadius2 = baseBlurRadius2.clamp(32.0, 40.0);

    final baseOffset1 = min(
      screenWidth * (isSmallScreen ? 0.015 : 0.02),
      screenHeight * (isSmallScreen ? 0.01 : 0.015),
    );
    final offset1 = baseOffset1.clamp(6.0, 8.0);

    final baseOffset2 = min(
      screenWidth * (isSmallScreen ? 0.03 : 0.04),
      screenHeight * (isSmallScreen ? 0.02 : 0.03),
    );
    final offset2 = baseOffset2.clamp(12.0, 16.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getNumberDisplayColor(context, gameState),
            _getNumberDisplayColor(context, gameState).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: _getNumberDisplayColor(
              context,
              gameState,
            ).withValues(alpha: 0.4),
            blurRadius: blurRadius1,
            spreadRadius: 0,
            offset: Offset(0, offset1),
          ),
          BoxShadow(
            color: _getNumberDisplayColor(
              context,
              gameState,
            ).withValues(alpha: 0.2),
            blurRadius: blurRadius2,
            spreadRadius: 0,
            offset: Offset(0, offset2),
          ),
        ],
      ),
      child: Center(child: _NumberSpinner(isSmallScreen: isSmallScreen)),
    );
  }

  Color _getNumberDisplayColor(
    BuildContext context,
    HigherLowerGameState gameState,
  ) {
    if (gameState.isWaiting) {
      return Theme.of(context).colorScheme.primary;
    }
    return AppTheme.darkWarning;
  }

  // Localized performant spinner to avoid provider-wide rebuilds

  Widget _buildGameButtons(
    BuildContext context,
    HigherLowerGameState gameState,
    HigherLowerProvider provider,
    bool isSmallScreen,
  ) {
    final spacing = isSmallScreen ? 12.0 : 20.0;

    return Row(
      children: [
        // Lower Button
        Expanded(
          child: _buildGameButton(
            context,
            AppLocalizations.of(context)!.lower,
            AppIcons.arrowDown,
            AppTheme.darkError,
            gameState.isGameActive && !gameState.isAnimating
                ? () => provider.guessLower()
                : null,
            isSmallScreen,
          ),
        ),

        SizedBox(width: spacing),

        // Higher Button
        Expanded(
          child: _buildGameButton(
            context,
            AppLocalizations.of(context)!.higher,
            AppIcons.arrowUp,
            AppTheme.darkSuccess,
            gameState.isGameActive && !gameState.isAnimating
                ? () => provider.guessHigher()
                : null,
            isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildGameButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
    bool isSmallScreen,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Buton yüksekliği ekran boyutuna göre ayarlanır
    final baseHeight = min(
      screenWidth * (isSmallScreen ? 0.16 : 0.2),
      screenHeight * (isSmallScreen ? 0.1 : 0.12),
    );
    final height = baseHeight.clamp(64.0, 80.0);

    // Kenar yuvarlaklığı ekran boyutuna göre ayarlanır
    final baseBorderRadius = min(
      screenWidth * (isSmallScreen ? 0.04 : 0.05),
      screenHeight * (isSmallScreen ? 0.03 : 0.04),
    );
    final borderRadius = baseBorderRadius.clamp(16.0, 20.0);

    // Efekt boyutları ekran boyutuna göre ayarlanır
    final baseBlurRadius1 = min(
      screenWidth * (isSmallScreen ? 0.02 : 0.03),
      screenHeight * (isSmallScreen ? 0.015 : 0.02),
    );
    final blurRadius1 = baseBlurRadius1.clamp(8.0, 12.0);

    final baseBlurRadius2 = min(
      screenWidth * (isSmallScreen ? 0.04 : 0.05),
      screenHeight * (isSmallScreen ? 0.03 : 0.04),
    );
    final blurRadius2 = baseBlurRadius2.clamp(16.0, 20.0);

    final baseOffset1 = min(
      screenWidth * (isSmallScreen ? 0.008 : 0.01),
      screenHeight * (isSmallScreen ? 0.005 : 0.007),
    );
    final offset1 = baseOffset1.clamp(3.0, 4.0);

    final baseOffset2 = min(
      screenWidth * (isSmallScreen ? 0.015 : 0.02),
      screenHeight * (isSmallScreen ? 0.01 : 0.015),
    );
    final offset2 = baseOffset2.clamp(6.0, 8.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 1.0, end: onPressed != null ? 1.0 : 0.6),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: blurRadius1,
                  spreadRadius: 0,
                  offset: Offset(0, offset1),
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: blurRadius2,
                  spreadRadius: 0,
                  offset: Offset(0, offset2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: Colors.white.withValues(alpha: 0.3),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: _GameButtonContent(
                  text: text,
                  icon: icon,
                  onPressed: onPressed,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameButtonContent extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSmallScreen;

  const _GameButtonContent({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isSmallScreen = false,
  });

  @override
  State<_GameButtonContent> createState() => _GameButtonContentState();
}

class _GameButtonContentState extends State<_GameButtonContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp() {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapCancel(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isSmallScreen ? 12 : 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: min(
                      MediaQuery.of(context).size.width *
                          (widget.isSmallScreen ? 0.06 : 0.07),
                      MediaQuery.of(context).size.height *
                          (widget.isSmallScreen ? 0.04 : 0.05),
                    ),
                  ),
                  SizedBox(height: widget.isSmallScreen ? 6 : 8),
                  Text(
                    widget.text,
                    style: (widget.isSmallScreen
                            ? TextThemeManager.buttonSmall
                            : TextThemeManager.buttonMedium)
                        .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NumberSpinner extends StatefulWidget {
  final bool isSmallScreen;

  const _NumberSpinner({this.isSmallScreen = false});

  @override
  State<_NumberSpinner> createState() => _NumberSpinnerState();
}

class _NumberSpinnerState extends State<_NumberSpinner> {
  final Random _random = Random();
  Timer? _spinTimer;
  int _displayNumber = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithProvider();
  }

  @override
  void didUpdateWidget(covariant _NumberSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWithProvider();
  }

  void _syncWithProvider() {
    final provider = Provider.of<HigherLowerProvider>(context);
    final state = provider.gameState;

    // Waiting state: no spin, show question UI handled in build
    if (state.isWaiting) {
      _stopSpin();
      return;
    }

    if (state.isAnimating) {
      _startSpin();
    } else {
      _stopSpin();
      setState(() {
        _displayNumber = state.currentNumber;
      });
    }
  }

  void _startSpin() {
    if (_spinTimer != null) return;
    // Update locally at 60hz/30hz for smoothness but low cost
    _spinTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        _displayNumber = _random.nextInt(50) + 1;
      });
    });
  }

  void _stopSpin() {
    _spinTimer?.cancel();
    _spinTimer = null;
  }

  @override
  void dispose() {
    _stopSpin();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HigherLowerProvider>(context);
    final state = provider.gameState;

    if (state.isWaiting) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 2000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Container(
              padding: EdgeInsets.all(widget.isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  widget.isSmallScreen ? 30 : 40,
                ),
              ),
              child: Icon(
                AppIcons.question,
                size: min(
                  MediaQuery.of(context).size.width *
                      (widget.isSmallScreen ? 0.09 : 0.12),
                  MediaQuery.of(context).size.height *
                      (widget.isSmallScreen ? 0.06 : 0.08),
                ),
                color: Colors.white,
              ),
            ),
          );
        },
      );
    }

    final numberToShow =
        state.isAnimating ? _displayNumber : state.currentNumber;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      tween: Tween(begin: 0.9, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(widget.isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(
                widget.isSmallScreen ? 30 : 40,
              ),
            ),
            child: Text(
              numberToShow.toString(),
              style: TextThemeManager.headlineSmall.copyWith(
                fontSize: min(
                  MediaQuery.of(context).size.width *
                      (widget.isSmallScreen ? 0.09 : 0.12),
                  MediaQuery.of(context).size.height *
                      (widget.isSmallScreen ? 0.06 : 0.08),
                ),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
