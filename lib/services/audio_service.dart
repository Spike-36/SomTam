// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Play an audio asset by Flutter asset path.
  /// Example: playAsset('assets/audio/context/Z004.stoochie.context.mp3')
  Future<void> playAsset(String assetPath) async {
    // Stop anything currently playing to avoid overlap
    try {
      await _player.stop();
    } catch (_) {}

    // Use AssetSource for bundled assets
    await _player.play(AssetSource(_stripAssetsPrefix(assetPath)));
  }

  /// Optionally expose a stop method
  Future<void> stop() => _player.stop();

  /// Clean up the player (call from dispose)
  Future<void> dispose() async {
    try {
      await _player.stop();
    } catch (_) {}
    await _player.release();
    await _player.dispose();
  }

  // audioplayers expects AssetSource('audio/foo.mp3') for assets/audio/foo.mp3
  String _stripAssetsPrefix(String path) {
    if (path.startsWith('assets/')) {
      return path.substring('assets/'.length);
    }
    return path;
  }
}
