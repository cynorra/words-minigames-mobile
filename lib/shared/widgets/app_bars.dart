import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/text_theme_manager.dart';
import '../../features/favorites/providers/favorites_provider.dart';

/// Centralized AppBar management system for the app
class AppBars {
  /// Game Screen AppBar with favorite and leaderboard buttons
  static PreferredSizeWidget gameScreenAppBar({
    required BuildContext context,
    required String title,
    required String gameId,
    VoidCallback? onBackPressed,
    bool centerTitle = false,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextThemeManager.appTitlePrimary(context).copyWith(fontSize: 18),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      titleSpacing: 0,
      actions: [
        // Favorite button (only show if gameId exists)
        if (gameId.isNotEmpty)
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => favoritesProvider.toggleFavorite(gameId),
                  icon: Icon(
                    favoritesProvider.isFavorite(gameId)
                        ? AppIcons.favoriteFilled
                        : AppIcons.favoriteOutline,
                    color:
                        favoritesProvider.isFavorite(gameId)
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
        // Leaderboard button (only show if gameId exists)
        if (gameId.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 14, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AppRouter.pushNamed(
                    context,
                    AppRouter.gameLeaderboard,
                    arguments: {'gameId': gameId, 'title': title},
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/icon/winner.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onBackPressed ?? () => AppRouter.pop(context),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// Settings/Leaderboard AppBar with simple back button
  static PreferredSizeWidget settingsAppBar({
    required BuildContext context,
    required String title,
    VoidCallback? onBackPressed,
    bool centerTitle = true,
  }) {
    return AppBar(
      title: Text(title, style: TextThemeManager.appTitlePrimary(context)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onBackPressed ?? () => AppRouter.pop(context),
        ),
      ),
    );
  }

  /// Leaderboard AppBar with screen title style
  static PreferredSizeWidget leaderboardAppBar({
    required BuildContext context,
    required String title,
    VoidCallback? onBackPressed,
    bool centerTitle = true,
  }) {
    return AppBar(
      title: Text(title, style: TextThemeManager.screenTitlePrimary(context)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onBackPressed ?? () => AppRouter.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
