// lib/ui/flashcard_tile.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';

class FlashcardTile extends StatelessWidget {
  final List<Flashcard> cards;
  final int index;
  final AudioService audio;
  final void Function(int)? onCardSelected;
  final String languageCode; // 👈 add this

  const FlashcardTile({
    super.key,
    required this.cards,
    required this.index,
    required this.audio,
    this.onCardSelected,
    this.languageCode = 'en',
  });

  Flashcard get card => cards[index];

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
    final meaning = card.meaningFor(languageCode); // 👈 localized

    return ListTile(
      title: Text(card.scottish),
      subtitle: Text(meaning.isEmpty ? '—' : meaning),
      trailing: IconButton(
        icon: const Icon(Icons.volume_up),
        tooltip: 'Play word',
        onPressed: () => _playWord(context),
      ),
      onTap: () {
        if (onCardSelected != null) {
          onCardSelected!(index);
        } else {
          // ...fallback push detail if you like
        }
      },
    );
  }
}
