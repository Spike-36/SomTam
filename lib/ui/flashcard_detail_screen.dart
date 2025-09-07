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
const double kPhoneticSize = 22;
const double kMeaningSize = 22;
const double kGrammarSize = 18;
const double kContextSize = 18;
const double kInfoSize = 18;

const double kTopPadding = 60;
const double kIpaGap = 12;
const double kSmallGap = 8;
const double kBlockGap = 16;
const double kContextGap = 24;
const double kBetweenContexts = 8;

// — chevrons —
const double kChevronButtonSize = 56.0;
const double kChevronIconSize = 32.0;
const double kChevronOuterPad = 12.0;

const Color kMeaningColor = Colors.black;
const Color kInfoColor = Colors.black87;
const Color kSpeakerColor = Colors.black38;
const Color kContextEnColor = Colors.white;

const FontWeight kMeaningWeight = FontWeight.w700;
const FontWeight kContextForeignWeight = FontWeight.w700;

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

    final displayMeaning = card.meaningFor(lang);
    final displayContext = card.contextFor(lang);
    final englishContext = card.contextFor('en');
    final displayInfo = card.infoFor(lang);

    final hasIpa = card.ipa.trim().isNotEmpty;
    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasGrammar = card.grammarType.trim().isNotEmpty;
    final hasForeignContext = displayContext.trim().isNotEmpty;
    final hasEnglishContext = englishContext.trim().isNotEmpty;
    final hasInfo = displayInfo.trim().isNotEmpty;

    final grammarLabel =
        hasGrammar ? tGrammar(card.grammarType, langCode: lang) : '';

    final list = Padding(
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
              IconButton(
                tooltip: 'Play word',
                icon: const Icon(Icons.volume_up, color: kSpeakerColor),
                onPressed: () => _safePlay(context, _wordPath(card.audioScottish)),
              ),
            ],
          ),

          // IPA + Grammar
          if (hasIpa || (hasGrammar && grammarLabel.isNotEmpty)) ...[
            const SizedBox(height: kIpaGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasIpa)
                  Expanded(
                    child: Text(
                      card.ipa,
                      style: const TextStyle(
                        fontFamily: 'CharisSIL',
                        fontSize: kIpaSize,
                        height: 1.2,
                        color: Colors.black87,
                      ),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                if (hasGrammar && grammarLabel.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      grammarLabel,
                      style: const TextStyle(
                        fontFamily: 'SourceSerif4',
                        fontSize: kGrammarSize,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ],

          // Phonetic
          if (hasPhonetic) ...[
            const SizedBox(height: kSmallGap),
            Text(
              '[${card.phonetic}]',
              style: TextStyle(
                fontFamily: 'CharisSIL',
                fontSize: kPhoneticSize,
                fontStyle: FontStyle.italic,
                height: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: kBlockGap),

            // Divider inset 24px
            const Divider(
              color: Colors.black54,
              thickness: 1,
              height: 1,
            ),

            const SizedBox(height: kBlockGap),
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

          if (hasEnglishContext) ...[
            const SizedBox(height: kContextGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    englishContext,
                    style: const TextStyle(
                      fontFamily: 'SourceSerif4',
                      fontSize: kContextSize,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: kContextEnColor,
                    ),
                  ),
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

          if (hasForeignContext) ...[
            const SizedBox(height: kBetweenContexts),
            Text(
              displayContext,
              style: const TextStyle(
                fontFamily: 'SourceSerif4',
                fontSize: kContextSize,
                height: 1.3,
                fontWeight: kContextForeignWeight,
              ),
            ),
          ],

          if (hasInfo) ...[
            const SizedBox(height: kBlockGap),
            Text(
              displayInfo,
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

    return Scaffold(
      body: Stack(
        children: [
          Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: list,
          ),

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
