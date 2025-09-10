import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import 'flashcard_tile.dart';

enum _DeckViewMode { typeIndex, listView }

class DeckScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final AudioService audio;
  final String languageCode;
  final void Function(int)? onCardSelected;

  final int resetTicker; // used to reset view when parent changes

  const DeckScreen({
    super.key,
    required this.cards,
    required this.audio,
    this.languageCode = 'en',
    this.onCardSelected,
    this.resetTicker = 0,
  });

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final ScrollController _scroll = ScrollController();

  _DeckViewMode _mode = _DeckViewMode.typeIndex;
  String? _currentTypeInList;

  @override
  void didUpdateWidget(covariant DeckScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // when the tick changes, jump back to the index screen
    if (oldWidget.resetTicker != widget.resetTicker) {
      setState(() {
        _mode = _DeckViewMode.typeIndex;
        _currentTypeInList = null;
      });
      if (_scroll.hasClients) {
        _scroll.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _DeckViewMode.typeIndex) {
      // --- Show the type index (case-insensitive sort) ---
      final types = widget.cards
          .map((c) => (c.type ?? '').trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      return ListView.separated(
        itemCount: types.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final t = types[i];
          return ListTile(
            title: Text(
              t.isNotEmpty ? (t[0].toUpperCase() + t.substring(1)) : t,
              style: const TextStyle(
                fontFamily: 'SourceSerif4',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              setState(() {
                _mode = _DeckViewMode.listView;
                _currentTypeInList = t;
              });
            },
          );
        },
      );
    }

    // --- Show the list of words for the selected type (type-aware sort) ---
    final selectedType = (_currentTypeInList ?? '').trim().toLowerCase();

    final filtered = widget.cards
        .where((c) => (c.type ?? '').trim().toLowerCase() == selectedType)
        .toList(growable: false);

    // Make a sortable copy
    final sorted = [...filtered];

    final isNumbers = selectedType == 'numbers' || selectedType == 'number';

    if (isNumbers) {
      sorted.sort((a, b) => _asInt(a.value).compareTo(_asInt(b.value)));
    } else {
      sorted.sort((a, b) => _display(a).compareTo(_display(b)));
    }

    return ListView.builder(
      controller: _scroll,
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        return FlashcardTile(
          cards: sorted,
          index: i,
          audio: widget.audio,
          languageCode: widget.languageCode,
          onCardSelected: (_) {
            final tappedCard = sorted[i];
            final globalIndex =
                widget.cards.indexWhere((c) => c.id == tappedCard.id);
            if (globalIndex != -1) {
              widget.onCardSelected?.call(globalIndex);
            }
          },
        );
      },
    );
  }

  // ---- Helpers ----

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v?.toString() ?? '';
    return int.tryParse(s) ?? 1 << 30; // push unknowns to end
  }

  String _display(Flashcard c) {
    // 🔑 Always sort alphabetically by English (meaning)
    return (c.meaning ?? '').toLowerCase().trim();
  }
}
