import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class I18n {
  // MVP-only languages
  static const Map<String, String> labelToCode = {
    'English': 'en',
    'French': 'fr',
    'Spanish': 'es',
    'German': 'de',
    'Arabic': 'ar',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Chinese': 'zh',
  };

  static const Set<String> rtlLangs = {'ar'};

  /// UI packs you actually ship
  static const List<String> _uiLangs = ['en','fr','es','de','ar','ja','ko','zh'];

  // Loaded UI dictionaries
  static final Map<String, Map<String, String>> _resources = {};
  static bool _loaded = false;

  static String labelFor(String code) =>
      labelToCode.entries.firstWhere(
        (e) => e.value == code,
        orElse: () => const MapEntry('English', 'en'),
      ).key;

  /// Expose ONLY MVP languages to pickers
  static List<String> get supportedLanguages => List.unmodifiable(_uiLangs);

  static Future<void> load() async {
    if (_loaded) return;
    for (final code in _uiLangs) {
      final raw = await rootBundle.loadString('assets/i18n/$code.json');
      final map = (json.decode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v.toString()));
      _resources[code] = map;
    }
    _loaded = true;
  }

  /// Normalize to MVP; anything else → 'en'
  static String normalize(String? lang) {
    if (lang == null || lang.trim().isEmpty) return 'en';
    final raw = lang.trim();

    // exact code
    if (_uiLangs.contains(raw)) return raw;

    // label
    final fromLabel = labelToCode[raw];
    if (fromLabel != null) return fromLabel;

    // base of locale like 'fr-FR' -> 'fr'
    final base = raw.toLowerCase().split('-').first;
    if (_uiLangs.contains(base)) return base;

    return 'en';
  }

  /// UI strings (keys in en/fr/… JSONs)
  static String t(String key, {String lang = 'en'}) {
    final code = normalize(lang);
    final dict = _resources[code] ?? _resources['en'];
    if (dict != null && dict.containsKey(key)) return dict[key]!;
    return key;
  }

  static bool isRTL(String? lang) => rtlLangs.contains(normalize(lang));
}
