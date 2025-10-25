import 'package:flutter/material.dart';
import 'dart:async';
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

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen>
    with TickerProviderStateMixin {
  int? _lastAutoPlayedIndex;
  bool _revealed = false;
  bool _animating = false; // 👉 lock controls during sequence
  late AnimationController _wordCtrl;
  late AnimationController _buttonCtrl;
  late AnimationController _phoneticCtrl;
  late Animation<double> _wordFade;
  late Animation<double> _buttonFade;
  late Animation<double> _phoneticFade;

  Flashcard get card => widget.cards[widget.index];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayIfNeeded());
  }

  void _initAnimations() {
    _wordCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _buttonCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _phoneticCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _wordFade = CurvedAnimation(parent: _wordCtrl, curve: Curves.easeInOut);
    _buttonFade = CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeInOut);
    _phoneticFade = CurvedAnimation(parent: _phoneticCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _buttonCtrl.dispose();
    _phoneticCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _safePlay(String path) async {
    if (path.isEmpty) return;
    try {
      await widget.audio.playAsset(path);
    } catch (_) {
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
    await _safePlay(path);
  }

  void _goTo(int newIndex) {
    if (_animating) return;
    final n = widget.cards.length;
    if (n == 0) return;
    final wrapped = (newIndex % n + n) % n;
    widget.onIndexChange?.call(wrapped);
  }

  // 👉 Core Step 5 reveal sequence
  Future<void> _runRevealSequence() async {
    if (_animating) return;
    setState(() => _animating = true);
    final path = _wordPath(card.audioThai);

    if (path.isEmpty) {
      // missing audio → reveal immediately
      setState(() => _revealed = true);
      _wordCtrl.forward();
      _buttonCtrl.forward();
      _phoneticCtrl.forward();
      setState(() => _animating = false);
      return;
    }

    // first Thai audio
    await _safePlay(path);

    // small delay
    await Future.delayed(const Duration(milliseconds: 500));

    // second Thai audio while fading in elements
    unawaited(_safePlay(path));

    setState(() => _revealed = true);
    _wordCtrl.forward();

    // stagger sequence
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _phoneticCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _animating = false);
  }

  void _onRightButtonPressed() {
    if (_animating) return;
    if (!_revealed) {
      _runRevealSequence();
    } else {
      _goTo(widget.index + 1);
    }
  }

  bool _containsThai(String text) =>
      RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.45;
    final headword = (card.thai ?? '').trim();
    final headwordFont = _containsThai(headword) ? 'Sarabun' : 'EBGaramond';
    final phonetic = (card.phonetic ?? '').trim();

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
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _wordFade,
                  child: GestureDetector(
                    onTap: () => _safePlay(_wordPath(card.audioThai)),
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
                FadeTransition(
                  opacity: _buttonFade,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _safePlay(_wordPath(card.audioThai)),
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
                FadeTransition(
                  opacity: _phoneticFade,
                  child: Text(
                    phonetic,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
        _goTo(v < 0 ? widget.index + 1 : widget.index - 1);
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

          // Left chevron
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

          // Right dynamic button
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
}
