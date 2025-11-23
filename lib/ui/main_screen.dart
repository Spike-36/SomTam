// 🔄 main_screen.dart — Start → CategoryOverviewScreen + preserved navigation

import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../data/card.dart';
import '../services/audio_service.dart';

// NEW IMPORT
import 'category_overview_screen.dart';

import 'home_screen.dart';
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';

/// Navigation flow:
/// HomeScreen → CategoryOverviewScreen → DeckScreen (filtered + sorted) → FlashcardDetailScreen
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

              // Start → CategoryOverviewScreen
              onStart: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryOverviewScreen(
                      onCategorySelected: (selectedCategory) {
                        final selectedLower =
                            selectedCategory.trim().toLowerCase();

                        // 🔄 Filter by membership in c.types (multi-category)
                        final filtered = cards.where((c) {
                          return c.types
                              .map((t) => t.trim().toLowerCase())
                              .contains(selectedLower);
                        }).toList();

                        // =====================================================
                        // ⭐ SORTING RULES
                        // =====================================================

                        // ⭐ Custom order for Core Words
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

                            // Lookup or push to end
                            final orderA = coreOrder[keyA] ?? 9999;
                            final orderB = coreOrder[keyB] ?? 9999;

                            return orderA.compareTo(orderB);
                          });

                        } else if (selectedLower == "numbers") {
                          // ⭐ Numerical sort using card.value
                          filtered.sort((a, b) {
                            final intA = a.value ?? 0;
                            final intB = b.value ?? 0;
                            return intA.compareTo(intB);
                          });

                        } else {
                          // ⭐ Default alphabetical sort (English meaning)
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
