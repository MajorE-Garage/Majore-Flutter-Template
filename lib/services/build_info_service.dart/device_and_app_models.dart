class DeviceInfoModel {
  final String deviceBrand;
  final String deviceModel;

  DeviceInfoModel({
    required this.deviceBrand,
    required this.deviceModel,
  });
}

class AppInfoModel {
  final String buildNumber;
  final String versionNumber;
  final String packageName;

  AppInfoModel({
    required this.packageName,
    required this.buildNumber,
    required this.versionNumber,
  });
}

class LocaleInfoModel {
  final String languageCode;
  final String countryCode;
  final String timezone;

  LocaleInfoModel({
    required this.languageCode,
    required this.countryCode,
    required this.timezone,
  });
}
