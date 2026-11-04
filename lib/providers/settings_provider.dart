import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  static const _themeKey = 'theme_mode';
  static const _apiKeyKey = 'claude_api_key';
  static const _welcomeKey = 'seen_welcome';

  // The API key is a secret, so it goes in the secure storage instead of
  // shared_preferences, which is just a plain file on disk.
  final _secureStorage = const FlutterSecureStorage();

  ThemeMode themeMode = ThemeMode.system;
  String? apiKey;
  bool seenWelcome = false;
  bool loaded = false; // false until the saved settings have been read

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      themeMode = ThemeMode.values.byName(savedTheme);
    }
    seenWelcome = prefs.getBool(_welcomeKey) ?? false;
    apiKey = await _secureStorage.read(key: _apiKeyKey);
    loaded = true;
    notifyListeners();
  }

  // Called by the Get Started button so the welcome screen only shows once.
  Future<void> finishWelcome() async {
    seenWelcome = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
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
