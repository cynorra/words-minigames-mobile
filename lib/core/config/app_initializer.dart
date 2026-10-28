import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:quicko_app/firebase_options.dart';

import '../services/admob_service.dart';
import '../services/in_app_purchase_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/sound_settings_service.dart';
import '../services/connectivity_service.dart';

class AppInitializer {
  AppInitializer._();

  static bool _initialized = false;

  /// Performs one-time application initialization in a well-defined order.
  /// Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> initialize() async {
    if (_initialized) return;

    // Ensure Flutter engine is ready
    // and set device orientation before any UI builds.
    await _ensureFlutterBindingAndOrientation();

    // Core services that are required app-wide
    await _initializeCoreServices();

    // Initialize connectivity service
    await ConnectivityService().initialize();

    // Firebase last so platform bindings are already in place
    await _initializeFirebase();

    _initialized = true;
  }

  static Future<void> _ensureFlutterBindingAndOrientation() async {
    // Widgets binding
    try {
      // ignore: deprecated_member_use_from_same_package
      WidgetsFlutterBinding.ensureInitialized();
    } catch (_) {
      // ignore
    }

    // Orientation
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> _initializeCoreServices() async {
    // Order matters slightly:
    // - IAP status before ad services
    // - Sound settings for early usage
    await Future.wait(<Future<void>>[
      InAppPurchaseService().initialize(),
      SoundSettingsService.ensureInitialized(),
    ]);

    await AdMobService().initialize();
    await InterstitialAdService().initialize();

    // Reset session upsell flag on app start
    InterstitialAdService().resetSessionUpsellFlag();
  }

  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      rethrow;
    }
  }
}
