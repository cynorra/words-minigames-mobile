import 'package:flutter/material.dart';
import 'package:quicko_app/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../models/onboarding_page_data.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingPageData data;
  final AppLocalizations localizations;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.localizations,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late Animation<double> _iconScale;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _iconController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largeSpacing,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon section
          _buildIconSection(),

          const SizedBox(height: AppConstants.extraLargeSpacing),

          // Text section
          _buildTextSection(),
        ],
      ),
    );
  }

  Widget _buildIconSection() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.data.gradientColors,
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: widget.data.color.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.data.color.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: _iconScale,
        child: Icon(widget.data.icon, size: 80, color: widget.data.color),
      ),
    );
  }

  Widget _buildTextSection() {
    return FadeTransition(
      opacity: _textFade,
      child: Column(
        children: [
          // Title
          Text(
            _getLocalizedText(widget.data.title),
            style: TextThemeManager.screenTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Description
          Text(
            _getLocalizedText(widget.data.description),
            style: TextThemeManager.bodyLarge.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getLocalizedText(String key) {
    switch (key) {
      case 'onboardingTitle1':
        return widget.localizations.onboardingTitle1;
      case 'onboardingDescription1':
        return widget.localizations.onboardingDescription1;
      case 'onboardingTitle2':
        return widget.localizations.onboardingTitle2;
      case 'onboardingDescription2':
        return widget.localizations.onboardingDescription2;
      case 'onboardingTitle3':
        return widget.localizations.onboardingTitle3;
      case 'onboardingDescription3':
        return widget.localizations.onboardingDescription3;
      default:
        return key;
    }
  }
}
