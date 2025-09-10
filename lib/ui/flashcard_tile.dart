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
    required this.onCardSelected,   // now required
    this.languageCode = 'en',
  });

  Flashcard get card => cards[index];

  // --- Typography to match detail screen ---
  static const TextStyle _headwordStyle = TextStyle(
    fontFamily: 'EBGaramond',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.15,
  );

  static const TextStyle _phoneticStyle = TextStyle(
    fontFamily: 'CharisSIL',
    fontSize: 18,
    height: 1.2,
    color: Colors.black54,
  );

  static const TextStyle _meaningStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 21,
    height: 1.3,
    color: Colors.black87,
  );

  /// Builds a playable asset path for Korean audio.
  String _wordPath(String? filename) {
    if (filename == null) return '';
    final f = filename.trim();
    if (f.isEmpty) return '';
    if (f.contains('/')) return f; // already a path
    return 'assets/audio/korean/$f';
  }

  Future<void> _playWord(BuildContext context) async {
    final path = _wordPath(card.audioScottish);
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

  @override
  Widget build(BuildContext context) {
    final localized = card.meaningFor(languageCode);
    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasMeaning = localized.trim().isNotEmpty;

    return InkWell(
      onTap: () => onCardSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 🔑 vertical centering
          children: [
            // --- English meaning on the left ---
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

            // --- Korean + phonetic stacked, right aligned ---
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  card.scottish,
                  style: _headwordStyle,
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

            // --- Speaker on the far right ---
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.black38),
              tooltip: 'Play word',
              onPressed: () => _playWord(context),
            ),
          ],
        ),
      ),
    );
  }
}
