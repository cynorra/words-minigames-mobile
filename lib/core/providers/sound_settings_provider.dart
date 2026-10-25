import 'package:flutter/material.dart';
import '../services/sound_settings_service.dart';
import '../utils/sound_utils.dart';

class SoundSettingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _soundEnabled = true;
  double _effectsVolume = 0.7;

  bool get isLoading => _isLoading;
  bool get soundEnabled => _soundEnabled;
  double get effectsVolume => _effectsVolume;

  SoundSettingsProvider() {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await SoundSettingsService.ensureInitialized();
    _soundEnabled = SoundSettingsService.isSoundEnabled;
    _effectsVolume = SoundSettingsService.effectsVolume;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;
    _soundEnabled = enabled;
    notifyListeners();
    await SoundSettingsService.setSoundEnabled(enabled);
    // Safety: stop any looping/ongoing sounds when disabled
    if (!enabled) {
      await SoundUtils.stopSpinnerSound();
    }
  }

  Future<void> setEffectsVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    if (_effectsVolume == clamped) return;
    _effectsVolume = clamped;
    notifyListeners();
    await SoundSettingsService.setEffectsVolume(clamped);
  }
}
