import 'package:flutter/material.dart';
import 'ui/main_screen.dart'; // ✅ new main screen with bottom nav

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braw',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const MainScreen(), // ✅ now starts with bottom nav
    );
  }
}
