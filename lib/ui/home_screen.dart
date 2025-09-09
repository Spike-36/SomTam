// lib/ui/home_screen.dart
import 'package:flutter/material.dart';
import '../i18n/i18n.dart';
import 'widgets/app_background.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onAudioTap;

  // 🔧 Gap values (adjust these numbers to move things around)
  static const double topGap = 65;
  static const double logoToSubtitleGap = 25;
  static const double subtitleToButtonsGap = 170;
  static const double betweenButtonsGap = 50;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        imageAsset: '',                 // ⛔️ disable tartan bg (kept placeholder)
        blueOverlayOpacity: 1.0,        // 🔵 full saturation
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: topGap),

              // --- Braw logo (commented out; keep for later replacement) ---
              // Center(
              //   child: Image.asset(
              //     'assets/images/brawHeading.png',
              //     width: 300,
              //     height: 120,
              //     fit: BoxFit.contain,
              //   ),
              // ),

              SizedBox(height: logoToSubtitleGap),

              Center(
                child: Text(
                  I18n.t("WordKimchi", lang: languageCode),
                  style: const TextStyle(
                    fontSize: 27,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFBD59), // yellow
                    shadows: [Shadow(blurRadius: 6, offset: Offset(0, 1))],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: subtitleToButtonsGap),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Audio
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFBD59), width: 2),
                            foregroundColor: const Color(0xFFFFBD59),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'SourceSerif4',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: onAudioTap,
                          child: Text(I18n.t("audio", lang: languageCode)),
                        ),
                      ),

                      SizedBox(height: betweenButtonsGap),

                      // Language
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFBD59), width: 2),
                            foregroundColor: const Color(0xFFFFBD59),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'SourceSerif4',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: onLanguageTap,
                          child: Text(I18n.labelFor(languageCode)),
                        ),
                      ),
                    ],
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
