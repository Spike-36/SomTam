import 'package:audioplayers/audioplayers.dart';

/// Tiny wrapper for simple asset playback.
/// - Two player channels (A and B) so short sounds can overlap without cutting each other.
/// - Plays bundled assets declared in pubspec.
/// - No background, no playlists, no mic.
class AudioService {
  final AudioPlayer _playerA = AudioPlayer(playerId: 'braw3_main_a');
  final AudioPlayer _playerB = AudioPlayer(playerId: 'braw3_main_b');

  AudioService() {
    _configureContext();
    _playerA.setReleaseMode(ReleaseMode.stop);
    _playerB.setReleaseMode(ReleaseMode.stop);
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

  AudioPlayer _select(String channel) =>
      (channel.toLowerCase() == 'b') ? _playerB : _playerA;

  /// Plays a bundled asset on the chosen [channel] ('a' or 'b').
  /// If [interrupt] is true (default), stops that channel before play.
  Future<void> playAsset(String assetPath, {bool interrupt = true, String channel = 'a'}) async {
    if (assetPath.isEmpty) return;
    final player = _select(channel);
    if (interrupt) {
      await player.stop();
    }
    await player.play(AssetSource(_normalize(assetPath)));
  }

  Future<void> stop({String channel = 'a'}) async {
    await _select(channel).stop();
  }

  Future<void> setVolume(double v, {String channel = 'a'}) async {
    await _select(channel).setVolume(v.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    await _playerA.dispose();
    await _playerB.dispose();
  }
}
