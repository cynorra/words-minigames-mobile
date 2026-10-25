import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/supported_locales.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = SupportedLocales.defaultLocale;
  bool _isLoading = false;

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;
  String get languageCode => _currentLocale.languageCode;

  LanguageProvider() {
    loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        // Use the improved getLocaleByLanguageCode method
        _currentLocale =
            SupportedLocales.getLocaleByLanguageCode(savedLanguage) ??
            SupportedLocales.defaultLocale;
      } else {
        // Default to English for new installations
        _currentLocale = SupportedLocales.defaultLocale;
        // Save the default language preference
        await prefs.setString(
          _languageKey,
          SupportedLocales.defaultLocale.languageCode,
        );
      }
    } catch (e) {
      // Fallback to English if there's an error
      _currentLocale = SupportedLocales.fallbackLocale;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    Locale? newLocale = SupportedLocales.getLocaleByLanguageCode(languageCode);

    // Fallback to default locale if not found
    newLocale ??= SupportedLocales.defaultLocale;

    if (_currentLocale.languageCode == newLocale.languageCode &&
        _currentLocale.countryCode == newLocale.countryCode) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      _currentLocale = newLocale;
    } catch (e) {
      // Handle error if needed
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeLanguageToEnglish() async {
    await changeLanguage('en');
  }

  Future<void> changeLanguageToTurkish() async {
    await changeLanguage('tr');
  }

  Future<void> changeLanguageToSpanish() async {
    await changeLanguage('es');
  }

  Future<void> changeLanguageToPortuguese() async {
    await changeLanguage('pt_BR');
  }

  Future<void> changeLanguageToArabic() async {
    await changeLanguage('ar');
  }

  Future<void> changeLanguageToGerman() async {
    await changeLanguage('de');
  }

  Future<void> changeLanguageToFrench() async {
    await changeLanguage('fr');
  }

  Future<void> changeLanguageToIndonesian() async {
    await changeLanguage('id');
  }

  Future<void> changeLanguageToHindi() async {
    await changeLanguage('hi');
  }

  Future<void> changeLanguageToRussian() async {
    await changeLanguage('ru');
  }

  Future<void> changeLanguageToItalian() async {
    await changeLanguage('it');
  }

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isTurkish => _currentLocale.languageCode == 'tr';
  bool get isSpanish => _currentLocale.languageCode == 'es';
  bool get isPortuguese =>
      _currentLocale.languageCode == 'pt' && _currentLocale.countryCode == 'br';
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isGerman => _currentLocale.languageCode == 'de';
  bool get isFrench => _currentLocale.languageCode == 'fr';
  bool get isIndonesian => _currentLocale.languageCode == 'id';
  bool get isHindi => _currentLocale.languageCode == 'hi';
  bool get isRussian => _currentLocale.languageCode == 'ru';
  bool get isItalian => _currentLocale.languageCode == 'it';

  /// Get all supported locales
  List<Locale> get supportedLocales => SupportedLocales.locales;

  /// Check if current locale is supported
  bool get isCurrentLocaleSupported =>
      SupportedLocales.isSupported(_currentLocale);

  /// Get locale by index
  Locale? getLocaleByIndex(int index) {
    if (index >= 0 && index < SupportedLocales.locales.length) {
      return SupportedLocales.locales[index];
    }
    return null;
  }

  /// Get index of current locale
  int get currentLocaleIndex {
    return SupportedLocales.locales.indexWhere(
      (locale) =>
          locale.languageCode == _currentLocale.languageCode &&
          locale.countryCode == _currentLocale.countryCode,
    );
  }
}
