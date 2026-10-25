import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service to persist and expose app sound settings.
/// UI updates should be handled by a Provider that delegates to this service.
class SoundSettingsService {
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyEffectsVolume = 'effects_volume';

  static bool _initialized = false;
  static late SharedPreferences _prefs;

  static bool _soundEnabled = true;
  static double _effectsVolume = 0.7; // 0.0 - 1.0

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _soundEnabled = _prefs.getBool(_keySoundEnabled) ?? true;
      _effectsVolume = _prefs.getDouble(_keyEffectsVolume) ?? 0.7;
      _effectsVolume = _clampVolume(_effectsVolume);
    } catch (e) {
      // Handle initialization error silently in production
    }
    _initialized = true;
  }

  static bool get isSoundEnabled => _soundEnabled;
  static double get effectsVolume => _effectsVolume;

  static Future<void> setSoundEnabled(bool enabled) async {
    await ensureInitialized();
    _soundEnabled = enabled;
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  static Future<void> setEffectsVolume(double volume) async {
    await ensureInitialized();
    _effectsVolume = _clampVolume(volume);
    await _prefs.setDouble(_keyEffectsVolume, _effectsVolume);
  }

  static double _clampVolume(double v) {
    if (v.isNaN) return 0.7;
    if (v < 0) return 0.0;
    if (v > 1) return 1.0;
    return v;
  }
}
