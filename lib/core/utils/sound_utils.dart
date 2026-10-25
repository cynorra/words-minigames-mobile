import 'package:audioplayers/audioplayers.dart';
import '../services/sound_settings_service.dart';

class SoundUtils {
  // Core initialization
  static bool _isInitialized = false;

  // Dedicated looping player (e.g., spinner)
  static AudioPlayer? _spinnerPlayer;

  // Legacy single player kept for backward compatibility (not preferred for SFX)
  static AudioPlayer? _audioPlayer;

  // Reusable short SFX pool to prevent excessive allocations and sound mixing artifacts
  static final List<AudioPlayer> _sfxPool = <AudioPlayer>[];
  static const int _sfxMaxPoolSize = 4; // up to 4 concurrent short effects
  static int _sfxNextIndex = 0; // round-robin selection

  // Throttle map to avoid spamming the same sound too frequently
  static final Map<String, DateTime> _throttleGuards = <String, DateTime>{};

  /// Initialize sound system and warm-up pool
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Ensure settings are available before interacting with players
    await SoundSettingsService.ensureInitialized();

    // Keep a legacy player for compatibility (used by some API methods)
    _audioPlayer = AudioPlayer();

    // Pre-create a small pool of sfx players (idle, to be reused)
    for (int i = 0; i < _sfxMaxPoolSize; i++) {
      final AudioPlayer player = AudioPlayer();
      // Ensure each SFX player stops after completing a sound
      player.setReleaseMode(ReleaseMode.stop);
      _sfxPool.add(player);
    }

