import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/managers/settings_manager.dart';

/// Reusable widget for settings options
/// This widget encapsulates the common UI pattern for settings options
class SettingsOptionWidget extends StatelessWidget {
  final SettingsOptionData optionData;
  final VoidCallback onTap;
  final bool showArrow;
  final Widget? trailing;

  const SettingsOptionWidget({
    super.key,
    required this.optionData,
    required this.onTap,
    this.showArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return UIUtils.createSettingsOptionContainer(
      context: context,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Row(
              children: [
                // Icon Container
                UIUtils.createIconContainer(
                  context: context,
                  child: Text(
                    optionData.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppConstants.mediumSpacing),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        optionData.title,
                        style: UIUtils.getSettingsOptionTitleStyle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        optionData.subtitle,
                        style: UIUtils.getSettingsOptionSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),

                // Trailing widget or arrow
                if (trailing != null)
                  trailing!
                else if (showArrow)
                  UIUtils.createArrowIcon(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to create settings option widgets easily
extension SettingsOptionExtension on SettingsOptionData {
  Widget toWidget({
    required VoidCallback onTap,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return SettingsOptionWidget(
      optionData: this,
      onTap: onTap,
      showArrow: showArrow,
      trailing: trailing,
    );
  }
}
