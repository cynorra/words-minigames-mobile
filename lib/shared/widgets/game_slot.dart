import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/text_theme_manager.dart';

class GameSlot extends StatelessWidget {
  final int? number;
  final int position;
  final bool isActive;
  final VoidCallback? onTap;
  final double? size;

  const GameSlot({
    super.key,
    this.number,
    required this.position,
    this.isActive = false,
    this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: number != null ? 0.9 + (0.1 * value) : 1.0,
            child: Container(
              width: size ?? 60,
              height: size ?? 60,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppTheme.darkSlotBackground
                        : AppTheme.lightSlotBackground,
                border: Border.all(
                  color:
                      isDark
                          ? AppTheme.darkSlotBorder
                          : AppTheme.lightSlotBorder,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: (isDark
                                    ? AppTheme.darkSlotBorder
                                    : AppTheme.lightSlotBorder)
                                .withValues(alpha: isDark ? 0.3 : 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pozisyon numarası - aydınlık tema için daha iyi kontrast
                  Text(
                    '${position + 1}.',
                    style: TextThemeManager.gameSlotNumber.copyWith(
                      color:
                          isDark
                              ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              )
                              : AppTheme.lightSlotText.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Sayı veya boş alan - aydınlık tema için daha iyi kontrast
                  number != null
                      ? TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 200),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, scaleValue, child) {
                          return Transform.scale(
                            scale: scaleValue,
                            child: Text(
                              number.toString(),
                              style: TextThemeManager.gameSlotValue.copyWith(
                                color:
                                    isDark
                                        ? theme.colorScheme.primary
                                        : AppTheme.lightSlotText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: (size ?? 60) / 3,
                        height: (size ?? 60) / 3,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  )
                                  : AppTheme.lightSlotText.withValues(
                                    alpha: 0.15,
                                  ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
