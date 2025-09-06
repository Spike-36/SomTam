// lib/ui/flashcard_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';
import '../I18n/grammar_i18n.dart'; // ← for tGrammar()

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
            final tween = Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));
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

    final displayMeaning = card.meaningFor(lang);
    final displayContext = card.contextFor(lang);
    final englishContext = card.contextFor('en');
    final displayInfo = card.infoFor(lang);

    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasGrammar = card.grammarType.trim().isNotEmpty;
    final hasForeignContext = displayContext.trim().isNotEmpty;
    final hasEnglishContext = englishContext.trim().isNotEmpty;
    final hasInfo = displayInfo.trim().isNotEmpty;

    final grammarLabel = hasGrammar ? tGrammar(card.grammarType, langCode: lang) : '';

    final list = Padding(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
      child: ListView(
        children: [
          // Main word row with play button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  card.scottish,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
              ),
              IconButton(
                tooltip: 'Play word',
                icon: const Icon(Icons.volume_up),
                onPressed: () => _safePlay(context, _wordPath(card.audioScottish)),
              ),
            ],
          ),

          if (hasPhonetic) ...[
            const SizedBox(height: 8),
            Text(
              card.phonetic,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
          ],

          const SizedBox(height: 16),
          Text(
            displayMeaning.isEmpty ? '—' : displayMeaning,
            style: const TextStyle(fontSize: 20, color: Colors.black54),
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
          ),

          if (hasGrammar && grammarLabel.isNotEmpty) ...[
            const SizedBox(height: 16),
            Align(
              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                grammarLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],

          if (hasEnglishContext) ...[
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    englishContext,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Play context',
                  icon: const Icon(Icons.volume_up),
                  onPressed: () =>
                      _safePlay(context, _contextPath(card.audioScottishContext)),
                ),
              ],
            ),
          ],

          if (hasForeignContext) ...[
            const SizedBox(height: 8),
            Text(
              displayContext,
              style: const TextStyle(fontSize: 16),
            ),
          ],

          if (hasInfo) ...[
            const SizedBox(height: 24),
            Text(
              displayInfo,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 100),
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
