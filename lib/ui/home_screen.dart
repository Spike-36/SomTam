import 'package:flutter/material.dart';
import '../I18n/i18n.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onAudioTap;

  // 🔧 Autoplay props
  final bool autoAudio;
  final ValueChanged<bool> onAutoAudioChanged;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onAudioTap,
    required this.autoAudio,
    required this.onAutoAudioChanged,
  });

  // --- Layout controls (clean + predictable) ---
  static const double topGap = 25;
  static const double headingGap = 40;

  static const double startButtonBottomSpacing = 40;   // distance between Start and Auto-Audio block
  static const double autoAudioBottomSpacing = 40;      // gap under the Auto-Audio block

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
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: topGap),

            // --- Logo ---
            Center(
              child: Image.asset(
                'assets/images/ui/yumWordsLogo.png',
                width: 375,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: headingGap),

            // --- Thai heading ---
            const Center(
              child: Text(
                'ประเทศไทย',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: Color(0xFFFF6B3D),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Thai flag ---
            Center(
              child: Image.asset(
                'assets/images/ui/thaiFlag.png',
                width: 80,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 14),

            // --- English heading ---
            const Center(
              child: Text(
                'Thailand',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: Color(0xFFFF6B3D),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const Spacer(),

            // --- Start button ---
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7CC576), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 27),
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
                    color: Color(0xFF7CC576),
                  ),
                ),
              ),
            ),

            const SizedBox(height: startButtonBottomSpacing),

            // --- Auto-Audio toggle block ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    autoAudio ? 'Auto-Audio On' : 'Auto-Audio Off',
                    style: _labelStyle.copyWith(
                      color: autoAudio
                          ? const Color(0xFF7CC576)
                          : const Color(0xFFFF6B3D),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: autoAudio,
                      onChanged: onAutoAudioChanged,
                      activeColor: const Color(0xFF7CC576),
                      activeTrackColor: const Color(0xFF7CC576).withOpacity(0.5),
                      inactiveThumbColor: const Color(0xFFFF6B3D),
                      inactiveTrackColor: const Color(0xFFFF6B3D).withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: autoAudioBottomSpacing),
          ],
        ),
      ),
    );
  }
}
