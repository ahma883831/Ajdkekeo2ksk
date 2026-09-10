import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Loops a subtle background music track. Call [duck] before speaking a
/// sentence via TTS and [unduck] afterward so the music doesn't compete
/// with the pronunciation audio.
class BackgroundMusicService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;
  static const double _normalVolume = 0.35;
  static const double _duckedVolume = 0.08;

  Future<void> init() async {
    try {
      await _player.setAsset('assets/audio/background_loop.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(_normalVolume);
    } catch (_) {
      // Asset not bundled yet — background music simply stays silent
      // until a background_loop.mp3 file is added to assets/audio/.
    }
  }

  Future<void> play() async {
    if (!enabled) return;
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> duck() => _player.setVolume(_duckedVolume);

  Future<void> unduck() => _player.setVolume(_normalVolume);

  Future<void> toggle(bool value) async {
    enabled = value;
    if (enabled) {
      await play();
    } else {
      await pause();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
