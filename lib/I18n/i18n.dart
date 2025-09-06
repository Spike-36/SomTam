// lib/i18n/i18n.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class I18n {
  // MVP-only languages (English labels → ISO codes)
  static const Map<String, String> labelToCode = {
    'English': 'en',
    'French':  'fr',
    'Spanish': 'es',
    'German':  'de',
    'Arabic':  'ar',
    'Japanese':'ja',
    'Korean':  'ko',
    'Chinese': 'zh',
  };

  // Native endonyms for display (ISO code → native name)
  static const Map<String, String> _nativeLabel = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'ar': 'العربية',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
  };

  static const Set<String> rtlLangs = {'ar'};

  /// UI packs you actually ship
  static const List<String> _uiLangs = ['en','fr','es','de','ar','ja','ko','zh'];

  // ---- Global selected language (single source of truth) ----
  static String _currentLang = 'en';
  static String get currentLang => _currentLang;
  static void setCurrentLang(String code) {
    _currentLang = normalize(code);
  }

  // Loaded UI dictionaries
  static final Map<String, Map<String, String>> _resources = {};
  static bool _loaded = false;

  /// English label for ISO code
  static String labelFor(String code) {
    final c = normalize(code);
    // Find by code in labelToCode values
    final hit = labelToCode.entries.firstWhere(
      (e) => e.value == c,
      orElse: () => const MapEntry('English', 'en'),
    );
    return hit.key;
  }

  /// Native endonym for ISO code (falls back to English label)
  static String nativeLabelFor(String code) {
    final c = normalize(code);
    return _nativeLabel[c] ?? labelFor(c);
  }

  /// “Native (English)” combined label, avoiding duplicates (e.g. English)
  static String combinedLabel(String code) {
    final native = nativeLabelFor(code);
    final english = labelFor(code);
    return native.toLowerCase() == english.toLowerCase()
        ? native
        : '$native ($english)';
  }

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

  /// Normalize to MVP; labels or locales like 'fr-FR' → 'fr'; anything else → 'en'
  static String normalize(String? lang) {
    if (lang == null || lang.trim().isEmpty) return 'en';
    final raw = lang.trim();

    // exact ISO code
    if (_uiLangs.contains(raw)) return raw;

    // locale like 'fr-FR' or 'fr_FR'
    final lowered = raw.toLowerCase();
    final base = lowered.split(RegExp(r'[-_]')).first;
    if (_uiLangs.contains(base)) return base;

    // label (case-insensitive) → code
    final byLabel = labelToCode.entries.firstWhere(
      (e) => e.key.toLowerCase() == lowered,
      orElse: () => const MapEntry('', ''),
    );
    if (byLabel.value.isNotEmpty) return byLabel.value;

    return 'en';
  }

  /// UI strings (keys in en/fr/… JSONs)
  static String t(String key, {String lang = 'en'}) {
    final code = normalize(lang);
    final dict = _resources[code] ?? _resources['en'];
    if (dict != null && dict.containsKey(key)) return dict[key]!;
    return key;
  }

  /// Convenience: translate with the current global language
  static String tc(String key) => t(key, lang: _currentLang);

  static bool isRTL(String? lang) => rtlLangs.contains(normalize(lang));
}
