// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/feedback_provider.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

class FeedbackFormWidget extends StatelessWidget {
  const FeedbackFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),
            const SizedBox(height: AppConstants.largeSpacing),

            // Form Section
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  _buildCategorySelector(context, feedbackProvider),
                  const SizedBox(height: AppConstants.largeSpacing),

                  // Title Field
                  _buildTitleField(context, feedbackProvider),
                  const SizedBox(height: AppConstants.mediumSpacing),

                  // Description Field
                  _buildDescriptionField(context, feedbackProvider),
                  const SizedBox(height: AppConstants.mediumSpacing),

                  // Email Field (Optional)
                  _buildEmailField(context, feedbackProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallSpacing),
              Text(
                l10n.directContact,
                style: TextThemeManager.sectionTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            l10n.directContactDescription,
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          GestureDetector(
            onTap: () => _launchEmail(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
                vertical: AppConstants.smallSpacing,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'quickogamehelp@gmail.com',
                    style: TextThemeManager.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    FeedbackProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackCategory,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
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
          child: DropdownButtonFormField<String>(
            initialValue: _getValidDropdownValue(
              provider.feedbackData.category,
              context,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
                vertical: AppConstants.smallSpacing,
              ),
            ),
            items:
                FeedbackProvider.getCategories(context).map((String category) {
                  return DropdownMenuItem<String>(
                    value: FeedbackProvider.getCategoryKey(category, context),
                    child: Text(
                      category,
                      style: TextThemeManager.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.updateCategory(newValue);
              }
            },
            dropdownColor: Theme.of(context).colorScheme.surface,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context, FeedbackProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final hasError =
        (provider.feedbackData.title.trim().isEmpty ||
            provider.feedbackData.title.trim().length < 3) &&
        provider.hasValidationError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackTitle,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
              width: hasError ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    hasError
                        ? Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            initialValue: provider.feedbackData.title,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.feedbackTitleHint,
              hintStyle: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
                vertical: AppConstants.smallSpacing,
              ),
            ),
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (value) => provider.updateTitle(value),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppConstants.smallSpacing),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: AppConstants.smallSpacing),
              Expanded(
                child: Text(
                  provider.feedbackData.title.trim().isEmpty
                      ? 'Please enter a title'
                      : 'Title must be at least 3 characters',
                  style: TextThemeManager.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionField(
    BuildContext context,
    FeedbackProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final hasError =
        (provider.feedbackData.description.trim().isEmpty ||
            provider.feedbackData.description.trim().length < 10) &&
        provider.hasValidationError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackDescription,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
              width: hasError ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    hasError
                        ? Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            initialValue: provider.feedbackData.description,
            maxLines: 5,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.feedbackDescriptionHint,
              hintStyle: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
                vertical: AppConstants.smallSpacing,
              ),
            ),
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (value) => provider.updateDescription(value),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppConstants.smallSpacing),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: AppConstants.smallSpacing),
              Expanded(
                child: Text(
                  provider.feedbackData.description.trim().isEmpty
                      ? 'Please enter a description'
                      : 'Description must be at least 10 characters',
                  style: TextThemeManager.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, FeedbackProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackEmail,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          l10n.feedbackEmailDescription,
          style: TextThemeManager.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
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
          child: TextFormField(
            initialValue: provider.feedbackData.userEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.feedbackEmailHint,
              hintStyle: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
                vertical: AppConstants.smallSpacing,
              ),
            ),
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (value) => provider.updateUserEmail(value),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Ensures the dropdown value is valid
  String _getValidDropdownValue(String currentCategory, BuildContext context) {
    final validCategories = FeedbackProvider.getCategories(context);
    final validKeys =
        validCategories
            .map(
              (category) => FeedbackProvider.getCategoryKey(category, context),
            )
            .toList();

    // If current category is valid, return it
    if (validKeys.contains(currentCategory)) {
      return currentCategory;
    }

    // Otherwise, return the first valid category (bug)
    return 'bug';
  }

  void _launchEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final feedbackProvider = Provider.of<FeedbackProvider>(
      context,
      listen: false,
    );

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'quickogamehelp@gmail.com',
      queryParameters: {
        'subject': l10n.feedbackFrom(feedbackProvider.feedbackData.title),
        'body': feedbackProvider.feedbackData.description,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showEmailLaunchErrorBottomSheet(context);
    }
  }

  void _showEmailLaunchErrorBottomSheet(BuildContext context) {
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
                        Icons.mail_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  // Title
                  Text(
                    l10n.emailLaunchError,
                    style: TextThemeManager.sectionTitle.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  // Description
                  Text(
                    'Please try again manually or use the feedback form instead.',
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
                        'Got it!',
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
