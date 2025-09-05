import 'package:flutter/material.dart';
import '../data/card.dart';
import '../data/repository.dart';
import '../services/audio_service.dart';
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
  int _currentIndex = 0;               // shared card index
  bool _autoAudio = false;             // ✅ default OFF each launch
  final audio = AudioService();
  List<Flashcard> cards = [];

  @override
  void initState() {
    super.initState();
    DeckRepository().loadBundled().then((c) => setState(() => cards = c));
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
    final pages = [
      const Center(child: Text('🏠 Home')),
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
          autoAudio: _autoAudio,        // ✅ pass setting to Word tab
        )
      else
        const Center(child: Text('No cards yet')),
      SettingsScreen(                       // ✅ settings tab
        autoAudio: _autoAudio,
        onAutoAudioChanged: (v) => setState(() => _autoAudio = v),
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Word'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
