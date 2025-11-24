// main_screen.dart — Clean architecture version
// MaterialApp moved OUTSIDE the FutureBuilder so app-wide state works properly.

import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../data/card.dart';
import '../services/audio_service.dart';

import 'category_overview_screen.dart';
import 'home_screen.dart';
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final AudioService audio = AudioService();
  late final Future<List<Flashcard>> cardsFuture = Repository().load();

  bool autoAudio = false;   // ← Global toggle works everywhere

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SomTam LinearNav',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),

      home: FutureBuilder<List<Flashcard>>(
        future: cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final cards = snapshot.data!;

          return HomeScreen(
            languageCode: 'en',
            autoAudio: autoAudio,
            onLanguageTap: () {},

            onAutoAudioChanged: (val) {
              setState(() => autoAudio = val);
            },

            onStart: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryOverviewScreen(
                    onCategorySelected: (selectedCategory) {
                      final selectedLower =
                          selectedCategory.trim().toLowerCase();

                      // =====================================================
                      // EXACT MATCH FIX — No contains()
                      // =====================================================
                      final filtered = cards.where((c) {
                        return c.types
                            .map((t) => t.trim().toLowerCase())
                            .any((t) => t == selectedLower);   // ← FIXED
                      }).toList();

                      // =====================================================
                      // SORTING RULES
                      // =====================================================

                      if (selectedLower == "core words") {
                        const coreOrder = {
                          "hello": 0,
                          "yes": 1,
                          "no": 2,
                          "delicious": 3,
                          "thank you": 4,
                        };

                        filtered.sort((a, b) {
                          final keyA = a.meaning.trim().toLowerCase();
                          final keyB = b.meaning.trim().toLowerCase();
                          final orderA = coreOrder[keyA] ?? 9999;
                          final orderB = coreOrder[keyB] ?? 9999;
                          return orderA.compareTo(orderB);
                        });

                      } else if (selectedLower == "numbers") {
                        filtered.sort((a, b) {
                          final intA = a.value ?? 0;
                          final intB = b.value ?? 0;
                          return intA.compareTo(intB);
                        });

                      } else {
                        filtered.sort((a, b) =>
                            a.meaning.trim().toLowerCase().compareTo(
                                  b.meaning.trim().toLowerCase(),
                                ));
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeckScreen(
                            cards: filtered,
                            audio: audio,
                            categoryLabel: selectedCategory,
                            onCardSelected: (startIndex) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => _FlashcardDetailRoute(
                                    cards: filtered,
                                    startIndex: startIndex,
                                    audio: audio,
                                    autoAudio: autoAudio,
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
        },
      ),
    );
  }
}

// ============================================================================
//  Wrapper to keep index state isolated & autoAudio in sync
// ============================================================================
class _FlashcardDetailRoute extends StatefulWidget {
  final List<Flashcard> cards;
  final int startIndex;
  final AudioService audio;
  final bool autoAudio; 

  const _FlashcardDetailRoute({
    required this.cards,
    required this.startIndex,
    required this.audio,
    required this.autoAudio,
  });

  @override
  State<_FlashcardDetailRoute> createState() => _FlashcardDetailRouteState();
}

class _FlashcardDetailRouteState extends State<_FlashcardDetailRoute> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
  }

  @override
  Widget build(BuildContext context) {
    return FlashcardDetailScreen(
      cards: widget.cards,
      index: currentIndex,
      audio: widget.audio,

      onIndexChange: (nextIndex) {
        setState(() => currentIndex = nextIndex);
      },

      autoAudio: widget.autoAudio,
    );
  }
}
