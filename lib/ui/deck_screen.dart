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
      setState(() => _mode = _DeckViewMode.typeIndex);
    }
    if (oldWidget.cards != widget.cards) {
      _rebuildRows();
    }
  }

  void _rebuildRows() {
    final rows = <_Row>[];
    final sectionStarts = <String, int>{};
    String? lastType;

    for (final c in widget.cards) {
      final type = c.type.trim();
      if (type.isNotEmpty && type != lastType) {
        sectionStarts[type] = rows.length;
        rows.add(_Row.header(type));
        lastType = type;
      }
      rows.add(_Row.item(c));
    }

    setState(() {
      _rows = rows;
      _sectionStarts = sectionStarts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TYPE INDEX VIEW
    if (_mode == _DeckViewMode.typeIndex) {
      final orderedTypes = <String>[];
      for (final c in widget.cards) {
        final t = c.type.trim();
        if (t.isNotEmpty && !orderedTypes.contains(t)) orderedTypes.add(t);
      }

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
                                duration: const Duration(milliseconds: 450),
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
              onPressed: () =>
                  setState(() => _mode = _DeckViewMode.typeIndex),
            ),
            // 👉 Flatten header + list painting to remove seam
            Expanded(
              child: Container(
                color: Colors.white,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final row = _rows[i];

                    // --- HEADER ROWS ---
                    if (row.isHeader) {
                      final title = row.header ?? '';
                      return Container(
                        width: double.infinity,
                        color: const Color(0xFFFF6B3D),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 14, 16, 10),
                          child: Text(
                            title[0].toUpperCase() + title.substring(1),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      );
                    }

                    // --- CARD ROWS ---
                    final card = row.card;
                    if (card == null) return const SizedBox.shrink();

                    return Container(
                      color: Colors.white,
                      child: FlashcardTile(
                        cards: [card],
                        index: 0,
                        audio: widget.audio,
                        languageCode: widget.languageCode,
                        onCardSelected: (_) {
                          final globalIndex = widget.cards
                              .indexWhere((c) => c.id == card.id);
                          if (globalIndex != -1) {
                            widget.onCardSelected?.call(globalIndex);
                          }
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
