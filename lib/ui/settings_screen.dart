import 'package:flutter/material.dart';
import '../i18n/i18n.dart';
import 'widgets/app_background.dart';

class SettingsScreen extends StatelessWidget {
  final bool autoAudio;
  final ValueChanged<bool> onAutoAudioChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.autoAudio,
    required this.onAutoAudioChanged,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  // --- Typography (all white, tuned for dark bg) ---
  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'EBGaramond',
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: Colors.white,
  );

  static const TextStyle _listTileStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 18,
    height: 1.3,
    color: Colors.white,
  );

  static const TextStyle _subtitleStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 16,
    height: 1.3,
    color: Colors.white70,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        imageAsset: 'assets/images/brawHome.jpg',
        blueOverlayOpacity: 0.75,
        child: Column(
          children: [
            AppBar(
              title: Text(
                I18n.t('settings', lang: languageCode),
                style: _titleStyle,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            Expanded(
              child: ListView(
                children: [
                  // --- Language picker heading ---
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      I18n.t('language', lang: languageCode),
                      style: _listTileStyle,
                    ),
                  ),

                  // --- Permanent radio list of all supported languages ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: I18n.supportedLanguages.map((code) {
                        final display = I18n.combinedLabel(code);
                        return RadioListTile<String>(
                          value: code,
                          groupValue: languageCode,
                          onChanged: (v) {
                            if (v != null) onLanguageChanged(v);
                          },
                          activeColor: Colors.white,
                          title: Text(display, style: _listTileStyle),
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(color: Colors.white54),

                  // --- Autoplay switch BELOW the language list ---
                  SwitchListTile(
                    title: Text(
                      I18n.t('autoplay', lang: languageCode),
                      style: _listTileStyle,
                    ),
                    subtitle: Text(
                      I18n.t('autoplay_description', lang: languageCode),
                      style: _subtitleStyle,
                    ),
                    value: autoAudio,
                    activeColor: Colors.white,
                    onChanged: onAutoAudioChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
