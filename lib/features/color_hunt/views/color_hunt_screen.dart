import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quicko_app/core/constants/app_icons.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../models/color_hunt_game_state.dart';
import '../providers/color_hunt_provider.dart';

class ColorHuntScreen extends StatelessWidget {
  const ColorHuntScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ColorHuntProvider(),
      child: const _ColorHuntView(),
    );
  }
}

class _ColorHuntView extends StatelessWidget {
  const _ColorHuntView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorHuntProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;

        // Create game result when game is over
        GameResult? gameResult;
        if (gameState.showGameOver) {
          // Color Hunt doesn't have a win condition, only game over
          final isWin = false; // Always false since there's no win condition
          gameResult = GameResult(
            isWin: isWin,
            score: gameState.score,
            title: AppLocalizations.of(context)!.gameOver,
            lossReason: AppLocalizations.of(context)!.wrongColorSelection,
          );
        }

        return GameScreenBase(
          title: 'color_hunt',
          descriptionKey: 'color_hunt_description',
          gameId: 'color_hunt',
          gameResult: gameResult,
          onTryAgain: () {
            provider.hideGameOver();
            provider.resetGame();
          },
          onContinueGame: () => provider.continueGame(),
          canContinueGame: () => provider.canContinueGame(),
          onGameResultCleared: () {
            provider.cleanupGame();
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
          child: _buildGameContent(context, gameState, provider),
        );
      },
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    ColorHuntGameState gameState,
    ColorHuntProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final spacing =
            isSmallScreen
                ? AppConstants.largeSpacing
                : AppConstants.extraLargeSpacing;

