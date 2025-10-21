import 'package:flutter/material.dart';
import '../data/card.dart';
import '../data/repository.dart';
import '../services/audio_service.dart';
import '../I18n/i18n.dart';
import '../utils/sort.dart'; // type+headword sort
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
  // Tabs: 0 Home, 1 List, 2 Word, 3 Settings
  int _selectedIndex = 0;
  int _currentIndex = 0; // index within _sortedCards for Word tab
  bool _autoAudio = false;
  String _languageCode = 'en';

  final audio = AudioService();

  /// When this increments, DeckScreen resets to the type index view.
  int _listResetTick = 0;

  // Data
  List<Flashcard> _cards = [];
  List<Flashcard> _sortedCards = [];
  bool _i18nReady = false;

  void _rebuildSorted() {
    _sortedCards = sortByTypeThenHeadword(_cards);
    if (_currentIndex >= _sortedCards.length) {
      _currentIndex = _sortedCards.isEmpty ? 0 : _sortedCards.length - 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = Repository();
    final results = await Future.wait([
      I18n.load(),
      repo.load(),
    ]);

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

  // From List tab: user tapped a card in the sorted list
  void _onCardSelected(int indexInSorted) {
    setState(() {
      _currentIndex = indexInSorted;
      _selectedIndex = 2; // switch to Word tab
    });
  }

  // From Word tab: user swiped between cards
  void _onIndexChange(int newIndex) {
    setState(() => _currentIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (!_i18nReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = <Widget>[
      HomeScreen(
        languageCode: _languageCode,
        onLanguageTap: () => setState(() => _selectedIndex = 3),
        onAudioTap: () => setState(() => _selectedIndex = 3),
        autoAudio: _autoAudio,
        onAutoAudioChanged: (v) => setState(() => _autoAudio = v),
      ),
      DeckScreen(
        cards: _sortedCards,
        audio: audio,
        languageCode: _languageCode,
        onCardSelected: _onCardSelected,
        resetTicker: _listResetTick,
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
        Center(
          child: Text(I18n.t('words', lang: _languageCode)),
        ),
      // 👉 Updated SettingsScreen: Under construction
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
        onTap: (i) {
          if (i == 1) {
            setState(() {
              _listResetTick++;
              _selectedIndex = i;
            });
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        backgroundColor: const Color(0xFF003478),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
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
  icon: const Icon(Icons.search),
  label: 'Find',
),
        ],
      ),
    );
  }
}
