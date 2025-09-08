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
  static const double autoplayTopGap = 35;    // top → Autoplay block
  static const double autoplayGap = 5;       // Autoplay block → divider
  static const double dividerBottomGap = 24;  // divider → language radios

  // 🔒 Lock the autoplay block so nothing moves
  static const double autoplayBlockHeight = 140.0;   // tweak to taste (120–160)
  static const double autoplaySwitchBoxWidth = 80.0; // reserves width for switch
  static const int autoplayTitleMaxLines = 2;
  static const int autoplaySubtitleMaxLines = 3;

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
              // Gap at top so Autoplay isn’t jammed into the notch
              const SizedBox(height: autoplayTopGap),

              // --- Autoplay (custom row; toggle locked in place) ---
              SizedBox(
                height: autoplayBlockHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title + subtitle never change the row height or switch position
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
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              I18n.t('autoplay_description', lang: languageCode),
                              style: _subtitleStyle,
                              maxLines: autoplaySubtitleMaxLines,
                              overflow: TextOverflow.ellipsis,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Fixed-width box prevents horizontal jitter across locales/platforms
                      SizedBox(
                        width: autoplaySwitchBoxWidth,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch.adaptive(
                            value: autoAudio,
                            onChanged: onAutoAudioChanged,
                            activeColor: _brawYellow,
                            // For slightly smaller touch target on Material:
                            // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Consistent spacer before the divider
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
