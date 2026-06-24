import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT Token 安全存储
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';

  static Future<void> save(String token, int userId) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<int?> getUserId() async {
    final s = await _storage.read(key: _userIdKey);
    return s != null ? int.tryParse(s) : null;
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}