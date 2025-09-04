import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'card.dart';

class DeckRepository {
  Future<List<Flashcard>> loadBundled() async {
    final raw = await rootBundle.loadString('assets/data/cards.json');
    final data = json.decode(raw);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Flashcard.fromJson)
          .toList();
    }

    // If your cards.json is { "cards": [ ... ] }
    if (data is Map<String, dynamic> && data['cards'] is List) {
      final list = (data['cards'] as List).whereType<Map<String, dynamic>>();
      return list.map(Flashcard.fromJson).toList();
    }

    // Fallback: empty
    return <Flashcard>[];
  }
}
