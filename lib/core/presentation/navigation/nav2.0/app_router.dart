import 'package:go_router/go_router.dart';
import '../../../../features/authentication/ui/login_view.dart';
import 'app_navigator2.0.dart';
import 'route_name.dart';

class AppGoRouter {

  static final GoRouter goRouter = GoRouter(
    initialLocation: AppRoutePaths.splash.path,
    debugLogDiagnostics: true,
    navigatorKey: AppNavigator20.navigatorKey,
    redirect: (context, state) {
      // Handle authentication redirects here
      return null;
    },
    // errorBuilder: (context, state) => ErrorView(error: state.error),
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
      // GoRoute(
      //   path: AppRoutePaths.dashboard.path,
      //   name: AppRoutePaths.dashboard.name,
      //   builder: (context, state) => const DashboardView(),
      // ),
      // Dynamic routes
      // GoRoute(
      //   path: '/user/:userId',
      //   name: 'userProfile',
      //   builder: (context, state) {
      //     final userId = state.pathParameters['userId']!;
      //     return UserProfileView(userId: userId);
      //   },
      // ),
     
    ],
  );
}
