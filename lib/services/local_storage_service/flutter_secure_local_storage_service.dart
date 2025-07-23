import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'local_storage_service.dart';

class FlutterSecureLocalStorage implements LocalStorageService {
  final FlutterSecureStorage flutterSecureStorage;

  FlutterSecureLocalStorage({required this.flutterSecureStorage});

  Future<void> _write<T>(String key, T value) async {
    return flutterSecureStorage.write(key: key, value: value.toString());
  }

  Future<String?> _read(String key) async {
    final rawValue = await flutterSecureStorage.read(key: key);
    return rawValue;
  }

  @override
  Future saveBool(String key, bool value) async {
    await _write(key, value);
  }

  @override
  Future saveString(String key, String value) async {
    await _write<String>(key, value);
  }

  @override
  Future saveDouble(String key, num value) {
    return _write<double>(key, value.toDouble());
  }

  @override
  Future<bool?> fetchBool(String key) async {
    final rawVal = await _read(key);
    if (rawVal == 'true') return true;
    if (rawVal == 'false') return false;
    return null;
  }

  @override
  Future<String?> fetchString(String key) async {
    return _read(key);
  }

  @override
  Future<double?> fetchDouble(String key) async {
    final rawVal = await _read(key);
    if (rawVal == null) return null;
    final val = double.tryParse(rawVal);
    return val;
  }

  @override
  Future<bool> clearEntireStorage() async {
    await flutterSecureStorage.deleteAll();
    return true;
  }

  @override
  Future<bool> clearField(String key) async {
    try {
      await flutterSecureStorage.delete(key: key);
      return true;
    } catch (e) {
      return false;
    }
  }
}
