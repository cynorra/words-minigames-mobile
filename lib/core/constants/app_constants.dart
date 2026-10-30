class AppConstants {
  // App
  static const String appName = 'Words & Brain Mini Games';

  // Legal
  // If you host your Privacy Policy, update this to your live URL.
  // Having this constant allows showing a functional link in-app and in metadata.
  static const String privacyPolicyUrl =
      'https://github.com/cynorra/words-minigames-mobile/blob/main/PRIVACY.md';
  // Apple standard EULA URL per App Store guidance
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  // Game Constants
  static const int minNumber = 1;
  static const int maxNumber = 50;
  static const int slotCount = 10;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'tr'];
  static const String defaultLanguage = 'en';

  // Supported Themes
}
