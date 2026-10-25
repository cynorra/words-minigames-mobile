// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/text_theme_manager.dart';
import '../../core/utils/sound_utils.dart';
// import '../../core/utils/global_context.dart';
import '../../l10n/app_localizations.dart';
import 'dialog/continue_game_dialog.dart';
import 'dialog/game_in_progress_dialog.dart';
import 'dialog/congrats_dialog.dart';
import '../../core/services/leaderboard_service.dart';
import 'dialog/leaderboard_register_dialog.dart';
import '../../core/services/leaderboard_profile_service.dart';
import 'app_bars.dart';
import 'game_action_button.dart';

class GameScreenBase extends StatefulWidget {
  final String title;
  final String descriptionKey;
  final String gameId;
  final Widget child;
  final Widget? descriptionIcon;
  final Widget? customTopWidget;
  final bool isWaiting;
  final GameResult? gameResult;
  final VoidCallback? onTryAgain;
  final VoidCallback? onBackToMenu;
  final VoidCallback? onStartGame;
  final VoidCallback? onResetGame;
  final Future<bool> Function()? onContinueGame;
  final Future<bool> Function()? canContinueGame;
  final VoidCallback? onGameResultCleared;
  final bool isGameInProgress;
  final VoidCallback? onPauseGame;
  final VoidCallback? onResumeGame;
  final bool showCongratsOnWin;

  const GameScreenBase({
    super.key,
    required this.title,
    required this.descriptionKey,
    required this.gameId,
    required this.child,
    this.descriptionIcon,
    this.customTopWidget,
    this.isWaiting = false,
    this.gameResult,
    this.onTryAgain,
    this.onBackToMenu,
    this.onStartGame,
    this.onResetGame,
    this.onContinueGame,
    this.canContinueGame,
    this.onGameResultCleared,
    this.isGameInProgress = false,
    this.onPauseGame,
    this.onResumeGame,
    this.showCongratsOnWin = false,
  });

  @override
  State<GameScreenBase> createState() => _GameScreenBaseState();
}

class GameResult {
  final bool isWin;
  final int score;
  final String? subtitle;
  final String title;
  final String? customIcon;
  final String? lossReason; // New field for explaining why player lost

  const GameResult({
    required this.isWin,
    required this.score,
    this.subtitle,
    required this.title,
    this.customIcon,
    this.lossReason,
  });
}

class GameResultField {
  final String label;
  final IconData? icon;
  final Color? color;

  const GameResultField({required this.label, this.icon, this.color});
}

