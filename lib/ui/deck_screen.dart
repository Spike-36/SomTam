import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';
import 'flashcard_tile.dart';

class DeckScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final AudioService audio;
  final void Function(int)? onCardSelected;
  final String languageCode; // 👈 add this

  const DeckScreen({
    super.key,
    required this.cards,
    required this.audio,
    this.onCardSelected,
    this.languageCode = 'en',
  });

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = widget.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.t('list', lang: lang)),
      ),
      body: widget.cards.isEmpty
          ? Center(child: Text(I18n.t('loading', lang: lang)))
          : ListView.separated(
              itemCount: widget.cards.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => FlashcardTile(
                cards: widget.cards,      // pass the whole list
                index: i,                 // pass the index
                audio: widget.audio,
                onCardSelected: widget.onCardSelected,
                languageCode: lang,       // 👈 forward for localized previews (if your tile uses it)
              ),
            ),
    );
  }
}
