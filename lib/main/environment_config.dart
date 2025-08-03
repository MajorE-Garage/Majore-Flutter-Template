import 'package:flutter/services.dart';

class EnvironmentConfig {
  // App Info
  static const isProd = bool.fromEnvironment('IS_PROD') || appFlavor == 'prod';
  static const appName = String.fromEnvironment('APP_NAME');
  static const flavor = appFlavor ?? '';

  // Connection Info
  static const apiUrl = String.fromEnvironment('API_URL');
}
