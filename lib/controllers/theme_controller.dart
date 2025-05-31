import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePreferenceKey = 'app_themepreference';

class ThemeController with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? themeString = prefs.getString(_themePreferenceKey);

      if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    } catch (e) {
      print("Error loading theme preference: $e");
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String themeString;
      if (themeMode == ThemeMode.light) {
        themeString = 'light';
      } else if (themeMode == ThemeMode.dark) {
        themeString = 'dark';
      } else {
        themeString = 'system';
      }
      await prefs.setString(_themePreferenceKey, themeString);
    } catch (e) {
      print("Error saving theme preference: $e");
    }
  }
}
