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
  static const double autoplayBlockHeight = 100.0;
  static const double autoplaySwitchBoxWidth = 80.0;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: topGap),

            // --- Logo ---
            Center(
              child: Image.asset(
                'assets/images/ui/somtam_logo.png',
                width: 260,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 8),

            // --- Beta label ---
            const Center(
              child: Text(
                'beta 1.0',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                  color: Color(0xFF003478),
                  letterSpacing: 0.6,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 👉 Start button moved up here
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003478),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAudioTap,
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontFamily: 'SourceSerif4',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // --- Automatic Audio toggle ---
            SizedBox(
              height: autoplayBlockHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Automatic Audio',
                          style: _labelStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
          ],
        ),
      ),
    );
  }
}
