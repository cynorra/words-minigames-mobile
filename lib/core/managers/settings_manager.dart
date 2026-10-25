import 'package:flutter/material.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/in_app_purchase_provider.dart';
import '../../l10n/app_localizations.dart';

/// Manager class to handle all settings-related business logic
/// This separates business logic from UI components
class SettingsManager {
  static const Map<String, String> _languageDisplayNames = {
    'en': 'English',
    'tr': 'Türkçe',
    'es': 'Español',
    'pt': 'Português',
    'ar': 'العربية',
    'de': 'Deutsch',
    'fr': 'Français',
    'id': 'Bahasa Indonesia',
    'hi': 'हिंदी',
    'az': 'Azərbaycan',
    'it': 'Italiano',
    'ru': 'Русский',
  };

  static const Map<String, String> _languageEmojis = {
    'en': '🇺🇸',
    'tr': '🇹🇷',
    'es': '🇪🇸',
    'pt': '🇧🇷',
    'ar': '🇸🇦',
    'de': '🇩🇪',
    'fr': '🇫🇷',
    'id': '🇮🇩',
    'hi': '🇮🇳',
    'az': '🇦🇿',
    'it': '🇮🇹',
    'ru': '🇷🇺',
  };

  /// Get display name for language code
  static String getLanguageDisplayName(String languageCode) {
    return _languageDisplayNames[languageCode] ?? '';
  }

  /// Get emoji flag for language code
  static String getLanguageEmoji(String languageCode) {
    return _languageEmojis[languageCode] ?? '🌐';
  }

  /// Get current theme display name
  static String getCurrentThemeDisplay(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    switch (themeProvider.currentThemeMode) {
      case AppThemeMode.light:
        return AppLocalizations.of(context)!.lightTheme;
      case AppThemeMode.dark:
        return AppLocalizations.of(context)!.darkTheme;
      case AppThemeMode.system:
        return AppLocalizations.of(context)!.systemTheme;
    }
  }

  /// Get theme emoji
  static String getThemeEmoji(ThemeProvider themeProvider) {
    return themeProvider.getThemeModeEmoji(themeProvider.currentThemeMode);
  }

  /// Get ad-free status display text
  static String getAdFreeStatusDisplay(
    BuildContext context,
    InAppPurchaseProvider purchaseProvider,
  ) {
    if (purchaseProvider.isAdFree || purchaseProvider.isSubscriptionActive) {
      return AppLocalizations.of(context)!.lifetimeAccess;
    }
    return AppLocalizations.of(context)!.subscriptionPrice;
  }

  /// Get ad-free title
  static String getAdFreeTitle(
    BuildContext context,
    InAppPurchaseProvider purchaseProvider,
  ) {
    return purchaseProvider.isAdFree
        ? AppLocalizations.of(context)!.lifetimeAccess
        : AppLocalizations.of(context)!.removeAds;
  }

  /// Get ad-free emoji
  static String getAdFreeEmoji(InAppPurchaseProvider purchaseProvider) {
    return purchaseProvider.isAdFree ? '✅' : '🚫';
  }

  /// Get settings options data
  static List<SettingsOptionData> getSettingsOptions(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
    InAppPurchaseProvider purchaseProvider,
  ) {
    final List<SettingsOptionData> options = [
      SettingsOptionData(
        title: AppLocalizations.of(context)!.language,
        subtitle: getLanguageDisplayName(
          languageProvider.currentLocale.languageCode,
        ),
        icon: Icons.language_rounded,
        emoji: getLanguageEmoji(languageProvider.currentLocale.languageCode),
        route: '/language-settings',
      ),
      SettingsOptionData(
        title: AppLocalizations.of(context)!.theme,
        subtitle: getCurrentThemeDisplay(context, themeProvider),
        icon: Icons.palette_rounded,
        emoji: getThemeEmoji(themeProvider),
        route: '/theme-settings',
      ),
      SettingsOptionData(
        title: AppLocalizations.of(context)!.soundSettings,
        subtitle: AppLocalizations.of(context)!.soundSettingsMenuSubtitle,
        icon: Icons.volume_up_rounded,
        emoji: '🔊',
        route: '/sound-settings',
      ),
      SettingsOptionData(
        title: AppLocalizations.of(context)!.leaderboardProfile,
        subtitle: AppLocalizations.of(context)!.leaderboardProfileSubtitle,
        icon: Icons.emoji_events_rounded,
        emoji: '🏅',
        route: '/leaderboard-profile',
      ),
      // Remove Ads option should be visible on all platforms.
      SettingsOptionData(
        title: getAdFreeTitle(context, purchaseProvider),
        subtitle: getAdFreeStatusDisplay(context, purchaseProvider),
        icon: Icons.block_rounded,
        emoji: getAdFreeEmoji(purchaseProvider),
        route: '/ad-free-subscription',
      ),
      SettingsOptionData(
        title: AppLocalizations.of(context)!.feedbackAndSuggestions,
        subtitle: AppLocalizations.of(context)!.feedbackAndSuggestionsSubtitle,
        icon: Icons.feedback_rounded,
        emoji: '💬',
        route: '/feedback',
      ),
    ];

    return options;
  }
}

/// Data class for settings options
class SettingsOptionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final String route;

  const SettingsOptionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.route,
  });
}
