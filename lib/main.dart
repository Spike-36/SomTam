import 'package:flutter/material.dart';
import 'i18n/i18n.dart';
import 'ui/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await I18n.load(); // ✅ load i18n JSONs from assets
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braw',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'Sarabun', // 👉 Apply Sarabun globally
      ),
      home: const MainScreen(),
    );
  }
}
