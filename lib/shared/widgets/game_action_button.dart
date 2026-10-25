import 'package:flutter/material.dart';
import '../../core/theme/text_theme_manager.dart';
import '../../core/constants/app_icons.dart';
import '../../l10n/app_localizations.dart';

class GameActionButton extends StatelessWidget {
  final bool isWaiting;
  final VoidCallback onPressed;
  final String? startText;
  final String? restartText;

  const GameActionButton({
    super.key,
    required this.isWaiting,
    required this.onPressed,
    this.startText,
    this.restartText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isWaiting
                    ? [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ]
                    : [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.6),
                    ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: isWaiting ? 0.3 : 0.15),
              blurRadius: isWaiting ? 12 : 6,
              offset: Offset(0, isWaiting ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      isWaiting ? AppIcons.play : AppIcons.refresh,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextThemeManager.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                    child: Text(
                      isWaiting
                          ? (startText ??
                              AppLocalizations.of(context)!.startGame)
                          : (restartText ??
                              AppLocalizations.of(context)!.restartGame),
                    ),
                  ),
                  if (isWaiting) ...[
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
