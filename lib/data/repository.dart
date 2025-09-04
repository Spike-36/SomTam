import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'card.dart';

class DeckRepository {
  Future<List<Flashcard>> loadBundled() async {
    // Corrected path to match pubspec.yaml and actual folder
    final jsonStr = await rootBundle.loadString('assets/data/cards.json');
    final list = (json.decode(jsonStr) as List);
    return list.map((e) => Flashcard.fromJson(e)).toList();
  }
}
