import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool autoAudio;
  final ValueChanged<bool> onAutoAudioChanged;

  const SettingsScreen({
    super.key,
    required this.autoAudio,
    required this.onAutoAudioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Auto-play Scottish audio on new word'),
            subtitle: const Text('Off by default each time you open the app'),
            value: autoAudio,
            onChanged: onAutoAudioChanged,
          ),
        ],
      ),
    );
  }
}
