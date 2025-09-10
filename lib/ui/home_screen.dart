// lib/ui/home_screen.dart
import 'package:flutter/material.dart';
import '../I18n/i18n.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onAudioTap;

  // 🔧 Gap values (adjust for spacing)
  static const double topGap = 65;
  static const double headerToButtonsGap = 120;
  static const double betweenButtonsGap = 40;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    // A single faded color for both text + outline
    const fadedColor = Colors.black45; // tweak to black45 or black38 if too strong

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: topGap),

            // --- Combined logo + title image ---
            Center(
              child: Image.asset(
                'assets/images/ui/wordkimchi_logo.png',
                width: 260,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: headerToButtonsGap),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Audio button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: fadedColor, width: 2),
                          foregroundColor: fadedColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'SourceSerif4',
                            fontWeight: FontWeight.w600,
                            color: fadedColor,
                          ),
                        ),
                        onPressed: onAudioTap,
                        child: Text(I18n.t("audio", lang: languageCode)),
                      ),
                    ),

                    SizedBox(height: betweenButtonsGap),

                    // Language button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: fadedColor, width: 2),
                          foregroundColor: fadedColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'SourceSerif4',
                            fontWeight: FontWeight.w600,
                            color: fadedColor,
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
    );
  }
}
