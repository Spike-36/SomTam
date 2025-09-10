// lib/ui/settings_screen.dart
import 'package:flutter/material.dart';
import '../I18n/i18n.dart';

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

  static const TextStyle _listTileStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 18,
    height: 1.3,
    color: Colors.black,
  );

  static const TextStyle _subtitleStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 16,
    height: 1.3,
    color: Colors.black54,
  );

  static const double autoplayTopGap = 35;
  static const double autoplayGap = 5;
  static const double dividerBottomGap = 24;

  static const double autoplayBlockHeight = 140.0;
  static const double autoplaySwitchBoxWidth = 80.0;
  static const int autoplayTitleMaxLines = 2;
  static const int autoplaySubtitleMaxLines = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ plain white background
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: autoplayTopGap),

            // --- Autoplay toggle ---
            SizedBox(
              height: autoplayBlockHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            I18n.t('autoplay', lang: languageCode),
                            style: _listTileStyle,
                            maxLines: autoplayTitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            I18n.t('autoplay_description',
                                lang: languageCode),
                            style: _subtitleStyle,
                            maxLines: autoplaySubtitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: autoplaySwitchBoxWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Switch.adaptive(
                          value: autoAudio,
                          onChanged: onAutoAudioChanged,
                          activeColor: Colors.black,
                          inactiveThumbColor: Colors.black54,
                          inactiveTrackColor: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: autoplayGap),
            const Divider(color: Colors.black26),
            const SizedBox(height: dividerBottomGap),

            // --- Only Korean option ---
            RadioTheme(
              data: RadioThemeData(
                fillColor: MaterialStateProperty.all(Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: RadioListTile<String>(
                  value: 'korean',
                  groupValue: 'korean', // always preselected
                  onChanged: (v) {
                    if (v != null) onLanguageChanged(v);
                  },
                  title: Text(I18n.combinedLabel('korean'),
                      style: _listTileStyle),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
