// 🔄 main_screen.dart — wired Start button + working chevrons via onIndexChange

import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../data/card.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';

/// Minimal navigation:
/// HomeScreen → DeckScreen → FlashcardDetailScreen
/// Detail screen chevrons update index via onIndexChange (StatefulBuilder route).
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 👉 Shared audio service
  late final audio = AudioService();

  // 👉 Load cards once
  late final Future<List<Flashcard>> cardsFuture = Repository().load();

  // 👉 Home toggle
  bool autoAudio = false;

  @override
  Widget build(BuildContext context) {
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
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }

        final cards = snapshot.data!;

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
              onAutoAudioChanged: (val) => setState(() => autoAudio = val),

              // 👉 TOP "Start" button action (now active)
              onAudioTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckScreen(
                      cards: cards,
                      audio: audio,

                      // 👉 When a card is tapped in Deck, push Detail with live index state
                      onCardSelected: (startIndex) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              // 🔧 Local index state for this route
                              int currentIndex = startIndex;

                              return StatefulBuilder(
                                builder: (context, setRouteState) {
                                  return FlashcardDetailScreen(
                                    cards: cards,
                                    index: currentIndex,
                                    audio: audio,
                                    // 👉 chevrons call this and we just setState the local index
                                    onIndexChange: (nextIndex) {
                                      setRouteState(() {
                                        currentIndex = nextIndex;
                                      });
                                    },
                                    // 👉 forward the Home toggle if you want autoplay behavior
                                    autoAudio: autoAudio, // optional but harmless
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
