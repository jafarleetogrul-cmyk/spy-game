import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final _player = AudioPlayer();
  static bool soundEnabled = true;
  static bool vibrationEnabled = true;

  static Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  static Future<void> play(String sound) async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/$sound'));
    } catch (_) {}
  }

  static Future<void> vibrate({int duration = 50}) async {
    if (!vibrationEnabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(duration: duration);
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> vibratePattern(List<int> pattern) async {
    if (!vibrationEnabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(pattern: pattern);
      }
    } catch (_) {}
  }

  // ── Named sounds ─────────────────────────────────────────
  static Future<void> cardFlip() async {
    await play('card_flip.wav');
    await vibrate(duration: 30);
  }

  static Future<void> roundEnd() async {
    await play('round_end.wav');
    await vibrate(duration: 100);
  }

  static Future<void> gameOver() async {
    await play('game_over.wav');
    await vibratePattern([0, 100, 100, 200]);
  }

  static Future<void> timerTick() async {
    await play('timer_tick.wav');
  }

  static Future<void> timerWarning() async {
    await play('timer_warning.wav');
    await vibratePattern([0, 50, 50, 50, 50, 50]);
  }

  static Future<void> win() async {
    await play('win.wav');
    await vibratePattern([0, 100, 50, 100, 50, 200]);
  }

  static Future<void> buttonTap() async {
    await vibrate(duration: 20);
  }
}
