import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../data/card.dart'; // ✅ ensure the path is correct

class Repository {
  static const _assetPath = 'assets/data/cards.json';

  Future<List<Flashcard>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    // 1) Remap incoming JSON to the legacy keys the model/UI expects.
    final mapped = list.map(_mapKoreanEnglishToLegacyKeys).toList();

    // 2) Sort by type; inside each type:
    //    - numbers → by numeric `numeral`
    //    - others  → alphabetically by English field
    mapped.sort(_typeAwareMapComparator);

    // 3) Parse into model objects in the already-sorted order.
    return mapped.map((j) => Flashcard.fromJson(j)).toList(growable: false);
  }
}

/// Remap your Thai/English JSON to the legacy keys expected by Flashcard.fromJson.
/// We keep original keys and add aliases; nothing is removed.
Map<String, dynamic> _mapKoreanEnglishToLegacyKeys(Map<String, dynamic> src) {
  final m = Map<String, dynamic>.from(src);

  // Display/text fields
  m['scottish'] = m['thai'];                        // 🔄 display Thai instead of Korean
  m['phonetic'] = m['phonetic'] ?? m['koreanPhonetic']; // fallback to plain 'phonetic' if no 'koreanPhonetic'
  m['meaning']  = m['english'];                     // index-language gloss
  // 'context' not present → leave null

  // Audio aliases to match existing UI expectations
  m['audioScottish']        = m['audioThai'];       // 🔄 main target audio now points to Thai
  m['audioScottishSlow']    = m['audioThai'];       // optional: reuse same clip for slow version
  m['audioScottishContext'] = m['audioEnglish'];    // use English as "context" clip

  // id, image, showIndex, type, numeral, etc. pass through unchanged
  return m;
}

/// Comparator that:
/// 1) sorts by 'type' (case-insensitive),
/// 2) if type == 'numbers' → numeric sort by 'numeral',
/// 3) otherwise → alphabetical by English field.
int _typeAwareMapComparator(Map<String, dynamic> a, Map<String, dynamic> b) {
  final ta = (a['type'] ?? '').toString().toLowerCase();
  final tb = (b['type'] ?? '').toString().toLowerCase();

  final byType = ta.compareTo(tb);
  if (byType != 0) return byType;

  if (ta == 'numbers') {
    final va = _asInt(a['numeral']);
    final vb = _asInt(b['numeral']);
    return va.compareTo(vb);
  }

  final ea = (a['english'] ?? a['meaning'] ?? '').toString().toLowerCase().trim();
  final eb = (b['english'] ?? b['meaning'] ?? '').toString().toLowerCase().trim();
  return ea.compareTo(eb);
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
