import 'package:flutter/material.dart';

import '../../../core/services/admob_service.dart';
import '../../../core/services/in_app_purchase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../l10n/app_localizations.dart';

enum ContinueGameResult { continued, restarted, exited, dismissed }

class ContinueGameDialog extends StatefulWidget {
  final String gameId;
  final String gameTitle;
  final int currentScore;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final bool canOneTimeContinue;

  const ContinueGameDialog({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.currentScore,
    required this.onContinue,
    required this.onRestart,
    required this.onExit,
    required this.canOneTimeContinue,
  });

  @override
  State<ContinueGameDialog> createState() => _ContinueGameDialogState();
}

class _ContinueGameDialogState extends State<ContinueGameDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _isAdAvailable = false;
  bool _continueGranted = false;
  bool _hasUsedOneTimeContinue = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);

    _checkAdAvailability();
    _checkAdFreeStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAdAvailability() async {
    final adService = AdMobService();
    final available = await adService.loadRewardedAd();

    if (mounted) {
      setState(() {
        _isAdAvailable = available;
      });
    }
  }

  Future<void> _checkAdFreeStatus() async {
    // This method is kept for future use if needed
    // Currently using _isAdFreeEnabled() method instead
  }

  /// Check if ad-free mode is enabled
  bool _isAdFreeEnabled() {
    final purchaseService = InAppPurchaseService();
    return purchaseService.isAdFree;
  }

  /// Check if one-time continue is available for ad-free users
  bool _isOneTimeContinueAvailable() {
    return _isAdFreeEnabled() &&
        widget.canOneTimeContinue &&
        !_hasUsedOneTimeContinue;
  }

  /// Handle one-time continue for ad-free users
  void _handleOneTimeContinue() {
    setState(() {
      _hasUsedOneTimeContinue = true;
    });

    // Call the continue callback
    widget.onContinue();
    Navigator.of(context).pop(ContinueGameResult.continued);
  }

  Future<void> _showRewardedAd() async {
    if (_isAdFreeEnabled()) {
      // For ad-free users, check if one-time continue is available
      if (_isOneTimeContinueAvailable()) {
        _handleOneTimeContinue();
        return;
      } else {
        // Ad-free user has already used their one-time continue
        _showAdNotAvailableDialog();
        return;
      }
    }

    if (!_isAdAvailable) {
      _showAdNotAvailableDialog();
      return;
    }

    final adService = AdMobService();
    _continueGranted = false;
    final success = await adService.showRewardedAd(
      onRewarded: () {
        // Mark as earned; continue will be granted when ad is dismissed
        _continueGranted = true;
      },
      onAdClosed: () {
        setState(() {
          _isLoading = false;
        });
        // Continue the game when ad is dismissed (regardless of rewarded callback)
        if (!_continueGranted) {
          _continueGranted = true;
        }
        widget.onContinue();
        Navigator.of(context).pop(ContinueGameResult.continued);
      },
      onAdFailed: (error) {
        setState(() {
          _isLoading = false;
        });
        _showAdNotAvailableDialog();
      },
    );

    if (!success) {
      setState(() {
        _isLoading = false;
      });
      _showAdNotAvailableDialog();
    }
  }

  void _showAdNotAvailableDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.adNotAvailable),
            content: Text(AppLocalizations.of(context)!.adNotAvailableMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkError,
                      AppTheme.darkError.withValues(alpha: 0.8),
                    ],
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
                      child: const Icon(
                        Icons.pause_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.gameOver,
                            style: TextThemeManager.subtitleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.gameTitle} - ${localizations.score} ${widget.currentScore}',
                            style: TextThemeManager.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only show title and subtitle if ads are available or user is ad-free
                    if (_isAdFreeEnabled() || _isAdAvailable) ...[
                      Text(
                        localizations.continueGame,
                        style: TextThemeManager.subtitleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isAdFreeEnabled()
                            ? (_isOneTimeContinueAvailable()
                                ? localizations.continueGameDescription
                                : localizations.oneTimeContinueUsed)
                            : localizations.watchAdToContinueDescription,
                        style: TextThemeManager.bodyMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Continue Button - Only show for normal users (ad-free users will see button below)
                    if (!_isAdFreeEnabled() && _isAdAvailable) ...[
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.darkSuccess,
                                    AppTheme.darkSuccess.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.darkSuccess.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: !_isLoading ? _showRewardedAd : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              localizations.watchAdToContinue,
                                              style: TextThemeManager.bodyMedium
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // Minimal spacing when continue button is not shown
                      const SizedBox(height: 8),
                    ],

                    // Ad-free user one-time continue button (above restart buttons)
                    if (_isAdFreeEnabled() &&
                        _isOneTimeContinueAvailable()) ...[
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.darkSuccess,
                              AppTheme.darkSuccess.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.darkSuccess.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              !_isLoading ? _handleOneTimeContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        localizations.oneTimeContinue,
                                        style: TextThemeManager.bodyMedium
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                widget.onRestart();
                                Navigator.of(
                                  context,
                                ).pop(ContinueGameResult.restarted);
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: AppTheme.darkWarning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.restart,
                                    style: TextThemeManager.bodyMedium.copyWith(
                                      color: AppTheme.darkWarning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Do not exit the game screen here.
                                // Return the intent and let caller handle post-save exit.
                                Navigator.of(
                                  context,
                                ).pop(ContinueGameResult.exited);
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.exit_to_app_rounded,
                                    color: AppTheme.darkError,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.exit,
                                    style: TextThemeManager.bodyMedium.copyWith(
                                      color: AppTheme.darkError,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
