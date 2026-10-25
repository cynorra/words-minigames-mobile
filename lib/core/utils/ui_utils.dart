import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/text_theme_manager.dart';

/// Utility class for common UI operations
/// This separates UI logic from view components
class UIUtils {
  /// Create a settings option container with consistent styling
  static Widget createSettingsOptionContainer({
    required BuildContext context,
    required Widget child,
    double? width,
  }) {
    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Create an icon container with consistent styling
  static Widget createIconContainer({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              borderColor ??
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  /// Create a text style for settings option title
  static TextStyle getSettingsOptionTitleStyle(BuildContext context) {
    return TextThemeManager.subtitleMedium.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
  }

  /// Create a text style for settings option subtitle
  static TextStyle getSettingsOptionSubtitleStyle(BuildContext context) {
    return TextThemeManager.bodySmall.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
  }

  /// Create an arrow icon with consistent styling
  static Widget createArrowIcon(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      size: 16,
    );
  }

  /// Create a loading indicator with consistent styling
  static Widget createLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          Text(
            'Loading...',
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Create an empty state widget with consistent styling
  static Widget createEmptyState({
    required BuildContext context,
    required String message,
    required IconData icon,
    Color? iconColor,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppConstants.largeSpacing),
        padding: const EdgeInsets.all(AppConstants.extraLargeSpacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Text(
              message,
              style: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Create a section header with consistent styling
  static Widget createSectionHeader({
    required BuildContext context,
    required String title,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.mediumSpacing,
            vertical: AppConstants.smallSpacing,
          ),
      child: Text(
        title,
        style: TextThemeManager.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Create a responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSpacing * 0.8;
    } else if (screenWidth < 900) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.2;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSize * 0.9;
    } else if (screenWidth < 900) {
      return baseSize;
    } else {
      return baseSize * 1.1;
    }
  }
}
