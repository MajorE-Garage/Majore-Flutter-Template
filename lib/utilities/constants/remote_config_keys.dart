// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import '../../main/environment_config.dart';

class RemoteKeys {
  RemoteKeys._();
  static final i = RemoteKeys._();

  final FORCE_APP_VERSION = 'minimum_version';

  final AVAILABLE_APP_VERSION = 'current_version';
  final ORDER_SERVICE_FEE = 'ORDER_SERVICE_FEE';
}

extension RemoteKeysFormat on String {
  String get withEnv =>
      '${EnvironmentConfig.isProd ? 'prod' : 'staging'}'
      '_'
      '${Platform.isIOS ? 'ios' : 'android'}'
      '_'
      '$this';
}
