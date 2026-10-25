import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import 'modern_dialog_base.dart';
import 'dialog_config.dart';
import '../../../core/services/in_app_purchase_service.dart';

class ModernRemoveAdsDialog extends ModernDialogBase {
  const ModernRemoveAdsDialog({super.key});

  @override
  State<ModernRemoveAdsDialog> createState() => _ModernRemoveAdsDialogState();
}

class _ModernRemoveAdsDialogState
    extends ModernDialogBaseState<ModernRemoveAdsDialog> {
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  List<Widget> buildDialogContentList() {
    final localizations = AppLocalizations.of(context)!;
    final headerConfig = DialogConfig.premiumHeader;
    final isAdFree = InAppPurchaseService().isAdFree;

    // If user is already ad-free, show a simple acknowledgement UI
    if (isAdFree) {
      return [
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
        buildContentSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildContentHeader(
                title: localizations.unlockedBenefits,
                description: localizations.getCleanExperience,
              ),
              DialogConfig.extraLargeVerticalSpacing,
              buildActionButtons(
                buttons: [
                  ModernDialogButton(
                    text: localizations.gotIt,
                    onPressed: () => Navigator.of(context).pop(),
                    style: ModernDialogButtonStyle.primary(
                      AppTheme.darkPrimary,
                    ),
                    icon: Icons.check_circle_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ];
    }

    return [
      // Header
      buildDialogHeader(
        icon: Icon(
          headerConfig.icon,
          color: Colors.white,
          size: DialogConfig.iconSize,
        ),
        title: localizations.removeAds,
        subtitle: localizations.removeAdsDescription,
        gradientColor: headerConfig.color,
      ),

      // Content
      buildContentSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildContentHeader(
              title: localizations.premiumFeatures,
              description: localizations.getCleanExperience,
            ),
            DialogConfig.largeVerticalSpacing,

            // Features list
            _buildFeatureItem(
              icon: Icons.block_rounded,
              title: localizations.noBannerAds,
              color: AppTheme.darkError,
            ),
            DialogConfig.mediumVerticalSpacing,
            _buildFeatureItem(
              icon: Icons.close_rounded,
              title: localizations.noInterstitialAds,
              color: AppTheme.darkWarning,
            ),
            DialogConfig.mediumVerticalSpacing,
            _buildFeatureItem(
              icon: Icons.play_circle_rounded,
              title: localizations.noRewardedAds,
              color: AppTheme.darkSuccess,
            ),
            DialogConfig.mediumVerticalSpacing,
            _buildFeatureItem(
              icon: Icons.auto_awesome_rounded,
              title: localizations.cleanExperience,
              color: AppTheme.darkPrimary,
            ),

            DialogConfig.largeVerticalSpacing,

            // Price section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.goldYellow.withValues(alpha: 0.1),
                    AppTheme.goldYellow.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.goldYellow.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Best value badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.goldYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.goldYellow.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      localizations.bestValue,
                      style: TextThemeManager.bodySmall.copyWith(
                        color: AppTheme.goldYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    localizations.subscriptionPrice,
                    style: TextThemeManager.titleMedium.copyWith(
                      color: AppTheme.goldYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.oneTimePayment,
                    style: TextThemeManager.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            DialogConfig.extraLargeVerticalSpacing,

            // Action buttons
            buildActionButtons(
              buttons: [
                ModernDialogButton(
                  text: localizations.maybeLater,
                  onPressed: () => Navigator.of(context).pop(),
                  style: ModernDialogButtonStyle.secondary(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                ModernDialogButton(
                  text: localizations.buyNow,
                  onPressed: () {
                    Navigator.of(context).pop();
                    AppRouter.pushNamed(context, '/ad-free-subscription');
                  },
                  style: ModernDialogButtonStyle.primary(AppTheme.goldYellow),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
