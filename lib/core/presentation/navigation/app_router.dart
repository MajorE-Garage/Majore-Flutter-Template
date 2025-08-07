import 'package:go_router/go_router.dart';

import '../../../features/authentication/ui/login_view.dart';
import '../ui_components/others/error_view.dart';
import 'app_navigator.dart';
import 'app_routes.dart';

abstract class AppRouter {
  // Global navigator key for context-free navigation

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    navigatorKey: AppNavigator.mainNavigatorKey,
    redirect: (context, state) {
      // Handle redirects here
      //
      return null; // No redirect needed
    },
    errorBuilder: (context, state) => ErrorView(
      error: state.error ?? 'Unknown error',
      routeName: state.uri.path,
      path: state.uri.toString(),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginView(),
      ),
      // Dynamic routes
      // GoRoute(
      //   path: '/user/:userId', // Use the path pattern that matches userProfile function
      //   name: AppRoutes.userProfile('').name, // Use the name from the route definition
      //   builder: (context, state) {
      //     final userId = state.pathParameters['userId']!;
      //     return UserProfileView(userId: userId);
      //   },
      // ),
    ],
  );
}
