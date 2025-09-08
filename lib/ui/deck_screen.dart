// lib/ui/deck_screen.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';
import 'flashcard_tile.dart';
import 'flashcard_detail_screen.dart';

// ---- Sorting toggles (adjust if you prefer) ----
const bool kSortAscending = true;
// If you ever want to sort by the localized meaning instead of the headword,
// flip this to true:
const bool kSortByMeaningForLanguage = false;

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
  int _cmpStrings(String a, String b) {
    final la = a.trim().toLowerCase();
    final lb = b.trim().toLowerCase();
    final c = la.compareTo(lb);
    if (c != 0) return c;
    // tie-breaker keeps sort stable across platforms
    return a.trim().compareTo(b.trim());
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.languageCode;

    // Build a sorted copy so we don't mutate the source list.
    final List<Flashcard> sortedCards = List<Flashcard>.from(widget.cards);
    final keyFor = (Flashcard c) =>
        kSortByMeaningForLanguage ? c.meaningFor(lang) : c.scottish;

    sortedCards.sort((a, b) =>
        _cmpStrings(keyFor(a), keyFor(b)) * (kSortAscending ? 1 : -1));

    // If a parent provided onCardSelected expecting ORIGINAL indices,
    // map each sorted card back to its original index.
    final Map<Flashcard, int> originalIndex = {
      for (int i = 0; i < widget.cards.length; i++) widget.cards[i]: i
    };

    return Scaffold(
      body: sortedCards.isEmpty
          ? Center(child: Text(I18n.t('loading', lang: lang)))
          : ListView.separated(
              itemCount: sortedCards.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => FlashcardTile(
                cards: sortedCards,   // pass the sorted list to the tile
                index: i,             // index within the sorted list
                audio: widget.audio,
                languageCode: lang,
                onCardSelected: widget.onCardSelected ??
                    (idxInSorted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FlashcardDetailScreen(
                            cards: sortedCards,    // keep detail view in sorted order
                            index: idxInSorted,
                            audio: widget.audio,
                            languageCode: lang,
                          ),
                        ),
                      );
                    },
              ),
            ),
    );
  }
}
