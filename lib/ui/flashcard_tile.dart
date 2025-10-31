import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';

class FlashcardTile extends StatelessWidget {
  final List<Flashcard> cards;        // authoritative (sorted) list
  final int index;                    // index within that list
  final AudioService audio;
  final ValueChanged<int> onCardSelected; // parent-controlled navigation
  final String languageCode;          // 'en', 'fr', 'de', etc.

  const FlashcardTile({
    super.key,
    required this.cards,
    required this.index,
    required this.audio,
    required this.onCardSelected,
    this.languageCode = 'en',
  });

  Flashcard get card => cards[index];

  // --- Typography to match detail screen ---

  static const TextStyle _headwordStyle = TextStyle(
    fontFamily: 'EBGaramond',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.15,
    color: Colors.black,
  );

  static const TextStyle _thaiStyle = TextStyle(
    fontFamily: 'Sarabun',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.2,
    color: Colors.black,
  );

  static const TextStyle _phoneticStyle = TextStyle(
    fontFamily: 'CharisSIL',
    fontSize: 16,
    height: 1.2,
    color: Colors.black54,
  );

  static const TextStyle _meaningStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.3,
    color: Colors.black87,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  String _wordPath(String? filename) {
    if (filename == null) return '';
    final f = filename.trim();
    if (f.isEmpty) return '';
    if (f.contains('/')) return f;
    return 'assets/audio/thai/$f';
  }

  Future<void> _playWord(BuildContext context) async {
    final path = _wordPath(card.audioThai);
    if (path.isEmpty) return;
    try {
      await audio.playAsset(path);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio not available: $path')),
      );
    }
  }

  bool _containsThai(String text) {
    return RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final localized = card.meaningFor(languageCode);
    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasMeaning = localized.trim().isNotEmpty;

    final headword = card.scottish.trim();
    final headwordStyle =
        _containsThai(headword) ? _thaiStyle : _headwordStyle;

    return Material(
      type: MaterialType.transparency, // ✅ fixes “No Material widget found”
      child: InkWell(
        onTap: () => onCardSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Meaning on the left ---
              Expanded(
                child: hasMeaning
                    ? Text(
                        localized,
                        style: _meaningStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const Text('—', style: _meaningStyle),
              ),

              // --- Thai / headword + phonetic stacked right ---
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    headword,
                    style: headwordStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasPhonetic)
                    Text(
                      card.phonetic,
                      style: _phoneticStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

              const SizedBox(width: 6),

              // --- Speaker icon ---
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.black38),
                tooltip: 'Play word',
                onPressed: () => _playWord(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
