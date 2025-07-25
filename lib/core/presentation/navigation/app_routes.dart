import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TODO(Toyyib): Port to Navigation 2.0

class _ShadowRoute<T> extends PageRoute<T> {
  @override
  RouteSettings get settings => const RouteSettings(name: 'ShadowRoute');

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox.shrink();
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration.zero;
}

abstract class AppRoutes {
  static const dashboardRoute = 'Dashboard';
  static const loginRoute = 'LoginView';
  static const splashRoute = 'Splash';

  static Route<T> generateRoutes<T>(RouteSettings settings) {
    switch (settings.name) {
      default:
        return _ShadowRoute();
    }
  }

  static final routes = <String, WidgetBuilder>{
    //
  };

  static Route<T> getPageRoute<T>({required RouteSettings settings, required Widget view}) {
    if (settings.name == null) {
      settings = RouteSettings(name: view.runtimeType.toString(), arguments: settings.arguments);
    }

    return Platform.isIOS
        ? CupertinoPageRoute<T>(settings: settings, builder: (_) => view)
        : MaterialPageRoute<T>(settings: settings, builder: (_) => view);
  }
}
