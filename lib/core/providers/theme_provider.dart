import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme_mode';

  AppThemeMode _currentThemeMode = AppThemeMode.system;
  bool _isLoading = false;
  late SharedPreferences _prefs;

  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isLoading => _isLoading;

  // Computed properties for easy access
  bool get isLightMode => _currentThemeMode == AppThemeMode.light;
  bool get isDarkMode => _currentThemeMode == AppThemeMode.dark;
  bool get isSystemMode => _currentThemeMode == AppThemeMode.system;

  ThemeProvider() {
    initializeTheme();
  }

  Future<void> initializeTheme() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = _prefs.getInt(_themeKey);

      if (savedThemeIndex != null &&
          savedThemeIndex < AppThemeMode.values.length) {
        _currentThemeMode = AppThemeMode.values[savedThemeIndex];
      } else {
        // Default to dark theme for new installations
        _currentThemeMode = AppThemeMode.dark;
        // Save the default theme preference
        await _prefs.setInt(_themeKey, AppThemeMode.dark.index);
      }
    } catch (e) {
      // Fallback to dark theme if there's an error
      _currentThemeMode = AppThemeMode.dark;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeTheme(AppThemeMode themeMode) async {
    if (_currentThemeMode == themeMode) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentThemeMode = themeMode;
      await _prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      // Handle error if needed
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLightTheme() async {
    await changeTheme(AppThemeMode.light);
  }

  Future<void> setDarkTheme() async {
    await changeTheme(AppThemeMode.dark);
  }

  Future<void> setSystemTheme() async {
    await changeTheme(AppThemeMode.system);
  }

  // Get the effective theme mode considering system preference
  AppThemeMode getEffectiveThemeMode(BuildContext context) {
    if (_currentThemeMode == AppThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark
          ? AppThemeMode.dark
          : AppThemeMode.light;
    }
    return _currentThemeMode;
  }

  // Get theme mode display name
  String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  // Get theme mode description
  String getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light theme for bright environments';
      case AppThemeMode.dark:
        return 'Dark theme for low-light environments';
      case AppThemeMode.system:
        return 'Follows your device theme setting';
    }
  }

  // Get theme mode icon
  IconData getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  // Get theme mode emoji
  String getThemeModeEmoji(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return '☀️';
      case AppThemeMode.dark:
        return '🌙';
      case AppThemeMode.system:
        return '⚙️';
    }
  }
}
