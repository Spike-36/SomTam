import 'package:flutter/material.dart';
import '../data/card.dart';
import '../data/repository.dart';
import '../services/audio_service.dart';
import '../i18n/i18n.dart'; // i18n helper
import 'deck_screen.dart';
import 'flashcard_detail_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _currentIndex = 0;        // shared card index
  bool _autoAudio = false;      // default OFF each launch
  String _languageCode = 'en';  // selected UI/content language

  final audio = AudioService();
  List<Flashcard> cards = [];
  bool _i18nReady = false;      // ✅ wait until JSONs are loaded

  @override
  void initState() {
    super.initState();

    // ✅ Load i18n dictionaries and cards in parallel
    Future.wait([
      I18n.load(),
      DeckRepository().loadBundled(),
    ]).then((results) {
      setState(() {
        _i18nReady = true;
        cards = results[1] as List<Flashcard>;
      });
    });
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  void _onCardSelected(int index) {
    setState(() {
      _currentIndex = index;
      _selectedIndex = 2; // jump to Word tab
    });
  }

  void _onIndexChange(int newIndex) {
    setState(() => _currentIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (!_i18nReady) {
      // ✅ Prevents crash / key fallback before translations load
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      Center(child: Text('🏠 ${I18n.t("home", lang: _languageCode)}')),
      DeckScreen(
        cards: cards,
        audio: audio,
        onCardSelected: _onCardSelected,
      ),
      if (cards.isNotEmpty)
        FlashcardDetailScreen(
          cards: cards,
          index: _currentIndex,
          audio: audio,
          onIndexChange: _onIndexChange,
          autoAudio: _autoAudio,
          languageCode: _languageCode, // pass language into Word tab
        )
      else
        Center(child: Text(I18n.t('words', lang: _languageCode))),
      SettingsScreen(
        autoAudio: _autoAudio,
        onAutoAudioChanged: (v) => setState(() => _autoAudio = v),
        languageCode: _languageCode,
        onLanguageChanged: (c) => setState(() => _languageCode = c),
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
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
