import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'card.dart';

class DeckRepository {
  static const _assetPath = 'assets/data/cards.json';
  static List<Flashcard>? _cache;

  /// Load cards from bundled asset. Set [forceRefresh] to true to ignore cache.
  Future<List<Flashcard>> loadBundled({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      final raw = await rootBundle.loadString(_assetPath);
      final dynamic data = json.decode(raw);
      final cards = _decodeToCards(data);
      _cache = cards;
      return cards;
    } catch (e, st) {
      debugPrint('DeckRepository.loadBundled error: $e\n$st');
      return const <Flashcard>[];
    }
  }

  List<Flashcard> _decodeToCards(dynamic data) {
    // Case 1: plain list: [ { ...card... }, ... ]
    if (data is List) {
      return data
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(Flashcard.fromJson)
          .toList();
    }

    // Case 2: wrapped: { "cards": [ ... ] }
    if (data is Map && data['cards'] is List) {
      final list = (data['cards'] as List)
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(Flashcard.fromJson)
          .toList();
      return list;
    }

    // Unexpected shape
    debugPrint('DeckRepository: unexpected JSON shape in $_assetPath');
    return const <Flashcard>[];
    }
}
