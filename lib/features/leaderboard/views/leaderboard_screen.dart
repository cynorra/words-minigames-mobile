// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quicko_app/core/constants/games_config.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/routes/app_router.dart';
import '../../../shared/models/leaderboard_entry.dart';
import '../../../shared/widgets/inline_banner_ad_widget.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../../../shared/widgets/app_bars.dart';
import '../providers/leaderboard_provider.dart';
import '../../../core/mixins/screen_animation_mixin.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin, ScreenAnimationMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: buildAnimatedBody(
        child: Consumer<LeaderboardProvider>(
          builder: (context, leaderboardProvider, child) {
            if (leaderboardProvider.isLoading) {
              return _buildLoadingState();
            }

            if (!leaderboardProvider.hasEntries) {
              return _buildEmptyState();
            }

            return _buildLeaderboardContent(leaderboardProvider);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBars.leaderboardAppBar(
      context: context,
      title: AppLocalizations.of(context)!.leaderboard,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          Text(
            AppLocalizations.of(context)!.loadingFavorites,
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppConstants.largeSpacing),
        padding: const EdgeInsets.all(AppConstants.extraLargeSpacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Text(
              AppLocalizations.of(context)!.noLeaderboardData,
              style: TextThemeManager.screenTitle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              AppLocalizations.of(context)!.playGamesToSeeScores,
              style: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => AppRouter.pop(context),
                icon: Image.asset(
                  'assets/icon/joystick.png',
                  width: 24,
                  height: 24,
                ),
                label: Text(
                  AppLocalizations.of(context)!.playGames,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(LeaderboardProvider leaderboardProvider) {
    final totalEntries = leaderboardProvider.entries.length;
    const int groupSize = 8;
    final int numberOfInlineBanners = totalEntries ~/ groupSize; // after each 8

    // Items: 0 stats, 1 banner, 2 swipe hint, then groups of 8 entries + 1 banner
    final int totalListItems = 3 + totalEntries + numberOfInlineBanners;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: totalListItems,
      itemBuilder: (context, index) {
        if (index == 0) return _buildStatistics(leaderboardProvider);
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mediumSpacing,
            ),
            child: BannerAdWidget(),
          );
        }
        if (index == 2) return _buildSwipeHint();

        final int afterHeaderIndex = index - 3;
        // Pattern length: 9 (8 entries + 1 banner)
        if ((afterHeaderIndex + 1) % 9 == 0) {
          // Inline banner after each 8 entries; use custom spacing to match card spacing
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const InlineBannerAdWidget(
              verticalPadding: 8.0, // Reduced padding to match card spacing
            ),
          );
        }

        // Compute entry index by subtracting banners before this position
        final int bannersBefore = afterHeaderIndex ~/ 9;
        final int entryIndex = afterHeaderIndex - bannersBefore;
        final entry = leaderboardProvider.entries[entryIndex];

        return AnimatedBuilder(
          animation: fadeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - fadeAnimation.value)),
              child: Opacity(
                opacity: fadeAnimation.value,
                child: _buildLeaderboardCard(entry, entryIndex + 1),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatistics(LeaderboardProvider leaderboardProvider) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.mediumSpacing),
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
              AppLocalizations.of(context)!.totalGames,
              leaderboardProvider.totalEntries.toString(),
              'joystick',
              AppTheme.darkSuccess,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              AppLocalizations.of(context)!.highestScore,
              leaderboardProvider.highestScore.toString(),
              'winner',
              AppTheme.darkWarning,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              AppLocalizations.of(context)!.averageScore,
              leaderboardProvider.averageScore.toStringAsFixed(1),
              'average',
              AppTheme.darkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String iconPath,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon Container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              GamesConfig.getGameIconPath(iconPath),
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),

        // Value Text
        Text(
          value,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Title Container with guaranteed 2-line layout
        Container(
          height: 40, // Fixed height for consistent 2-line layout
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextThemeManager.bodySmall.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.2, // Optimized line height for 2 lines
              fontSize: 12, // Slightly smaller font for better fit
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, int rank) {
    final gameConfig = GamesConfig.getGameById(entry.gameId);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(
      context,
      listen: false,
    );

    return Dismissible(
      key: Key('leaderboard_${entry.gameId}_${entry.highScore}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(
          context,
          entry,
          leaderboardProvider,
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.darkError,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    () => AppRouter.pushNamed(
                      context,
                      gameConfig?.route ?? AppRouter.home,
                    ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getRankColor(rank),
                              _getRankColor(rank).withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getRankColor(rank).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            rank.toString(),
                            style: TextThemeManager.subtitleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Game icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Image.asset(
                              gameConfig != null
                                  ? GamesConfig.getGameIconPath(gameConfig.icon)
                                  : 'assets/icon/joystick.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Game info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGameTitle(context, entry.gameId),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(entry.lastPlayed ?? DateTime.now()),
                              style: TextThemeManager.bodySmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getRankColor(rank).withValues(alpha: 0.1),
                              _getRankColor(rank).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _getRankColor(rank).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          entry.highScore.toString(),
                          style: TextStyle(
                            color: _getRankColor(rank),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Delete button
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    // Format: DD.MM.YY (e.g., "22.03.25")
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');

    return '$day.$month.$year';
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    LeaderboardEntry entry,
    LeaderboardProvider leaderboardProvider,
  ) async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Warning icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.darkError,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  AppLocalizations.of(context)!.deleteHighScore,
                  style: TextThemeManager.subtitleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppLocalizations.of(context)!.deleteHighScoreMessage,
                    style: TextThemeManager.bodyMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Score preview
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.highestScore,
                              style: TextThemeManager.bodySmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              entry.highScore.toString(),
                              style: TextThemeManager.subtitleMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextThemeManager.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Delete button
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.darkError,
                                AppTheme.darkError.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.darkError.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              await leaderboardProvider.removeHighScore(
                                entry.gameId,
                              );
                              Navigator.of(context).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_forever_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: TextThemeManager.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeHint() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumSpacing,
        vertical: AppConstants.smallSpacing,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumSpacing,
        vertical: AppConstants.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.darkError.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.swipe_left_rounded,
              color: AppTheme.darkError,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.smallSpacing),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.swipeToDeleteHint,
              style: TextThemeManager.bodySmall.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGameTitle(BuildContext context, String gameId) {
    final localizations = AppLocalizations.of(context)!;
    switch (gameId) {
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
      case 'rps':
        return localizations.rockPaperScissors;
      case 'twenty_one':
        return localizations.twentyOne;
      case 'reaction_time':
        return localizations.reactionTime;
      default:
        return gameId;
    }
  }
}

// (No sliver header; using a simple ListView for a standard scroll experience.)
