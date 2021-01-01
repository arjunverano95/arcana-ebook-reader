import 'package:flutter/material.dart';

class Navigation {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigation() : navigatorKey =  GlobalKey<NavigatorState>();

  Future<dynamic> navigate(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> popAndNavigate(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState
        .popAndPushNamed(routeName, arguments: arguments);
  }

  void pop() {
    return navigatorKey.currentState.pop();
  }
}
