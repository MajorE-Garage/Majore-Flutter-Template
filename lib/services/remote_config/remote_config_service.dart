import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logging/logging.dart';

abstract class RemoteConfigService {
  static final instance = _RemoteConfigService();

  bool getBool(String key);
  double getDouble(String key);
  int getInt(String key);
  String getString(String key);
  Future<bool> initialise();
  Future<bool> refresh();
}

class _RemoteConfigService extends RemoteConfigService {
  final FirebaseRemoteConfig remoteConfig;

  _RemoteConfigService() : remoteConfig = FirebaseRemoteConfig.instance;

  @override
  bool getBool(String key) => remoteConfig.getBool(key);

  @override
  double getDouble(String key) => remoteConfig.getDouble(key);

  @override
  int getInt(String key) => remoteConfig.getInt(key);

  @override
  String getString(String key) => remoteConfig.getString(key);

  @override
  Future<bool> initialise() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 2),
          minimumFetchInterval: const Duration(days: 1),
        ),
      );
      return await remoteConfig.fetchAndActivate();
    } catch (e, t) {
      Logger(runtimeType.toString()).severe('RemoteConfigService failed to initialise', e, t);
      return false;
    }
  }

  @override
  Future<bool> refresh() async {
    try {
      return await remoteConfig.fetchAndActivate();
    } catch (e, t) {
      Logger(runtimeType.toString()).severe('RemoteConfigService failed to refresh', e, t);
      return false;
    }
  }
}
