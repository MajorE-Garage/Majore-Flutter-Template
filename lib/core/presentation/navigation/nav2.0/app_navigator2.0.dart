import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/analytics_service/analytics_service.dart';
import 'route_name.dart';


class AppNavigator20 {

  AppNavigator20._();
  static final AppNavigator20 main = AppNavigator20._();

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get currentContext => _navigatorKey.currentContext;
  bool get canPop => _navigatorKey.currentContext?.canPop() ?? false;
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  // ===== ROUTE-BASED NAVIGATION =====

  void pushRoute(AppRoute route,
      {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('push', route);
      context.pushNamed(route.name,
          queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  void replaceRoute(AppRoute route,
      {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('replace', route);
      context.goNamed(route.name, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  void clearAndGoRoute(AppRoute route,
      {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('clear_and_go', route);
      context.goNamed(route.name, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  // ===== NAMED ROUTE NAVIGATION =====

  /// Push a named route (adds to stack)
  void pushNamed(String routeName,
      {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('push', routeName);
      context.pushNamed(routeName, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  /// Replace current route (like pushReplacement)
  void replaceNamed(String routeName,
      {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('replace', routeName);
      context.goNamed(routeName, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  /// Push and clear navigation stack (like pushNamedAndRemoveUntil)
  void clearAndGoNamed(String routeName,
      {Map<String, String> params = const {}, Map<String, dynamic> extra = const {}}) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('clear_and_go', routeName);
      context.goNamed(routeName, queryParameters: params, extra: extra.isNotEmpty ? extra : null);
    }
  }

  // ===== CONVENIENCE METHODS =====

  /// Navigate to splash
  void goToSplash() => pushRoute(AppRoutePaths.splash);

  /// Navigate to login
  void goToLogin() => pushRoute(AppRoutePaths.login);

  /// Navigate to dashboard
  void goToDashboard() => pushRoute(AppRoutePaths.dashboard);



  // ===== REPLACEMENT CONVENIENCE METHODS =====

  /// Replace with splash
  void replaceWithSplash() => replaceRoute(AppRoutePaths.splash);

  /// Replace with login
  void replaceWithLogin() => replaceRoute(AppRoutePaths.login);

  /// Replace with dashboard
  void replaceWithDashboard() => replaceRoute(AppRoutePaths.dashboard);





  // ===== CLEAR AND GO CONVENIENCE METHODS =====

  /// Clear stack and go to splash
  void clearAndGoToSplash() => clearAndGoRoute(AppRoutePaths.splash);

  /// Clear stack and go to login
  void clearAndGoToLogin() => clearAndGoRoute(AppRoutePaths.login);

  /// Clear stack and go to dashboard
  void clearAndGoToDashboard() => clearAndGoRoute(AppRoutePaths.dashboard);


  // ===== POP OPERATIONS =====

  /// Pop the current route
  void pop([Object? result]) {
    final context = currentContext;
    if (context != null && context.canPop()) {
      _logNavigation('pop', 'current');
      context.pop(result);
    }
  }

  /// Maybe pop the current route
  Future<bool> maybePop([Object? result]) async {
    final context = currentContext;
    if (context != null) {
      final canPop = await Navigator.of(context).maybePop(result);
      if (canPop) {
        _logNavigation('pop', 'current');
      }
      return canPop;
    }
    return false;
  }

  /// Pop until a specific route name
  void popUntilNamed(String routeName) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('pop_until', routeName);
      Navigator.of(context).popUntil((route) => route.settings.name == routeName);
    }
  }

  /// Pop until a specific route
  void popUntilRoute(AppRoute route) {
    popUntilNamed(route.name);
  }

  /// Pop until splash
  void popUntilSplash() => popUntilRoute(AppRoutePaths.splash);

  /// Pop until login
  void popUntilLogin() => popUntilRoute(AppRoutePaths.login);


  // ===== DIALOG AND BOTTOM SHEET =====
  /// Open a dialog
  Future<T?> openDialog<T>({
    required Widget dialog,
    String? routeName,
    bool barrierDismissable = true,
  }) {
    final context = currentContext;
    if (context != null) {
      _logNavigation('open_dialog', routeName ?? dialog.runtimeType.toString());
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
    final context = currentContext;
    if (context != null) {
      _logNavigation('open_bottom_sheet', routeName ?? sheet.runtimeType.toString());
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

  // ===== UTILITY METHODS =====

  /// Check if current route is a specific route
  bool isCurrentRoute(AppRoute route) {
    final context = currentContext;
    if (context != null) {
      final currentRoute = GoRouterState.of(context);
      return currentRoute.name == route.name;
    }
    return false;
  }

  /// Get current route name
  String? getCurrentRouteName() {
    final context = currentContext;
    if (context != null) {
      final currentRoute = GoRouterState.of(context);
      return currentRoute.name;
    }
    return null;
  }

  /// Get current route path
  String? getCurrentRoutePath() {
    final context = currentContext;
    if (context != null) {
      final currentRoute = GoRouterState.of(context);
      return currentRoute.uri.path;
    }
    return null;
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
      debugPrint('Analytics error in AppNavigator20: $e');
    }
  }
}
