import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/text_theme_manager.dart';
import '../../l10n/app_localizations.dart';

class GameDescription extends StatelessWidget {
  final String descriptionKey;
  final IconData? icon;

  const GameDescription({super.key, required this.descriptionKey, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon with modern styling
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon ?? Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.mediumSpacing),
        // Description text
        Expanded(
          child: Text(
            _getLocalizedDescription(context, descriptionKey),
            style: TextThemeManager.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _getLocalizedDescription(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'blind_sort_description':
        return localizations.blindSortDescription;
      case 'higher_lower_description':
        return localizations.higherLowerDescription;
      case 'color_hunt_description':
        return localizations.colorHuntDescription;
      case 'aim_trainer_description':
        return localizations.aimTrainerDescription;
      case 'number_memory_description':
        return localizations.numberMemoryDescription;
      case 'find_difference_description':
        return localizations.findDifferenceDescription;
      case 'rock_paper_scissors_description':
        return localizations.rockPaperScissorsDescription;
      case 'twenty_one_description':
        return localizations.twentyOneDescription;
      case 'reactionTimeDescription':
        return localizations.reactionTimeDescription;
      case 'patternMemoryDescription':
        return localizations.patternMemoryDescription;
      default:
        return key;
    }
  }
}
