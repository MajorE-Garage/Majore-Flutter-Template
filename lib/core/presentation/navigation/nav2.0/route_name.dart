import 'package:flutter/material.dart';

class AppRoute  {
  const AppRoute({
    required this.name,
    required this.path,
    this.requiresAuth = false,
    this.analyticsName,
  });

  final String name;
  final String path;
  final bool requiresAuth;
  final String? analyticsName;

  @override
  String toString() => name;
}

class AppRoutePaths  {
  // Route definitions with both name and path
  static const AppRoute splash =
      AppRoute(name: 'splash', path: '/', analyticsName: 'Splash_Screen');
  static const AppRoute login =
      AppRoute(name: 'login', path: '/login', analyticsName: 'Login_Screen');
  static const AppRoute dashboard = AppRoute(
      name: 'dashboard', path: '/dashboard', requiresAuth: true, analyticsName: 'Dashboard_Screen');
  static const AppRoute profile = AppRoute(
      name: 'profile', path: '/profile', requiresAuth: true, analyticsName: 'Profile_Screen');


  // Dynamic routes with parameters
  static AppRoute userProfile(String userId) => AppRoute(
        name: 'userProfile',
        path: '/user/$userId',
        requiresAuth: true,
        analyticsName: 'User_Profile_Screen',
      );


  // Helper methods
  static List<AppRoute> get allRoutes => [
    splash,
    login,
    dashboard,
    profile,
  ];

  static AppRoute? findByName(String name) {
    try {
      return allRoutes.firstWhere((route) => route.name == name);
    } catch (e) {
      return null;
    }
  }

  static AppRoute? findByPath(String path) {
    try {
      return allRoutes.firstWhere((route) => route.path == path);
    } catch (e) {
      return null;
    }
  }
}
