import 'package:flutter/material.dart';
import '../I18n/i18n.dart';

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLanguageTap;

  final VoidCallback onStart;

  final bool autoAudio;
  final ValueChanged<bool> onAutoAudioChanged;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onStart,
    required this.autoAudio,
    required this.onAutoAudioChanged,
  });

  static const double topGap = 25;
  static const double headingGap = 40;

  static const double startButtonBottomSpacing = 40;
  static const double autoAudioBottomSpacing = 40;

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

            Center(
              child: Image.asset(
                'assets/images/ui/yumWordsLogo.png',
                width: 375,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: headingGap),

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

            Center(
              child: Image.asset(
                'assets/images/ui/thaiFlag.png',
                width: 80,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 14),

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

            // ============================================================
            // FIXED VERSION — identical spacing, correct hitboxes
            // ============================================================
            Padding(
              padding: const EdgeInsets.only(bottom: 50), // replaces outer Transform
              child: Column(
                children: [

                  // ======================================================
                  // Auto-Audio block (moved up additional 50px)
                  // ======================================================
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50), // replaces inner Transform
                    child: Column(
                      children: [
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
                                  activeTrackColor:
                                      const Color(0xFF7CC576).withOpacity(0.5),
                                  inactiveThumbColor: const Color(0xFFFF6B3D),
                                  inactiveTrackColor:
                                      const Color(0xFFFF6B3D).withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          '(Turn on to enable audio while browsing.)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: autoAudioBottomSpacing),
                      ],
                    ),
                  ),

                  // ======================================================
                  // START BUTTON
                  // ======================================================
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CC576),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 27,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onStart,
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: startButtonBottomSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
