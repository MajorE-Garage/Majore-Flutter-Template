class AppRoutePaths {
  // Route definitions with both name and path
  static const AppRoute splash = AppRoute(name: 'splash', path: '/');
  static const AppRoute login = AppRoute(name: 'login', path: '/login');
  static const AppRoute dashboard = AppRoute(name: 'dashboard', path: '/dashboard');
  static const AppRoute profile = AppRoute(name: 'profile', path: '/profile');
  static const AppRoute settings = AppRoute(name: 'settings', path: '/settings');

  // Dynamic routes with parameters
  static AppRoute userProfile(String userId) => AppRoute(
    name: 'userProfile',
    path: '/user/$userId',
  );
}



class AppRoute {
  const AppRoute({
    required this.name,
    required this.path,
  });
  final String name;
  final String path;
}