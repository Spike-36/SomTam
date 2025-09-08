// lib/ui/flashcard_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../i18n/i18n.dart';
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

// ===================== Styles ======================
const double kHeadwordSize = 60;
const double kIpaSize = 20;
const double kPhoneticSize = 20;
const double kMeaningSize = 22;
const double kGrammarSize = 18;
const double kContextSize = 18;
const double kInfoSize = 18;

const double kTopPadding = 60;
const double kIpaGap = 12;
const double kSmallGap = 8;
const double kBlockGap = 16;
const double kContextGap = 18;
const double kBetweenContexts = 18;

// — chevrons —
const double kChevronButtonSize = 56.0;
const double kChevronIconSize = 32.0;
const double kChevronOuterPad = 12.0;

const Color kMeaningColor = Colors.black;
const Color kInfoColor = Colors.black87;
const Color kSpeakerColor = Colors.black38;
const Color kContextEnColor = Colors.black87;

// emphasis
const FontWeight kMeaningWeight = FontWeight.w700;
const FontWeight kContextForeignWeight = FontWeight.w700;

// ===== Speaker icon fine-tune controls =====
const double kWordSpeakerSize = 28.0;
const double kContextSpeakerSize = 26.0;
const double kWordSpeakerYOffset = 10.0;     // (− up, + down)
const double kContextSpeakerYOffset = -11.0;  // (− up, + down)

// ===== IPA + Grammar layout tuning =====
const double kIpaGrammarGap = 12.0;
const double kGrammarXOffset = 0.0;
const double kGrammarYOffset = 0.0;

// ===== Divider between phonetic and meaning =====
const double kRuleGapTop = 16.0;
const double kRuleGapBottom = 16.0;
const double kRuleThickness = 1.2;
const Color  kRuleColor = Colors.black38;

// ===== Swipe tuning =====
const double kSwipeVelocityThreshold = 300.0;

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

  double _bottomReserve(BuildContext c) {
    final safe = MediaQuery.of(c).padding.bottom;
    return kChevronButtonSize + (kChevronOuterPad * 2) + safe + 12;
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

  @override
  Widget build(BuildContext context) {
    final lang = widget.languageCode;
    final isRtl = I18n.isRTL(lang);

    // i18n fields
    final displayMeaning = card.meaningFor(lang);
    final englishContext = card.contextEnStrict();            // EN row
    final foreignContext = card.contextForeignStrict(lang);   // foreign above EN row
    final hasForeignContext = foreignContext.isNotEmpty;

    // flags
    final hasIpa = card.ipa.trim().isNotEmpty;
    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasGrammar = card.grammarType.trim().isNotEmpty;

    final grammarLabel =
        hasGrammar ? tGrammar(card.grammarType, langCode: lang) : '';

    // ======= LIST =======
    final contentList = Padding(
      padding: EdgeInsets.only(
        top: kTopPadding,
        left: 24,
        right: 24,
        bottom: _bottomReserve(context),
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
                  style: const TextStyle(
                    fontFamily: 'EBGaramond',
                    fontWeight: FontWeight.w600,
                    fontSize: kHeadwordSize,
                    height: 1.08,
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, kWordSpeakerYOffset),
                child: IconButton(
                  tooltip: 'Play word',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.volume_up,
                      color: kSpeakerColor, size: kWordSpeakerSize),
                  onPressed: () =>
                      _safePlay(context, _wordPath(card.audioScottish)),
                ),
              ),
            ],
          ),

          // IPA + Grammar (inline, baseline-aligned)
          if (hasIpa || (hasGrammar && grammarLabel.isNotEmpty)) ...[
            const SizedBox(height: kIpaGap),
            Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: RichText(
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'CharisSIL',
                          fontSize: kIpaSize,
                          height: 1.2,
                          color: Colors.black87,
                        ),
                        children: [
                          if (hasIpa) TextSpan(text: card.ipa),
                          if (hasIpa && (hasGrammar && grammarLabel.isNotEmpty))
                            const WidgetSpan(child: SizedBox(width: kIpaGrammarGap)),
                          if (hasGrammar && grammarLabel.isNotEmpty)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: Transform.translate(
                                offset: Offset(kGrammarXOffset, kGrammarYOffset),
                                child: Text(
                                  grammarLabel,
                                  style: const TextStyle(
                                    fontFamily: 'SourceSerif4',
                                    fontSize: kGrammarSize,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (hasPhonetic) ...[
            const SizedBox(height: kSmallGap),
            Text(
              '[${card.phonetic}]',
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: TextStyle(
                fontFamily: 'CharisSIL',
                fontSize: kPhoneticSize,
                fontStyle: FontStyle.italic,
                height: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),

            const SizedBox(height: kRuleGapTop),
            const Divider(color: kRuleColor, thickness: kRuleThickness, height: 0),
            const SizedBox(height: kRuleGapBottom),
          ],

          // Meaning
          Text(
            displayMeaning.isEmpty ? '—' : displayMeaning,
            style: const TextStyle(
              fontFamily: 'SourceSerif4',
              fontSize: kMeaningSize,
              height: 1.35,
              color: kMeaningColor,
              fontWeight: kMeaningWeight,
            ),
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
          ),

          // --- Foreign context directly under Meaning (if present) ---
          const SizedBox(height: kContextGap),
          if (hasForeignContext) ...[
            Text(
              foreignContext,
              style: const TextStyle(
                fontFamily: 'SourceSerif4',
                fontSize: kContextSize,
                height: 1.3,
                fontWeight: kContextForeignWeight,
              ),
            ),
            const SizedBox(height: kBetweenContexts),
          ],

          // --- English context row with speaker (always shown) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  englishContext.isEmpty ? '—' : englishContext,
                  style: const TextStyle(
                    fontFamily: 'SourceSerif4',
                    fontSize: kContextSize,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: kContextEnColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Transform.translate(
                offset: const Offset(0, kContextSpeakerYOffset),
                child: IconButton(
                  tooltip: 'Play context',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.volume_up,
                      color: kSpeakerColor, size: kContextSpeakerSize),
                  onPressed: () => _safePlay(
                    context,
                    _contextPath(card.audioScottishContext),
                  ),
                ),
              ),
            ],
          ),

          if (card.infoFor(lang).trim().isNotEmpty) ...[
            const SizedBox(height: kBlockGap),
            Text(
              card.infoFor(lang),
              style: const TextStyle(
                fontFamily: 'SourceSerif4',
                fontSize: kInfoSize,
                height: 1.35,
                color: kInfoColor,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ],
      ),
    );

    // Swipe between records
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
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: contentList,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          swipeable,
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: _bottomReserve(context),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.88),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                bottom: kChevronOuterPad + MediaQuery.of(context).padding.bottom,
              ),
              child: _floatingButton(Icons.chevron_left, () => _goTo(widget.index - 1)),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 8,
                bottom: kChevronOuterPad + MediaQuery.of(context).padding.bottom,
              ),
              child: _floatingButton(Icons.chevron_right, () => _goTo(widget.index + 1)),
            ),
          ),
        ],
      ),
    );
  }
}
