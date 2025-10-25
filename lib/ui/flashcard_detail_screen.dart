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

// ==================== Styles ====================
const double kHeadwordSize = 48;
const double kChevronButtonSize = 56.0;
const double kChevronIconSize = 32.0;
const double kChevronOuterPad = 12.0;
const Color kSpeakerColor = Colors.black38;
const double kSwipeVelocityThreshold = 300.0;

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  int? _lastAutoPlayedIndex;
  bool _revealed = false;

  bool _showWord = false;
  bool _showSpeaker = false;
  bool _showPhonetic = false;
  bool _busy = false;

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

  Future<void> _safePlay(BuildContext context, String path, {bool interrupt = true, String channel = 'a'}) async {
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
      _showWord = _showSpeaker = _showPhonetic = false; // 👉 reset fades
      _busy = false;
    }
    if (oldWidget.index != widget.index ||
        oldWidget.autoAudio != widget.autoAudio ||
        oldWidget.languageCode != widget.languageCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayIfNeeded());
    }
  }

  void _goTo(int newIndex) {
    if (_busy) return; // 👉 block during reveal
    final n = widget.cards.length;
    if (n == 0) return;
    final wrapped = (newIndex % n + n) % n;
    widget.onIndexChange?.call(wrapped);
  }

  // 👉 Two-audio sequence using separate channels (B then A)
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
        // 👉 Audio #1: channel B, non-interrupting
        widget.audio.playAsset(path, interrupt: false, channel: 'b');

        // 500 ms gap
        await Future.delayed(const Duration(milliseconds: 2000));

        // 👉 Audio #2: channel A (normal)
        await _safePlay(context, path, interrupt: true, channel: 'a');

        // 👉 start reveal visuals
        setState(() => _revealed = true);

        // Thai word fade (600ms)
        Future.delayed(const Duration(milliseconds: 0), () {
          if (mounted) setState(() => _showWord = true);
        });
        // +250ms → speaker
        Future.delayed(const Duration(milliseconds: 850), () {
          if (mounted) setState(() => _showSpeaker = true);
        });
        // +250ms → phonetic placeholder (still hidden content-wise)
        Future.delayed(const Duration(milliseconds: 1100), () {
          if (mounted) setState(() => _showPhonetic = true);
        });

        // keep UI locked until fades done
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
                if (_revealed)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 👉 Thai word fade-in
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
                                fontSize: kHeadwordSize,
                                height: 1.08,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 👉 Speaker fade-in
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

                      // 👉 Phonetic fade-in (placeholder still hidden)
                      AnimatedOpacity(
                        opacity: _showPhonetic ? 0.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: const SizedBox.shrink(),
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
