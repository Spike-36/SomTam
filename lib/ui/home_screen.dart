import 'package:flutter/material.dart';
import '../i18n/i18n.dart';
import 'widgets/app_background.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final double overlay;
  final String imageAsset;

  const HomeScreen({
    super.key,
    required this.languageCode,
    this.overlay = 0.75, // default stronger overlay
    this.imageAsset = 'assets/images/brawHome.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        imageAsset: imageAsset,
        blueOverlayOpacity: overlay,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Braw logo
            Image.asset(
              'assets/images/brawHeading.png',
              width: 300,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),

            // Subtitle: "ScotSpeak" via i18n
            Text(
              I18n.t("scotspeak", lang: languageCode),
              style: const TextStyle(
                fontSize: 30,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFBD59), // same yellow as Braw2
                shadows: [Shadow(blurRadius: 6, offset: Offset(0, 1))],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Optional home text (can remove if not wanted)
            Text(
              '🏠 ${I18n.t("home", lang: languageCode)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 6, offset: Offset(0, 1))],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
