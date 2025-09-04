import 'package:flutter/material.dart';
import 'data/repository.dart';
import 'data/card.dart';
import 'services/audio_service.dart';
import 'ui/video_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (_, i) => FlashcardTile(card: cards[i], audio: audio),
      ),
    );
  }
}

class FlashcardTile extends StatelessWidget {
  final Flashcard card;
  final AudioService audio;
  const FlashcardTile({super.key, required this.card, required this.audio});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (card.image.isNotEmpty)
              Image.asset(card.image, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(card.term, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            Text(card.meaning, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => audio.playAsset(card.audio),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play audio'),
                ),
                if (card.video != null)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoScreen(assetPath: card.video!)),
                    ),
                    icon: const Icon(Icons.play_circle),
                    label: const Text('Play video'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
