import 'package:flutter/material.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart'; // ← match your actual folder casing

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
  int? _lastAutoPlayedIndex; // ensure one auto-play per word

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
    // Re-run auto play when index/autoAudio/language changes
    if (oldWidget.index != widget.index ||
        oldWidget.autoAudio != widget.autoAudio ||
        oldWidget.languageCode != widget.languageCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayIfNeeded());
      // No setState() here — rebuild happens anyway when widget updates.
    }
  }

  void _goTo(int newIndex) {
    final n = widget.cards.length;
    if (n == 0) return;
    final wrapped = (newIndex % n + n) % n; // loop both directions
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
            final isNext = wrapped > (oldIndex ?? widget.index) ||
                ((oldIndex ?? widget.index) == n - 1 && wrapped == 0);
            const left = Offset(-1, 0), right = Offset(1, 0);
            final tween = Tween(
              begin: isNext ? right : left,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    }
  }

  int? get oldIndex => _lastAutoPlayedIndex;

  @override
  Widget build(BuildContext context) {
    final lang = widget.languageCode;
    final isRtl = I18n.isRTL(lang);

    // Localized meaning/context with EN fallback (helpers on Flashcard)
    final displayMeaning = card.meaningFor(lang);
    final displayContext = card.contextFor(lang);

    final hasPhonetic = card.phonetic.trim().isNotEmpty;
    final hasGrammar  = card.grammarType.trim().isNotEmpty;
    final hasContext  = displayContext.trim().isNotEmpty;

    Widget contextRow() {
      final text = Expanded(child: Text(displayContext));
      final icon = IconButton(
        tooltip: 'Play context',
        icon: const Icon(Icons.play_circle_outline),
        onPressed: () => _safePlay(context, _contextPath(card.audioScottishContext)),
      );

      // In RTL, put text first, icon after (mirrors LTR visually)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isRtl
            ? [text, const SizedBox(width: 8), icon]
            : [
                const Padding(
                  padding: EdgeInsets.only(right: 12, top: 2),
                  child: Icon(Icons.chat_bubble_outline),
                ),
                text,
                const SizedBox(width: 8),
                icon,
              ],
      );
    }

    final list = ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          card.scottish,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
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
        if (hasGrammar) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.category, size: 20),
              const SizedBox(width: 8),
              Text(card.grammarType, textAlign: isRtl ? TextAlign.right : TextAlign.left),
            ],
          ),
        ],
        if (hasContext) ...[
          const SizedBox(height: 24),
          contextRow(),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => _safePlay(context, _wordPath(card.audioScottish)),
          icon: const Icon(Icons.volume_up),
          label: const Text('Play audio'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(card.scottish),
        actions: [
          IconButton(
            tooltip: 'Play word',
            icon: const Icon(Icons.volume_up),
            onPressed: () => _safePlay(context, _wordPath(card.audioScottish)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Apply RTL/LTR to the text region only
          Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: list,
          ),

          // Left arrow (loops)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 40),
              onPressed: () => _goTo(widget.index - 1),
            ),
          ),

          // Right arrow (loops)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 40),
              onPressed: () => _goTo(widget.index + 1),
            ),
          ),
        ],
      ),
    );
  }
}
