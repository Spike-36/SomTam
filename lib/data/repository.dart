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

    // 👉 Simple phonetic log to confirm data integrity
    for (final m in mapped) {
      final phon = m['phonetic'] ?? '';
      if (phon.toString().isNotEmpty) {
        print('🧩 PHONETIC for ${m['id']}: $phon');
      }
    }

    // 2) Sort by type; inside each type:
    //    - numbers → by numeric `value`
    //    - others  → alphabetically by display string (scottish/thai)
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

  // id, image, showIndex, type, value, etc. pass through unchanged
  return m;
}

/// Comparator that:
/// 1) sorts by 'type' (case-insensitive),
/// 2) if type == 'numbers' → numeric sort by 'value',
/// 3) otherwise → alphabetical by display term (scottish/thai), with fallbacks.
int _typeAwareMapComparator(Map<String, dynamic> a, Map<String, dynamic> b) {
  final ta = (a['type'] ?? '').toString().toLowerCase();
  final tb = (b['type'] ?? '').toString().toLowerCase();

  final byType = ta.compareTo(tb);
  if (byType != 0) return byType;

  if (ta == 'numbers') {
    final va = _asInt(a['value']);
    final vb = _asInt(b['value']);
    return va.compareTo(vb);
  }

  final sa = _displayString(a);
  final sb = _displayString(b);
  return sa.compareTo(sb);
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

String _displayString(Map<String, dynamic> m) {
  // Prefer the remapped 'scottish' (now Thai). Fall back sensibly.
  final s = (m['scottish'] ??
          m['thai'] ??
          m['foreign'] ??   // legacy foreign script if present
          m['meaning'] ??   // English gloss as last resort
          '')
      .toString()
      .toLowerCase()
      .trim();
  return s;
}
