import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/text_theme_manager.dart';
import '../../core/constants/app_constants.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Directionality(
          textDirection:
              languageProvider.currentLocale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie Animation
                    _buildLottieAnimation(context),
                    const SizedBox(height: AppConstants.largeSpacing * 2),

                    // Title
                    _buildTitle(context),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    // Description
                    _buildDescription(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLottieAnimation(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/lottie/no_internet.json',
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.noInternetTitle,
      style: TextThemeManager.screenTitle.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.noInternetDescription,
      style: TextThemeManager.bodyLarge.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
