import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';

// ==================== Styles ====================
const double kHeadwordSize = 42; // 🔄 reduced from 48
const double kChevronButtonSize = 56.0;
const double kChevronIconSize = 32.0;
const double kChevronOuterPad = 12.0;
const Color kSpeakerColor = Colors.black38;
const double kSwipeVelocityThreshold = 300.0;

// 👉 Manual fine-tune constants for EN button position & size
const double kENButtonOffset = 16.0;
const double kENButtonSize = 42.0; // 🔄 smaller circle

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

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  int? _lastAutoPlayedIndex;
  bool _revealed = false;
  bool _showWord = false;
  bool _showSpeaker = false;
  bool _showPhonetic = false;
  bool _busy = false;
  bool _showEnglish = false; // 🔄 toggles English/meaning visibility

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

  Future<void> _safePlay(BuildContext context, String path,
      {bool interrupt = true, String channel = 'a'}) async {
    if (path.isEmpty) return;
    try {
      await widget.audio.playAsset(path, interrupt: interrupt, channel: channel);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Audio not available: $path')));
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
    if (oldWidget.index != widget.index) {
      _lastAutoPlayedIndex = null;
      _revealed = false;
      _showWord = _showSpeaker = _showPhonetic = false;
      _busy = false;
      _showEnglish = false; // reset between cards
    }
    if (oldWidget.index != widget.index ||
        oldWidget.autoAudio != widget.autoAudio ||
        oldWidget.languageCode != widget.languageCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayIfNeeded());
    }
  }

  void _goTo(int newIndex) {
    if (_busy) return;
    final n = widget.cards.length;
    if (n == 0) return;
    final wrapped = (newIndex % n + n) % n;
    widget.onIndexChange?.call(wrapped);
  }

  Future<void> _onRightButtonPressed() async {
    if (_busy) return;

    if (!_revealed) {
      setState(() => _busy = true);
      final path = _wordPath(card.audioThai);

      if (path.isEmpty) {
        setState(() {
          _revealed = true;
          _showWord = _showSpeaker = _showPhonetic = true;
          _busy = false;
        });
        return;
      }

      try {
        widget.audio.playAsset(path, interrupt: false, channel: 'b');
        await Future.delayed(const Duration(milliseconds: 2500));
        await _safePlay(context, path, interrupt: true, channel: 'a');

        setState(() => _revealed = true);
        Future.delayed(const Duration(milliseconds: 0), () {
          if (mounted) setState(() => _showWord = true);
        });
        Future.delayed(const Duration(milliseconds: 850), () {
          if (mounted) setState(() => _showSpeaker = true);
        });
        Future.delayed(const Duration(milliseconds: 1150), () {
          if (mounted) setState(() => _showPhonetic = true);
        });
        await Future.delayed(const Duration(milliseconds: 1600));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    } else {
      _goTo(widget.index + 1);
    }
  }

  Widget _floatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required Color iconColor,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: kChevronButtonSize,
          height: kChevronButtonSize,
          child: Icon(icon, size: kChevronIconSize, color: iconColor),
        ),
      ),
    );
  }

  bool _containsThai(String text) =>
      RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.45;
    final headword = (card.thai ?? '').trim();
    final headwordFont = _containsThai(headword) ? 'Sarabun' : 'EBGaramond';
    final englishWord = (card.meaning ?? '').trim();

    final imageStack = Stack(
      fit: StackFit.expand,
      children: [
        (card.image ?? '').trim().isEmpty
            ? Container(color: Colors.black12)
            : Image.asset(_imagePath(card.image), fit: BoxFit.cover),

        // 👉 English word visible only when EN button pressed
        if (_showEnglish && englishWord.isNotEmpty)
          Positioned(
            bottom: kENButtonOffset + 4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  englishWord,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // 🔄 centered text
                ),
              ),
            ),
          ),

        // 🔄 EN button (only visible until pressed)
        if (!_showEnglish)
          Positioned(
            left: kENButtonOffset,
            bottom: kENButtonOffset,
            child: GestureDetector(
              onTap: () => setState(() => _showEnglish = true),
              child: Container(
                width: kENButtonSize,
                height: kENButtonSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'EN',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 15, // 🔄 slightly smaller
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final scroll = CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: imageHeight,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(background: imageStack),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                if (_revealed)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: _showWord ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: GestureDetector(
                          onTap: () =>
                              _safePlay(context, _wordPath(card.audioThai)),
                          child: Center(
                            child: Text(
                              headword,
                              style: TextStyle(
                                fontFamily: headwordFont,
                                fontWeight: FontWeight.w600,
                                fontSize: kHeadwordSize, // 🔄 reduced Thai font
                                height: 1.08,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedOpacity(
                        opacity: _showSpeaker ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: Material(
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
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.volume_up,
                                  color: kSpeakerColor, size: 36),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedOpacity(
                        opacity: _showPhonetic ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: Center(
                          child: Text(
                            card.phonetic ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'EBGaramond',
                              fontSize: 28,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
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
        if (_busy) return;
        final v = details.primaryVelocity ?? 0;
        if (v.abs() < kSwipeVelocityThreshold) return;
        if (v < 0) _goTo(widget.index + 1);
        else _goTo(widget.index - 1);
      },
      child: scroll,
    );

    final IconData rightIcon =
        _revealed ? Icons.chevron_right : Icons.volume_up;
    final Color rightColor = _revealed ? Colors.white : Colors.green;
    final Color rightIconColor = _revealed ? Colors.black87 : Colors.white;

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
                icon: Icons.chevron_left,
                onPressed: () => _goTo(widget.index - 1),
                color: Colors.white,
                iconColor: Colors.black87,
              ),
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
                icon: rightIcon,
                onPressed: _onRightButtonPressed,
                color: rightColor,
                iconColor: rightIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
