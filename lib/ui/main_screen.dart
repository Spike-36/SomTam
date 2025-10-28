import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../data/card.dart'; // ✅ add this so Flashcard type is known
import '../services/audio_service.dart';
import 'home_screen.dart';
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';

/// Minimal navigation structure:
/// HomeScreen → DeckScreen → FlashcardDetailScreen
/// No bottom tab bar. Home button on FlashcardDetailScreen returns to Home.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final audio = AudioService();

  // ✅ Explicitly typed as Future<List<Flashcard>>
  late final Future<List<Flashcard>> cardsFuture = Repository().load();

  bool autoAudio = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Explicitly typed FutureBuilder
    return FutureBuilder<List<Flashcard>>(
      future: cardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        final cards = snapshot.data!; // ✅ now correctly typed as List<Flashcard>

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SomTam LinearNav',
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            body: HomeScreen(
              languageCode: 'en',
              autoAudio: autoAudio,
              onLanguageTap: () {},
              onAudioTap: () {},
              onAutoAudioChanged: (val) => setState(() => autoAudio = val),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003478),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckScreen(
                      cards: cards,
                      audio: audio,
                      onCardSelected: (index) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashcardDetailScreen(
                              cards: cards,
                              index: index,
                              audio: audio,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                'Start',
                style: TextStyle(
                  fontFamily: 'SourceSerif4',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
