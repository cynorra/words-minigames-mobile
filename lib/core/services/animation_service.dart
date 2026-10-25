import 'package:flutter/material.dart';

/// Centralized animation service for managing all app animations
/// This service provides consistent animation patterns across the app
class AnimationService {
  // Animation durations
  static const Duration _fadeDuration = Duration(milliseconds: 300);
  static const Duration _slideDuration = Duration(milliseconds: 200);
  static const Duration _scaleDuration = Duration(milliseconds: 250);
  static const Duration _bounceDuration = Duration(milliseconds: 400);

  // Animation curves
  static const Curve _fadeCurve = Curves.easeOut;
  static const Curve _slideCurve = Curves.easeOut;
  static const Curve _scaleCurve = Curves.easeInOut;
  static const Curve _bounceCurve = Curves.elasticOut;

  /// Create fade animation controller
  static AnimationController createFadeController(TickerProvider vsync) {
    return AnimationController(duration: _fadeDuration, vsync: vsync);
  }

  /// Create slide animation controller
  static AnimationController createSlideController(TickerProvider vsync) {
    return AnimationController(duration: _slideDuration, vsync: vsync);
  }

  /// Create scale animation controller
  static AnimationController createScaleController(TickerProvider vsync) {
    return AnimationController(duration: _scaleDuration, vsync: vsync);
  }

  /// Create bounce animation controller
  static AnimationController createBounceController(TickerProvider vsync) {
    return AnimationController(duration: _bounceDuration, vsync: vsync);
  }

  /// Create fade animation
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: _fadeCurve));
  }

  /// Create slide animation
  static Animation<Offset> createSlideAnimation(
    AnimationController controller,
  ) {
    return Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: _slideCurve));
  }

  /// Create slide animation with custom direction
  static Animation<Offset> createSlideAnimationWithDirection(
    AnimationController controller,
    SlideDirection direction,
  ) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0, 0.05);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -0.05);
        break;
      case SlideDirection.left:
        begin = const Offset(0.05, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-0.05, 0);
        break;
    }

    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: _slideCurve));
  }

  /// Create scale animation
  static Animation<double> createScaleAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: _scaleCurve));
  }

  /// Create bounce animation
  static Animation<double> createBounceAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: _bounceCurve));
  }

  /// Start entrance animations
  static void startEntranceAnimations(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.forward();
    }
  }

  /// Start exit animations
  static void startExitAnimations(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.reverse();
    }
  }

  /// Dispose animation controllers
  static void disposeControllers(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  /// Create staggered entrance animation
  static void startStaggeredEntrance(
    List<AnimationController> controllers, {
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    for (int i = 0; i < controllers.length; i++) {
      Future.delayed(staggerDelay * i, () {
        try {
          controllers[i].forward();
        } catch (e) {
          // Controller might be disposed
        }
      });
    }
  }

  /// Create staggered exit animation
  static void startStaggeredExit(
    List<AnimationController> controllers, {
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    for (int i = 0; i < controllers.length; i++) {
      Future.delayed(staggerDelay * i, () {
        try {
          controllers[i].reverse();
        } catch (e) {
          // Controller might be disposed
        }
      });
    }
  }
}

/// Enum for slide animation directions
enum SlideDirection { up, down, left, right }

/// Animation configuration for different screen types
class AnimationConfig {
  final Duration fadeDuration;
  final Duration slideDuration;
  final Curve fadeCurve;
  final Curve slideCurve;
  final SlideDirection slideDirection;
  final bool enableStaggered;

  const AnimationConfig({
    this.fadeDuration = const Duration(milliseconds: 300),
    this.slideDuration = const Duration(milliseconds: 200),
    this.fadeCurve = Curves.easeOut,
    this.slideCurve = Curves.easeOut,
    this.slideDirection = SlideDirection.up,
    this.enableStaggered = false,
  });

  /// Default animation config for screens
  static const AnimationConfig screen = AnimationConfig();

  /// Fast animation config for dialogs
  static const AnimationConfig dialog = AnimationConfig(
    fadeDuration: Duration(milliseconds: 200),
    slideDuration: Duration(milliseconds: 150),
  );

  /// Slow animation config for important screens
  static const AnimationConfig important = AnimationConfig(
    fadeDuration: Duration(milliseconds: 400),
    slideDuration: Duration(milliseconds: 300),
  );

  /// Staggered animation config for lists
  static const AnimationConfig staggered = AnimationConfig(
    enableStaggered: true,
  );
}
