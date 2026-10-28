import 'dart:io';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  static bool get isProduction => environment == 'production';

  // Android AdMob IDs
  static const String _prodAndroidBanner = 'ca-app-pub-4674211063760769/8014468725';
  static const String _prodAndroidLeaderboardBanner = 'ca-app-pub-4674211063760769/1863993345';
  static const String _prodAndroidInterstitial = 'ca-app-pub-4674211063760769/2075746330';
  static const String _prodAndroidRewarded = 'ca-app-pub-4674211063760769/7822897035';
  static const String _defaultAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _defaultAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _defaultAndroidRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // iOS AdMob Test IDs
  static const String _defaultIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _defaultIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _defaultIosRewarded = 'ca-app-pub-3940256099942544/1712485313';

  // Banner Ad Unit ID
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_BANNER_AD_ID');
      if (defined.isNotEmpty) return defined;
      return isProduction ? _prodAndroidBanner : _defaultAndroidBanner;
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('IOS_BANNER_AD_ID', defaultValue: _defaultIosBanner);
    }
    return '';
  }

  // Leaderboard Banner Ad Unit ID
  String get leaderboardBannerAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_LEADERBOARD_BANNER_AD_ID');
      if (defined.isNotEmpty) return defined;
      return isProduction ? _prodAndroidLeaderboardBanner : _defaultAndroidBanner;
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('IOS_LEADERBOARD_BANNER_AD_ID', defaultValue: _defaultIosBanner);
    }
    return '';
  }

  // Interstitial Ad Unit ID
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_INTERSTITIAL_AD_ID');
      if (defined.isNotEmpty) return defined;
      return isProduction ? _prodAndroidInterstitial : _defaultAndroidInterstitial;
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('IOS_INTERSTITIAL_AD_ID', defaultValue: _defaultIosInterstitial);
    }
    return '';
  }

  // Rewarded Ad Unit ID
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_REWARDED_AD_ID');
      if (defined.isNotEmpty) return defined;
      return isProduction ? _prodAndroidRewarded : _defaultAndroidRewarded;
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('IOS_REWARDED_AD_ID', defaultValue: _defaultIosRewarded);
    }
    return '';
  }
}
