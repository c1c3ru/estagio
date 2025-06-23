import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesManager {
  final SharedPreferences? _prefs;

  PreferencesManager(this._prefs);

  // User Token
  Future<void> saveUserToken(String token) async {
    if (_prefs != null) {
      await _prefs!.setString('user_token', token);
    }
  }

  String? getUserToken() {
    return _prefs?.getString('user_token');
  }

  Future<void> removeUserToken() async {
    await _prefs?.remove('user_token');
  }

  // User Data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (_prefs != null) {
      await _prefs!.setString('user_data', jsonEncode(userData));
    }
  }

  Map<String, dynamic>? getUserData() {
    if (_prefs == null) return null;
    final userDataString = _prefs!.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs?.remove('user_data');
  }

  // Theme
  Future<void> saveThemeMode(String themeMode) async {
    if (_prefs != null) {
      await _prefs!.setString('theme_mode', themeMode);
    }
  }

  String? getThemeMode() {
    return _prefs?.getString('theme_mode');
  }

  // First Launch
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    if (_prefs != null) {
      await _prefs!.setBool('is_first_launch', isFirstLaunch);
    }
  }

  bool isFirstLaunch() {
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  // Clear All
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
