import 'dart:io';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');
  static bool get isProduction => true;

  // Official Live Android AdMob IDs (never use Google test IDs)
  static const String _prodAndroidBanner = 'ca-app-pub-4674211063760769/8014468725';
  static const String _prodAndroidLeaderboardBanner = 'ca-app-pub-4674211063760769/1863993345';
  static const String _prodAndroidInterstitial = 'ca-app-pub-4674211063760769/2075746330';
  static const String _prodAndroidRewarded = 'ca-app-pub-4674211063760769/7822897035';

  // Official Live iOS AdMob IDs
  static const String _prodIosBanner = 'ca-app-pub-4674211063760769/9584879730';
  static const String _prodIosLeaderboardBanner = 'ca-app-pub-4674211063760769/2173293578';
  static const String _prodIosInterstitial = 'ca-app-pub-4674211063760769/2075746330';
  static const String _prodIosRewarded = 'ca-app-pub-4674211063760769/7555496667';

  // Banner Ad Unit ID
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_BANNER_AD_ID');
      return defined.isNotEmpty ? defined : _prodAndroidBanner;
    } else if (Platform.isIOS) {
      const defined = String.fromEnvironment('IOS_BANNER_AD_ID');
      return defined.isNotEmpty ? defined : _prodIosBanner;
    }
    return '';
  }

  // Leaderboard Banner Ad Unit ID
  String get leaderboardBannerAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_LEADERBOARD_BANNER_AD_ID');
      return defined.isNotEmpty ? defined : _prodAndroidLeaderboardBanner;
    } else if (Platform.isIOS) {
      const defined = String.fromEnvironment('IOS_LEADERBOARD_BANNER_AD_ID');
      return defined.isNotEmpty ? defined : _prodIosLeaderboardBanner;
    }
    return '';
  }

  // Interstitial Ad Unit ID
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_INTERSTITIAL_AD_ID');
      return defined.isNotEmpty ? defined : _prodAndroidInterstitial;
    } else if (Platform.isIOS) {
      const defined = String.fromEnvironment('IOS_INTERSTITIAL_AD_ID');
      return defined.isNotEmpty ? defined : _prodIosInterstitial;
    }
    return '';
  }

  // Rewarded Ad Unit ID
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      const defined = String.fromEnvironment('ANDROID_REWARDED_AD_ID');
      return defined.isNotEmpty ? defined : _prodAndroidRewarded;
    } else if (Platform.isIOS) {
      const defined = String.fromEnvironment('IOS_REWARDED_AD_ID');
      return defined.isNotEmpty ? defined : _prodIosRewarded;
    }
    return '';
  }
}
