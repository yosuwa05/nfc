import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();

  // Boolean operations
  static Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<bool> getBool(String key) async {
    final value = await _storage.read(key: key);
    return value == 'true' ? true : false;
  }

  // String operations
  static Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  // Integer operations
  static Future<void> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? int.parse(value) : null;
  }

  // Double operations
  static Future<void> setDouble(String key, double value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<double?> getDouble(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? double.parse(value) : null;
  }

  // List operations
  static Future<void> setList(String key, List<String> value) async {
    await _storage.write(key: key, value: value.join('|||'));
  }

  static Future<List<String>?> getList(String key) async {
    final value = await _storage.read(key: key);
    return value?.split('|||');
  }

  // Utility operations
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}

