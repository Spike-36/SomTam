import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';

class FlashcardDetailScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final int index;
  final AudioService audio;
  final ValueChanged<int>? onIndexChange;
  final bool autoAudio;
  final String languageCode;

  const FlashcardDetailScreen({
    super.key,
    required this.cards,
    required this.index,
    required this.audio,
    this.onIndexChange,
    this.autoAudio = false,
    this.languageCode = 'en',
  });

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

// ===================== Styles ======================
const double kHeadwordSize = 48;
const double kPhoneticSize = 26;
const double kMeaningSize = 26;

const double kChevronButtonSize = 56.0;
const double kChevronIconSize = 32.0;
const double kChevronOuterPad = 12.0;

const Color kMeaningColor = Colors.black;
const Color kSpeakerColor = Colors.black38;

// Swipe tuning
const double kSwipeVelocityThreshold = 300.0;

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  int? _lastAutoPlayedIndex;
  Flashcard get card => widget.cards[widget.index];

  String _wordPath(String? filename) {
    final f = (filename ?? '').trim();
    if (f.isEmpty) return '';
    if (f.contains('/')) return f;
    return 'assets/audio/thai/$f';
  }

  String _imagePath(String? filename) {
    final f = (filename ?? '').trim();
    if (f.isEmpty) return '';
    if (f.contains('/')) return f;
    return 'assets/images/words/$f';
  }

  Future<void> _safePlay(BuildContext context, String path) async {
    if (path.isEmpty) return;
    try {
      await widget.audio.playAsset(path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio not available: $path')),
      );
    }
  }

  Future<void> _autoPlayIfNeeded() async {
    if (!widget.autoAudio) return;
    if (_lastAutoPlayedIndex == widget.index) return;
    final path = _wordPath(card.audioThai);
    if (path.isEmpty) return;
    _lastAutoPlayedIndex = widget.index;
    await _safePlay(context, path);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayIfNeeded());
  }

  @override
  void didUpdateWidget(covariant FlashcardDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.autoAudio != widget.autoAudio ||
        oldWidget.languageCode != widget.languageCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayIfNeeded());
    }
  }

  void _goTo(int newIndex) {
    final n = widget.cards.length;
    if (n == 0) return;
    final wrapped = (newIndex % n + n) % n;
    widget.onIndexChange?.call(wrapped);
  }

  Widget _floatingButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: kChevronButtonSize,
          height: kChevronButtonSize,
          child: Icon(icon, size: kChevronIconSize),
        ),
      ),
    );
  }

  bool _containsThai(String text) {
    return RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.languageCode;
    final displayMeaning = card.meaningFor(lang);
    final hasPhonetic = (card.phonetic ?? '').trim().isNotEmpty;

    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.45;
    final headword = (card.thai ?? '').trim();
    final headwordFont = _containsThai(headword) ? 'Sarabun' : 'EBGaramond';

    final scroll = CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: imageHeight,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            background: ((card.image ?? '').trim().isEmpty)
                ? Container(color: Colors.black12)
                : Image.asset(_imagePath(card.image), fit: BoxFit.cover),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 👉 Combined layout for Thai + Speaker + Phonetic
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _safePlay(context, _wordPath(card.audioThai)),
                      child: Center(
                        child: Text(
                          headword,
                          style: TextStyle(
                            fontFamily: headwordFont,
                            fontWeight: FontWeight.w600,
                            fontSize: kHeadwordSize,
                            height: 1.08,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 👉 Subtle animated ripple on icon only
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () =>
                            _safePlay(context, _wordPath(card.audioThai)),
                        splashColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                        highlightColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.06),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.volume_up,
                            color: kSpeakerColor,
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    if (hasPhonetic)
                      GestureDetector(
                        onTap: () =>
                            _safePlay(context, _wordPath(card.audioThai)),
                        child: Text(
                          '[${card.phonetic}]',
                          style: TextStyle(
                            fontFamily: 'CharisSIL',
                            fontSize: kPhoneticSize,
                            fontStyle: FontStyle.italic,
                            height: 1.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  displayMeaning.isEmpty ? '—' : displayMeaning,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: kMeaningSize,
                    height: 1.35,
                    color: kMeaningColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ],
    );

    final swipeable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v.abs() < kSwipeVelocityThreshold) return;
        if (v < 0) {
          _goTo(widget.index + 1);
        } else {
          _goTo(widget.index - 1);
        }
      },
      child: scroll,
    );

    return Scaffold(
      body: Stack(
        children: [
          swipeable,
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                bottom:
                    kChevronOuterPad + MediaQuery.of(context).padding.bottom,
              ),
              child: _floatingButton(
                  Icons.chevron_left, () => _goTo(widget.index - 1)),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 8,
                bottom:
                    kChevronOuterPad + MediaQuery.of(context).padding.bottom,
              ),
              child: _floatingButton(
                  Icons.chevron_right, () => _goTo(widget.index + 1)),
            ),
          ),
        ],
      ),
    );
  }
}
