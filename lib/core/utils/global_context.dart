import 'package:flutter/material.dart';

class GlobalContext {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context {
    return navigatorKey.currentContext;
  }

  static NavigatorState? get navigator {
    return navigatorKey.currentState;
  }
}
