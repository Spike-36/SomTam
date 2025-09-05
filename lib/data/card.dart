// lib/data/card.dart
import '../I18n/i18n.dart'; // normalize + labelToCode

class Flashcard {
  final String id;
  final String scottish;
  final String meaning;              // legacy/default (usually EN)
  final String phonetic;
  final String context;              // legacy/default
  final String grammarType;
  final String audioScottish;
  final String audioScottishContext;
  final String audioScottishSlow;
  final String ipa;

  // NEW: built from legacy keys like "French", "French_Context"
  final Map<String, String>? meaningI18n;
  final Map<String, String>? contextI18n;

  Flashcard({
    required this.id,
    required this.scottish,
    required this.meaning,
    required this.phonetic,
    required this.context,
    required this.grammarType,
    required this.audioScottish,
    required this.audioScottishContext,
    required this.audioScottishSlow,
    this.ipa = '',
    this.meaningI18n,
    this.contextI18n,
  });

  factory Flashcard.fromJson(Map<String, dynamic> j) {
    String s(dynamic v) => (v ?? '').toString().trim();

    // 1) Collect i18n maps from your legacy fields:
    final Map<String, String> mMap = {};
    final Map<String, String> cMap = {};

    // Pull from "meaning"/"context" if they’re plain strings
    final rawMeaning = j['meaning'];
    final rawContext = j['context'];
    if (rawMeaning is String && rawMeaning.trim().isNotEmpty) mMap['en'] = rawMeaning.trim();
    if (rawContext is String && rawContext.trim().isNotEmpty) cMap['en'] = rawContext.trim();

    // Scan every entry like "French", "French_Context"
    for (final entry in j.entries) {
      final key = entry.key.toString();
      final val = (entry.value ?? '').toString().trim();
      if (val.isEmpty) continue;

      // e.g., "French", "Spanish", "Arabic", etc.
      if (I18n.labelToCode.containsKey(key)) {
        final code = I18n.labelToCode[key]!;
        mMap[code] = val;
        continue;
      }

      // e.g., "French_Context"
      const suffix = '_Context';
      if (key.endsWith(suffix)) {
        final base = key.substring(0, key.length - suffix.length);
        if (I18n.labelToCode.containsKey(base)) {
          final code = I18n.labelToCode[base]!;
          cMap[code] = val;
        }
      }
    }

    // 2) If "meaning"/"context" were provided as { "en": "...", "fr": "..." } maps, merge them in.
    if (rawMeaning is Map) {
      rawMeaning.forEach((k, v) => mMap[k.toString()] = (v ?? '').toString());
    }
    if (rawContext is Map) {
      rawContext.forEach((k, v) => cMap[k.toString()] = (v ?? '').toString());
    }

    // 3) Build the object (legacy fields keep EN/fallback so old UI still works)
    final legacyMeaning = mMap['en'] ?? s(rawMeaning);
    final legacyContext = cMap['en'] ?? s(rawContext);

    return Flashcard(
      id: s(j['id']),
      scottish: s(j['scottish']),
      meaning: legacyMeaning,
      phonetic: s(j['phonetic']),
      context: legacyContext,
      grammarType: s(j['grammarType']),
      audioScottish: s(j['audioScottish']),
      audioScottishContext: s(j['audioScottishContext']),
      audioScottishSlow: s(j['audioScottishSlow']),
      ipa: s(j['ipa']),
      meaningI18n: mMap.isEmpty ? null : mMap,
      contextI18n: cMap.isEmpty ? null : cMap,
    );
  }

  // ----- helpers -----
  String meaningFor(String lang) {
    final code = I18n.normalize(lang);
    if (meaningI18n != null) {
      return meaningI18n![code] ?? meaningI18n!['en'] ?? meaning;
    }
    return meaning;
  }

  String contextFor(String lang) {
    final code = I18n.normalize(lang);
    if (contextI18n != null) {
      return contextI18n![code] ?? contextI18n!['en'] ?? context;
    }
    return context;
  }
}
