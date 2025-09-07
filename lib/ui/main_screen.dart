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
  int _selectedIndex = 0;
  int _currentIndex = 0;
  bool _autoAudio = false;
  String _languageCode = 'en';

  final audio = AudioService();
  List<Flashcard> cards = [];
  bool _i18nReady = false;

  @override
  void initState() {
    super.initState();

    Future.wait([
      I18n.load(),
      DeckRepository().loadBundled(forceRefresh: true),
    ]).then((results) {
      I18n.setCurrentLang(_languageCode);
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
        cards: cards,
        audio: audio,
        languageCode: _languageCode,
        onCardSelected: _onCardSelected,
      ),
      if (cards.isNotEmpty)
        FlashcardDetailScreen(
          cards: cards,
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
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        // Try each of these blues and pick the one that looks best:
        //backgroundColor: const Color(0xFF003F7F), // Option A: Darker than before
        //backgroundColor: const Color(0xFF004080), // Option B: Slightly deeper navy
        //backgroundColor: const Color(0xFF002D5C), // Option C: Much darker navy
        //backgroundColor: const Color(0xFF0A0A0A), // Near-black
        backgroundColor: const Color(0xFF121212), // Material dark theme black



        selectedItemColor: const Color(0xFFFFBD59), // Yellow
        unselectedItemColor: const Color(0xFFFFBD59), // Same yellow
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
