/// Model class for device information.
///
/// This class encapsulates device-specific information including the
/// manufacturer brand and device model. The information is gathered
/// from platform-specific APIs and normalized across different platforms.
///
/// Example usage:
/// ```dart
/// final device = DeviceInfoModel(
///   deviceBrand: 'Apple',
///   deviceModel: 'iPhone 14 Pro'
/// );
/// print('Running on ${device.deviceBrand} ${device.deviceModel}');
/// ```
class DeviceInfoModel {
  /// The brand or manufacturer of the device.
  ///
  /// This represents the company that manufactured the device.
  /// Examples: "Apple", "Samsung", "Google", "OnePlus", etc.
  /// On iOS, this typically represents the device name rather than "Apple".
  final String deviceBrand;

  /// The model identifier of the device.
  ///
  /// This represents the specific model of the device.
  /// Examples: "iPhone 14 Pro", "SM-G991B", "Pixel 6", etc.
  /// The format may vary between platforms and manufacturers.
  final String deviceModel;

  /// Creates a new [DeviceInfoModel] with the specified device information.
  ///
  /// [deviceBrand] The brand or manufacturer of the device.
  /// [deviceModel] The model identifier of the device.
  DeviceInfoModel({required this.deviceBrand, required this.deviceModel});
}

/// Model class for application information.
///
/// This class encapsulates application-specific information including
/// version details and package identification. This information is
/// useful for analytics, debugging, and version management.
///
/// Example usage:
/// ```dart
/// final app = AppInfoModel(
///   packageName: 'com.example.myapp',
///   buildNumber: '123',
///   versionNumber: '1.2.3'
/// );
/// print('${app.packageName} v${app.versionNumber} (${app.buildNumber})');
/// ```
class AppInfoModel {
  /// The build number of the application.
  ///
  /// This is typically an incremental number that increases with each build.
  /// It's used internally for version tracking and is often not visible to users.
  /// Example: "123", "456", "1001"
  final String buildNumber;

  /// The version number of the application.
  ///
  /// This is the user-facing version number that follows semantic versioning.
  /// It's displayed to users in app stores and settings.
  /// Example: "1.2.3", "2.0.0", "1.5.2-beta"
  final String versionNumber;

  /// The package name (bundle identifier) of the application.
  ///
  /// This is the unique identifier for the application across platforms.
  /// It follows reverse domain notation and is used by app stores and the OS.
  /// Example: "com.example.myapp", "com.company.productname"
  final String packageName;

  /// Creates a new [AppInfoModel] with the specified application information.
  ///
  /// [packageName] The unique package identifier for the application.
  /// [buildNumber] The build number of the application.
  /// [versionNumber] The user-facing version number of the application.
  AppInfoModel({required this.packageName, required this.buildNumber, required this.versionNumber});
}

/// Model class for locale and timezone information.
///
/// This class encapsulates user locale and timezone settings which are
/// useful for localization, analytics, and time-based features.
///
/// Example usage:
/// ```dart
/// final locale = LocaleInfoModel(
///   languageCode: 'en',
///   countryCode: 'US',
///   timezone: 'America/New_York'
/// );
/// print('User locale: ${locale.languageCode}_${locale.countryCode}');
/// print('Timezone: ${locale.timezone}');
/// ```
class LocaleInfoModel {
  /// The language code of the user's locale.
  ///
  /// This is the ISO 639-1 two-letter language code representing the
  /// user's preferred language. Used for localization and content selection.
  /// Example: "en", "es", "fr", "de", "ja"
  final String languageCode;

  /// The country code of the user's locale.
  ///
  /// This is the ISO 3166-1 alpha-2 two-letter country code representing
  /// the user's country or region. Used for region-specific content and formatting.
  /// Example: "US", "GB", "CA", "FR", "JP"
  /// Returns "Unknown" if the country code cannot be determined.
  final String countryCode;

  /// The timezone identifier of the user's current location.
  ///
  /// This is the IANA timezone identifier representing the user's current
  /// timezone. Used for time-based calculations and displaying local times.
  /// Example: "America/New_York", "Europe/London", "Asia/Tokyo"
  final String timezone;

  /// Creates a new [LocaleInfoModel] with the specified locale information.
  ///
  /// [languageCode] The ISO 639-1 language code.
  /// [countryCode] The ISO 3166-1 alpha-2 country code.
  /// [timezone] The IANA timezone identifier.
  LocaleInfoModel({required this.languageCode, required this.countryCode, required this.timezone});
}
