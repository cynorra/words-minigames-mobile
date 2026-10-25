import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Configuration class for dialog themes and common properties
class DialogConfig {
  // Common dialog properties
  static const double borderRadius = 24.0;
  static const EdgeInsets dialogPadding = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets contentPadding = EdgeInsets.all(24);
  static const EdgeInsets headerPadding = EdgeInsets.all(24);
  static const double buttonHeight = 56.0;
  static const double iconSize = 28.0;
  static const double iconContainerSize = 52.0;
  static const double iconContainerRadius = 16.0;

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Curve animationCurve = Curves.elasticOut;

  // Shadow configuration
  static List<BoxShadow> get dialogShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Header configurations for different dialog types
  static DialogHeaderConfig get successHeader => DialogHeaderConfig(
    color: AppTheme.darkSuccess,
    icon: Icons.emoji_events_rounded,
  );

  static DialogHeaderConfig get warningHeader => DialogHeaderConfig(
    color: AppTheme.darkWarning,
    icon: Icons.warning_rounded,
  );

  static DialogHeaderConfig get errorHeader =>
      DialogHeaderConfig(color: AppTheme.darkError, icon: Icons.error_rounded);

  static DialogHeaderConfig get infoHeader =>
      DialogHeaderConfig(color: AppTheme.darkPrimary, icon: Icons.info_rounded);

  static DialogHeaderConfig get premiumHeader => DialogHeaderConfig(
    color: AppTheme.goldYellow,
    icon: Icons.workspace_premium_rounded,
  );

  // Button configurations
  static DialogButtonConfig get primaryButton =>
      DialogButtonConfig(type: DialogButtonType.primary, height: buttonHeight);

  static DialogButtonConfig get secondaryButton => DialogButtonConfig(
    type: DialogButtonType.secondary,
    height: buttonHeight,
  );

  // Spacing configurations
  static const SizedBox smallVerticalSpacing = SizedBox(height: 8);
  static const SizedBox mediumVerticalSpacing = SizedBox(height: 16);
  static const SizedBox largeVerticalSpacing = SizedBox(height: 24);
  static const SizedBox extraLargeVerticalSpacing = SizedBox(height: 32);

  static const SizedBox smallHorizontalSpacing = SizedBox(width: 8);
  static const SizedBox mediumHorizontalSpacing = SizedBox(width: 16);
  static const SizedBox largeHorizontalSpacing = SizedBox(width: 24);
}

/// Header configuration for different dialog types
class DialogHeaderConfig {
  final Color color;
  final IconData icon;

  const DialogHeaderConfig({required this.color, required this.icon});
}

/// Button configuration
class DialogButtonConfig {
  final DialogButtonType type;
  final double height;

  const DialogButtonConfig({required this.type, required this.height});
}

/// Dialog button types
enum DialogButtonType { primary, secondary }

/// Predefined dialog sizes
enum DialogSize { small, medium, large }

extension DialogSizeExtension on DialogSize {
  double get maxWidth {
    switch (this) {
      case DialogSize.small:
        return 300;
      case DialogSize.medium:
        return 400;
      case DialogSize.large:
        return 500;
    }
  }
}
