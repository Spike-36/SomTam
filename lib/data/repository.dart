import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'card.dart';

class Repository {
  static const _assetPath = 'assets/data/cards.json';

  Future<List<Flashcard>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    return list
        .map(_mapKoreanEnglishToLegacyKeys) // <- only change: remap keys for the UI
        .map(Flashcard.fromJson)
        .toList(growable: false);
  }
}

/// Remap your new Korean/English JSON shape to the legacy keys the UI/model expect.
/// We do NOT delete original keys; we just add aliases so Flashcard.fromJson stays unchanged.
Map<String, dynamic> _mapKoreanEnglishToLegacyKeys(Map<String, dynamic> src) {
  final m = Map<String, dynamic>.from(src);

  // Text fields
  m['scottish'] = m['korean'];            // display word used across UI
  m['phonetic'] = m['koreanPhonetic'];    // romanization
  m['meaning']  = m['english'];           // index-language gloss
  // No context sentence in your data → leave 'context' null

  // Audio fields wired to existing UI expectations
  m['audioScottish']        = m['audioKorean'];       // main target audio
  m['audioScottishSlow']    = m['audioKoreanSlow'];   // slow target audio
  m['audioScottishContext'] = m['audioEnglish'];      // use English as "context" clip

  // Pass through other useful fields unchanged
  // id, image, showIndex, type, value, etc. are already present

  return m;
}
