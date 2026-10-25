import 'package:flutter/material.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/games_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/constants/app_icons.dart';
import '../../../shared/models/game_model.dart';
import '../providers/favorites_provider.dart';
import '../../../shared/widgets/inline_banner_ad_widget.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../../../shared/widgets/app_bars.dart';
import '../../../core/mixins/screen_animation_mixin.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin, ScreenAnimationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: buildAnimatedBody(
        child: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, child) {
            // Load favorites if not already loaded
            if (!favoritesProvider.isLoading &&
                favoritesProvider.favorites.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                favoritesProvider.loadFavorites();
              });
            }

            if (favoritesProvider.isLoading) {
              return _buildLoadingState();
            }

            if (!favoritesProvider.hasFavorites) {
              return _buildEmptyState();
            }

            return _buildFavoritesList(favoritesProvider);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBars.settingsAppBar(
      context: context,
      title: AppLocalizations.of(context)!.favorites,
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
                color: AppTheme.darkError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                AppIcons.favoriteOutline,
                size: 64,
                color: AppTheme.darkError,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Text(
              AppLocalizations.of(context)!.noFavoritesYet,
              style: TextThemeManager.screenTitle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              AppLocalizations.of(context)!.addGamesToFavorites,
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
                  AppLocalizations.of(context)!.browseGames,
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

  Widget _buildFavoritesList(FavoritesProvider favoritesProvider) {
    final favoriteGames =
        favoritesProvider.favorites
            .map((gameId) => GamesConfig.getGameById(gameId))
            .where((game) => game != null)
            .toList();

    final List<Widget> children = [];

    // Add banner ad at the top
    children.add(
      const Padding(
        padding: EdgeInsets.only(bottom: AppConstants.mediumSpacing),
        child: BannerAdWidget(),
      ),
    );

    for (int i = 0; i < favoriteGames.length; i++) {
      final game = favoriteGames[i]!;
      children.add(
        AnimatedBuilder(
          animation: fadeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - fadeAnimation.value)),
              child: Opacity(
                opacity: fadeAnimation.value,
                child: _buildFavoriteCard(context, game),
              ),
            );
          },
        ),
      );

      // Insert a banner after every 8 favorites, except after the last item
      final isEighth = (i + 1) % 8 == 0;
      final isLast = i == favoriteGames.length - 1;
      if (isEighth && !isLast) {
        // Use custom spacing to match the 16px gap between favorite cards
        children.add(
          const InlineBannerAdWidget(
            verticalPadding: 8.0, // Reduced padding to match card spacing
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      children: children,
    );
  }

  Widget _buildFavoriteCard(BuildContext context, GameModel game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppRouter.pushNamed(context, game.route),
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
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: Row(
              children: [
                // Game icon with modern design
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: Image.asset(
                        GamesConfig.getGameIconPath(game.icon),
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Game information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.getTitle(context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.getDescription(context),
                        style: TextThemeManager.bodyMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Remove from favorites button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkError.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final favoritesProvider = Provider.of<FavoritesProvider>(
                        context,
                        listen: false,
                      );
                      favoritesProvider.toggleFavorite(game.id);
                    },
                    icon: const Icon(
                      AppIcons.favoriteFilled,
                      color: AppTheme.darkError,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
