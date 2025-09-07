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

  // i18n maps built from keys like "French", "French_Context", "French_Info"
  final Map<String, String>? meaningI18n;
  final Map<String, String>? contextI18n;
  final Map<String, String>? infoI18n; // per-language info text

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
    this.infoI18n,
  });

  factory Flashcard.fromJson(Map<String, dynamic> j) {
    String s(dynamic v) => (v ?? '').toString().trim();

    final Map<String, String> mMap = {}; // meaning
    final Map<String, String> cMap = {}; // context
    final Map<String, String> iMap = {}; // info

    final rawMeaning = j['meaning'];
    final rawContext = j['context'];

    // Legacy EN strings
    if (rawMeaning is String && rawMeaning.trim().isNotEmpty) {
      mMap['en'] = rawMeaning.trim();
    }
    if (rawContext is String && rawContext.trim().isNotEmpty) {
      cMap['en'] = rawContext.trim();
    }

    // Map-style { "en": "...", "fr": "..." }
    if (rawMeaning is Map) {
      rawMeaning.forEach((k, v) => mMap[k.toString()] = (v ?? '').toString());
    }
    if (rawContext is Map) {
      rawContext.forEach((k, v) => cMap[k.toString()] = (v ?? '').toString());
    }

    // Scan all entries for "Label", "Label_Context", "Label_Info"
    for (final entry in j.entries) {
      final key = entry.key.toString();
      final val = (entry.value ?? '').toString().trim();
      if (val.isEmpty) continue;

      // "French" / "Spanish" -> meaning
      if (I18n.labelToCode.containsKey(key)) {
        final code = I18n.labelToCode[key]!;
        mMap[code] = val;
        continue;
      }

      // "..._Context" -> context
      const ctxSuffix = '_Context';
      if (key.endsWith(ctxSuffix)) {
        final base = key.substring(0, key.length - ctxSuffix.length);

        if (I18n.labelToCode.containsKey(base)) {
          final code = I18n.labelToCode[base]!;
          cMap[code] = val;
        } else {
          // Accept ISO-like codes only, ignore unknown labels
          final lower = base.toLowerCase();
          final iso = lower.split(RegExp(r'[-_]')).first;
          final looksIso = RegExp(r'^[a-z]{2}$').hasMatch(iso);
          if (looksIso) {
            cMap[iso] = val;
          }
        }
        continue;
      }

      // "..._Info" -> info
      const infoSuffix = '_Info';
      if (key.endsWith(infoSuffix)) {
        final base = key.substring(0, key.length - infoSuffix.length);

        if (I18n.labelToCode.containsKey(base)) {
          final code = I18n.labelToCode[base]!;
          iMap[code] = val;
        } else {
          // Accept ISO-like codes only, ignore unknown labels
          final lower = base.toLowerCase();
          final iso = lower.split(RegExp(r'[-_]')).first;
          final looksIso = RegExp(r'^[a-z]{2}$').hasMatch(iso);
          if (looksIso) {
            iMap[iso] = val;
          }
        }
        continue;
      }
    }

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
      infoI18n: iMap.isEmpty ? null : iMap,
    );
  }

  // ----------------- helpers (empty-string aware fallbacks) -----------------

  String _pick(Map<String, String>? map, String code, String legacyEn, String legacy) {
    if (map == null) return legacy;
    final sel = (map[code] ?? '').trim();
    if (sel.isNotEmpty) return sel;

    // Try language region collapse (e.g., fr-FR -> fr)
    if (code.contains('-') || code.contains('_')) {
      final base = code.split(RegExp(r'[-_]')).first;
      final baseVal = (map[base] ?? '').trim();
      if (baseVal.isNotEmpty) return baseVal;
    }

    final en = (map['en'] ?? legacyEn).trim();
    if (en.isNotEmpty) return en;

    return legacy;
  }

  String meaningFor(String lang) {
    final code = I18n.normalize(lang);
    return _pick(meaningI18n, code, meaningI18n?['en'] ?? '', meaning);
  }

  String contextFor(String lang) {
    final code = I18n.normalize(lang);
    return _pick(contextI18n, code, contextI18n?['en'] ?? '', context);
  }

  /// Per-language info text.
  /// Rule: chosen language → English → else empty.
  String infoFor(String lang) {
    final code = I18n.normalize(lang);
    final m = infoI18n;
    if (m == null) return '';
    final sel = (m[code] ?? '').trim();
    if (sel.isNotEmpty) return sel;

    if (code.contains('-') || code.contains('_')) {
      final base = code.split(RegExp(r'[-_]')).first;
      final baseVal = (m[base] ?? '').trim();
      if (baseVal.isNotEmpty) return baseVal;
    }

    final en = (m['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    return '';
  }
}
