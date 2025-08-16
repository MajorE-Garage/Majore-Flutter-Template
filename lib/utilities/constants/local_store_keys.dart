// ignore_for_file: constant_identifier_names

/// Constants for local storage keys used throughout the application.
///
/// This class provides a centralized location for all local storage keys
/// to ensure consistency and avoid typos when storing and retrieving data.
/// Using these constants helps prevent key naming conflicts and makes
/// refactoring easier.
///
/// The class follows a singleton pattern to provide global access to
/// the constants while preventing instantiation.
///
/// Example usage:
/// ```dart
/// // Save user preference
/// await storage.saveBool(LocalStoreKeys.BIOMETRIC_ENABLED, true);
///
/// // Retrieve user preference
/// final isEnabled = await storage.fetchBool(LocalStoreKeys.BIOMETRIC_ENABLED);
/// ```
class LocalStoreKeys {
  LocalStoreKeys._();
  static final i = LocalStoreKeys._();

  static const THEME_MODE = 'THEME_MODE';
}