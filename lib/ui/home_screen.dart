// lib/ui/home_screen.dart
import 'package:flutter/material.dart';
import '../i18n/i18n.dart';
import 'widgets/app_background.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onAudioTap;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    // If your app shows a bottom nav elsewhere, this keeps content clear of it.
    const double bottomSafePadding = kBottomNavigationBarHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        imageAsset: 'assets/images/brawHome.jpg',
        blueOverlayOpacity: 0.75,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Will only scroll if content > viewport
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/brawHeading.png',
                            width: 300,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Subtitle
                        Center(
                          child: Text(
                            I18n.t("scotspeak", lang: languageCode),
                            style: const TextStyle(
                              fontSize: 27,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFBD59),
                              shadows: [Shadow(blurRadius: 6, offset: Offset(0, 1))],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const Spacer(),

                        // Buttons
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

                                const SizedBox(height: 30),

                                // Language button (wired to same as Audio)
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
                                    onPressed: onAudioTap, // <— changed
                                    child: Text(I18n.labelFor(languageCode)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom breathing room so it doesn't clash with nav bar
                        const SizedBox(height: 40 + bottomSafePadding),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
