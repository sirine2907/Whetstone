import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  static const _themeKey = 'theme_mode';
  static const _apiKeyKey = 'claude_api_key';

  // The API key is a secret, so it goes in the secure storage instead of
  // shared_preferences, which is just a plain file on disk.
  final _secureStorage = const FlutterSecureStorage();

  ThemeMode themeMode = ThemeMode.system;
  String? apiKey;

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      themeMode = ThemeMode.values.byName(savedTheme);
    }
    apiKey = await _secureStorage.read(key: _apiKeyKey);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> saveApiKey(String key) async {
    apiKey = key.trim();
    notifyListeners();
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<void> removeApiKey() async {
    apiKey = null;
    notifyListeners();
    await _secureStorage.delete(key: _apiKeyKey);
  }
}
