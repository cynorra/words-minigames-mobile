import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';
import 'in_app_purchase_service.dart';
import '../providers/in_app_purchase_provider.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  final AppConfig _config = AppConfig();

  // Get AdMob IDs from configuration
  String get _rewardedAdUnitId => _config.rewardedAdUnitId;
  String get _bannerAdUnitId => _config.bannerAdUnitId;
  String get _leaderboardBannerAdUnitId => _config.leaderboardBannerAdUnitId;

  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isBannerAdLoaded = false;
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  InAppPurchaseProvider? _purchaseProvider;

  /// Initialize AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Set up listener for ad-free status changes
  void setupAdFreeStatusListener(InAppPurchaseProvider purchaseProvider) {
    _purchaseProvider = purchaseProvider;
    _purchaseProvider?.addAdFreeStatusListener(_onAdFreeStatusChanged);
  }

  /// Handle ad-free status changes
  void _onAdFreeStatusChanged() {
    // Check current status and dispose ads if user becomes ad-free
    final isAdFree = _purchaseService.isAdFree;
    if (isAdFree) {
      _disposeAllAds();
    }
  }

  /// Dispose all ads immediately
  void _disposeAllAds() {
    try {
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isAdLoaded = false;
      _isAdLoading = false;

      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
    } catch (e) {
      // Handle disposal errors silently
    }
  }

  /// Load rewarded ad
  Future<bool> loadRewardedAd() async {
    // Don't load ads if user has ad-free subscription
    if (!shouldShowAds) {
      return false;
    }

    if (_isAdLoading || _isAdLoaded) return _isAdLoaded;

    _isAdLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isAdLoaded = true;
            _isAdLoading = false;

            // Set up ad event listeners
            _setupAdEventListeners();
          },
          onAdFailedToLoad: (error) {
            _isAdLoaded = false;
            _isAdLoading = false;
          },
        ),
      );
    } catch (e) {
      _isAdLoaded = false;
      _isAdLoading = false;
    }

    return _isAdLoaded;
  }

  /// Setup default ad event listeners (without external callbacks)
  void _setupAdEventListeners() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isAdLoaded = false;
        _rewardedAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAdLoaded = false;
        _rewardedAd = null;
      },
      onAdShowedFullScreenContent: (ad) {},
    );
  }

  /// Show rewarded ad
  Future<bool> showRewardedAd({
    required Function() onRewarded,
    required Function() onAdClosed,
    required Function(String error) onAdFailed,
  }) async {
    // Don't show ads if user has ad-free subscription
    if (!shouldShowAds) {
      // For ad-free users, directly call onRewarded to continue
      onRewarded();
      return true;
    }

    if (!_isAdLoaded || _rewardedAd == null) {
      final loaded = await loadRewardedAd();
      if (!loaded) {
        onAdFailed('Ad not available');
        return false;
      }
    }

    try {
      // Attach per-show callbacks so we can notify when the ad is actually dismissed
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _isAdLoaded = false;
          _rewardedAd = null;
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isAdLoaded = false;
          _rewardedAd = null;
          onAdFailed(error.toString());
        },
        onAdShowedFullScreenContent: (ad) {},
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );

      return true;
    } catch (e) {
      onAdFailed(e.toString());
      return false;
    }
  }

  /// Load banner ad
  Future<bool> loadBannerAd() async {
    // Don't load banner ads if user has ad-free subscription
    if (!shouldShowAds) {
      return false;
    }

    if (_isBannerAdLoaded) {
      return true;
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
          },
          onAdOpened: (ad) {},
          onAdClosed: (ad) {},
        ),
      );

      await _bannerAd!.load();

      return _isBannerAdLoaded;
    } catch (e) {
      _isBannerAdLoaded = false;
      return false;
    }
  }

  /// Load banner ad with retry mechanism
  Future<bool> loadBannerAdWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final success = await loadBannerAd();
      if (success) {
        return true;
      }

      if (attempt < maxRetries) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return false;
  }

  /// Load leaderboard banner ad
  Future<bool> loadLeaderboardBannerAd() async {
    // Don't load banner ads if user has ad-free subscription
    if (!shouldShowAds) {
      return false;
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: _leaderboardBannerAdUnitId,
        size: AdSize.leaderboard,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
          },
          onAdOpened: (ad) {},
          onAdClosed: (ad) {},
        ),
      );

      await _bannerAd!.load();

      return _isBannerAdLoaded;
    } catch (e) {
      _isBannerAdLoaded = false;
      return false;
    }
  }

  /// Load leaderboard banner ad with retry mechanism
  Future<bool> loadLeaderboardBannerAdWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final success = await loadLeaderboardBannerAd();
      if (success) {
        return true;
      }

      if (attempt < maxRetries) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return false;
  }

  /// Get banner ad widget
  Widget? getBannerAdWidget() {
    // Don't show banner ads if user has ad-free subscription
    if (!shouldShowAds) {
      return null;
    }

    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  /// Get banner ad widget with responsive sizing
  Widget? getResponsiveBannerAdWidget() {
    // Don't show banner ads if user has ad-free subscription
    if (!shouldShowAds) {
      return null;
    }

    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  /// Check if ad is available
  bool get isAdAvailable => _isAdLoaded && _rewardedAd != null;

  /// Check if banner ad is available
  bool get isBannerAdAvailable => _isBannerAdLoaded && _bannerAd != null;

  /// Check if ads should be shown (respects ad-free subscription and test mode)
  bool get shouldShowAds {
    // Always check the latest status from the purchase service
    final isAdFree = _purchaseService.isAdFree;

    // If user is ad-free, dispose any existing ads
    if (isAdFree) {
      _disposeAllAds();
    }

    return !isAdFree;
  }

  /// Check if banner ads should be shown
  bool get shouldShowBannerAds => shouldShowAds && isBannerAdAvailable;

  /// Check if rewarded ads should be shown
  bool get shouldShowRewardedAds => shouldShowAds && isAdAvailable;

  /// Dispose ad
  void dispose() {
    _purchaseProvider?.removeAdFreeStatusListener(_onAdFreeStatusChanged);
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    _isAdLoading = false;
    _isBannerAdLoaded = false;
  }
}
