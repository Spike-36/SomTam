// main_screen.dart — Option A-1 (Minimal change: Fix navigation only)

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

  bool autoAudio = false;

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

                      // FILTER FULL LIST BY TOP-LEVEL CATEGORY
                      final filtered = cards.where((c) {
                        return c.types
                            .map((t) => t.trim().toLowerCase())
                            .contains(selectedLower);
                      }).toList();

                      // STANDARD CATEGORY SORTS
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
                          return (coreOrder[keyA] ?? 9999)
                              .compareTo(coreOrder[keyB] ?? 9999);
                        });

                      } else if (selectedLower == "numbers") {
                        filtered.sort((a, b) =>
                            (a.value ?? 0).compareTo(b.value ?? 0));

                      } else {
                        filtered.sort((a, b) =>
                            a.meaning.trim().toLowerCase().compareTo(
                                  b.meaning.trim().toLowerCase(),
                                ));
                      }

                      // ------------------------------------------------------------------
                      // DECK SCREEN
                      // ------------------------------------------------------------------
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeckScreen(
                            cards: filtered,
                            audio: audio,
                            categoryLabel: selectedCategory,

                            // ON CARD SELECTED — Option A-1 Fix
                            onCardSelected: (startIndex) {
                              final Flashcard tapped = filtered[startIndex];

                              // Detect sub-category
                              String? subgroup;
                              if ((tapped.drinksType ?? "").isNotEmpty) {
                                subgroup = tapped.drinksType;
                              } else if ((tapped.proteinTypes ?? "").isNotEmpty) {
                                subgroup = tapped.proteinTypes;
                              } else if ((tapped.hasTypes ?? "").isNotEmpty) {
                                subgroup = tapped.hasTypes;
                              }

                              List<Flashcard> finalList;

                              if (subgroup == null || subgroup.trim().isEmpty) {
                                // No sub-category: use full category list
                                finalList = filtered;
                              } else {
                                // Only items from this subgroup
                                finalList = filtered.where((c) {
                                  return (c.drinksType == subgroup) ||
                                         (c.proteinTypes == subgroup) ||
                                         (c.hasTypes == subgroup);
                                }).toList();
                              }

                              // Preserve alphabetical order already applied
                              // Find tapped index inside subgroup
                              final newIndex = finalList.indexWhere(
                                  (c) => c.id == tapped.id);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      _FlashcardDetailRoute(
                                        cards: finalList,
                                        startIndex: newIndex,
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
//  Isolated DetailScreen wrapper (unchanged)
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
