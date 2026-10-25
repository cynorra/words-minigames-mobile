import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/game_screen_base.dart';
import '../providers/guess_the_flag_provider.dart';
import '../models/guess_the_flag_game_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../l10n/app_localizations.dart';

class GuessTheFlagScreen extends StatelessWidget {
  const GuessTheFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GuessTheFlagProvider(),
      child: Consumer<GuessTheFlagProvider>(
        builder: (context, provider, child) {
          final gameState = provider.gameState;

          return GameScreenBase(
            title: 'guess_the_flag',
            descriptionKey: 'guess_the_flag_description',
            gameId: 'guess_the_flag',
            isWaiting: gameState.isWaiting,
            isGameInProgress: gameState.isGameActive,
            onStartGame: provider.startGame,
            onResetGame: provider.resetGame,
            onPauseGame: provider.pauseGame,
            onResumeGame: provider.resumeGame,
            onContinueGame: () => provider.continueGame(),
            canContinueGame: () => provider.canContinueGame(),
            onGameResultCleared: provider.cleanupGame,
            gameResult: _buildGameResult(context, gameState),
            showCongratsOnWin: false,
            customTopWidget: _buildTopWidget(context, gameState),
            child: _buildGameContent(context, gameState, provider),
          );
        },
      ),
    );
  }

  Widget _buildTopWidget(
    BuildContext context,
    GuessTheFlagGameState gameState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
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
                icon: Icons.timer_rounded,
                label: AppLocalizations.of(context)!.time,
                value: '${gameState.timeLeft}s',
                color: colorScheme.primary,
                isSmallScreen: isSmallScreen,
              ),
              _InfoPill(
                icon: Icons.emoji_events_rounded,
                label: AppLocalizations.of(context)!.score,
                value: '${gameState.score}',
                color: colorScheme.primary,
                isSmallScreen: isSmallScreen,
              ),
              _InfoPill(
                icon: Icons.favorite_rounded,
                label: AppLocalizations.of(context)!.lives,
                value: '${gameState.livesLeft}',
                color: colorScheme.primary,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextThemeManager.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextThemeManager.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    GuessTheFlagGameState gameState,
    GuessTheFlagProvider provider,
  ) {
    if (gameState.isWaiting) {
      return _buildWaitingContent(context);
    }

    if (gameState.isGameActive) {
      return _buildActiveGameContent(context, gameState, provider);
    }

    if (gameState.isGameOver) {
      return _buildGameOverContent(context, gameState);
    }

    return const SizedBox.shrink();
  }

  Widget _buildWaitingContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.flag,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.largeSpacing),
        Text(
          AppLocalizations.of(context)!.readyToStart,
          style: TextThemeManager.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          AppLocalizations.of(context)!.guessTheFlagDescription,
          style: TextThemeManager.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActiveGameContent(
    BuildContext context,
    GuessTheFlagGameState gameState,
    GuessTheFlagProvider provider,
  ) {
    return Column(
      children: [
        // Flag display
        Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              gameState.currentFlag?.flagEmoji ?? '',
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),

        const SizedBox(height: AppConstants.mediumSpacing),

        // Answer options in 2x2 grid
        _buildAnswerOptionsGrid(context, gameState, provider),
      ],
    );
  }

  Widget _buildAnswerOptionsGrid(
    BuildContext context,
    GuessTheFlagGameState gameState,
    GuessTheFlagProvider provider,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.smallSpacing,
        mainAxisSpacing: AppConstants.smallSpacing,
        childAspectRatio: 2.5,
      ),
      itemCount: gameState.options.length,
      itemBuilder: (context, index) {
        final option = gameState.options[index];
        final isSelected = gameState.selectedAnswer == option;
        final isCorrect = gameState.isCorrect && isSelected;
        final isWrong =
            gameState.selectedAnswer != null &&
            gameState.selectedAnswer == option &&
            !isCorrect;

        Color? backgroundColor;
        Color? borderColor;

        if (isSelected) {
          if (isCorrect) {
            backgroundColor = Colors.green.withValues(alpha: 0.2);
            borderColor = Colors.green;
          } else if (isWrong) {
            backgroundColor = Colors.red.withValues(alpha: 0.2);
            borderColor = Colors.red;
          }
        }

        return ElevatedButton(
          // Always enabled; provider guards repeat taps after selection
          onPressed: () => provider.selectAnswer(option),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(
              color:
                  borderColor ??
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallSpacing,
              vertical: AppConstants.smallSpacing,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
          ),
          child: Text(
            option,
            style: TextThemeManager.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildGameOverContent(
    BuildContext context,
    GuessTheFlagGameState gameState,
  ) {
    final title = AppLocalizations.of(context)!.timeUp;
    final subtitle = AppLocalizations.of(context)!.timeUpDescription;
    const icon = Icons.timer_off;
    final color = Colors.orange;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 64, color: color),
        ),
        const SizedBox(height: AppConstants.largeSpacing),
        Text(
          title,
          style: TextThemeManager.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            subtitle,
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppConstants.mediumSpacing),
        Text(
          '${AppLocalizations.of(context)!.finalScore}: ${gameState.score}',
          style: TextThemeManager.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  GameResult? _buildGameResult(
    BuildContext context,
    GuessTheFlagGameState gameState,
  ) {
    if (!gameState.isGameOver) return null;
    return GameResult(
      isWin: false,
      score: gameState.score,
      title: AppLocalizations.of(context)!.timeUp,
      subtitle: AppLocalizations.of(context)!.timeUpDescription,
    );
  }

  // Reusable info pill copied to match Aim Trainer UI
  // Kept local to avoid coupling; consider moving to shared if reused elsewhere
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
