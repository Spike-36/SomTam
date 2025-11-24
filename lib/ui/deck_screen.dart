// lib/ui/deck_screen.dart

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

  bool _showTapTip = false; // 👉 onboarding overlay visible?

  // 👉 DEV RESET FUNCTION — now forces banner/overlay ON immediately
  Future<void> _devResetTip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hideDeckTapTip');
    setState(() {
      _showTapTip = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _devResetTip(); // ALWAYS shows banner during testing

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

  // ===================================================================================
  // 👉 UPDATED: Sub-category grouping for Drinks, Proteins, Herbs/Aromatics/Spices
  // ===================================================================================
  void _rebuildRows() {
    final rows = <_Row>[];
    final sectionStarts = <String, int>{};

    final mainType = widget.categoryLabel.trim();

    // Add main category header
    if (mainType.isNotEmpty) {
      sectionStarts[mainType] = rows.length;
      rows.add(_Row.header(mainType));
    }

    final List<Flashcard> cards = widget.cards;

    // Determine if this category has subcategories
    final isDrinks = mainType.toLowerCase() == "drinks" || mainType.toLowerCase() == "drinks & herbs";
    final isProteins = mainType.toLowerCase() == "proteins";
    final isHerbs = mainType.toLowerCase() == "herbs" || mainType.toLowerCase() == "herbs & aromatics";

    // 👉 Sub-category order maps
    const drinksOrder = [
      "Local Drinks",
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

    // If the category does NOT have subcategories, keep existing behaviour
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

    // 👉 Build grouping map dynamically from card fields
    final Map<String, List<Flashcard>> groups = {};

    for (final c in cards) {
      String? sub;

      if (isDrinks) sub = c.drinksType;        // field from JSON
      if (isProteins) sub = c.proteinTypes;
      if (isHerbs) sub = c.hasTypes;

      sub = (sub ?? "").trim();

      if (sub.isEmpty) continue; // ignore missing data

      groups.putIfAbsent(sub, () => []);
      groups[sub]!.add(c);
    }

    // 👉 Ordered grouping output
    List<String> order;

    if (isDrinks) order = drinksOrder;
    else if (isProteins) order = proteinOrder;
    else order = herbsOrder;

    for (final sub in order) {
      if (!groups.containsKey(sub)) continue;

      // 👉 Add subheader
      rows.add(_Row.header(sub));

      // 👉 Add all cards under this subheader
      for (final c in groups[sub]!) {
        rows.add(_Row.item(c));
      }
    }

    setState(() {
      _rows = rows;
      _sectionStarts = sectionStarts;
    });
  }

  // ===================================================================================

  Widget _buildTapTipOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
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
                  mainAxisSize: MainAxisSize.max,
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
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                              'assets/images/ui/card_preview.png'),
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _DeckViewMode.typeIndex) {
      final orderedTypes = <String>[];
      final t = widget.categoryLabel.trim();
      if (t.isNotEmpty) orderedTypes.add(t);

      return Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              BackButtonCommon(inline: true, onPressed: () => Navigator.pop(context)),
              Expanded(
                child: ListView.separated(
                  itemCount: orderedTypes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = orderedTypes[i];
                    return ListTile(
                      title: Text(
                        t[0].toUpperCase() + t.substring(1),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
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
        child: Stack(
          children: [
            Column(
              children: [
                BackButtonCommon(inline: true, onPressed: () => Navigator.pop(context)),

                if (_rows.isNotEmpty && _rows.first.isHeader)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFF6B3D),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Text(
                      widget.categoryLabel[0].toUpperCase() +
                          widget.categoryLabel.substring(1),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    itemCount: _rows.length,
                    itemBuilder: (context, i) {
                      final row = _rows[i];

                      if (row.isHeader) {
                        // 👉 Sub-category header UI
                        if (row.header != widget.categoryLabel) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  row.header!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.black12,
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final card = row.card;
                      if (card == null) return const SizedBox.shrink();

                      final localIndex =
                          widget.cards.indexWhere((c) => c.id == card.id);
                      final idx = localIndex == -1 ? 0 : localIndex;

                      return FlashcardTile(
                        cards: widget.cards,
                        index: idx,
                        audio: widget.audio,
                        languageCode: widget.languageCode,
                        onCardSelected: (selectedIndex) {
                          widget.onCardSelected?.call(selectedIndex);
                        },
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
