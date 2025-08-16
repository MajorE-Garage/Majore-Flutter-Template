export '../../utilities/constants/local_store_keys.dart';

/// Abstract base class for local storage services.
///
/// This class provides a unified interface for storing and retrieving data
/// locally on the device. It supports common data types (bool, String, double)
/// and provides methods for clearing stored data.
///
/// The service is designed to work with secure storage solutions and provides
/// a clean abstraction over different storage backends (secure storage,
/// shared preferences, etc.). All operations are asynchronous to avoid
/// blocking the UI thread.
///
/// Common use cases include:
/// - Storing user preferences and settings
/// - Caching authentication tokens
/// - Persisting user credentials (securely)
/// - Storing onboarding state
/// - Caching application data
///
/// Example usage:
/// ```dart
/// final storage = ServiceLocator.get<LocalStorageService>();
///
/// // Save user preferences
/// await storage.saveBool(LocalStoreKeys.BIOMETRIC_ENABLED, true);
/// await storage.saveString(LocalStoreKeys.THEME_MODE, 'dark');
///
/// // Retrieve stored values
/// final biometricEnabled = await storage.fetchBool(LocalStoreKeys.BIOMETRIC_ENABLED);
/// final themeMode = await storage.fetchString(LocalStoreKeys.THEME_MODE);
///
/// // Clear specific data
/// await storage.clearField(LocalStoreKeys.REFRESH_TOKEN);
/// ```
abstract class LocalStorageService {
  /// Saves a boolean value to local storage.
  ///
  /// This method stores a boolean value associated with the given key.
  /// The value can be retrieved later using [fetchBool].
  ///
  /// [key] The unique identifier for the stored value. Consider using
  /// constants from [LocalStoreKeys] for consistency.
  /// [value] The boolean value to store.
  ///
  /// Example:
  /// ```dart
  /// await storage.saveBool(LocalStoreKeys.BIOMETRIC_ENABLED, true);
  /// ```
  Future saveBool(String key, bool value);

  /// Saves a string value to local storage.
  ///
  /// This method stores a string value associated with the given key.
  /// The value can be retrieved later using [fetchString].
  ///
  /// [key] The unique identifier for the stored value. Consider using
  /// constants from [LocalStoreKeys] for consistency.
  /// [value] The string value to store.
  ///
  /// Example:
  /// ```dart
  /// await storage.saveString(LocalStoreKeys.REFRESH_TOKEN, 'abc123');
  /// ```
  Future saveString(String key, String value);

  /// Saves a numeric value to local storage as a double.
  ///
  /// This method stores a numeric value (int, double, num) as a double
  /// associated with the given key. The value can be retrieved later
  /// using [fetchDouble].
  ///
  /// [key] The unique identifier for the stored value. Consider using
  /// constants from [LocalStoreKeys] for consistency.
  /// [value] The numeric value to store (will be converted to double).
  ///
  /// Example:
  /// ```dart
  /// await storage.saveDouble('user_rating', 4.5);
  /// await storage.saveDouble('login_count', 10); // int converted to double
  /// ```
  Future saveDouble(String key, num value);

  /// Retrieves a boolean value from local storage.
  ///
  /// This method retrieves a boolean value associated with the given key.
  /// Returns `null` if the key doesn't exist or the value cannot be
  /// parsed as a boolean.
  ///
  /// [key] The unique identifier for the stored value.
  ///
  /// Returns the stored boolean value, or `null` if not found or invalid.
  ///
  /// Example:
  /// ```dart
  /// final isEnabled = await storage.fetchBool(LocalStoreKeys.BIOMETRIC_ENABLED);
  /// if (isEnabled == true) {
  ///   // Biometric authentication is enabled
  /// }
  /// ```
  Future<bool?> fetchBool(String key);

  /// Retrieves a string value from local storage.
  ///
  /// This method retrieves a string value associated with the given key.
  /// Returns `null` if the key doesn't exist.
  ///
  /// [key] The unique identifier for the stored value.
  ///
  /// Returns the stored string value, or `null` if not found.
  ///
  /// Example:
  /// ```dart
  /// final token = await storage.fetchString(LocalStoreKeys.REFRESH_TOKEN);
  /// if (token != null) {
  ///   // Use the stored token for authentication
  /// }
  /// ```
  Future<String?> fetchString(String key);

  /// Retrieves a double value from local storage.
  ///
  /// This method retrieves a numeric value associated with the given key.
  /// Returns `null` if the key doesn't exist or the value cannot be
  /// parsed as a double.
  ///
  /// [key] The unique identifier for the stored value.
  ///
  /// Returns the stored double value, or `null` if not found or invalid.
  ///
  /// Example:
  /// ```dart
  /// final rating = await storage.fetchDouble('user_rating');
  /// if (rating != null) {
  ///   // Display the user's rating
  /// }
  /// ```
  Future<double?> fetchDouble(String key);

  /// Clears all data from local storage.
  ///
  /// This method removes all stored key-value pairs from the local storage.
  /// Use with caution as this operation cannot be undone. This is typically
  /// called during user logout or app reset scenarios.
  ///
  /// Returns `true` if the operation was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await storage.clearEntireStorage();
  /// if (success) {
  ///   // All data has been cleared
  /// }
  /// ```
  Future<bool> clearEntireStorage();

  /// Removes a specific key-value pair from local storage.
  ///
  /// This method removes the data associated with the given key from
  /// local storage. If the key doesn't exist, the operation is considered
  /// successful.
  ///
  /// [key] The unique identifier for the data to remove.
  ///
  /// Returns `true` if the operation was successful, `false` if an error occurred.
  ///
  /// Example:
  /// ```dart
  /// final success = await storage.clearField(LocalStoreKeys.REFRESH_TOKEN);
  /// if (success) {
  ///   // Token has been removed
  /// }
  /// ```
  Future<bool> clearField(String key);
}
