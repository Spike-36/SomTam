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
  _DeckViewMode _mode = _DeckViewMode.listView;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<_Row> _rows = const [];
  Map<String, int> _sectionStarts = const {};

  bool _showTapTip = false;

  @override
  void initState() {
    super.initState();
    _rebuildRows();
    _loadTapTipPreference();
  }

  Future<void> _loadTapTipPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final hideTip = prefs.getBool('hideDeckTapTip') ?? false;
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

  // ============================================================
  // BUILD ROWS WITH SUBCATEGORY GROUPING
  // ============================================================
  void _rebuildRows() {
    final rows = <_Row>[];
    final sectionStarts = <String, int>{};

    final mainType = widget.categoryLabel.trim().toLowerCase();

    bool fuzzyMatch(String category, List<String> needles) {
      return needles.any((n) => category.contains(n));
    }

    final isDrinks = fuzzyMatch(mainType, [
      "drink",
      "drinks",
      "drinks & herbs",
    ]);

    final isProteins = fuzzyMatch(mainType, [
      "protein",
      "proteins",
    ]);

    final isHerbs = fuzzyMatch(mainType, [
      "herbs",
      "aromatics",
      "spices",
      "herbs, aromatics & spices",
    ]);

    // Add primary header
    sectionStarts[mainType] = rows.length;
    rows.add(_Row.header(widget.categoryLabel));

    final cards = widget.cards;

    const drinksOrder = [
      "Soft Drinks",
      "Coffee",
      "Tea",
      "Other Hot Drinks",
      "Alcoholic Drinks"
    ];

    const proteinOrder = [
      "Meat",
      "Seafood",
      "Other Proteins",
    ];

    const herbsOrder = [
      "Herbs",
      "Aromatics",
      "Spices",
    ];

    // If no grouping applies → flat list
    if (!isDrinks && !isProteins && !isHerbs) {
      for (final c in cards) {
        rows.add(_Row.item(c));
      }
      setState(() {
        _rows = rows;
        _sectionStarts = sectionStarts;
      });
      return;
    }

    // Build grouped structure
    final Map<String, List<Flashcard>> groups = {};

    for (final c in cards) {
      String? sub;

      if (isDrinks) sub = c.drinksType;
      if (isProteins) sub = c.proteinTypes;
      if (isHerbs) sub = c.hasTypes;

      sub = (sub ?? "").trim();
      if (sub.isEmpty) continue;

      groups.putIfAbsent(sub, () => []);
      groups[sub]!.add(c);
    }

    final List<String> order =
        isDrinks ? drinksOrder : isProteins ? proteinOrder : herbsOrder;

    for (final sub in order) {
      if (!groups.containsKey(sub)) continue;

      rows.add(_Row.header(sub));

      for (final c in groups[sub]!) {
        rows.add(_Row.item(c));
      }
    }

    setState(() {
      _rows = rows;
      _sectionStarts = sectionStarts;
    });
  }

  // ============================================================
  // TIP OVERLAY
  // ============================================================
  Widget _buildTapTipOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.85,
              maxHeight: size.height * 0.8,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEFE3),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 26, color: Colors.black87),
                        const SizedBox(width: 8),
                        const Text(
                          'Tip',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 22, color: Colors.black87),
                          onPressed: _dismissTapTip,
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap a word to view the image,\npronunciation and audio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child:
                              Image.asset('assets/images/ui/card_preview.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _dismissTapTip,
                      child: const Text(
                        "Don't show again",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B3D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: BackButtonCommon(
                      inline: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (_rows.isNotEmpty && _rows.first.isHeader)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFF6B3D),
                    padding:
                        const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Text(
                      widget.categoryLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: _rows.length,
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    itemBuilder: (context, i) {
                      final row = _rows[i];

                      if (row.isHeader &&
                          row.header != widget.categoryLabel) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 22),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                row.header!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Divider(
                              thickness: 1.4,
                              color: Colors.black26,
                            ),
                          ],
                        );
                      }

                      if (row.isHeader) return const SizedBox.shrink();

                      final card = row.card!;
                      final idx =
                          widget.cards.indexWhere((c) => c.id == card.id);

                      return FlashcardTile(
                        cards: widget.cards,
                        index: idx,
                        audio: widget.audio,
                        languageCode: widget.languageCode,
                        onCardSelected:
                            widget.onCardSelected ?? (_) {},
                      );
                    },
                  ),
                ),
              ],
            ),

            if (_showTapTip) _buildTapTipOverlay(context),
          ],
        ),
      ),
    );
  }
}
