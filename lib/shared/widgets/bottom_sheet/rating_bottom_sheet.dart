// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../core/mixins/screen_animation_mixin.dart';

import '../../../core/theme/text_theme_manager.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_router.dart';

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({super.key});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet>
    with TickerProviderStateMixin, ScreenAnimationMixin, StarAnimationMixin {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    initializeAnimationsWithLongSlide();
    initializeStarAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced handle bar
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Modern header with improved spacing
                _buildModernHeader(),

                const SizedBox(height: AppConstants.largeSpacing),

                // Enhanced rating stars with better animations
                _buildEnhancedRatingStars(),

                const SizedBox(height: AppConstants.largeSpacing),

                // Improved action buttons with better visual hierarchy
                _buildModernActionButtons(),

                const SizedBox(height: AppConstants.largeSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largeSpacing,
      ),
      child: Column(
        children: [
          // Enhanced star icon with gradient and animation
          ScaleTransition(
            scale: starAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.star_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.largeSpacing),

          // Enhanced title with better typography
          Text(
            AppLocalizations.of(context)!.rateQuicko,
            style: TextThemeManager.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Improved description with better readability
          Text(
            AppLocalizations.of(context)!.rateQuickoDescription,
            style: TextThemeManager.bodyLarge.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRatingStars() {
    return Column(
      children: [
        // Enhanced question text
        Text(
          AppLocalizations.of(context)!.howWouldYouRate,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppConstants.largeSpacing),

        // Enhanced star rating with better animations
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index < _selectedRating;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = index + 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                transform:
                    Matrix4.identity()
                      ..scale(isSelected ? 1.1 : 1.0)
                      ..translate(0.0, isSelected ? -2.0 : 0.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.goldYellow.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 44,
                    color:
                        isSelected
                            ? AppTheme.goldYellow
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: AppConstants.mediumSpacing),

        // Enhanced rating text with animation
        if (_selectedRating > 0)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_selectedRating),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
                vertical: AppConstants.smallSpacing,
              ),
              decoration: BoxDecoration(
                color: _getRatingColor(_selectedRating).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRatingColor(
                    _selectedRating,
                  ).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getRatingText(_selectedRating),
                style: TextThemeManager.bodyMedium.copyWith(
                  color: _getRatingColor(_selectedRating),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largeSpacing,
      ),
      child: Column(
        children: [
          // Enhanced rate button - always visible but conditionally enabled
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient:
                  _selectedRating >= 4
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      )
                      : null,
              color:
                  _selectedRating >= 4
                      ? null
                      : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    _selectedRating >= 4
                        ? Colors.transparent
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: const [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    (_selectedRating == 0 || _isSubmitting)
                        ? null
                        : _onPrimaryAction,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largeSpacing,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting) ...[
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _selectedRating >= 4
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.mediumSpacing),
                      ] else ...[
                        Icon(
                          Icons.star_rounded,
                          color:
                              _selectedRating >= 4
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : (_selectedRating == 0
                                      ? Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.4)
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface),
                          size: 24,
                        ),
                        const SizedBox(width: AppConstants.mediumSpacing),
                      ],
                      Text(
                        _isSubmitting
                            ? AppLocalizations.of(context)!.openingStore
                            : (_selectedRating >= 4
                                ? AppLocalizations.of(context)!.rateOnStore
                                : AppLocalizations.of(context)!.sendFeedback),
                        style: TextThemeManager.buttonLarge.copyWith(
                          color:
                              _selectedRating >= 4
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : (_selectedRating == 0
                                      ? Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.4)
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPrimaryAction() async {
    if (_selectedRating >= 4) {
      await _rateApp();
    } else {
      await _goFeedback();
    }
  }

  Future<void> _goFeedback() async {
    if (!mounted) return;
    Navigator.of(context).pop();
    AppRouter.pushNamed(context, AppRouter.feedback);
  }

  Color _getRatingColor(int rating) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    switch (rating) {
      case 1:
        return Theme.of(context).colorScheme.error;
      case 2:
        return isDark ? AppTheme.darkWarning : AppTheme.lightWarning;
      case 3:
        return AppTheme.goldYellow;
      case 4:
      case 5:
        return isDark ? AppTheme.darkSuccess : AppTheme.lightSuccess;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return AppLocalizations.of(context)!.ratingPoor;
      case 2:
        return AppLocalizations.of(context)!.ratingFair;
      case 3:
        return AppLocalizations.of(context)!.ratingGood;
      case 4:
        return AppLocalizations.of(context)!.ratingVeryGood;
      case 5:
        return AppLocalizations.of(context)!.ratingExcellent;
      default:
        return '';
    }
  }

  Future<void> _rateApp() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final String storeUrl =
          Platform.isIOS
              ? 'https://apps.apple.com/app/quicko/id6751204576'
              : 'https://play.google.com/store/apps/details?id=com.cynnora.braingames';

      final Uri uri = Uri.parse(storeUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Could not open store');
      }
    } catch (e) {
      // No snackbar on error per requirement
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
