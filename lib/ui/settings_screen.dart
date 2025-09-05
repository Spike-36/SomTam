import 'package:flutter/material.dart';
import '../I18n/i18n.dart'; // ✅ your i18n helper

class SettingsScreen extends StatelessWidget {
  final bool autoAudio;
  final ValueChanged<bool> onAutoAudioChanged;
  final String languageCode;                 // ✅ clearer name
  final ValueChanged<String> onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.autoAudio,
    required this.onAutoAudioChanged,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.t('settings', lang: languageCode))),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(I18n.t('autoplay', lang: languageCode)),
            subtitle: Text(I18n.t('autoplay_description', lang: languageCode)),
            value: autoAudio,
            onChanged: onAutoAudioChanged,
          ),
          const Divider(),
          ListTile(
            title: Text(I18n.t('language', lang: languageCode)),
            trailing: DropdownButton<String>(
              value: languageCode,
              items: I18n.supportedLanguages
                  .map(
                    (code) => DropdownMenuItem(
                      value: code,
                      child: Text(I18n.labelFor(code)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onLanguageChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
