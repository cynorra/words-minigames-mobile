import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/app_config.dart';
import '../../core/services/admob_service.dart';

/// A self-contained banner ad widget that manages its own BannerAd instance.
///
/// Use this for inline placements where multiple banners may appear in a list
/// or grid. It respects the global ad-free/test mode state via AdMobService.
class InlineBannerAdWidget extends StatefulWidget {
  final double verticalPadding;
  final double horizontalPadding;

  const InlineBannerAdWidget({
    super.key,
    this.verticalPadding = 8.0,
    this.horizontalPadding = 16.0,
  });

  @override
  State<InlineBannerAdWidget> createState() => _InlineBannerAdWidgetState();
}

class _InlineBannerAdWidgetState extends State<InlineBannerAdWidget> {
  final AdMobService _adMobService = AdMobService();
  final AppConfig _config = AppConfig();

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_adMobService.shouldShowAds) {
      return;
    }

    if (_isLoading || _isLoaded) return;
    _isLoading = true;

    try {
      final adUnitId = _config.bannerAdUnitId;

      final banner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _bannerAd = ad as BannerAd;
                _isLoaded = true;
                _isLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _isLoaded = false;
                _isLoading = false;
              });
            }
          },
        ),
      );

      await banner.load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoaded = false;
          _isLoading = false;
        });
      }
    }
  }

  void _disposeBannerIfAny() {
    try {
      _bannerAd?.dispose();
    } catch (_) {}
    _bannerAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  @override
  void dispose() {
    _disposeBannerIfAny();
    super.dispose();
  }

  void _checkAdFreeStatus() {
    final shouldShow = _adMobService.shouldShowAds;
    if (!shouldShow && _bannerAd != null) {
      // User became ad-free, dispose ad immediately
      _disposeBannerIfAny();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check ad-free status on every build
    _checkAdFreeStatus();

    final shouldShow = _adMobService.shouldShowAds;

    if (!shouldShow) {
      // Use fallback height that matches list spacing when ads are disabled
      return SizedBox(height: _getFallbackHeight());
    }

    if (!_isLoaded && !_isLoading) {
      // Try load if eligible and not yet loading
      _load();
    }

    if (!_isLoaded || _bannerAd == null) {
      // Use fallback height that matches list spacing when ad fails to load
      return SizedBox(height: _getFallbackHeight());
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        bottom: widget.verticalPadding,
        top: widget.verticalPadding,
        left: widget.horizontalPadding,
        right: widget.horizontalPadding,
      ),
      width: double.infinity,
      child: SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  /// Calculate the fallback height when ads are disabled/failed
  /// This should match the typical spacing between list items
  double _getFallbackHeight() {
    // For favorites and home screens (verticalPadding: 8.0), return exactly 16px to match spacing
    // For other screens, return a reasonable default
    return widget.verticalPadding * 2;
  }
}
