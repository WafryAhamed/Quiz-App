import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _roleKey = 'role';

  static Future<void> saveSession(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, payload['token'] as String? ?? '');
    await prefs.setString(_userIdKey, payload['userId'] as String? ?? '');
    await prefs.setString(_nameKey, payload['name'] as String? ?? '');
    await prefs.setString(_emailKey, payload['email'] as String? ?? '');
    await prefs.setString(_roleKey, payload['role'] as String? ?? 'student');
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) ?? '';
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) ?? '';
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey) ?? 'student';
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleKey);
  }
}
