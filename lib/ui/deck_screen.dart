import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import 'flashcard_tile.dart';

enum _DeckViewMode { typeIndex, listView }

class DeckScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final AudioService audio;
  final String languageCode;
  final void Function(int)? onCardSelected;
  final int resetTicker;

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

// Simple flattened row model: header or item
class _Row {
  final String? header;
  final Flashcard? card;
  const _Row.header(this.header) : card = null;
  const _Row.item(this.card) : header = null;
  bool get isHeader => header != null;
}

class _DeckScreenState extends State<DeckScreen> {
  _DeckViewMode _mode = _DeckViewMode.typeIndex;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  List<_Row> _rows = const [];
  Map<String, int> _sectionStarts = const {};

  @override
  void didUpdateWidget(covariant DeckScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTicker != widget.resetTicker) {
      setState(() => _mode = _DeckViewMode.typeIndex);
    }
    if (oldWidget.cards != widget.cards) {
      _rebuildRows();
    }
  }

  @override
  void initState() {
    super.initState();
    _rebuildRows();
  }

  List<String> _sortedTypes(List<Flashcard> cards) {
    final types = cards
        .map((c) => (c.type).trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return types;
  }

  String _display(Flashcard c) => c.meaning.toLowerCase().trim();

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v?.toString() ?? '';
    return int.tryParse(s) ?? 1 << 30;
  }

  Map<String, List<Flashcard>> _grouped() {
    final byType = <String, List<Flashcard>>{};
    for (final c in widget.cards) {
      final t = c.type.trim();
      if (t.isEmpty) continue;
      byType.putIfAbsent(t, () => []).add(c);
    }

    for (final entry in byType.entries) {
      final lower = entry.key.toLowerCase();
      if (lower == 'numbers' || lower == 'number') {
        entry.value.sort((a, b) => _asInt(a.value).compareTo(_asInt(b.value)));
      } else {
        entry.value.sort((a, b) => _display(a).compareTo(_display(b)));
      }
    }
    return byType;
  }

  void _rebuildRows() {
    final grouped = _grouped();
    final typeOrder = _sortedTypes(widget.cards);
    final rows = <_Row>[];
    final sectionStarts = <String, int>{};

    for (final type in typeOrder) {
      sectionStarts[type] = rows.length;
      rows.add(_Row.header(type));
      final cardsOfType = grouped[type] ?? const <Flashcard>[];
      for (final c in cardsOfType) {
        rows.add(_Row.item(c));
      }
      rows.add(const _Row.header('')); // spacer row
    }

    setState(() {
      _rows = rows;
      _sectionStarts = sectionStarts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _DeckViewMode.typeIndex) {
      final types = _sortedTypes(widget.cards);
      return SafeArea(
        top: true,
        bottom: false,
        child: ListView.separated(
          itemCount: types.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final t = types[i];
            return ListTile(
              title: Text(
                t.isNotEmpty ? (t[0].toUpperCase() + t.substring(1)) : t,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                if (_rows.isEmpty || _sectionStarts.isEmpty) {
                  _rebuildRows();
                }
                final targetIndex = _sectionStarts[t] ?? 0;
                setState(() => _mode = _DeckViewMode.listView);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_itemScrollController.isAttached) {
                    _itemScrollController.scrollTo(
                      index: targetIndex,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                });
              },
            );
          },
        ),
      );
    }

    // 👉 List view (dividers removed)
    return SafeArea(
      top: true,
      bottom: false,
      child: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: _rows.length,
        itemBuilder: (context, i) {
          final row = _rows[i];

          if (row.isHeader) {
            final title = row.header ?? '';
            if (title.isEmpty) return const SizedBox(height: 8);
            return Container(
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Text(
                title[0].toUpperCase() + title.substring(1),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            );
          }

          final card = row.card;
          if (card == null) return const SizedBox.shrink();

          // 👉 render card (divider removed)
          return FlashcardTile(
            cards: const [],
            index: 0,
            audio: widget.audio,
            languageCode: widget.languageCode,
            onCardSelected: (_) {
              final globalIndex = widget.cards.indexWhere((c) => c.id == card.id);
              if (globalIndex != -1) {
                widget.onCardSelected?.call(globalIndex);
              }
            },
          )._withCard(card);
        },
      ),
    );
  }
}

// --- Helper ---
extension _FlashcardTileWithCard on FlashcardTile {
  Widget _withCard(Flashcard card) {
    return FlashcardTile(
      cards: [card],
      index: 0,
      audio: audio,
      onCardSelected: onCardSelected,
      languageCode: languageCode,
    );
  }
}
