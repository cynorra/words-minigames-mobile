import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../l10n/app_localizations.dart';
import 'modern_dialog_base.dart';
import 'dialog_config.dart';

class AdFreeSuccessDialog extends ModernDialogBase {
  final VoidCallback onContinue;

  const AdFreeSuccessDialog({super.key, required this.onContinue});

  @override
  State<AdFreeSuccessDialog> createState() => _AdFreeSuccessDialogState();
}

class _AdFreeSuccessDialogState
    extends ModernDialogBaseState<AdFreeSuccessDialog> {
  @override
  List<Widget> buildDialogContentList() {
    final localizations = AppLocalizations.of(context)!;
    final headerConfig = DialogConfig.premiumHeader;

    return [
      // Header with premium gradient
      buildDialogHeader(
        icon: Icon(
          headerConfig.icon,
          color: Colors.white,
          size: DialogConfig.iconSize,
        ),
        title: localizations.purchaseSuccess,
        subtitle: localizations.lifetimeAccess,
        gradientColor: headerConfig.color,
      ),

      // Content
      buildContentSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success message
            buildContentHeader(
              title: localizations.lifetimeAccess,
              description: localizations.removeAdsDescription,
            ),
            DialogConfig.extraLargeVerticalSpacing,

            // Benefits section
            Text(
              localizations.unlockedBenefits,
              style: TextThemeManager.subtitleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            DialogConfig.mediumVerticalSpacing,

            // Benefits list
            _buildBenefitsList(context),
            DialogConfig.extraLargeVerticalSpacing,

            // Action button
            buildActionButtons(
              buttons: [
                ModernDialogButton(
                  text: localizations.gotIt,
                  onPressed: () {
                    widget.onContinue();
                    Navigator.of(context).pop();
                  },
                  style: ModernDialogButtonStyle.primary(AppTheme.darkPrimary),
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildBenefitsList(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildBenefitItem(
            context,
            Icons.block_rounded,
            localizations.noBannerAdvertisements,
          ),
          _buildBenefitItem(
            context,
            Icons.block_rounded,
            localizations.noFullScreenAds,
          ),
          _buildBenefitItem(
            context,
            Icons.block_rounded,
            localizations.noVideoAds,
          ),
          _buildBenefitItem(
            context,
            Icons.auto_awesome_rounded,
            localizations.distractionFreeGaming,
          ),
          _buildBenefitItem(
            context,
            Icons.all_inclusive_rounded,
            localizations.oneTimePaymentForeverAccess,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.darkSuccess.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.darkSuccess, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
