// lib/ui/flashcard_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
// lowercase path you standardized elsewhere
import '../i18n/i18n.dart';
// grammar helper lives in /lib/I18n
import '../I18n/grammar_i18n.dart'; // tGrammar()

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

// ====================================================
// 🎛️ STYLE SETTINGS — tweak these to adjust the whole screen
// ====================================================

// Font sizes
const double kHeadwordSize = 34;
const double kIpaSize = 18;        // NEW: IPA line
const double kPhoneticSize = 18;
const double kMeaningSize = 20;
const double kGrammarSize = 14;
const double kContextSize = 16;
const double kInfoSize = 16;

// Vertical spacing
const double kTopPadding = 100;     // space from very top
const double kIpaGap = 6;           // headword → IPA
const double kSmallGap = 8;         // IPA → phonetic, etc.
const double kBlockGap = 16;        // generic block gap
const double kContextGap = 24;      // before English/Scottish context
const double kBetweenContexts = 8;  // EN context → foreign context
const double kBottomSpacer = 100;   // keep arrows off content

// Colors
const Color kMeaningColor = Colors.black54;
const Color kInfoColor = Colors.black87;
const Color kSpeakerColor = Colors.black38; // ← fade both speaker icons
const Color kContextEnColor = Colors.white; // EN/Scottish bold line
// ====================================================

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  int? _lastAutoPlayedIndex;
  Flashcard get card => widget.cards[widget.index];

  String _wordPath(String filename) {
    if (filename.trim().isEmpty) return '';
    if (filename.contains('/')) return filename;
    return 'assets/audio/scottish/$filename';
  }

  String _contextPath(String filename) {
    if (filename.trim().isEmpty) return '';
    if (filename.contains('/')) return filename;
    return 'assets/audio/context/$filename';
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
    final path = _wordPath(card.audioScottish);
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
    if (widget.onIndexChange != null) {
      widget.onIndexChange!(wrapped);
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => FlashcardDetailScreen(
            cards: widget.cards,
            index: wrapped,
            audio: widget.audio,
            autoAudio: widget.autoAudio,
            languageCode: widget.languageCode,
          ),
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.languageCode;
    final isRtl = I18n.isRTL(lang);

    // i18n fields
    final displayMeaning = card.meaningFor(lang);
    final displayContext = card.contextFor(lang);
    final englishContext = card.contextFor('en');
    final displayInfo = card.infoFor(lang);

    // availability flags
    final hasIpa = card.ipa.trim().isNotEmpty;
    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasGrammar = card.grammarType.trim().isNotEmpty;
    final hasForeignContext = displayContext.trim().isNotEmpty;
    final hasEnglishContext = englishContext.trim().isNotEmpty;
    final hasInfo = displayInfo.trim().isNotEmpty;

    // grammar label via table
    final grammarLabel =
        hasGrammar ? tGrammar(card.grammarType, langCode: lang) : '';

    // --- Typography (uses your pubspec-registered families) ---
    final headwordStyle = const TextStyle(
      fontFamily: 'EBGaramond',
      fontWeight: FontWeight.w600, // SemiBold
      fontSize: kHeadwordSize,
      height: 1.08,
    );

    final ipaStyle = const TextStyle(
      fontFamily: 'CharisSIL', // good for IPA glyph coverage
      fontSize: kIpaSize,
      height: 1.2,
      color: Colors.black87,
    );

    final phoneticStyle = TextStyle(
      fontFamily: 'CharisSIL',
      fontSize: kPhoneticSize,
      height: 1.2,
      color: Theme.of(context).colorScheme.primary,
    );

    const meaningStyle = TextStyle(
      fontFamily: 'SourceSerif4',
      fontSize: kMeaningSize,
      height: 1.35,
      color: kMeaningColor,
    );

    const grammarStyle = TextStyle(
      fontFamily: 'SourceSerif4',
      fontSize: kGrammarSize,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );

    const contextEnStyle = TextStyle(
      fontFamily: 'SourceSerif4',
      fontSize: kContextSize,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: kContextEnColor,
    );

    const contextForeignStyle = TextStyle(
      fontFamily: 'SourceSerif4',
      fontSize: kContextSize,
      height: 1.3,
    );

    const infoStyle = TextStyle(
      fontFamily: 'SourceSerif4',
      fontSize: kInfoSize,
      height: 1.35,
      color: kInfoColor,
    );

    final list = Padding(
      padding: const EdgeInsets.only(
        top: kTopPadding,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: ListView(
        children: [
          // Headword + play
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  card.scottish,
                  style: headwordStyle,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
              ),
              IconButton(
                tooltip: 'Play word',
                icon: const Icon(Icons.volume_up, color: kSpeakerColor),
                onPressed: () => _safePlay(context, _wordPath(card.audioScottish)),
              ),
            ],
          ),

          // IPA (NEW) — only if present
          if (hasIpa) ...[
            const SizedBox(height: kIpaGap),
            Text(
              card.ipa,
              style: ipaStyle,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
          ],

          // Phonetic
          if (hasPhonetic) ...[
            const SizedBox(height: kSmallGap),
            Text(
              card.phonetic,
              style: phoneticStyle,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
          ],

          // Meaning
          const SizedBox(height: kBlockGap),
          Text(
            displayMeaning.isEmpty ? '—' : displayMeaning,
            style: meaningStyle,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
          ),

          // Grammar label (translated)
          if (hasGrammar && grammarLabel.isNotEmpty) ...[
            const SizedBox(height: kBlockGap),
            Align(
              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                grammarLabel,
                style: grammarStyle,
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],

          // Context (EN/Scottish) + speaker
          if (hasEnglishContext) ...[
            const SizedBox(height: kContextGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(englishContext, style: contextEnStyle),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Play context',
                  icon: const Icon(Icons.volume_up, color: kSpeakerColor),
                  onPressed: () => _safePlay(
                      context, _contextPath(card.audioScottishContext)),
                ),
              ],
            ),
          ],

          // Foreign context
          if (hasForeignContext) ...[
            const SizedBox(height: kBetweenContexts),
            Text(displayContext, style: contextForeignStyle),
          ],

          // Info block (JUSTIFIED)
          if (hasInfo) ...[
            const SizedBox(height: kBlockGap),
            Text(
              displayInfo,
              style: infoStyle,
              textAlign: TextAlign.justify, // ← justified per your request
            ),
          ],

          const SizedBox(height: kBottomSpacer),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: list,
          ),
          // Bottom nav arrows (unchanged)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 40),
                onPressed: () => _goTo(widget.index - 1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: IconButton(
                icon: const Icon(Icons.chevron_right, size: 40),
                onPressed: () => _goTo(widget.index + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
