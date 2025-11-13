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
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // ⚪ White background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: topGap),

            // --- Logo ---
            Center(
              child: Image.asset(
                'assets/images/ui/yumWordsLogo.png',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            // 👉 Thai flag image
            Center(
              child: Image.asset(
                'assets/images/ui/thaiFlag.png',
                width: 100,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 14),

            // --- Heading: Thailand ---
            const Center(
              child: Text(
                'Thailand',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, // Semi-bold
                  fontSize: 32,
                  color: Color(0xFFFF6B3D), // 🟠 bright orange
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // --- Spacer to push controls to bottom ---
            const Spacer(),

            // --- Start button (outlined green) ---
Center(
  child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFF7CC576), width: 2), // 🟢 green border
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
        color: Color(0xFF7CC576), // 🟢 green text
      ),
    ),
  ),
),


            const SizedBox(height: 30),

            // --- Audio On toggle ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Auto-Audio',
                    style: _labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: autoAudio,
                      onChanged: onAutoAudioChanged,
                      activeColor: Colors.black,
                      activeTrackColor: Colors.black54,
                      inactiveThumbColor: Colors.black45,
                      inactiveTrackColor: Colors.black26,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // Gap at bottom
          ],
        ),
      ),
    );
  }
}
