import 'package:flutter/material.dart';
import '../services/interstitial_ad_service.dart';
import '../services/firebase_metrics_service.dart';
import '../services/analytics_service.dart';
import '../constants/games_config.dart';

class AppNavigationObserver extends NavigatorObserver {
  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteChange(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // No metrics on pop; ads logic still runs
    _trackRouteChange(null);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackRouteChange(newRoute?.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _trackRouteChange(null);
  }

  /// Track route change and trigger interstitial ad if conditions are met
  void _trackRouteChange(String? routeName) {
    // Use a microtask to ensure this runs after the navigation is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitialAdService.onRouteChanged();

      // Metrics: If pushed route is a game route, record open
      final String? gameId = GamesConfig.getGameIdByRoute(routeName);
      if (gameId != null) {
        FirebaseMetricsService().incrementGameOpenCount(gameId);
        AnalyticsService().logGameOpened(gameId: gameId);
      }
    });
  }
}
