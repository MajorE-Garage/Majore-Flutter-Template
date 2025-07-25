import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/authentication/ui/login_view.dart';


class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static final GoRouter goRouter = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // to handle page rerouting if toke
      return null;
    },
    //(Toyyib) I added this to router for handling error view,
    //but we've handled it in the main application widget but could be useful though
    // errorBuilder: (context, state) => ErrorView(error: state.error),
    routes: [
      // GoRoute(
      //   path: splash,
      //   name: 'splash',
      //   builder: (context, state) => const LoginView(),
      // ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      // GoRoute(
      //   path: dashboard,
      //   name: 'dashboard',
      //   builder: (context, state) => const LoginView(),
      // ),
    ],
  );



  // Push with custom path
  static void push(BuildContext context, String path) => context.push(path);
  // PushReplace with custom path
  static void pushReplace(BuildContext context, String path) =>
      context.replace(path);
  // Pop methods
  static void pop(BuildContext context, [Object? result]) =>
      context.pop(result);
  static bool canPop(BuildContext context) => context.canPop();
}
