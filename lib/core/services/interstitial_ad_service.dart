import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';
import 'in_app_purchase_service.dart';
import 'package:flutter/material.dart';
import '../utils/global_context.dart';
import '../../shared/widgets/dialog/modern_remove_ads_dialog.dart';
import '../providers/in_app_purchase_provider.dart';

class InterstitialAdService {
  static final InterstitialAdService _instance =
      InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  final AppConfig _config = AppConfig();
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  InAppPurchaseProvider? _purchaseProvider;

  // Interstitial ad management
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool _isInterstitialAdLoading = false;

  // Route tracking
  int _routeChangeCount = 0;
  DateTime? _lastInterstitialAdShown;
  int _interstitialsShownSincePrompt = 0;
  bool _hasShownUpsellThisSession = false;

  // Configuration
  static const int _routeChangeThreshold = 15;
  static const Duration _minimumAdInterval = Duration(minutes: 1);

  /// Get interstitial ad unit ID
  String get _interstitialAdUnitId => _config.interstitialAdUnitId;

  /// Check if ads should be shown (respects ad-free subscription and test mode)
  bool get _shouldShowAds {
    // Always check the latest status from the purchase service
    final isAdFree = _purchaseService.isAdFree;

    // If user is ad-free, dispose any existing ads
    if (isAdFree) {
      _disposeAllAds();
    }

    return !isAdFree;
  }

  /// Initialize the service
  Future<void> initialize() async {
    // Preload the first interstitial ad
    await loadInterstitialAd();
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
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
      _isInterstitialAdLoading = false;
    } catch (e) {
      // Handle disposal errors silently
    }
  }

  /// Load interstitial ad
  Future<bool> loadInterstitialAd() async {
    // Don't load interstitial ads if user has ad-free subscription
    if (!_shouldShowAds) {
      return false;
    }

    if (_isInterstitialAdLoading || _isInterstitialAdLoaded) {
      return _isInterstitialAdLoaded;
    }

    _isInterstitialAdLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _isInterstitialAdLoading = false;

            // Set up ad event listeners
            _setupInterstitialAdEventListeners();
          },
          onAdFailedToLoad: (error) {
            _isInterstitialAdLoaded = false;
            _isInterstitialAdLoading = false;
          },
        ),
      );
    } catch (e) {
      _isInterstitialAdLoaded = false;
      _isInterstitialAdLoading = false;
    }

    return _isInterstitialAdLoaded;
  }

  /// Setup interstitial ad event listeners
  void _setupInterstitialAdEventListeners() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isInterstitialAdLoaded = false;
        _interstitialAd = null;
        _lastInterstitialAdShown = DateTime.now();

        // Load the next interstitial ad
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isInterstitialAdLoaded = false;
        _interstitialAd = null;

        // Try to load another ad
        loadInterstitialAd();
      },
      onAdShowedFullScreenContent: (ad) {},
    );
  }

  /// Track route change and show ad if conditions are met
  Future<void> onRouteChanged() async {
    if (_shouldShowAds) {
      _routeChangeCount++;

      if (_shouldShowInterstitialAd()) {
        await showInterstitialAd();
      }
    }
  }

  /// Check if interstitial ad should be shown
  bool _shouldShowInterstitialAd() {
    // Don't show if user has ad-free subscription or test mode
    if (!_shouldShowAds) {
      return false;
    }

    // Check route change threshold
    if (_routeChangeCount < _routeChangeThreshold) {
      return false;
    }

    // Check minimum interval between ads
    if (_lastInterstitialAdShown != null) {
      final timeSinceLastAd = DateTime.now().difference(
        _lastInterstitialAdShown!,
      );
      if (timeSinceLastAd < _minimumAdInterval) {
        return false;
      }
    }

    return true;
  }

  /// Show interstitial ad
  Future<bool> showInterstitialAd() async {
    // Don't show interstitial ads if user has ad-free subscription
    if (!_shouldShowAds) {
      return false;
    }

    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      final loaded = await loadInterstitialAd();
      if (!loaded) {
        return false;
      }
    }

    try {
      await _interstitialAd!.show();

      // Reset route change count after showing ad
      _routeChangeCount = 0;

      // Count interstitials and maybe prompt upsell
      _interstitialsShownSincePrompt++;
      if (_interstitialsShownSincePrompt % 5 == 0 &&
          !_hasShownUpsellThisSession) {
        _maybeShowAdFreeUpsell();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _maybeShowAdFreeUpsell() {
    if (!_shouldShowAds) return;

    final BuildContext? ctx = GlobalContext.context;
    if (ctx == null) return;

    // Mark that we've shown the upsell this session
    _hasShownUpsellThisSession = true;

    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
        return const ModernRemoveAdsDialog();
      },
    );
  }

  /// Force show interstitial ad (for testing or manual triggers)
  Future<bool> forceShowInterstitialAd() async {
    if (!_shouldShowAds) {
      return false;
    }

    return await showInterstitialAd();
  }

  /// Get current route change count
  int get routeChangeCount => _routeChangeCount;

  /// Get route change threshold
  int get routeChangeThreshold => _routeChangeThreshold;

  /// Get time since last ad was shown
  Duration? get timeSinceLastAd {
    if (_lastInterstitialAdShown == null) return null;
    return DateTime.now().difference(_lastInterstitialAdShown!);
  }

  /// Check if interstitial ad is available
  bool get isInterstitialAdAvailable =>
      _isInterstitialAdLoaded && _interstitialAd != null;

  /// Check if interstitial ads should be shown (respects ad-free subscription and test mode)
  bool get shouldShowInterstitialAds => _shouldShowAds;

  /// Reset route change count (useful for testing)
  void resetRouteChangeCount() {
    _routeChangeCount = 0;
  }

  /// Reset session upsell flag (call this when app starts or session begins)
  void resetSessionUpsellFlag() {
    _hasShownUpsellThisSession = false;
  }

  /// Dispose the service
  void dispose() {
    _purchaseProvider?.removeAdFreeStatusListener(_onAdFreeStatusChanged);
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;
    _isInterstitialAdLoading = false;
  }
}
