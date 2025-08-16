import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
// import 'package:native_updater/native_updater.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../utilities/extensions/string_extension.dart';
import 'device_and_app_models.dart';

/// Abstract base class for build and device information services.
///
/// This service provides access to device, application, and locale information
/// that can be useful for analytics, debugging, and feature customization.
/// It abstracts the complexity of gathering platform-specific information
/// and provides a unified interface across different platforms.
///
/// The service provides information about:
/// - Device details (brand, model, platform)
/// - Application details (version, build number, package name)
/// - Locale details (language, country, timezone)
/// - Update prompting capabilities
///
/// All information is cached after the first fetch to improve performance
/// and avoid redundant system calls.
///
/// Example usage:
/// ```dart
/// final buildInfo = ServiceLocator.get<BuildInfoService>();
///
/// // Get device information
/// final device = await buildInfo.deviceInfo;
/// print('Device: ${device.deviceBrand} ${device.deviceModel}');
///
/// // Get app information
/// final app = await buildInfo.appInfo;
/// print('Version: ${app.versionNumber} (${app.buildNumber})');
///
/// // Get locale information
/// final locale = await buildInfo.localeInfo;
/// print('Locale: ${locale.languageCode}_${locale.countryCode}');
/// ```
abstract class BuildInfoService {
  /// Retrieves device information including brand and model.
  ///
  /// This property provides details about the physical device the app is
  /// running on. The information is platform-specific and includes the
  /// device brand (manufacturer) and model name.
  ///
  /// The data is cached after the first fetch for performance.
  ///
  /// Returns a [DeviceInfoModel] containing device brand and model information.
  ///
  /// Example:
  /// ```dart
  /// final device = await buildInfo.deviceInfo;
  /// // iOS: device.deviceBrand = "iPhone", device.deviceModel = "iPhone 14 Pro"
  /// // Android: device.deviceBrand = "Samsung", device.deviceModel = "SM-G991B"
  /// ```
  Future<DeviceInfoModel> get deviceInfo;

  /// Retrieves application information including version and build details.
  ///
  /// This property provides details about the current application build,
  /// including version number, build number, and package name. This
  /// information is useful for analytics, debugging, and version checks.
  ///
  /// The data is cached after the first fetch for performance.
  ///
  /// Returns an [AppInfoModel] containing application version and build information.
  ///
  /// Example:
  /// ```dart
  /// final app = await buildInfo.appInfo;
  /// // app.versionNumber = "1.2.3"
  /// // app.buildNumber = "123"
  /// // app.packageName = "com.example.myapp"
  /// ```
  Future<AppInfoModel> get appInfo;

  /// Retrieves locale and timezone information.
  ///
  /// This property provides details about the user's current locale
  /// and timezone settings. This information is useful for localization,
  /// analytics, and time-based features.
  ///
  /// The data is cached after the first fetch for performance.
  ///
  /// Returns a [LocaleInfoModel] containing language, country, and timezone information.
  ///
  /// Example:
  /// ```dart
  /// final locale = await buildInfo.localeInfo;
  /// // locale.languageCode = "en"
  /// // locale.countryCode = "US"
  /// // locale.timezone = "America/New_York"
  /// ```
  Future<LocaleInfoModel> get localeInfo;

  /// Prompts the user to update the application.
  ///
  /// This method displays a native update dialog to encourage or force
  /// the user to update the application. The behavior depends on the
  /// [force] parameter and the platform's update mechanism.
  ///
  /// [context] The build context for displaying the update dialog.
  /// [force] Whether the update should be mandatory (prevents dismissing the dialog).
  ///
  /// Note: The actual implementation may vary based on the update mechanism
  /// used (App Store, Google Play, or custom update system).
  ///
  /// Example:
  /// ```dart
  /// // Prompt for optional update
  /// buildInfo.promptUserToUpdate(context, false);
  ///
  /// // Force mandatory update
  /// buildInfo.promptUserToUpdate(context, true);
  /// ```
  void promptUserToUpdate(BuildContext context, bool force);
}

class BuildInfoServiceImpl implements BuildInfoService {
  final DeviceInfoPlugin deviceInfoPlugin;

  BuildInfoServiceImpl({required this.deviceInfoPlugin});

  DeviceInfoModel? _deviceInfo;
  AppInfoModel? _appInfo;
  LocaleInfoModel? _localeInfo;

  @override
  Future<AppInfoModel> get appInfo async => _appInfo ??= await _fetchAppInfo();

  @override
  Future<DeviceInfoModel> get deviceInfo async => _deviceInfo ??= await _fetchDeviceInfo();

  @override
  Future<LocaleInfoModel> get localeInfo async => _localeInfo ??= await _fetchLocaleInfo();

  @override
  void promptUserToUpdate(BuildContext context, bool force) {
    try {
      // NativeUpdater.displayUpdateAlert(context, forceUpdate: force);
    } catch (e, s) {
      Logger(runtimeType.toString()).severe('Prompt for update ran into error', e, s);
    }
  }

  Future<DeviceInfoModel> _fetchDeviceInfo() async {
    try {
      DeviceInfoModel deviceInfo;
      if (Platform.isIOS) {
        deviceInfo = await _fetchIosInfo();
      } else if (Platform.isAndroid) {
        deviceInfo = await _fetchAndroidInfo();
      } else {
        deviceInfo = DeviceInfoModel(
          deviceBrand: Platform.operatingSystem,
          deviceModel: Platform.operatingSystemVersion,
        );
      }
      return deviceInfo;
    } catch (e, t) {
      Logger(runtimeType.toString()).severe('Device info fetch ran into error', e, t);
      rethrow;
    }
  }

  Future<DeviceInfoModel> _fetchIosInfo() async {
    final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;

    final deviceBrand = iosInfo.name;
    final deviceModel = '${iosInfo.model}/${iosInfo.utsname.machine}';

    return DeviceInfoModel(
      deviceBrand: _limitToMaxLength(deviceBrand),
      deviceModel: _limitToMaxLength(deviceModel),
    );
  }

  Future<DeviceInfoModel> _fetchAndroidInfo() async {
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    final deviceBrand = androidInfo.brand;
    final deviceModel = androidInfo.model;

    return DeviceInfoModel(
      deviceBrand: _limitToMaxLength(deviceBrand),
      deviceModel: _limitToMaxLength(deviceModel),
    );
  }

  String _limitToMaxLength(String value) {
    return value.truncate(23);
  }

  Future<AppInfoModel> _fetchAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();

      return AppInfoModel(
        packageName: info.packageName,
        buildNumber: info.buildNumber,
        versionNumber: info.version,
      );
    } catch (e, t) {
      Logger(runtimeType.toString()).severe('App info fetch ran into error', e, t);
      rethrow;
    }
  }

  Future<LocaleInfoModel> _fetchLocaleInfo() async {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final timezone = DateTime.now().timeZoneName;

      return LocaleInfoModel(
        languageCode: locale.languageCode,
        countryCode: locale.countryCode ?? 'Unknown',
        timezone: timezone,
      );
    } catch (e, t) {
      Logger(runtimeType.toString()).severe('Locale info fetch ran into error', e, t);
      rethrow;
    }
  }
}
