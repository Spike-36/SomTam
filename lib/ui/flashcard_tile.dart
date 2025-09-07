// lib/ui/flashcard_tile.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import 'flashcard_detail_screen.dart'; // fallback navigation target

class FlashcardTile extends StatelessWidget {
  final List<Flashcard> cards;
  final int index;
  final AudioService audio;
  final void Function(int)? onCardSelected;
  final String languageCode; // 'en', 'fr', 'de', etc.

  const FlashcardTile({
    super.key,
    required this.cards,
    required this.index,
    required this.audio,
    this.onCardSelected,
    this.languageCode = 'en',
  });

  Flashcard get card => cards[index];

  // --- Typography to match detail screen ---
  static const TextStyle _headwordStyle = TextStyle(
    fontFamily: 'EBGaramond',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 22,
    height: 1.15,
  );

  static const TextStyle _phoneticStyle = TextStyle(
    fontFamily: 'CharisSIL',
    fontSize: 16,
    height: 1.2,
    color: Colors.black54,
  );

  static const TextStyle _meaningStyle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 16,
    height: 1.3,
    color: Colors.black87,
  );

  String _wordPath(String filename) {
    if (filename.trim().isEmpty) return '';
    if (filename.contains('/')) return filename;
    return 'assets/audio/scottish/$filename';
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(card.scottish, style: _headwordStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPhonetic)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(card.phonetic, style: _phoneticStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          if (hasMeaning)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(localized, style: _meaningStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          if (!hasMeaning)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('—', style: _meaningStyle),
            ),
        ],
      ),
   trailing: IconButton(
  icon: const Icon(
    Icons.volume_up,
    color: Colors.black38, // faded, less "poppy"
  ),
  tooltip: 'Play word',
  onPressed: () => _playWord(context),
),

      onTap: () {
        if (onCardSelected != null) {
          onCardSelected!(index);
        } else {
          // Fallback: open detail and pass languageCode through
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FlashcardDetailScreen(
                cards: cards,
                index: index,
                audio: audio,
                languageCode: languageCode,
              ),
            ),
          );
        }
      },
    );
  }
}
