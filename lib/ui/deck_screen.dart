import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final String categoryLabel; // 👉 category header

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
  _DeckViewMode _mode = _DeckViewMode.listView;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<_Row> _rows = const [];
  Map<String, int> _sectionStarts = const {};

  bool _showTapTip = false; // 👉 onboarding banner visible?

  // 👉 DEV RESET FUNCTION — now forces banner ON immediately
  Future<void> _devResetTip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hideDeckTapTip');

    // 👉 Immediately re-show banner without needing a restart
    setState(() {
      _showTapTip = true;
    });
  }

  @override
  void initState() {
    super.initState();

    // 👉 DEV ONLY — uncomment this line to force-reset the banner instantly
    _devResetTip(); // 👉 ALWAYS SHOWS BANNER NOW DURING TESTING

    _rebuildRows();
    _loadTapTipPreference();
  }

  Future<void> _loadTapTipPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final hideTip = prefs.getBool('hideDeckTapTip') ?? false;

    // 🔄 Only show the banner if not hidden AND the dev override isn’t active
    if (!hideTip && mounted) {
      setState(() => _showTapTip = true);
    }
  }

  Future<void> _dismissTapTip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hideDeckTapTip', true);

    if (mounted) {
      setState(() => _showTapTip = false);
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

  Widget _buildTapTipBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFC7A3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tap a word to view the image, pronunciation, and audio.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _dismissTapTip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Don't show again",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF6B3D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/ui/card_preview.png',
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TYPE INDEX VIEW (single header)
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

    // LIST VIEW
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
                      fontWeight: FontWeight.w700),
                  ),
                ),
              ),

            if (_showTapTip) _buildTapTipBanner(),

            Expanded(
              child: Container(
                color: Colors.white,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final row = _rows[i];

                    if (row.isHeader) return const SizedBox.shrink();

                    final card = row.card;
                    if (card == null) return const SizedBox.shrink();

                    final localIndex =
                        widget.cards.indexWhere((c) => c.id == card.id);
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
