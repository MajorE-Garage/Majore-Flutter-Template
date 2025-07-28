import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../features/authentication/ui/login_view.dart';
import '../../../../core/domain/session_manager.dart';
import 'route_name.dart';

class AppGoRouter {
  // Global navigator key for context-free navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter goRouter = GoRouter(
    initialLocation: AppRoutePaths.splash.path,
    debugLogDiagnostics: true,
    navigatorKey: navigatorKey,
    redirect: (context, state) {
      // Handle authentication redirects here
      final sessionManager = ServiceLocator.get<SessionManager>();
      final isAuthenticated = sessionManager.isOpen;

      // Get the route being accessed
      final route = AppRoutePaths.findByPath(state.uri.path);

      // If route requires auth and user is not authenticated
      if (route?.requiresAuth == true && !isAuthenticated) {
        return AppRoutePaths.login.path;
      }

      // If user is authenticated and trying to access login/splash
      if (isAuthenticated &&
          (state.uri.path == AppRoutePaths.login.path ||
              state.uri.path == AppRoutePaths.splash.path)) {
        return AppRoutePaths.dashboard.path;
      }

      return null; // No redirect needed
    },
    // errorBuilder: (context, state) => _ErrorView(error: state.error),
    routes: [
      GoRoute(
        path: AppRoutePaths.splash.path,
        name: AppRoutePaths.splash.name,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutePaths.login.path,
        name: AppRoutePaths.login.name,
        builder: (context, state) => const LoginView(),
      ),
      // Dynamic routes
      // GoRoute(
      //   path: '/user/:userId', // Use the path pattern that matches userProfile function
      //   name: AppRoutePaths.userProfile('').name, // Use the name from the route definition
      //   builder: (context, state) {
      //     final userId = state.pathParameters['userId']!;
      //     return UserProfileView(userId: userId);
      //   },
      // ),
    ],
  );
}
