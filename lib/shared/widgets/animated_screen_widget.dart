import 'package:flutter/material.dart';
import '../../core/services/animation_service.dart';

/// Reusable animated screen widget that provides consistent animations
/// This widget can be used as a base for all screens that need fade and slide animations
class AnimatedScreenWidget extends StatefulWidget {
  final Widget child;
  final AnimationConfig animationConfig;
  final bool enableAnimations;
  final VoidCallback? onAnimationComplete;

  const AnimatedScreenWidget({
    super.key,
    required this.child,
    this.animationConfig = AnimationConfig.screen,
    this.enableAnimations = true,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedScreenWidget> createState() => _AnimatedScreenWidgetState();
}

class _AnimatedScreenWidgetState extends State<AnimatedScreenWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: widget.animationConfig.fadeDuration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: widget.animationConfig.slideDuration,
      vsync: this,
    );

    _fadeAnimation = AnimationService.createFadeAnimation(_fadeController);
    _slideAnimation = AnimationService.createSlideAnimationWithDirection(
      _slideController,
      widget.animationConfig.slideDirection,
    );

    if (widget.onAnimationComplete != null) {
      _fadeController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationComplete?.call();
        }
      });
    }

    if (widget.animationConfig.enableStaggered) {
      AnimationService.startStaggeredEntrance([
        _fadeController,
        _slideController,
      ]);
    } else {
      AnimationService.startEntranceAnimations([
        _fadeController,
        _slideController,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Animated dialog widget with fade and scale animations
class AnimatedDialogWidget extends StatefulWidget {
  final Widget child;
  final bool enableAnimations;
  final VoidCallback? onAnimationComplete;

  const AnimatedDialogWidget({
    super.key,
    required this.child,
    this.enableAnimations = true,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedDialogWidget> createState() => _AnimatedDialogWidgetState();
}

class _AnimatedDialogWidgetState extends State<AnimatedDialogWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeDialogAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeDialogAnimations() {
    _fadeController = AnimationService.createFadeController(this);
    _scaleController = AnimationService.createScaleController(this);

    _fadeAnimation = AnimationService.createFadeAnimation(_fadeController);
    _scaleAnimation = AnimationService.createScaleAnimation(_scaleController);

    if (widget.onAnimationComplete != null) {
      _fadeController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationComplete?.call();
        }
      });
    }

    AnimationService.startEntranceAnimations([
      _fadeController,
      _scaleController,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Extension methods for easy animation usage
extension AnimationExtensions on Widget {
  /// Wrap widget with fade and slide animations
  Widget withScreenAnimation({
    AnimationConfig animationConfig = AnimationConfig.screen,
    bool enableAnimations = true,
    VoidCallback? onAnimationComplete,
  }) {
    return AnimatedScreenWidget(
      animationConfig: animationConfig,
      enableAnimations: enableAnimations,
      onAnimationComplete: onAnimationComplete,
      child: this,
    );
  }

  /// Wrap widget with dialog animations
  Widget withDialogAnimation({
    bool enableAnimations = true,
    VoidCallback? onAnimationComplete,
  }) {
    return AnimatedDialogWidget(
      enableAnimations: enableAnimations,
      onAnimationComplete: onAnimationComplete,
      child: this,
    );
  }

  /// Wrap widget with fast animations
  Widget withFastAnimation({
    bool enableAnimations = true,
    VoidCallback? onAnimationComplete,
  }) {
    return withScreenAnimation(
      animationConfig: AnimationConfig.dialog,
      enableAnimations: enableAnimations,
      onAnimationComplete: onAnimationComplete,
    );
  }

  /// Wrap widget with important animations
  Widget withImportantAnimation({
    bool enableAnimations = true,
    VoidCallback? onAnimationComplete,
  }) {
    return withScreenAnimation(
      animationConfig: AnimationConfig.important,
      enableAnimations: enableAnimations,
      onAnimationComplete: onAnimationComplete,
    );
  }

  /// Wrap widget with staggered animations
  Widget withStaggeredAnimation({
    bool enableAnimations = true,
    VoidCallback? onAnimationComplete,
  }) {
    return withScreenAnimation(
      animationConfig: AnimationConfig.staggered,
      enableAnimations: enableAnimations,
      onAnimationComplete: onAnimationComplete,
    );
  }
}
