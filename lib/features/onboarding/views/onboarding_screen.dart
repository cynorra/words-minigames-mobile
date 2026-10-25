import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_indicator.dart';
import '../models/onboarding_page_data.dart';
import '../../../core/routes/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _initializePages();
    _fadeController.forward();
  }

  void _initializePages() {
    _pages.addAll([
      OnboardingPageData(
        icon: Icons.psychology_rounded,
        title: 'onboardingTitle1',
        description: 'onboardingDescription1',
        color: AppTheme.darkPrimary,
        gradientColors: [
          AppTheme.darkPrimary.withValues(alpha: 0.1),
          AppTheme.darkPrimary.withValues(alpha: 0.05),
        ],
      ),
      OnboardingPageData(
        icon: Icons.speed_rounded,
        title: 'onboardingTitle2',
        description: 'onboardingDescription2',
        color: AppTheme.darkSuccess,
        gradientColors: [
          AppTheme.darkSuccess.withValues(alpha: 0.1),
          AppTheme.darkSuccess.withValues(alpha: 0.05),
        ],
      ),
      OnboardingPageData(
        icon: Icons.emoji_events_rounded,
        title: 'onboardingTitle3',
        description: 'onboardingDescription3',
        color: AppTheme.goldYellow,
        gradientColors: [
          AppTheme.goldYellow.withValues(alpha: 0.1),
          AppTheme.goldYellow.withValues(alpha: 0.05),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // İlk sayfa için animasyon yapma
    if (page > 0) {
      _slideController.forward(from: 0);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );

    await onboardingProvider.completeOnboarding();

    if (mounted) {
      // Navigate to home screen
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeController,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              _buildSkipButton(localizations),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable swipe
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    // İlk sayfa için animasyon yapma
                    if (index == 0) {
                      return OnboardingPage(
                        data: _pages[index],
                        localizations: localizations,
                      );
                    }

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: OnboardingPage(
                        data: _pages[index],
                        localizations: localizations,
                      ),
                    );
                  },
                ),
              ),

              // Bottom section
              _buildBottomSection(localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(AppLocalizations localizations) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _skipOnboarding,
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mediumSpacing,
                  vertical: AppConstants.smallSpacing / 2,
                ),
                child: Text(
                  localizations.skip,
                  style: TextThemeManager.bodyMedium.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        children: [
          // Page indicators
          OnboardingIndicator(
            currentPage: _currentPage,
            totalPages: _pages.length,
            activeColor: _pages[_currentPage].color,
          ),

          const SizedBox(height: AppConstants.largeSpacing),

          // Action button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: _pages[_currentPage].color.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: _pages[_currentPage].color.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _nextPage,
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.mediumSpacing,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _pages[_currentPage].color,
                        _pages[_currentPage].color.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                    border: Border.all(
                      color: _pages[_currentPage].color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? localizations.getStarted
                          : localizations.next,
                      style: TextThemeManager.buttonLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
