import 'package:flutter/widgets.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver._();
  static final instance = AppNavigatorObserver._();

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('Did Pop from ${route.settings.name} to ${previousRoute?.settings.name}');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint(
      'Did Push to ${route.settings.name} from ${previousRoute?.settings.name ?? 'Nothing'}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint('Did Replace ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    debugPrint('Did Remove ${route.settings.name}');
  }
}
