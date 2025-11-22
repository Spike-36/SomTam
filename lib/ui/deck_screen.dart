import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import 'flashcard_tile.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'widgets/back_button_common.dart';

enum _DeckViewMode { typeIndex, listView }

class DeckScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final AudioService audio;
  final String languageCode;
  final void Function(int)? onCardSelected;
  final int resetTicker;

  // 👉 NEW: the category label we show in the coral header
  final String categoryLabel;

  const DeckScreen({
    super.key,
    required this.cards,
    required this.audio,
    required this.categoryLabel,
    this.languageCode = 'en',
    this.onCardSelected,
    this.resetTicker = 0,
  });

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _Row {
  final String? header;
  final Flashcard? card;
  const _Row.header(this.header) : card = null;
  const _Row.item(this.card) : header = null;
  bool get isHeader => header != null;
}

class _DeckScreenState extends State<DeckScreen> {
  _DeckViewMode _mode = _DeckViewMode.listView; // 👉 start directly in list view

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<_Row> _rows = const [];
  Map<String, int> _sectionStarts = const {};

  @override
  void initState() {
    super.initState();
    _rebuildRows();
  }

  @override
  void didUpdateWidget(covariant DeckScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTicker != widget.resetTicker) {
      // still honour the reset if you ever need it again
      setState(() => _mode = _DeckViewMode.listView);
    }
    if (oldWidget.cards != widget.cards ||
        oldWidget.categoryLabel != widget.categoryLabel) {
      _rebuildRows();
    }
  }

  void _rebuildRows() {
    final rows = <_Row>[];
    final sectionStarts = <String, int>{};

    final type = widget.categoryLabel.trim();

    if (type.isNotEmpty) {
      sectionStarts[type] = rows.length;
      rows.add(_Row.header(type));
    }

    for (final c in widget.cards) {
      rows.add(_Row.item(c));
    }

    setState(() {
      _rows = rows;
      _sectionStarts = sectionStarts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TYPE INDEX VIEW (kept, but it's now effectively a single entry)
    if (_mode == _DeckViewMode.typeIndex) {
      final orderedTypes = <String>[];
      final t = widget.categoryLabel.trim();
      if (t.isNotEmpty) orderedTypes.add(t);

      return Container(
        color: Colors.white,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButtonCommon(
                inline: true,
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: orderedTypes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = orderedTypes[i];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(
                          t[0].toUpperCase() + t.substring(1),
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
                                duration:
                                    const Duration(milliseconds: 450),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // CONTINUOUS LIST VIEW
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButtonCommon(
              inline: true,
              onPressed: () => Navigator.pop(context),
            ),

            // 👉 Coral header – ALWAYS the selected category label
            if (_rows.isNotEmpty && _rows.first.isHeader)
              Container(
                width: double.infinity,
                color: const Color(0xFFFF6B3D),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text(
                    widget.categoryLabel[0].toUpperCase() +
                        widget.categoryLabel.substring(1),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

            // 👉 List of cards
            Expanded(
              child: Container(
                color: Colors.white,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final row = _rows[i];

                    // We already render the header above; skip header rows here
                    if (row.isHeader) {
                      return const SizedBox.shrink();
                    }

                    final card = row.card;
                    if (card == null) return const SizedBox.shrink();

                    final localIndex = widget.cards.indexWhere(
                      (c) => c.id == card.id,
                    );
                    final idx = localIndex == -1 ? 0 : localIndex;

                    return Container(
                      color: Colors.white,
                      child: FlashcardTile(
                        cards: widget.cards,
                        index: idx,
                        audio: widget.audio,
                        languageCode: widget.languageCode,
                        onCardSelected: (selectedIndex) {
                          widget.onCardSelected?.call(selectedIndex);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
