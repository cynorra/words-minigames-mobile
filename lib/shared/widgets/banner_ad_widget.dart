import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/app_config.dart';
import '../../core/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdMobService _adMobService = AdMobService();
  final AppConfig _config = AppConfig();

  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _disposed = false;
  Timer? _retryTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && !_isLoaded && _bannerAd == null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_disposed || !mounted) return;
    if (!_adMobService.shouldShowAds) return;
    if (_isLoading || _isLoaded) return;
    _isLoading = true;

    try {
      final adUnitId = _config.bannerAdUnitId;
      if (adUnitId.isEmpty) {
        _isLoading = false;
        return;
      }

      final width = MediaQuery.of(context).size.width.truncate().clamp(320, 1200);
      AdSize? adaptiveSize;
      try {
        adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      } catch (_) {
        adaptiveSize = null;
      }
      final size = adaptiveSize ?? AdSize.banner;

      if (_disposed || !mounted) {
        _isLoading = false;
        return;
      }

      final banner = BannerAd(
        adUnitId: adUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (_disposed || !mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _bannerAd = ad as BannerAd;
              _adSize = size;
              _isLoaded = true;
              _isLoading = false;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (_disposed || !mounted) return;
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
              _isLoading = false;
            });
            _scheduleRetry();
          },
        ),
      );

      await banner.load();
    } catch (e) {
      if (!_disposed && mounted) {
        setState(() {
          _isLoaded = false;
          _isLoading = false;
        });
        _scheduleRetry();
      }
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 25), () {
      if (!_disposed && mounted && !_isLoaded && !_isLoading) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShow = _adMobService.shouldShowAds;

    if (!shouldShow) {
      if (_bannerAd != null) {
        _bannerAd?.dispose();
        _bannerAd = null;
        _isLoaded = false;
      }
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null || _adSize == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      alignment: Alignment.center,
      width: _adSize!.width.toDouble(),
      height: _adSize!.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