        return Opacity(
          opacity: gameState.isWaiting ? 0.4 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skor ve zaman gösterimi
              _buildScoreTimeDisplay(context, gameState, isSmallScreen),

              SizedBox(height: spacing),

              // Hedef renk gösterimi
              _buildTargetDisplay(context, gameState, isSmallScreen),

              SizedBox(height: spacing),

              // Renk kutuları
              _buildColorBoxes(context, gameState, provider, isSmallScreen),
            ],
          ),
        );
      },
    );
  }

  String _getLocalizedColorName(BuildContext context, String? colorKey) {
    if (colorKey == null) return '';

    switch (colorKey) {
      case 'red':
        return AppLocalizations.of(context)!.red;
      case 'green':
        return AppLocalizations.of(context)!.green;
      case 'blue':
        return AppLocalizations.of(context)!.blue;
      case 'purple':
        return AppLocalizations.of(context)!.purple;
      case 'orange':
        return AppLocalizations.of(context)!.orange;
      case 'yellow':
        return AppLocalizations.of(context)!.yellow;
      case 'pink':
        return AppLocalizations.of(context)!.pink;
      case 'brown':
        return AppLocalizations.of(context)!.brown;
      case 'cyan':
        return AppLocalizations.of(context)!.cyan;
      case 'lime':
        return AppLocalizations.of(context)!.lime;
      case 'magenta':
        return AppLocalizations.of(context)!.magenta;
      case 'teal':
        return AppLocalizations.of(context)!.teal;
      case 'indigo':
        return AppLocalizations.of(context)!.indigo;
      case 'amber':
        return AppLocalizations.of(context)!.amber;
      case 'deep_purple':
        return AppLocalizations.of(context)!.deep_purple;
      case 'light_blue':
        return AppLocalizations.of(context)!.light_blue;
      default:
        return colorKey;
    }
  }

  Widget _buildScoreTimeDisplay(
    BuildContext context,
    ColorHuntGameState gameState,
    bool isSmallScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final horizontalPadding =
        isSmallScreen ? AppConstants.smallSpacing : AppConstants.mediumSpacing;
    final verticalPadding =
        isSmallScreen
            ? AppConstants.smallSpacing / 2
            : AppConstants.smallSpacing;
    final spacing =
        isSmallScreen ? AppConstants.smallSpacing : AppConstants.mediumSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          isSmallScreen ? AppConstants.smallRadius : AppConstants.mediumRadius,
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: spacing / 2,
        children: [
          _InfoPill(
            icon: AppIcons.score,
            label: AppLocalizations.of(context)!.score,
            value: '${gameState.score}',
            color: colorScheme.primary,
            isSmallScreen: isSmallScreen,
          ),
          _InfoPill(
            icon: AppIcons.timer,
            label: AppLocalizations.of(context)!.time,
            value: '${gameState.timeLeft}s',
            color: colorScheme.primary,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay(
    BuildContext context,
    ColorHuntGameState gameState,
    bool isSmallScreen,
  ) {
    final horizontalPadding =
        isSmallScreen ? AppConstants.mediumSpacing : AppConstants.largeSpacing;
    final verticalPadding =
        isSmallScreen ? AppConstants.smallSpacing : AppConstants.mediumSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          isSmallScreen ? AppConstants.smallRadius : AppConstants.mediumRadius,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: isSmallScreen ? 6 : 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.target,
            style: (isSmallScreen
                    ? TextThemeManager.bodyMedium
                    : TextThemeManager.subtitleMedium)
                .copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(
            height:
                isSmallScreen
                    ? AppConstants.smallSpacing / 2
                    : AppConstants.smallSpacing,
          ),
          _AnimatedTargetText(
            colorName: _getLocalizedColorName(
              context,
              gameState.targetColorKey,
            ),
            textColor: gameState.textColor,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildColorBoxes(
    BuildContext context,
    ColorHuntGameState gameState,
    ColorHuntProvider provider,
    bool isSmallScreen,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate box size based on available width
        final availableWidth = constraints.maxWidth;
        final spacing = isSmallScreen ? 12.0 : 15.0;
        final totalSpacing = spacing * 4;
        final boxSize = (availableWidth - totalSpacing) / 4;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Minimum ve maksimum boyutlar ekran boyutuna göre ayarlanır
        final minSize = min(
          screenWidth * (isSmallScreen ? 0.15 : 0.18),
          screenHeight * (isSmallScreen ? 0.1 : 0.12),
        );
        final maxSize = min(
          screenWidth * (isSmallScreen ? 0.2 : 0.25),
          screenHeight * (isSmallScreen ? 0.15 : 0.18),
        );
        final finalBoxSize = boxSize.clamp(minSize, maxSize);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildColorBox(
                  context,
                  gameState.availableColors[index],
                  index,
                  gameState.wrongTapIndex == index,
                  gameState.isGameActive,
                  () => provider.onColorTap(index),
                  boxSize: finalBoxSize,
                  isSmallScreen: isSmallScreen,
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildColorBox(
    BuildContext context,
    Color color,
    int index,
    bool isWrong,
    bool isActive,
    VoidCallback? onTap, {
    double boxSize = 100,
    bool isSmallScreen = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Yarıçap ekran boyutuna göre ayarlanır
    final baseRadius = min(
      screenWidth * (isSmallScreen ? 0.03 : 0.04),
      screenHeight * (isSmallScreen ? 0.02 : 0.03),
    );
    final radius = baseRadius.clamp(
      AppConstants.smallRadius,
      AppConstants.mediumRadius,
    );

    // Efekt boyutları ekran boyutuna göre ayarlanır
    final baseBlurRadius = min(
      screenWidth * (isSmallScreen ? 0.02 : 0.03),
      screenHeight * (isSmallScreen ? 0.015 : 0.02),
    );
    final blurRadius = baseBlurRadius.clamp(8.0, 12.0);

    final baseSpreadRadius = min(
      screenWidth * (isSmallScreen ? 0.003 : 0.005),
      screenHeight * (isSmallScreen ? 0.002 : 0.003),
    );
    final spreadRadius = baseSpreadRadius.clamp(1.0, 2.0);

    final baseBorderWidth = min(
      screenWidth * (isSmallScreen ? 0.003 : 0.004),
      screenHeight * (isSmallScreen ? 0.002 : 0.003),
    );
    final borderWidth = baseBorderWidth.clamp(1.0, 2.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 1.0, end: onTap != null ? 1.0 : 0.6),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: color, // Always use the original color
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha:
                        isSmallScreen
                            ? 0.5
                            : 0.6, // Reduced shadow opacity for small screens
                  ),
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: isSmallScreen ? 2 : 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: borderWidth,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                splashColor: Colors.white.withValues(alpha: 0.4),
                highlightColor: Colors.white.withValues(alpha: 0.2),
                child: _AnimatedColorBoxContent(
                  color: color,
                  onTap: onTap,
                  boxSize: boxSize,
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
    final iconSize = isSmallScreen ? 16.0 : 20.0;
    final spacing = isSmallScreen ? 4.0 : 6.0;
    final labelFontSize = isSmallScreen ? 10.0 : 12.0;
    final valueFontSize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: isSmallScreen ? 0.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(width: spacing),
          Text(
            '$label:',
            style: TextThemeManager.bodySmall.copyWith(
              color: onSurface.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: labelFontSize,
            ),
          ),
          SizedBox(width: spacing / 1.5),
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

class _AnimatedColorBoxContent extends StatefulWidget {
  final Color color;
  final VoidCallback? onTap;
  final double boxSize;
  final bool isSmallScreen;

  const _AnimatedColorBoxContent({
    required this.color,
    required this.onTap,
    this.boxSize = 100,
    this.isSmallScreen = false,
  });

  @override
  State<_AnimatedColorBoxContent> createState() =>
      _AnimatedColorBoxContentState();
}

class _AnimatedColorBoxContentState extends State<_AnimatedColorBoxContent>
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
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp() {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: Container(
                width: widget.boxSize,
                height: widget.boxSize,
                decoration: BoxDecoration(
                  color: widget.color, // Always use the original color
                  borderRadius: BorderRadius.circular(
                    AppConstants.mediumRadius,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedTargetText extends StatefulWidget {
  final String colorName;
  final Color textColor;
  final bool isSmallScreen;

  const _AnimatedTargetText({
    required this.colorName,
    required this.textColor,
    this.isSmallScreen = false,
  });

  @override
  State<_AnimatedTargetText> createState() => _AnimatedTargetTextState();
}

class _AnimatedTargetTextState extends State<_AnimatedTargetText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mediumSpacing,
              vertical: AppConstants.smallSpacing,
            ),
            decoration: BoxDecoration(
              color: widget.textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              border: Border.all(
                color: widget.textColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              widget.colorName,
              style: TextThemeManager.gameNumber.copyWith(
                fontSize: min(
                  MediaQuery.of(context).size.width *
                      (widget.isSmallScreen ? 0.07 : 0.09),
                  MediaQuery.of(context).size.height *
                      (widget.isSmallScreen ? 0.05 : 0.07),
                ),
                color: widget.textColor,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(
                      alpha: widget.isSmallScreen ? 0.2 : 0.3,
                    ),
                    offset: const Offset(1, 1),
                    blurRadius: widget.isSmallScreen ? 1 : 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
