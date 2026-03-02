import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final _p = AudioPlayer();
  static bool soundEnabled = true;
  static bool vibrationEnabled = true;

  static Future<void> init() async => await _p.setReleaseMode(ReleaseMode.stop);

  static Future<void> _play(String f) async {
    if (!soundEnabled) return;
    try { await _p.play(AssetSource('sounds/$f')); } catch (_) {}
  }

  static Future<void> _vib({int ms = 50}) async {
    if (!vibrationEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) { Vibration.vibrate(duration: ms); }
      else { HapticFeedback.mediumImpact(); }
    } catch (_) { HapticFeedback.mediumImpact(); }
  }

  static Future<void> cardFlip() async { await _play('card_flip.wav'); await _vib(ms: 30); }
  static Future<void> roundEnd() async { await _play('round_end.wav'); await _vib(ms: 100); }
  static Future<void> gameOver() async { await _play('game_over.wav'); await _vib(ms: 200); }
  static Future<void> timerTick() async { await _play('timer_tick.wav'); }
  static Future<void> timerWarning() async { await _play('timer_warning.wav'); await _vib(ms: 150); }
  static Future<void> win() async { await _play('win.wav'); }
  static Future<void> tap() async { await _vib(ms: 20); }
}
