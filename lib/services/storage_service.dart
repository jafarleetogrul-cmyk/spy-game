import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey    = 'auth_token';
  static const _usernameKey = 'username';
  static const _userIdKey   = 'user_id';
  static const _settingsKey = 'settings_v3';

  static Future<void> saveAuth({required String token, required String username, required String userId}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
    await p.setString(_usernameKey, username);
    await p.setString(_userIdKey, userId);
  }

  static Future<Map<String,String?>> getAuth() async {
    final p = await SharedPreferences.getInstance();
    return {'token': p.getString(_tokenKey), 'username': p.getString(_usernameKey), 'user_id': p.getString(_userIdKey)};
  }

  static Future<void> clearAuth() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey); await p.remove(_usernameKey); await p.remove(_userIdKey);
  }

  static Future<Map<String,dynamic>> getSettings() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_settingsKey);
    if (raw == null) return {'language':'az','sound':true,'vibration':true,'server_url':'http://10.0.2.2:8080','round_time':5};
    try { return jsonDecode(raw) as Map<String,dynamic>; } catch (_) { return {}; }
  }

  static Future<void> saveSettings(Map<String,dynamic> s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_settingsKey, jsonEncode(s));
  }
}
