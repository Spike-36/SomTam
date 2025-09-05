import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../ui/flashcard_detail_screen.dart';

class FlashcardTile extends StatelessWidget {
  final List<Flashcard> cards;
  final int index;
  final AudioService audio;
  final void Function(int)? onCardSelected; // ✅ new callback

  const FlashcardTile({
    super.key,
    required this.cards,
    required this.index,
    required this.audio,
    this.onCardSelected,
  });

  Flashcard get card => cards[index];

  String _wordPath(String filename) {
    if (filename.trim().isEmpty) return '';
    if (filename.contains('/')) return filename; // already a full path
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
    return ListTile(
      title: Text(card.scottish),
      subtitle: Text(card.meaning.isEmpty ? '—' : card.meaning),
      trailing: IconButton(
        icon: const Icon(Icons.volume_up),
        tooltip: 'Play word',
        onPressed: () => _playWord(context),
      ),
      onTap: () {
        if (onCardSelected != null) {
          // ✅ Let MainScreen handle switching to Word tab
          onCardSelected!(index);
        } else {
          // fallback: push detail screen directly
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FlashcardDetailScreen(
                cards: cards,
                index: index,
                audio: audio,
                autoAudio: false, // ✅ must supply required param
              ),
            ),
          );
        }
      },
    );
  }
}
