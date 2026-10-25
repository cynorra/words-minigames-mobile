import 'package:flutter/material.dart';

/// A mixin that provides consistent animation setup for all screens.
/// 
/// This mixin centralizes the common fade and slide animations used across
/// the app, reducing code duplication and ensuring consistent behavior.
/// 
/// Usage:
/// ```dart
/// class MyScreen extends StatefulWidget {
///   @override
///   State<MyScreen> createState() => _MyScreenState();
/// }
/// 
/// class _MyScreenState extends State<MyScreen> with ScreenAnimationMixin {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: buildAnimatedBody(
///         child: YourContent(),
///       ),
///     );
///   }
/// }
/// ```
mixin ScreenAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Animation durations
  static const Duration fadeDuration = Duration(milliseconds: 300);
  static const Duration slideDuration = Duration(milliseconds: 200);
  static const Duration longSlideDuration = Duration(milliseconds: 400);

  /// Animation curves
  static const Curve fadeCurve = Curves.easeOut;
  static const Curve slideCurve = Curves.easeOut;
  static const Curve longSlideCurve = Curves.easeOutCubic;

  /// Animation values
  static const double fadeBegin = 0.0;
  static const double fadeEnd = 1.0;
  static const Offset slideBegin = Offset(0, 0.05);
  static const Offset slideEnd = Offset.zero;
  static const Offset bottomSlideBegin = Offset(0, 1);
  static const Offset bottomSlideEnd = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  /// Initialize the standard fade and slide animations
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: fadeDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: slideDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: fadeBegin,
      end: fadeEnd,
    ).animate(CurvedAnimation(parent: _fadeController, curve: fadeCurve));

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(CurvedAnimation(parent: _slideController, curve: slideCurve));

    _startAnimations();
  }

  /// Initialize animations with custom slide duration (for bottom sheets)
  void initializeAnimationsWithLongSlide() {
    _fadeController = AnimationController(
      duration: fadeDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: longSlideDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: fadeBegin,
      end: fadeEnd,
    ).animate(CurvedAnimation(parent: _fadeController, curve: fadeCurve));

    _slideAnimation = Tween<Offset>(
      begin: bottomSlideBegin,
      end: bottomSlideEnd,
    ).animate(CurvedAnimation(parent: _slideController, curve: longSlideCurve));

    _startAnimations();
  }

  /// Start the animations
  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  /// Dispose of animation controllers
  void _disposeAnimations() {
    _fadeController.dispose();
    _slideController.dispose();
  }

  /// Build an animated body with fade and slide transitions
  Widget buildAnimatedBody({
    required Widget child,
    bool useLongSlide = false,
  }) {
    if (useLongSlide) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }

  /// Get the fade animation
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Get the slide animation
  Animation<Offset> get slideAnimation => _slideAnimation;

  /// Get the fade controller
  AnimationController get fadeController => _fadeController;

  /// Get the slide controller
  AnimationController get slideController => _slideController;
}

/// A mixin for screens that need additional star animations (like rating bottom sheet)
mixin StarAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _starController;
  late Animation<double> _starAnimation;

  /// Star animation duration
  static const Duration starDuration = Duration(milliseconds: 600);

  /// Star animation curve
  static const Curve starCurve = Curves.elasticOut;

  /// Initialize star animation
  void initializeStarAnimation() {
    _starController = AnimationController(
      duration: starDuration,
      vsync: this,
    );

    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _starController, curve: starCurve));

    _starController.forward();
  }

  /// Dispose star animation controller
  void disposeStarAnimation() {
    _starController.dispose();
  }

  /// Get the star animation
  Animation<double> get starAnimation => _starAnimation;

  /// Get the star controller
  AnimationController get starController => _starController;
}
