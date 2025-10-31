import 'package:flutter/material.dart';
import '../I18n/i18n.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onAudioTap;

  // 🔧 Autoplay props
  final bool autoAudio;
  final ValueChanged<bool> onAutoAudioChanged;

  // 🔧 Layout constants
  static const double topGap = 65;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onAudioTap,
    required this.autoAudio,
    required this.onAutoAudioChanged,
  });

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2A11A), // 🟠 Somtam orange
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: topGap),

            // --- Logo ---
            Center(
              child: Image.asset(
                'assets/images/ui/somtam_logo_new.png',
                width: 260,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            // --- Beta label ---
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Beta Trial - Chiang Mai',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'November 2025',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 65), // 🔄 Lowered Start button by +25px

            // --- Start button (outlined white) ---
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 27,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAudioTap,
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 45), // 🔄 halfway between Start and bottom

            // --- Audio On toggle ---
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 60), // 🔄 tighter, centered
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Audio On',
                    style: _labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: autoAudio,
                      onChanged: onAutoAudioChanged,
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28), // 🔄 gap below Audio On row

            // --- Email label (non-clickable) ---
            const Center(
              child: Text(
                'pete@kumamoto.dev',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
