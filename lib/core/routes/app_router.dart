import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';

// Features
import '../../features/home/views/home_screen.dart';
import '../../features/blind_sort/views/blind_sort_screen.dart';
import '../../features/higher_lower/views/higher_lower_screen.dart';
import '../../features/color_hunt/views/color_hunt_screen.dart';
import '../../features/aim_trainer/views/aim_trainer_screen.dart';
import '../../features/number_memory/views/number_memory_screen.dart';
import '../../features/rps/views/rps_page.dart';
import '../../features/find_difference/views/find_difference_page.dart';
import '../../features/twenty_one/views/twenty_one_screen.dart';
import '../../features/reaction_time/views/reaction_time_screen.dart';
import '../../features/pattern_memory/views/pattern_memory_screen.dart';
import '../../features/tictactoe/views/tictactoe_screen.dart';
import '../../features/guess_the_flag/views/guess_the_flag_screen.dart';
import '../../features/word_unscrambler/views/word_unscrambler_screen.dart';
import '../../features/word_guess/views/word_guess_screen.dart';
import '../../features/favorites/views/favorites_screen.dart';
import '../../features/leaderboard/views/leaderboard_screen.dart';
import '../../features/leaderboard/views/game_leaderboard_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/settings/views/ad_free_subscription_screen.dart';
import '../../features/settings/views/feedback_screen.dart';
import '../../features/onboarding/views/onboarding_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String blindSort = '/blind-sort';
  static const String higherLower = '/higher-lower';
  static const String colorHunt = '/color-hunt';
  static const String aimTrainer = '/aim-trainer';
  static const String numberMemory = '/number-memory';
  static const String rps = '/rps';
  static const String findDifference = '/find-difference';
  static const String twentyOne = '/twenty-one';
  static const String reactionTime = '/reaction-time';
  static const String patternMemory = '/pattern-memory';
  static const String ticTacToe = '/tic-tac-toe';
  static const String guessTheFlag = '/guess-the-flag';
  static const String wordUnscrambler = '/word-unscrambler';
  static const String wordGuess = '/word-guess';
  static const String favorites = '/favorites';
  static const String leaderboard = '/leaderboard';
  static const String gameLeaderboard = '/game-leaderboard';
  static const String settings = '/settings';
  static const String adFreeSubscription = '/ad-free-subscription';
  static const String feedback = '/feedback';
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _buildModernRoute(routeSettings, const HomeScreen());

      case blindSort:
        return _buildModernRoute(routeSettings, const BlindSortScreen());

      case higherLower:
        return _buildModernRoute(routeSettings, const HigherLowerScreen());

      case colorHunt:
        return _buildModernRoute(routeSettings, const ColorHuntScreen());

      case aimTrainer:
        return _buildModernRoute(routeSettings, const AimTrainerScreen());

      case numberMemory:
        return _buildModernRoute(routeSettings, const NumberMemoryScreen());

      case rps:
        return _buildModernRoute(routeSettings, const RpsPage());

      case findDifference:
        return _buildModernRoute(routeSettings, const FindDifferencePage());

      case twentyOne:
        return _buildModernRoute(routeSettings, const TwentyOneScreen());

      case reactionTime:
        return _buildModernRoute(routeSettings, const ReactionTimeScreen());

      case patternMemory:
        return _buildModernRoute(routeSettings, const PatternMemoryScreen());

      case ticTacToe:
        return _buildModernRoute(routeSettings, const TicTacToeScreen());

      case guessTheFlag:
        return _buildModernRoute(routeSettings, const GuessTheFlagScreen());

      case wordUnscrambler:
        return _buildModernRoute(routeSettings, const WordUnscramblerScreen());

      case wordGuess:
        return _buildModernRoute(routeSettings, const WordGuessScreen());

      case favorites:
        return _buildModernRoute(routeSettings, const FavoritesScreen());

      case leaderboard:
        return _buildModernRoute(routeSettings, const LeaderboardScreen());

      case gameLeaderboard:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final String gameId = args?['gameId'] as String? ?? '';
        final String title = args?['title'] as String? ?? 'Leaderboard';
        return _buildModernRoute(
          routeSettings,
          // Lazy import to avoid circular deps; file path: features/leaderboard/views/game_leaderboard_screen.dart
          // ignore: prefer_const_constructors
          GameLeaderboardScreen(gameId: gameId, title: title),
        );

      case settings:
        return _buildModernRoute(routeSettings, const SettingsScreen());

      case adFreeSubscription:
        return _buildModernRoute(
          routeSettings,
          const AdFreeSubscriptionScreen(),
        );

      case feedback:
        return _buildModernRoute(routeSettings, const FeedbackScreen());

      case onboarding:
        return _buildModernRoute(routeSettings, const OnboardingScreen());

      default:
        return _buildModernRoute(
          routeSettings,
          Scaffold(
            body: Center(child: Text('Route not found: ${routeSettings.name}')),
          ),
        );
    }
  }

  static PageRoute<dynamic> _buildModernRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }

  // Navigation helper methods with modern transitions
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }
}
