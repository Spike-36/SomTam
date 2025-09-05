import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import 'flashcard_tile.dart';

class DeckScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final AudioService audio;
  final void Function(int)? onCardSelected; // ✅ optional callback

  const DeckScreen({
    super.key,
    required this.cards,
    required this.audio,
    this.onCardSelected,
  });

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Braw')),
      body: ListView.separated(
        itemCount: widget.cards.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => FlashcardTile(
          cards: widget.cards,   // ✅ pass the whole list
          index: i,              // ✅ pass the index
          audio: widget.audio,
          onCardSelected: widget.onCardSelected, // ✅ forward callback
        ),
      ),
    );
  }
}
