export '../../utilities/constants/local_store_keys.dart';

abstract class LocalStorageService {
  Future saveBool(String key, bool value);
  Future saveString(String key, String value);
  Future saveDouble(String key, num value);

  Future<bool?> fetchBool(String key);
  Future<String?> fetchString(String key);
  Future<double?> fetchDouble(String key);

  Future<bool> clearEntireStorage();
  Future<bool> clearField(String key);
}