    _isInitialized = true;
  }

  // =========================
  // Public API (unchanged)
  // =========================

  static Future<void> playGameStartSound() async {
    await _playSfx(
      'sounds/game_start.mp3',
      baseVolume: 0.7,
      throttleKey: 'game_start',
      minIntervalMs: 150,
    );
  }

  static Future<void> playLaserSound() async {
    await _playSfx(
      'sounds/laser_sound.mp3',
      baseVolume: 0.7,
      throttleKey: 'laser',
      minIntervalMs: 50,
    );
  }

  static Future<void> playWindSound() async {
    await _playSfx(
      'sounds/wind_sound.mp3',
      baseVolume: 0.5,
      throttleKey: 'wind',
      minIntervalMs: 200,
    );
  }

  static Future<void> playGameOverSound() async {
    await _playSfx(
      'sounds/game_over_sound.mp3',
      baseVolume: 0.7,
      throttleKey: 'game_over',
      minIntervalMs: 150,
    );
  }

  static Future<void> playWinnerSound() async {
    await _playSfx(
      'sounds/winner_sound.mp3',
      baseVolume: 0.8,
      throttleKey: 'winner',
      minIntervalMs: 200,
    );
  }

  /// Uygulama açılış sesi
  static Future<void> playOpeningSound() async {
    await _playSfx(
      'sounds/opening_sound.mp3',
      baseVolume: 0.8,
      throttleKey: 'opening',
      minIntervalMs: 500,
    );
  }

  static Future<void> playGameOverSoundLegacy() async {
    await _playSfx(
      'sounds/game_over.mp3',
      baseVolume: 0.7,
      throttleKey: 'game_over_legacy',
      minIntervalMs: 150,
    );
  }

  /// Doğru renk seçildiğinde blink sesi (Color Hunt)
  static Future<void> playBlinkSound() async {
    await _playSfx(
      'sounds/blink_sound.mp3',
      baseVolume: 0.7,
      throttleKey: 'blink',
      minIntervalMs: 40,
    );
  }

  /// Geri sayım sesi (son 3 saniye). Kısa ve üst üste çalabilir; hafif throttle.
  static Future<void> playCountDownSound() async {
    await _playSfx(
      'sounds/three_seconds_timer.mp3',
      baseVolume: 0.6,
      throttleKey: 'countdown',
      minIntervalMs: 250,
    );
  }

  /// Spinner sesi (loop). Aynı anda tek bir loop, idempotent başlat.
  static Future<void> playSpinnerSound() async {
    await SoundSettingsService.ensureInitialized();
    if (!SoundSettingsService.isSoundEnabled) return;

    _spinnerPlayer ??= AudioPlayer();
    try {
      await _spinnerPlayer!.setReleaseMode(ReleaseMode.loop);
      await _spinnerPlayer!.play(AssetSource('sounds/spinner_sound.mp3'));
      await _spinnerPlayer!.setVolume(_effectiveVolume(0.5));
    } catch (e) {
      // ignore: avoid_print
      print('Spinner sesi çalınırken hata: $e');
    }
  }

  /// Spinner sesini yumuşak bir şekilde durdur (fade out) ve kaynağı temizle.
  static Future<void> stopSpinnerSound() async {
    final AudioPlayer? player = _spinnerPlayer;
    if (player == null) return;
    try {
      // Simple fade-out over ~150ms to avoid click/pop artifacts
      final double step = 0.1;
      for (double v = 0.5; v >= 0.0; v -= step) {
        await player.setVolume(_effectiveVolume(v));
        await Future.delayed(const Duration(milliseconds: 30));
      }
      await player.stop();
      await player.dispose();
    } catch (e) {
      // ignore: avoid_print
      print('Spinner sesi durdurulurken hata: $e');
    } finally {
      _spinnerPlayer = null;
    }
  }

  /// Blind Sort tap sesi
  static Future<void> playTapSound() async {
    await _playSfx(
      'sounds/tap_sound.mp3',
      baseVolume: 0.7,
      throttleKey: 'tap',
      minIntervalMs: 30,
    );
  }

  /// Yeni rekor (level up) sesi
  static Future<void> playNewLevelSound() async {
    // Disabled per requirement to cancel record-breaking sounds
    return;
  }

  /// Kaynakları temizle
  static Future<void> dispose() async {
    try {
      for (final p in _sfxPool) {
        await p.stop();
        await p.dispose();
      }
      _sfxPool.clear();
      await _spinnerPlayer?.stop();
      await _spinnerPlayer?.dispose();
      _spinnerPlayer = null;
      await _audioPlayer?.dispose();
      _audioPlayer = null;
    } catch (_) {
      // ignore errors on shutdown
    } finally {
      _isInitialized = false;
    }
  }

  // Maintained for compatibility with existing calls
  static bool get isPlaying => _audioPlayer?.state == PlayerState.playing;
  static PlayerState? get playerState => _audioPlayer?.state;

  // =========================
  // Internals
  // =========================

  static Future<void> _playSfx(
    String assetPath, {
    required double baseVolume,
    String? throttleKey,
    int minIntervalMs = 0,
  }) async {
    await initialize();
    await SoundSettingsService.ensureInitialized();
    if (!SoundSettingsService.isSoundEnabled) return;

    // Throttle repeated triggers of the same sound key
    if (throttleKey != null && minIntervalMs > 0) {
      final DateTime now = DateTime.now();
      final DateTime? last = _throttleGuards[throttleKey];
      if (last != null && now.difference(last).inMilliseconds < minIntervalMs) {
        return;
      }
      _throttleGuards[throttleKey] = now;
    }

    // Pick the next available SFX player (round-robin). If busy, stop it softly and reuse.
    final AudioPlayer player = _nextSfxPlayer();

    try {
      await player.stop(); // ensure clean state
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_effectiveVolume(baseVolume));
      await player.play(AssetSource(assetPath));
    } catch (e) {
      // As a fallback, try using the legacy player once
      try {
        await _audioPlayer?.stop();
        await _audioPlayer?.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer?.setVolume(_effectiveVolume(baseVolume));
        await _audioPlayer?.play(AssetSource(assetPath));
      } catch (_) {
        // ignore
      }
    }
  }

  static AudioPlayer _nextSfxPlayer() {
    // Find an idle player if possible
    for (final p in _sfxPool) {
      if (p.state != PlayerState.playing) {
        return p;
      }
    }
    // None idle: reuse in round-robin (preempt)
    final AudioPlayer selected = _sfxPool[_sfxNextIndex % _sfxPool.length];
    _sfxNextIndex = (_sfxNextIndex + 1) % _sfxPool.length;
    return selected;
  }

  static double _effectiveVolume(double baseVolume) {
    final v = (baseVolume * SoundSettingsService.effectsVolume).clamp(0.0, 1.0);
    return v.toDouble();
  }
}
