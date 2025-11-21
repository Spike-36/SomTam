// 🔄 main_screen.dart — Start → CategoryOverviewScreen + preserved navigation

import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../data/card.dart';
import '../services/audio_service.dart';

// 👉 NEW IMPORT
import 'category_overview_screen.dart';

import 'home_screen.dart';
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';

/// Navigation flow:
/// HomeScreen → CategoryOverviewScreen → DeckScreen (filtered) → FlashcardDetailScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Shared audio service
  late final audio = AudioService();

  // Load card list once
  late final Future<List<Flashcard>> cardsFuture = Repository().load();

  // Home toggle
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

              // 🔄 REPLACED: Start → DeckScreen
              // 👉 Start → CategoryOverviewScreen
              onStart: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryOverviewScreen(
                      onCategorySelected: (selectedCategory) {
                        // 👉 Filter cards by selected category
                        final filtered = cards
                            .where((c) =>
                                c.type.trim().toLowerCase() ==
                                selectedCategory.trim().toLowerCase())
                            .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeckScreen(
                              cards: filtered,
                              audio: audio,

                              // Card tap → Detail screen
                              onCardSelected: (startIndex) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      int currentIndex = startIndex;

                                      return StatefulBuilder(
                                        builder: (context, setRouteState) {
                                          return FlashcardDetailScreen(
                                            cards: filtered,
                                            index: currentIndex,
                                            audio: audio,

                                            onIndexChange: (nextIndex) {
                                              setRouteState(() {
                                                currentIndex = nextIndex;
                                              });
                                            },

                                            autoAudio: autoAudio,
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
            ),
          ),
        );
      },
    );
  }
}
