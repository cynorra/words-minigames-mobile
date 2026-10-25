import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'modern_dialog_base.dart';
import 'dialog_config.dart';
import 'continue_game_dialog.dart';

class CongratsDialog extends ModernDialogBase {
  final String gameId;
  final String gameTitle;
  final int currentScore;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const CongratsDialog({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.currentScore,
    required this.onRestart,
    required this.onExit,
  });

  @override
  State<CongratsDialog> createState() => _CongratsDialogState();
}

class _CongratsDialogState extends ModernDialogBaseState<CongratsDialog> {
  @override
  List<Widget> buildDialogContentList() {
    final localizations = AppLocalizations.of(context)!;
    final headerConfig = DialogConfig.successHeader;

    return [
      // Header
      buildDialogHeader(
        icon: Icon(
          headerConfig.icon,
          color: Colors.white,
          size: DialogConfig.iconSize,
        ),
        title: localizations.congratulations,
        subtitle:
            '${widget.gameTitle} - ${localizations.score} ${widget.currentScore}',
        gradientColor: headerConfig.color,
      ),

      // Content
      buildContentSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildContentHeader(
              title: localizations.gameCompleted,
              description: localizations.gameCompletedMessage,
            ),
            DialogConfig.extraLargeVerticalSpacing,

            // Action buttons
            buildActionButtons(
              buttons: [
                ModernDialogButton(
                  text: localizations.restart,
                  onPressed: () {
                    // Restart immediately (no navigation) and return intent to caller
                    widget.onRestart();
                    Navigator.of(context).pop(ContinueGameResult.restarted);
                  },
                  style: ModernDialogButtonStyle.secondary(
                    AppTheme.darkWarning,
                  ),
                  icon: Icons.refresh_rounded,
                ),
                ModernDialogButton(
                  text: localizations.exit,
                  onPressed: () {
                    // Do not exit here. Return intent so caller can save score first.
                    Navigator.of(context).pop(ContinueGameResult.exited);
                  },
                  style: ModernDialogButtonStyle.primary(AppTheme.darkSuccess),
                  icon: Icons.exit_to_app_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
