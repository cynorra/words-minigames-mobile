import 'package:flutter/material.dart';
import '../services/animation_service.dart';

/// Mixin that provides easy animation management for StatefulWidget
/// This mixin handles all animation setup, lifecycle, and disposal
mixin AnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Animation configuration
  AnimationConfig get animationConfig => AnimationConfig.screen;

  /// Get fade animation
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Get slide animation
  Animation<Offset> get slideAnimation => _slideAnimation;

  /// Get all animation controllers
  List<AnimationController> get animationControllers => [
    _fadeController,
    _slideController,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    AnimationService.disposeControllers(animationControllers);
    super.dispose();
  }

  /// Initialize animations with custom configuration
  void _initializeAnimations() {
    // Create controllers with custom durations if needed
    _fadeController = AnimationController(
      duration: animationConfig.fadeDuration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: animationConfig.slideDuration,
      vsync: this,
    );

    // Create animations
    _fadeAnimation = AnimationService.createFadeAnimation(_fadeController);
    _slideAnimation = AnimationService.createSlideAnimationWithDirection(
      _slideController,
      animationConfig.slideDirection,
    );

    // Start animations
    if (animationConfig.enableStaggered) {
      AnimationService.startStaggeredEntrance(animationControllers);
    } else {
      AnimationService.startEntranceAnimations(animationControllers);
    }
  }

  /// Start entrance animations manually
  void startEntranceAnimations() {
    AnimationService.startEntranceAnimations(animationControllers);
  }

  /// Start exit animations
  void startExitAnimations() {
    AnimationService.startExitAnimations(animationControllers);
  }

  /// Start staggered entrance animations
  void startStaggeredEntrance({
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    AnimationService.startStaggeredEntrance(
      animationControllers,
      staggerDelay: staggerDelay,
    );
  }

  /// Start staggered exit animations
  void startStaggeredExit({
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    AnimationService.startStaggeredExit(
      animationControllers,
      staggerDelay: staggerDelay,
    );
  }

  /// Create animated widget with fade and slide
  Widget createAnimatedWidget(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: child),
    );
  }

  /// Create animated widget with only fade
  Widget createFadeAnimatedWidget(Widget child) {
    return FadeTransition(opacity: _fadeAnimation, child: child);
  }

  /// Create animated widget with only slide
  Widget createSlideAnimatedWidget(Widget child) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}

/// Mixin for screens with custom animation configuration
mixin CustomAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Override this to provide custom animation configuration
  AnimationConfig get animationConfig;

  /// Get fade animation
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Get slide animation
  Animation<Offset> get slideAnimation => _slideAnimation;

  /// Get all animation controllers
  List<AnimationController> get animationControllers => [
    _fadeController,
    _slideController,
  ];

  @override
  void initState() {
    super.initState();
    _initializeCustomAnimations();
  }

  @override
  void dispose() {
    AnimationService.disposeControllers(animationControllers);
    super.dispose();
  }

  /// Initialize animations with custom configuration
  void _initializeCustomAnimations() {
    // Create controllers with custom durations
    _fadeController = AnimationController(
      duration: animationConfig.fadeDuration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: animationConfig.slideDuration,
      vsync: this,
    );

    // Create animations with custom curves
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: animationConfig.fadeCurve,
      ),
    );

    _slideAnimation = AnimationService.createSlideAnimationWithDirection(
      _slideController,
      animationConfig.slideDirection,
    );

    // Start animations
    if (animationConfig.enableStaggered) {
      AnimationService.startStaggeredEntrance(animationControllers);
    } else {
      AnimationService.startEntranceAnimations(animationControllers);
    }
  }

  /// Create animated widget with fade and slide
  Widget createAnimatedWidget(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: child),
    );
  }
}

/// Mixin for dialogs with fast animations
mixin DialogAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  /// Get fade animation
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Get scale animation
  Animation<double> get scaleAnimation => _scaleAnimation;

  /// Get all animation controllers
  List<AnimationController> get animationControllers => [
    _fadeController,
    _scaleController,
  ];

  @override
  void initState() {
    super.initState();
    _initializeDialogAnimations();
  }

  @override
  void dispose() {
    AnimationService.disposeControllers(animationControllers);
    super.dispose();
  }

  /// Initialize dialog animations
  void _initializeDialogAnimations() {
    _fadeController = AnimationService.createFadeController(this);
    _scaleController = AnimationService.createScaleController(this);

    _fadeAnimation = AnimationService.createFadeAnimation(_fadeController);
    _scaleAnimation = AnimationService.createScaleAnimation(_scaleController);

    AnimationService.startEntranceAnimations(animationControllers);
  }

  /// Create animated dialog widget
  Widget createAnimatedDialogWidget(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: child),
    );
  }
}
