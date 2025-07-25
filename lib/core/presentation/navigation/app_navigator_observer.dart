import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../presentation.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver._();
  static final instance = AppNavigatorObserver._();

  final _stack = <Route>[];
  UnmodifiableListView<Route> get currentStack => UnmodifiableListView(_stack);
  UnmodifiableListView<String?> get currentStackRouteNames =>
      UnmodifiableListView(_stack.map((e) => e.settings.name));

  bool isCurrent(String routeName) {
    final currentRoute = _stack.last;
    assert(currentRoute.isCurrent);
    return routeName == currentRoute.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('Did Pop from ${route.settings.name} to ${previousRoute?.settings.name}');
    assert(_stack.last == route);
    _stack.removeLast();
    assert(_stack.isEmpty || _stack.last == previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == 'ShadowRoute') {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => AppNavigator.main.removeNamed('ShadowRoute'),
      );
    }
    debugPrint(
      'Did Push to ${route.settings.name} from ${previousRoute?.settings.name ?? 'Nothing'}',
    );
    assert(_stack.isEmpty || _stack.last == previousRoute);
    _stack.add(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint('Did Replace ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
    _stack.remove(oldRoute);
    if (newRoute != null) _stack.add(newRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    debugPrint('Did Remove ${route.settings.name}');
    _stack.remove(route);
  }
}
