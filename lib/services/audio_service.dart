import 'package:audioplayers/audioplayers.dart';

/// Tiny wrapper for simple asset playback.
/// - One player instance (new plays stop the previous one).
/// - Plays bundled assets declared in pubspec.
/// - No background, no playlists, no mic.
class AudioService {
  final AudioPlayer _player = AudioPlayer(playerId: 'braw3_main');

  AudioService() {
    _configureContext();
    _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> _configureContext() async {
    // Make audio audible even if iPhone is on silent. No background playback.
    await AudioPlayer.global.setAudioContext(const AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: [AVAudioSessionOptions.mixWithOthers],
      ),
      android: AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        isSpeakerphoneOn: false,
        stayAwake: false,
      ),
    ));
  }

  String _normalize(String assetPath) =>
      assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;

  /// Plays a bundled asset. If something is already playing, it stops first.
  Future<void> playAsset(String assetPath) async {
    if (assetPath.isEmpty) return;
    await _player.stop();
    // audioplayers expects the path relative to the assets root, not starting with 'assets/'
    await _player.play(AssetSource(_normalize(assetPath)));
  }

  Future<void> stop() => _player.stop();
  Future<void> setVolume(double v) => _player.setVolume(v.clamp(0.0, 1.0));
  Future<void> dispose() => _player.dispose();
}
