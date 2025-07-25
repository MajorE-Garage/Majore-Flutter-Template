import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_name.dart';

class AppNavigator20 {
  AppNavigator20._();

  static final AppNavigator20 main = AppNavigator20._();
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get currentContext => _navigatorKey.currentContext;
  bool get canPop => _navigatorKey.currentContext?.canPop() ?? false;
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;


  void pushRoute(AppRoute route, {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      context.pushNamed(route.name, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  void pushNamed(String routeName, {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      context.pushNamed(routeName, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  void goNamed(String routeName, {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      context.goNamed(routeName, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }
  
  void clearAndGo(String routeName, {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      context.goNamed(routeName, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }



  void pop([Object? result]) {
    final context = _navigatorKey.currentContext;
    if (context != null && context.canPop()) {
      context.pop(result);
    }
  }

  Future<bool> maybePop([Object? result]) async {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      return await Navigator.of(context).maybePop(result);
    }
    return false;
  }

  void popUntilNamed(String routeName) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).popUntil((route) => route.settings.name == routeName);
    }
  }


  /// Open a dialog
  Future<T?> openDialog<T>({
    required Widget dialog,
    String? routeName,
    bool barrierDismissable = true,
  }) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      return showDialog<T>(
        context: context,
        builder: (_) => dialog,
        barrierDismissible: barrierDismissable,
        routeSettings: RouteSettings(
          name: routeName ?? dialog.runtimeType.toString(),
        ),
      );
    }
    return Future.value(null);
  }

  /// Open a bottom sheet
  Future<T?> openBottomsheet<T>({
    required Widget sheet,
    String? routeName,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool useRootNavigator = false,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      return showModalBottomSheet<T>(
        context: context,
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
          maxHeight: MediaQuery.sizeOf(context).height - 2 * kToolbarHeight,
        ),
      );
    }
    return Future.value(null);
  }


}
