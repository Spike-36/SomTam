// lib/ui/deck_screen.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';
import 'flashcard_tile.dart';
import 'flashcard_detail_screen.dart'; // ← add this

class DeckScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final AudioService audio;
  final void Function(int)? onCardSelected;
  final String languageCode;

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

    // TEMP: prove what we're passing down
    assert(() {
      // ignore: avoid_print
      print('[DeckScreen] lang=$lang cards=${widget.cards.length}');
      return true;
    }());

    return Scaffold(
      // 👇 removed AppBar
      body: widget.cards.isEmpty
          ? Center(child: Text(I18n.t('loading', lang: lang)))
          : ListView.separated(
              itemCount: widget.cards.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => FlashcardTile(
                cards: widget.cards,
                index: i,
                audio: widget.audio,
                languageCode: lang, // ← selected language shown in list
                // On tap, push detail and pass the SAME language through
                onCardSelected: widget.onCardSelected ??
                    (idx) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FlashcardDetailScreen(
                            cards: widget.cards,
                            index: idx,
                            audio: widget.audio,
                            languageCode: lang, // ← critical: keep parity
                          ),
                        ),
                      );
                    },
              ),
            ),
    );
  }
}
