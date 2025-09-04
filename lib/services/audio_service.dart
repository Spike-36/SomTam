import 'package:just_audio/just_audio.dart';

class AudioService {
  final _player = AudioPlayer();

  Future<void> playAsset(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      // In a starter, just print; in production, show a toast/snackbar
      // ignore: avoid_print
      print('Audio error: $e');
    }
  }

  Future<void> dispose() => _player.dispose();
}
