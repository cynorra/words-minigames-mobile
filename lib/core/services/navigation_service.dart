import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../../features/settings/views/language_settings_screen.dart';
import '../../features/settings/views/theme_settings_screen.dart';
import '../../features/settings/views/sound_settings_screen.dart';
import '../../features/settings/views/ad_free_subscription_screen.dart';
import '../../features/settings/views/feedback_screen.dart';
import '../../features/settings/views/leaderboard_profile_settings_screen.dart';

/// Service class to handle all navigation logic
/// This separates navigation logic from UI components
class NavigationService {
  /// Navigate to language settings
  static void navigateToLanguageSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()),
    );
  }

  /// Navigate to theme settings
  static void navigateToThemeSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
    );
  }

  /// Navigate to ad-free subscription
  static void navigateToAdFreeSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdFreeSubscriptionScreen()),
    );
  }

  /// Navigate to sound settings
  static void navigateToSoundSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SoundSettingsScreen()),
    );
  }

  /// Navigate to leaderboard profile
  static void navigateToLeaderboardProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LeaderboardProfileSettingsScreen(),
      ),
    );
  }

  /// Navigate to feedback
  static void navigateToFeedback(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FeedbackScreen()));
  }

  /// Navigate to home
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
  }

  /// Navigate to onboarding
  static void navigateToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
  }

  /// Navigate to game screen
  static void navigateToGame(BuildContext context, String gameRoute) {
    Navigator.of(context).pushNamed(gameRoute);
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navigate back with result
  static void navigateBackWithResult(BuildContext context, dynamic result) {
    Navigator.of(context).pop(result);
  }

  /// Navigate and replace current route
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  /// Navigate and clear all previous routes
  static void navigateAndClearAll(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  /// Show dialog
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
    );
  }
}
