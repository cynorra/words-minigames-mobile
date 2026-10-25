// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../feedback/providers/feedback_provider.dart';
import '../../feedback/widgets/feedback_form_widget.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_bars.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                      child: SingleChildScrollView(
                        child: const FeedbackFormWidget(),
                      ),
                    ),
                  ),

                  // Fixed submit button at bottom
                  _buildFixedSubmitButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBars.settingsAppBar(context: context, title: l10n.feedback);
  }

  Widget _buildFixedSubmitButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  feedbackProvider.isFormValid
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                  feedbackProvider.isFormValid
                      ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8)
                      : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      feedbackProvider.isFormValid
                          ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3)
                          : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    feedbackProvider.isSubmitting ||
                            !feedbackProvider.isFormValid
                        ? null
                        : () => _submitFeedback(context, feedbackProvider),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.mediumSpacing,
                    horizontal: AppConstants.largeSpacing,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (feedbackProvider.isSubmitting) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallSpacing),
                      ] else ...[
                        Icon(
                          Icons.send_rounded,
                          color:
                              feedbackProvider.isFormValid
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.smallSpacing),
                      ],
                      Text(
                        feedbackProvider.isSubmitting
                            ? l10n.sending
                            : l10n.sendFeedback,
                        style: TextThemeManager.subtitleMedium.copyWith(
                          color:
                              feedbackProvider.isFormValid
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback(
    BuildContext context,
    FeedbackProvider provider,
  ) async {
    final success = await provider.submitFeedback();

    if (mounted) {
      if (success) {
        // Show success bottom sheet instead of SnackBar
        _showFeedbackSuccessBottomSheet(context);
      } else {
        // Show error bottom sheet instead of SnackBar
        _showFeedbackErrorBottomSheet(context);
      }
    }
  }

  void _showFeedbackSuccessBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Title
                  Text(
                    l10n.feedbackSentSuccess,
                    style: TextThemeManager.sectionTitle.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  // Description
                  Text(
                    l10n.feedbackSuccessDescription,
                    style: TextThemeManager.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.mediumRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n.feedbackSuccessGotIt,
                        style: TextThemeManager.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackErrorBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.error,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Title
                  Text(
                    l10n.feedbackErrorTitle,
                    style: TextThemeManager.sectionTitle.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  // Description
                  Text(
                    l10n.feedbackErrorDescription,
                    style: TextThemeManager.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.mediumRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n.feedbackSuccessGotIt,
                        style: TextThemeManager.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
