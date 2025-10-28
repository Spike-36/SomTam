import 'package:flutter/material.dart';
import 'i18n/i18n.dart';
import 'ui/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await I18n.load(); // ✅ Load i18n JSONs from assets before app runs
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SomTam LinearNav',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'Sarabun', // ✅ global font
      ),
      home: const MainScreen(), // Entry point of the new linear flow
    );
  }
}
