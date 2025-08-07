import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../../services/analytics_service/analytics_service.dart';
import 'app_routes.dart';

class AppNavigator {
  AppNavigator.of(this._navigationContext);
  AppNavigator.ofKey(GlobalKey<NavigatorState> mainNavigatorKey)
    : _navigationContext = mainNavigatorKey.currentContext!;
  final BuildContext _navigationContext;

  static final AppNavigator main = AppNavigator.ofKey(mainNavigatorKey);
  static final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

  BuildContext get currentContext => _navigationContext;
  bool get canPop => _navigationContext.canPop();

  // ===== ROUTE-BASED NAVIGATION =====

  void go(AppRoute route) {
    _logNavigation('push', route);
    _navigationContext.goNamed(
      route.name,
      queryParameters: route.queryParameters,
      pathParameters: route.pathParameters,
    );
  }

  void push(AppRoute route) {
    _logNavigation('push', route);
    _navigationContext.pushNamed(
      route.name,
      queryParameters: route.queryParameters,
      pathParameters: route.pathParameters,
    );
  }

  void pushReplacement(AppRoute route) {
    _logNavigation('replacement', route);
    _navigationContext.pushReplacementNamed(
      route.name,
      queryParameters: route.queryParameters,
      pathParameters: route.pathParameters,
    );
  }

  /// Pop the current route
  void pop([Object? result]) {
    _logNavigation('pop', 'current');
    _navigationContext.pop(result);
  }

  /// Maybe pop the current route
  Future<bool> maybePop([Object? result]) async {
    if (_navigationContext.canPop()) {
      _logNavigation('pop', 'current');
      _navigationContext.pop(result);
      return true;
    }
    return false;
  }

  // ===== DIALOG AND BOTTOM SHEET =====
  /// Open a dialog
  Future<T?> openDialog<T>({
    required Widget dialog,
    String? routeName,
    bool barrierDismissable = true,
    BuildContext? context,
  }) {
    context ??= _navigationContext;
    _logNavigation('open_dialog', routeName ?? dialog.runtimeType.toString());
    return showDialog<T>(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissable,
      routeSettings: RouteSettings(name: routeName ?? dialog.runtimeType.toString()),
    );
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
    BuildContext? context,
  }) {
    context ??= _navigationContext;

    _logNavigation('open_bottom_sheet', routeName ?? sheet.runtimeType.toString());
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) => sheet,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      routeSettings: RouteSettings(name: routeName ?? sheet.runtimeType.toString()),
      backgroundColor: backgroundColor,
      shape: shape,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height - 2 * kToolbarHeight,
      ),
    );
  }

  // ===== UTILITY METHODS =====

  /// Check if current route is a specific route
  bool isCurrentRoute(AppRoute route) {
    final currentRoute = GoRouterState.of(_navigationContext);
    return currentRoute.name == route.name || currentRoute.uri.path == route.path;
  }

  /// Get current route name
  AppRoute getCurrentRoute() {
    final currentRoute = GoRouterState.of(_navigationContext);
    return AppRoute(
      name: currentRoute.name ?? '',
      path: currentRoute.uri.path,
      queryParameters: currentRoute.uri.queryParameters,
    );
  }

  /// Get current route path
  String? getCurrentRoutePath() {
    final context = currentContext;
    final currentRoute = GoRouterState.of(context);
    return currentRoute.uri.path;
  }

  // ===== PRIVATE METHODS =====

  /// Log navigation events for analytics
  void _logNavigation(String action, dynamic route) {
    try {
      AnalyticsService.instance.logEvent(
        'Navigation_Action',
        properties: {
          'Action': action,
          'Route': route.toString(),
          'Timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silently handle analytics errors
      Logger(runtimeType.toString()).severe('Analytics error: $e');
    }
  }
}
