// lib/ui/main_screen.dart
import 'package:flutter/material.dart';
import '../data/card.dart';
import '../data/repository.dart';
import '../services/audio_service.dart';
import '../i18n/i18n.dart';
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;   // 0: Home, 1: List, 2: Word, 3: Settings
  int _currentIndex = 0;    // index in the SORTED list
  bool _autoAudio = false;
  String _languageCode = 'en';

  final audio = AudioService();

  /// Raw cards as loaded from repo (unsorted).
  List<Flashcard> _cards = [];

  /// Single source of truth for ordering: alphabetical by headword.
  List<Flashcard> _sortedCards = [];

  bool _i18nReady = false;

  List<Flashcard> _sortByHeadword(List<Flashcard> src) {
    final copy = List<Flashcard>.from(src);
    copy.sort((a, b) => a.scottish.toLowerCase().compareTo(b.scottish.toLowerCase()));
    return copy;
  }

  void _rebuildSorted() {
    _sortedCards = _sortByHeadword(_cards);
    if (_currentIndex >= _sortedCards.length) {
      _currentIndex = _sortedCards.isEmpty ? 0 : _sortedCards.length - 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _init(); // async bootstrap
  }

  Future<void> _init() async {
    final repo = Repository();
    // Load i18n and cards in parallel
    final results = await Future.wait([
      I18n.load(),       // Future<void>
      repo.load(),       // Future<List<Flashcard>>
    ]);

    // Set language and store cards
    I18n.setCurrentLang(_languageCode);
    final loaded = results[1] as List<Flashcard>;

    if (!mounted) return;
    setState(() {
      _i18nReady = true;
      _cards = loaded;
      _rebuildSorted();
    });
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  // Called when user taps a card in the (sorted) list.
  void _onCardSelected(int indexInSorted) {
    setState(() {
      _currentIndex = indexInSorted; // index refers to _sortedCards
      _selectedIndex = 2;            // switch to Word tab
    });
  }

  // Called by detail view when user swipes between cards.
  void _onIndexChange(int newIndex) {
    setState(() => _currentIndex = newIndex); // stays in sorted order
  }

  @override
  Widget build(BuildContext context) {
    if (!_i18nReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      HomeScreen(
        languageCode: _languageCode,
        onLanguageTap: () => setState(() => _selectedIndex = 3),
        onAudioTap: () => setState(() => _selectedIndex = 3),
      ),
      DeckScreen(
        cards: _sortedCards,
        audio: audio,
        languageCode: _languageCode,
        onCardSelected: _onCardSelected,
      ),
      if (_sortedCards.isNotEmpty)
        FlashcardDetailScreen(
          cards: _sortedCards,
          index: _currentIndex,
          audio: audio,
          onIndexChange: _onIndexChange,
          autoAudio: _autoAudio,
          languageCode: _languageCode,
        )
      else
        Center(child: Text(I18n.t('words', lang: _languageCode))),
      SettingsScreen(
        autoAudio: _autoAudio,
        onAutoAudioChanged: (v) => setState(() => _autoAudio = v),
        languageCode: _languageCode,
        onLanguageChanged: (code) {
          setState(() {
            _languageCode = code;
            I18n.setCurrentLang(code);
            _rebuildSorted();
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFFFFBD59),
        unselectedItemColor: const Color(0xFFFFBD59),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: I18n.t('home', lang: _languageCode),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: I18n.t('list', lang: _languageCode),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: I18n.t('words', lang: _languageCode),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: I18n.t('settings', lang: _languageCode),
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
