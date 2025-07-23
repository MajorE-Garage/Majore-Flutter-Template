import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'app_navigator_observer.dart';
import 'app_routes.dart';

export 'app_navigator_observer.dart';
export 'app_routes.dart';

class AppNavigator {
  AppNavigator.of(BuildContext context) : _navigator = Navigator.of(context);

  AppNavigator.ofKey(GlobalKey<NavigatorState> key)
      : _navigator = key.currentState!;

  static final mainKey = GlobalKey<NavigatorState>();
  static AppNavigator main = AppNavigator.ofKey(mainKey);

  final NavigatorState _navigator;

  BuildContext get currentContext => _navigator.context;

  bool get canPop => _navigator.canPop();

  Future<T?> push<T>(Widget view, {String? routeName}) {
    return _navigator.push<T>(
      AppRoutes.getPageRoute(
        settings: RouteSettings(name: routeName),
        view: view,
      ),
    );
  }

  Future<T?> pushReplacement<T, TO>(Widget view, {String? routeName}) {
    return _navigator.pushReplacement<T, TO>(
      AppRoutes.getPageRoute<T>(
        settings: RouteSettings(name: routeName),
        view: view,
      ),
    );
  }

  Future<T?> pushAndClear<T>(Widget view, {String? routeName}) {
    return _navigator.pushAndRemoveUntil<T>(
      AppRoutes.getPageRoute<T>(
        settings: RouteSettings(name: routeName),
        view: view,
      ),
      (_) => false,
    );
  }

  Future<T?> pushNamed<T>(String route, {arguments}) {
    return _navigator.pushNamed<T>(
      route,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedReplacement<T, TO>(String route, {arguments}) {
    return _navigator.pushReplacementNamed<T, TO>(
      route,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedAndClear<T>(String route, {arguments}) {
    return _navigator.pushNamedAndRemoveUntil<T>(
      route,
      (_) => false,
      arguments: arguments,
    );
  }

  void pop([result]) {
    return _navigator.pop(result);
  }

  Future<bool> maybePop([result]) {
    return _navigator.maybePop(result);
  }

  void popUntilNamed(String routeName) {
    return _navigator.popUntil(
      (route) => route.settings.name == routeName,
    );
  }

  void popUntilType(Type type) {
    final name = type.toString();
    return popUntilNamed(name);
  }

  bool removeNamed([String? routeName]) {
    try {
      final route = AppNavigatorObserver.instance.currentStack.firstWhere(
        (element) => element.settings.name == routeName,
      );
      _navigator.removeRoute(route);
      return true;
    } catch (e, t) {
      Logger('AppNavigator').severe('Tried to remove $routeName', e, t);
      return false;
    }
  }

  bool removeType(Type type) {
    final name = type.toString();
    try {
      final route = AppNavigatorObserver.instance.currentStack.firstWhere(
        (element) => element.settings.name == name,
      );
      _navigator.removeRoute(route);
      return true;
    } catch (e, t) {
      Logger('AppNavigator').severe('Tried to remove $name', e, t);
      return false;
    }
  }

  Future<T?> openDialog<T>({
    required Widget dialog,
    // BuildContext? context,
    String? routeName,
    bool barrierDismissable = true,
  }) {
    return showDialog<T>(
      context: currentContext,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissable,
      routeSettings: RouteSettings(
        name: routeName ?? dialog.runtimeType.toString(),
      ),
    );
  }

  Future<T?> openBottomsheet<T>({
    required Widget sheet,
    // BuildContext? context,
    String? routeName,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool useRootNavigator = false,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: currentContext,
      builder: (_) => sheet,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      routeSettings: RouteSettings(
        name: routeName ?? sheet.runtimeType.toString(),
      ),
      backgroundColor: backgroundColor,
      shape: shape,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(currentContext).height - 2 * kToolbarHeight,
      ),
    );
  }
}
