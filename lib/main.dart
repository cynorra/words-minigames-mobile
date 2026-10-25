import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/core/config/app_initializer.dart';
import 'package:device_preview/device_preview.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/onboarding_provider.dart';
import 'core/routes/app_router.dart';
import 'core/utils/global_context.dart';
import 'core/constants/supported_locales.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'core/utils/sound_utils.dart';
import 'shared/widgets/no_internet_screen.dart';
import 'shared/widgets/loading_screen.dart';
// Removed: handled by AppInitializer
import 'core/routes/navigation_observer.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(
    DevicePreview(
      enabled: !const bool.fromEnvironment('dart.vm.product'),
      builder: (context) => const MyApp(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SoundUtils.playOpeningSound();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: Consumer3<LanguageProvider, ThemeProvider, ConnectivityProvider>(
        builder: (
          context,
          languageProvider,
          themeProvider,
          connectivityProvider,
          child,
        ) {
          // Initialize favorites provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final favoritesProvider = Provider.of<FavoritesProvider>(
              context,
              listen: false,
            );
            favoritesProvider.initialize();
          });

          return MaterialApp(
            title: 'Words & Brain Mini Games',
            debugShowCheckedModeBanner: false,
            navigatorKey: GlobalContext.navigatorKey,
            useInheritedMediaQuery: true,
            locale: languageProvider.currentLocale,

            // Localization
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: SupportedLocales.locales,

            // Theme
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: _getThemeMode(themeProvider),

            // Routes
            initialRoute: _getInitialRoute(context),
            onGenerateRoute: AppRouter.generateRoute,
            navigatorObservers: [AppNavigationObserver()],

            // Performance
            builder: (context, child) {
              return Directionality(
                textDirection:
                    languageProvider.currentLocale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: _buildAppContent(context, connectivityProvider, child),
                ),
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(ThemeProvider themeProvider) {
    switch (themeProvider.currentThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String _getInitialRoute(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );

    if (onboardingProvider.isLoading) {
      // Show a loading screen or default to home
      return AppRouter.home;
    }

    return onboardingProvider.shouldShowOnboarding
        ? AppRouter.onboarding
        : AppRouter.home;
  }

  Widget _buildAppContent(
    BuildContext context,
    ConnectivityProvider connectivityProvider,
    Widget? child,
  ) {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );

    if (onboardingProvider.isLoading) {
      return const LoadingScreen();
    }

    if (connectivityProvider.showNoInternetScreen) {
      return const NoInternetScreen();
    }

    return child!;
  }
}
