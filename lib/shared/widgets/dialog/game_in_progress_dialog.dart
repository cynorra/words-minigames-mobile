import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'modern_dialog_base.dart';
import 'dialog_config.dart';

class GameInProgressDialog extends ModernDialogBase {
  final VoidCallback onStayInGame;
  final VoidCallback onExitGame;

  const GameInProgressDialog({
    super.key,
    required this.onStayInGame,
    required this.onExitGame,
  });

  @override
  State<GameInProgressDialog> createState() => _GameInProgressDialogState();
}

class _GameInProgressDialogState
    extends ModernDialogBaseState<GameInProgressDialog> {
  @override
  List<Widget> buildDialogContentList() {
    final localizations = AppLocalizations.of(context)!;
    final headerConfig = DialogConfig.warningHeader;

    return [
      // Header
      buildDialogHeader(
        icon: Icon(
          headerConfig.icon,
          color: Colors.white,
          size: DialogConfig.iconSize,
        ),
        title: localizations.gameInProgress,
        subtitle: localizations.gameInProgressSubtitle,
        gradientColor: headerConfig.color,
      ),

      // Content
      buildContentSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildContentHeader(
              title: localizations.gameInProgressTitle,
              description: localizations.gameInProgressMessage,
            ),
            DialogConfig.extraLargeVerticalSpacing,

            // Action buttons
            buildActionButtons(
              buttons: [
                ModernDialogButton(
                  text: localizations.exit,
                  onPressed: () {
                    widget.onExitGame();
                    Navigator.of(context).pop();
                  },
                  style: ModernDialogButtonStyle.secondary(AppTheme.darkError),
                  icon: Icons.close_rounded,
                ),
                ModernDialogButton(
                  text: localizations.stay,
                  onPressed: () {
                    widget.onStayInGame();
                    Navigator.of(context).pop();
                  },
                  style: ModernDialogButtonStyle.primary(AppTheme.darkSuccess),
                  icon: Icons.play_arrow_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
