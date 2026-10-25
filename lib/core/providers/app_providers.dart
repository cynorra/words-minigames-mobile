import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'in_app_purchase_provider.dart';
import 'language_provider.dart';
import 'sound_settings_provider.dart';

import 'theme_provider.dart';
import 'connectivity_provider.dart';
import 'onboarding_provider.dart';
import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/leaderboard/providers/leaderboard_provider.dart';
import '../../features/feedback/providers/feedback_provider.dart';
import '../services/admob_service.dart';
import '../services/interstitial_ad_service.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InAppPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SoundSettingsProvider()),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        // Feature providers
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ],
      child: _AdServicesSetup(child: child),
    );
  }
}

class _AdServicesSetup extends StatefulWidget {
  final Widget child;

  const _AdServicesSetup({required this.child});

  @override
  State<_AdServicesSetup> createState() => _AdServicesSetupState();
}

class _AdServicesSetupState extends State<_AdServicesSetup> {
  @override
  void initState() {
    super.initState();
    // Setup ad services listeners after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAdServicesListeners();
    });
  }

  void _setupAdServicesListeners() {
    final purchaseProvider = Provider.of<InAppPurchaseProvider>(
      context,
      listen: false,
    );
    
    // Setup listeners for ad services
    AdMobService().setupAdFreeStatusListener(purchaseProvider);
    InterstitialAdService().setupAdFreeStatusListener(purchaseProvider);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