class _GameScreenBaseState extends State<GameScreenBase>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _exitRequested = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    // Eğer game result varsa, continue dialog'unu göster
    if (widget.gameResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showContinueDialog();
      });
    }
  }

  @override
  void didUpdateWidget(GameScreenBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameResult != null && oldWidget.gameResult == null) {
      _showContinueDialog();
    }
  }

  void _showContinueDialog() {
    // Ses çal
    if (widget.gameResult!.isWin) {
      SoundUtils.playWinnerSound();
    } else {
      SoundUtils.playGameOverSound();
    }

    // Eğer kazanıldıysa ve congrats gösterilmesi gerekiyorsa, doğrudan congrats dialog'u göster
    if (widget.showCongratsOnWin && widget.gameResult!.isWin) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!context.mounted) return;
        if (widget.gameResult == null) return;

        final score = widget.gameResult!.score;

        final result = await showDialog<ContinueGameResult>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => CongratsDialog(
                gameId: widget.gameId,
                gameTitle: _getLocalizedTitle(context),
                currentScore: score,
                onRestart: () {
                  widget.onTryAgain?.call();
                },
                onExit: () {
                  // Exit will be handled after potential leaderboard flow
                },
              ),
        );

        if (!context.mounted) return;
        if (result == ContinueGameResult.continued) return;

        // Devam edilmediyse (restart/exit/dismiss), skor belli oldu → leaderboard kaydı iste
        _exitRequested = result == ContinueGameResult.exited;
        await _handleLeaderboardQualification(score);

        // If user chose exit, navigate back after handling leaderboard
        if (_exitRequested) {
          widget.onBackToMenu?.call();
        }
        _exitRequested = false;
      });
      return;
    }

    // Kaybedildiyse veya congrats gösterilmemesi gerekiyorsa, continue dialog'u göster
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!context.mounted) return;
      if (widget.gameResult == null) return;

      final score = widget.gameResult!.score;

      // Check if continue game is available
      bool canContinue = false;
      if (widget.canContinueGame != null) {
        canContinue = await widget.canContinueGame!();
      }

      final result = await showDialog<ContinueGameResult>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => ContinueGameDialog(
              gameId: widget.gameId,
              gameTitle: _getLocalizedTitle(context),
              currentScore: score,
              canOneTimeContinue: canContinue,
              onContinue: () {
                // Dışarıdan sağlanan devam et davranışı (varsa)
                widget.onContinueGame?.call();
                // gameResult temizlenirse, üstteki guard sonraki akışları engeller
              },
              onRestart: () {
                widget.onResetGame?.call();
              },
              onExit: () {
                // Exit will be handled after potential leaderboard flow
              },
            ),
      );

      if (!context.mounted) return;
      if (result == ContinueGameResult.continued) return;

      // Devam edilmediyse (restart/exit/dismiss), skor belli oldu → leaderboard akışını başlat
      _exitRequested = result == ContinueGameResult.exited;
      await _handleLeaderboardQualification(score);

      // If user chose exit, navigate back after handling leaderboard
      if (_exitRequested) {
        widget.onBackToMenu?.call();
      }
      _exitRequested = false;
    });
  }

  Future<void> _handleLeaderboardQualification(int score) async {
    if (score <= 0) {
      _finishFlowDefault();
      return;
    }
    try {
      // Check if score qualifies for leaderboard
      final rank = await LeaderboardService().getProvisionalRank(
        gameId: widget.gameId,
        score: score,
      );
      if (!mounted) return;

      if (rank != null && rank <= 10) {
        // Score qualifies for leaderboard
        // First check if user already has a profile and better score
        final profileService = LeaderboardProfileService();
        final hasProfile = await profileService.hasProfile();

        if (hasProfile) {
          final name = await profileService.getName() ?? '';
          final countryCode = await profileService.getCountryCode() ?? 'TR';

          // Check if user already has a better score before showing dialog
          final existingEntry = await LeaderboardService().getUserExistingEntry(
            gameId: widget.gameId,
            name: name,
            countryCode: countryCode,
          );

          if (existingEntry != null) {
            // User already has an entry in leaderboard
            if (existingEntry.score >= score) {
              // User already has a better score, skip leaderboard without showing dialog
              _finishFlowDefault();
              return;
            } else {
              // User has a lower score, show leaderboard dialog and then update
              final bool consent = await _askLeaderboardOptIn(score);
              if (!consent) {
                _finishFlowDefault();
                return;
              }

              final result = await LeaderboardService().submitScoreSmart(
                gameId: widget.gameId,
                name: name,
                countryCode: countryCode,
                score: score,
              );

              if (result.success) {
                _finishFlowWithLeaderboard();
              } else {
                // This shouldn't happen since we already checked, but handle just in case
                _finishFlowDefault();
              }
              return;
            }
          }

          // User doesn't have an entry yet, proceed with leaderboard opt-in
          final bool consent = await _askLeaderboardOptIn(score);
          if (!consent) {
            _finishFlowDefault();
            return;
          }

          // Use smart submission method
          final result = await LeaderboardService().submitScoreSmart(
            gameId: widget.gameId,
            name: name,
            countryCode: countryCode,
            score: score,
          );

          if (result.success) {
            _finishFlowWithLeaderboard();
          } else {
            // This shouldn't happen since we already checked, but handle just in case
            _finishFlowDefault();
          }
        } else {
          // User doesn't have a profile, show registration dialog
          final bool consent = await _askLeaderboardOptIn(score);
          if (!consent) {
            _finishFlowDefault();
            return;
          }

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => LeaderboardRegisterDialog(
                  gameTitle: _getLocalizedTitle(context),
                  score: score,
                  onSubmit: ({
                    required String name,
                    required String countryCode,
                  }) async {
                    await profileService.saveProfile(
                      name: name,
                      countryCode: countryCode,
                    );

                    // Use smart submission method
                    final result = await LeaderboardService().submitScoreSmart(
                      gameId: widget.gameId,
                      name: name,
                      countryCode: countryCode,
                      score: score,
                    );

                    if (context.mounted) Navigator.of(context).pop();

                    if (result.success) {
                      _finishFlowWithLeaderboard();
                    } else {
                      // This shouldn't happen for new users, but handle just in case
                      _finishFlowDefault();
                    }
                  },
                ),
          );
        }
      } else {
        _finishFlowDefault();
      }
    } catch (_) {
      if (!mounted) return;
      _finishFlowDefault();
    }
  }

  Future<bool> _askLeaderboardOptIn(int score) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.congratulations,
                                  style: TextThemeManager.subtitleMedium
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppLocalizations.of(context)!.yourScore} $score',
                                  style: TextThemeManager.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addToLeaderboard,
                            style: TextThemeManager.subtitleMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.addToLeaderboardDescription,
                            style: TextThemeManager.bodyMedium.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.giveUp,
                                      style: TextThemeManager.bodyMedium
                                          .copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.yesAdd,
                                      style: TextThemeManager.bodyMedium
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _showCongratsOnly() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CongratsDialog(
            gameId: widget.gameId,
            gameTitle: _getLocalizedTitle(context),
            currentScore: widget.gameResult?.score ?? 0,
            onRestart: () {
              widget.onTryAgain?.call();
            },
            onExit: () {
              widget.onBackToMenu?.call();
            },
          ),
    );
  }

  void _showCongratsWithLeaderboard() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CongratsDialog(
            gameId: widget.gameId,
            gameTitle: _getLocalizedTitle(context),
            currentScore: widget.gameResult?.score ?? 0,
            onRestart: () {
              widget.onTryAgain?.call();
            },
            onExit: () {
              _showLeaderboardDialog();
            },
          ),
    );
  }

  void _finishFlowDefault() {
    // Kayıt akışı sonrası veya nitelik yoksa:
    // Kazanıldıysa tebrikler, aksi halde continue dialogu
    if (_exitRequested) return; // Exit akışında ara UI göstermeden çık
    if (widget.showCongratsOnWin && (widget.gameResult?.isWin ?? false)) {
      _showCongratsOnly();
    } else {
      // İkinci bir continue dialogunu gösterme
      widget.onTryAgain?.call();
    }
  }

  void _finishFlowWithLeaderboard() {
    // Leaderboard kayıt akışı sonrası:
    // Kazanıldıysa tebrikler, aksi halde continue dialogu
    if (_exitRequested) return; // Exit akışında ara UI göstermeden çık
    if (widget.showCongratsOnWin && (widget.gameResult?.isWin ?? false)) {
      _showCongratsWithLeaderboard();
    } else {
      // İkinci bir continue dialogunu gösterme
      widget.onTryAgain?.call();
    }
  }

  void _showLeaderboardDialog() {
    Navigator.of(context).pop(); // Close congrats dialog first
    // İkinci continue dialogunu tetikleme, kullanıcıyı menüye veya tekrar dene akışına yönlendir
    widget.onBackToMenu?.call();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _getLocalizedTitle(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (widget.title) {
      case 'pattern_memory':
        return localizations.patternMemory;
      case 'blind_sort':
        return localizations.blindSort;
      case 'higher_lower':
        return localizations.higherLower;
      case 'color_hunt':
        return localizations.colorHunt;
      case 'aim_trainer':
        return localizations.aimTrainer;
      case 'number_memory':
        return localizations.numberMemory;
      case 'find_difference':
        return localizations.findDifference;
      case 'rock_paper_scissors':
        return localizations.rockPaperScissors;
      case 'twenty_one':
        return localizations.twentyOne;
      case 'reaction_time':
        return localizations.reactionTime;
      case 'tic_tac_toe':
        return localizations.ticTacToe;
      case 'guess_the_flag':
        return localizations.guessTheFlag;
      default:
        return widget.title;
    }
  }

  String _getLocalizedDescription(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (widget.descriptionKey) {
      case 'pattern_memory_description':
        return localizations.patternMemoryDescription;
      case 'blind_sort_description':
        return localizations.blindSortDescription;
      case 'higher_lower_description':
        return localizations.higherLowerDescription;
      case 'color_hunt_description':
        return localizations.colorHuntDescription;
      case 'aim_trainer_description':
        return localizations.aimTrainerDescription;
      case 'number_memory_description':
        return localizations.numberMemoryDescription;
      case 'find_difference_description':
        return localizations.findDifferenceDescription;
      case 'rock_paper_scissors_description':
        return localizations.rockPaperScissorsDescription;
      case 'twenty_one_description':
        return localizations.twentyOneDescription;
      case 'reactionTimeDescription':
        return localizations.reactionTimeDescription;
      case 'tic_tac_toe_description':
        return localizations.ticTacToeDescription;
      case 'guess_the_flag_description':
        return localizations.guessTheFlagDescription;
      default:
        return widget.descriptionKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxHeight < 600;
                final horizontalPadding =
                    isSmallScreen
                        ? AppConstants.smallSpacing
                        : AppConstants.mediumSpacing;
                final verticalPadding =
                    isSmallScreen
                        ? AppConstants.smallSpacing / 2
                        : AppConstants.smallSpacing;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    children: [
                      // Game description - SABİT
                      SizedBox(
                        height: isSmallScreen ? 80 : 100,
                        child: SingleChildScrollView(
                          child:
                              widget.descriptionIcon != null
                                  ? _buildGameDescription()
                                  : _buildSimpleDescription(),
                        ),
                      ),

                      SizedBox(
                        height:
                            isSmallScreen
                                ? AppConstants.smallSpacing
                                : AppConstants.largeSpacing,
                      ),

                      // Custom top widget (score/round displays)
                      if (widget.customTopWidget != null) ...[
                        widget.customTopWidget!,
                        SizedBox(
                          height:
                              isSmallScreen
                                  ? AppConstants.smallSpacing
                                  : AppConstants.mediumSpacing,
                        ),
                      ],

                      // Main game content - FLIP ANİMASYONU SADECE BURADA
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isSmallScreen ? 400 : 500,
                                maxHeight: isSmallScreen ? 450 : 600,
                              ),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: widget.isWaiting ? 0.5 : 1.0,
                                child: IgnorePointer(
                                  ignoring: widget.isWaiting,
                                  child: _buildFlipContent(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom actions - SABİT (her zaman göster)
                      SizedBox(
                        height:
                            isSmallScreen
                                ? AppConstants.smallSpacing
                                : AppConstants.mediumSpacing,
                      ),
                      _buildBottomActions(context, isSmallScreen),
                      const SizedBox(height: AppConstants.smallSpacing),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlipContent() {
    // Simple content without flip animation
    return widget.child;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBars.gameScreenAppBar(
      context: context,
      title: _getLocalizedTitle(context),
      gameId: widget.gameId,
      onBackPressed: () => _handleBackButtonPress(context),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isSmallScreen) {
    return GameActionButton(
      isWaiting: widget.isWaiting,
      onPressed: () {
        if (widget.gameResult != null) {
          // Show appropriate dialog (congrats or continue)
          _showContinueDialog();
        } else if (widget.isWaiting) {
          // Oyun bekliyor, start game
          widget.onStartGame?.call();
        } else {
          // Oyun aktif, reset game
          widget.onResetGame?.call();
        }
      },
    );
  }

  void _handleBackButtonPress(BuildContext context) async {
    if (widget.isGameInProgress) {
      // Pause the game when dialog shows
      widget.onPauseGame?.call();

      // Show game in progress dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => GameInProgressDialog(
              onStayInGame: () {
                // Resume the game when staying
                widget.onResumeGame?.call();
              },
              onExitGame: () {
                // Clean up game state first
                widget.onGameResultCleared?.call();

                // Exit like normal back button (dialog will close automatically)
                AppRouter.pop(context); // Exit game like normal back button
              },
            ),
      );
    } else {
      // No game in progress, exit normally
      AppRouter.pop(context);
    }
  }

  Widget _buildGameDescription() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            isSmallScreen
                ? AppConstants.smallSpacing
                : AppConstants.mediumSpacing,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 36 : 48,
                height: isSmallScreen ? 36 : 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.mediumRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    child: widget.descriptionIcon!,
                  ),
                ),
              ),
              SizedBox(
                width:
                    isSmallScreen
                        ? AppConstants.smallSpacing
                        : AppConstants.mediumSpacing,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedDescription(context),
                      style: TextThemeManager.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleDescription() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal:
                isSmallScreen
                    ? AppConstants.smallSpacing
                    : AppConstants.mediumSpacing,
            vertical:
                isSmallScreen
                    ? AppConstants.smallSpacing / 2
                    : AppConstants.smallSpacing,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _getLocalizedDescription(context),
            style: TextThemeManager.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
