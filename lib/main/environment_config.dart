
class EnvironmentConfig {
  // App Info
  static const isProd = bool.fromEnvironment('IS_PROD');
  static const appName = String.fromEnvironment('APP_NAME');

  // Connection Info
  static const apiUrl = String.fromEnvironment('API_URL');
}
