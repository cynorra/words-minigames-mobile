import 'package:flutter/material.dart';
import '../../../core/theme/text_theme_manager.dart';

/// Base class for all modern dialogs in the app
/// Provides consistent styling, animations, and structure
abstract class ModernDialogBase extends StatefulWidget {
  const ModernDialogBase({super.key});
}

abstract class ModernDialogBaseState<T extends ModernDialogBase>
    extends State<T>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Build the dialog header with gradient background
  Widget buildDialogHeader({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color gradientColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientColor, gradientColor.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: icon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextThemeManager.subtitleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextThemeManager.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the dialog content section with padding
  Widget buildContentSection({required Widget child}) {
    return Padding(padding: const EdgeInsets.all(24), child: child);
  }

  /// Build content title and description
  Widget buildContentHeader({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextThemeManager.subtitleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextThemeManager.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Build action buttons row
  Widget buildActionButtons({required List<ModernDialogButton> buttons}) {
    return Row(
      children:
          buttons
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final button = entry.value;
                return [
                  if (index > 0) const SizedBox(width: 16),
                  Expanded(child: button),
                ];
              })
              .expand((widgets) => widgets)
              .toList(),
    );
  }

  /// Main build method that structures the dialog
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: buildDialogContentList(),
          ),
        ),
      ),
    );
  }

  /// Abstract method to be implemented by subclasses
  List<Widget> buildDialogContentList();
}

/// Modern dialog button component
class ModernDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ModernDialogButtonStyle style;
  final IconData? icon;

  const ModernDialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: _buildDecoration(context),
      child: _buildButton(context),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    switch (style.type) {
      case ModernDialogButtonType.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [style.color, style.color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: style.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ModernDialogButtonType.secondary:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        );
    }
  }

  Widget _buildButton(BuildContext context) {
    final isSecondary = style.type == ModernDialogButtonType.secondary;

    if (isSecondary) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _buildButtonContent(context, isSecondary),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _buildButtonContent(context, isSecondary),
      );
    }
  }

  Widget _buildButtonContent(BuildContext context, bool isSecondary) {
    final textColor = isSecondary ? style.color : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextThemeManager.bodyMedium.copyWith(
            color: textColor,
            fontWeight: isSecondary ? FontWeight.w600 : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Button style configuration
class ModernDialogButtonStyle {
  final ModernDialogButtonType type;
  final Color color;

  const ModernDialogButtonStyle({required this.type, required this.color});

  factory ModernDialogButtonStyle.primary(Color color) {
    return ModernDialogButtonStyle(
      type: ModernDialogButtonType.primary,
      color: color,
    );
  }

  factory ModernDialogButtonStyle.secondary(Color color) {
    return ModernDialogButtonStyle(
      type: ModernDialogButtonType.secondary,
      color: color,
    );
  }
}

enum ModernDialogButtonType { primary, secondary }
