// lib/ui/settings_screen.dart
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

  // --- Colours ---
  static const _brawYellow = Color(0xFFFFBD59);

  // --- Typography (all yellow) ---
  static const TextStyle _listTileStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 18,
    height: 1.3,
    color: _brawYellow,
  );

  static const TextStyle _subtitleStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 16,
    height: 1.3,
    color: _brawYellow,
  );

  // --- Layout constants ---
  static const double autoplayTopGap = 40;   // top → Autoplay
  static const double autoplayGap = 40;      // Autoplay → divider
  static const double dividerBottomGap = 24; // divider → language radios

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        imageAsset: 'assets/images/brawHome.jpg',
        blueOverlayOpacity: 0.75,
        child: SafeArea(
          child: ListView(
            children: [
              // Gap at top so Autoplay isn’t jammed into notch
              const SizedBox(height: autoplayTopGap),

              // --- Autoplay switch ---
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
                activeColor: _brawYellow,
                onChanged: onAutoAudioChanged,
              ),

              // Add adjustable space before divider
              const SizedBox(height: autoplayGap),

              const Divider(color: Colors.white54),

              // Extra gap below divider
              const SizedBox(height: dividerBottomGap),

              // --- Language radio group ---
              RadioTheme(
                data: RadioThemeData(
                  fillColor: MaterialStateProperty.all(_brawYellow),
                  overlayColor: MaterialStateProperty.all(_brawYellow),
                ),
                child: Padding(
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
                        title: Text(display, style: _listTileStyle),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
