import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // for asset preflight
import 'data/repository.dart';
import 'data/card.dart';
import 'services/audio_service.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braw',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const DeckScreen(),
    );
  }
}

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});
  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final repo = DeckRepository();
  final audio = AudioService();

  List<Flashcard> cards = [];

  @override
  void initState() {
    super.initState();
    repo.loadBundled().then((c) => setState(() => cards = c));
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  // Accepts either a bare filename (e.g., "Z005.aye.scottish.mp3")
  // or a full path already (e.g., "assets/audio/scottish/Z005.aye.scottish.mp3").
  String _wordPath(String audioScottish) {
    final name = audioScottish.trim();
    if (name.isEmpty) return '';
    if (name.contains('/')) return name; // treat as full path from JSON
    return 'assets/audio/scottish/$name';
  }

  Future<void> _playWord(Flashcard c, BuildContext context) async {
    final path = _wordPath(c.audioScottish);
    if (path.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No filename in JSON (audioScottish is empty)')),
      );
      return;
    }

    // Preflight: confirm the asset is actually bundled at that path.
    try {
      debugPrint('🔎 Preflight load: $path');
      await rootBundle.load(path);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio not found: $path')),
      );
      return;
    }

    try {
      await audio.playAsset(path);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play: $path ($e)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Braw')),
      body: ListView.separated(
        itemCount: cards.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final c = cards[i];
          return ListTile(
            title: Text(c.scottish),
            subtitle: Text(c.meaning.isEmpty ? '—' : c.meaning),
            trailing: const Icon(Icons.volume_up),
            onTap: () => _playWord(c, context),
          );
        },
      ),
    );
  }
}
