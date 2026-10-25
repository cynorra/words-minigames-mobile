import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/app_config.dart';
import '../../core/services/admob_service.dart';

class LeaderboardBannerAdWidget extends StatefulWidget {
  const LeaderboardBannerAdWidget({super.key});

  @override
  State<LeaderboardBannerAdWidget> createState() =>
      _LeaderboardBannerAdWidgetState();
}

class _LeaderboardBannerAdWidgetState extends State<LeaderboardBannerAdWidget> {
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
    if (!_adMobService.shouldShowAds) return;
    if (_isLoading || _isLoaded) return;
    _isLoading = true;

    try {
      final adUnitId = _config.leaderboardBannerAdUnitId;

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

  @override
  void dispose() {
    try {
      _bannerAd?.dispose();
    } catch (_) {}
    _bannerAd = null;
    super.dispose();
  }

  void _checkAdFreeStatus() {
    final shouldShow = _adMobService.shouldShowAds;
    if (!shouldShow && _bannerAd != null) {
      // User became ad-free, dispose ad immediately
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check ad-free status on every build
    _checkAdFreeStatus();

    if (!_adMobService.shouldShowAds) {
      return const SizedBox.shrink();
    }
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
