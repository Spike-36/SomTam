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

      // The home is now a wrapper that handles async loading
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

            // FIX: This now updates properly everywhere
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

                      // Filter by type
                      final filtered = cards.where((c) {
                        return c.types
                            .map((t) => t.trim().toLowerCase())
                            .contains(selectedLower);
                      }).toList();

                      // =====================================================
                      // SORTING RULES
                      // =====================================================

                      // Custom order — Core Words
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
                        // Numerical sort
                        filtered.sort((a, b) {
                          final intA = a.value ?? 0;
                          final intB = b.value ?? 0;
                          return intA.compareTo(intB);
                        });

                      } else {
                        // Default alphabetical
                        filtered.sort((a, b) =>
                            a.meaning.trim().toLowerCase().compareTo(
                                  b.meaning.trim().toLowerCase(),
                                ));
                      }

                      // =====================================================

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeckScreen(
                            cards: filtered,
                            audio: audio,
                            categoryLabel: selectedCategory,

                            onCardSelected: (startIndex) {
                              // 🔄 REPLACED the broken StatefulBuilder with a proper wrapper
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => _FlashcardDetailRoute(
                                    // 👉 Pass-through params
                                    cards: filtered,
                                    startIndex: startIndex,
                                    audio: audio,
                                    autoAudio: autoAudio, // stays reactive
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
// 👉 NEW TINY WRAPPER WIDGET
//    Safely replaces the broken StatefulBuilder.
//    Rebuilds when MainScreen rebuilds → autoAudio stays in sync.
// ============================================================================

class _FlashcardDetailRoute extends StatefulWidget {
  final List<Flashcard> cards;
  final int startIndex;
  final AudioService audio;
  final bool autoAudio; // 👉 dynamic toggle

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

      // 👉 Keeps scroll/swipe navigation working
      onIndexChange: (nextIndex) {
        setState(() => currentIndex = nextIndex);
      },

      // 👉 The CRITICAL FIX:
      // When MainScreen toggles autoAudio and rebuilds,
      // this widget rebuilds too → updated value flows in.
      autoAudio: widget.autoAudio,
    );
  }
}
