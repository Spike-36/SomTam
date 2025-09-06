// lib/I18n/grammar_i18n.dart
// Canonical grammar keys and localized labels for ~12 languages.
// Mirrors the braw2 JS version, kept tiny and boring on purpose.

import 'package:flutter/foundation.dart';

// Canonical labels
const Map<String, Map<String, String>> _GRAMMAR_LABELS = {
  'noun': {
    'en': 'Noun', 'fr': 'Nom', 'de': 'Substantiv', 'es': 'Sustantivo', 'it': 'Sostantivo', 'pt': 'Substantivo',
    'zh': '名词', 'ja': '名詞', 'ko': '명사', 'th': 'คำนาม', 'tr': 'İsim', 'ar': 'اسم',
  },
  'proper_noun': {
    'en': 'Proper noun', 'fr': 'Nom propre', 'de': 'Eigenname', 'es': 'Nombre propio', 'it': 'Nome proprio', 'pt': 'Nome próprio',
    'zh': '专有名词', 'ja': '固有名詞', 'ko': '고유명사', 'th': 'ชื่อเฉพาะ', 'tr': 'Özel isim', 'ar': 'اسم علم',
  },
  'verb': {
    'en': 'Verb', 'fr': 'Verbe', 'de': 'Verb', 'es': 'Verbo', 'it': 'Verbo', 'pt': 'Verbo',
    'zh': '动词', 'ja': '動詞', 'ko': '동사', 'th': 'คำกริยา', 'tr': 'Fiil', 'ar': 'فعل',
  },
  'auxiliary_verb': {
    'en': 'Auxiliary verb', 'fr': 'Verbe auxiliaire', 'de': 'Hilfsverb', 'es': 'Verbo auxiliar', 'it': 'Verbo ausiliare', 'pt': 'Verbo auxiliar',
    'zh': '助动词', 'ja': '助動詞', 'ko': '조동사', 'th': 'กริยาช่วย', 'tr': 'Yardımcı fiil', 'ar': 'فعل مساعد',
  },
  'phrasal_verb': {
    'en': 'Phrasal verb', 'fr': 'Verbe à particule', 'de': 'Verb mit Partikel', 'es': 'Verbo frasal', 'it': 'Verbo frasale', 'pt': 'Verbo frasal',
    'zh': '短语动词', 'ja': '句動詞', 'ko': '구동사', 'th': 'กริยาวลี', 'tr': 'Deyimsel fiil', 'ar': 'فعل مركّب',
  },
  'adjective': {
    'en': 'Adjective', 'fr': 'Adjectif', 'de': 'Adjektiv', 'es': 'Adjetivo', 'it': 'Aggettivo', 'pt': 'Adjetivo',
    'zh': '形容词', 'ja': '形容詞', 'ko': '형용사', 'th': 'คำคุณศัพท์', 'tr': 'Sıfat', 'ar': 'صفة',
  },
  'adverb': {
    'en': 'Adverb', 'fr': 'Adverbe', 'de': 'Adverb', 'es': 'Adverbio', 'it': 'Avverbio', 'pt': 'Advérbio',
    'zh': '副词', 'ja': '副詞', 'ko': '부사', 'th': 'คำวิเศษณ์', 'tr': 'Zarf', 'ar': 'حال',
  },
  'pronoun': {
    'en': 'Pronoun', 'fr': 'Pronom', 'de': 'Pronomen', 'es': 'Pronombre', 'it': 'Pronome', 'pt': 'Pronome',
    'zh': '代词', 'ja': '代名詞', 'ko': '대명사', 'th': 'สรรพนาม', 'tr': 'Zamir', 'ar': 'ضمير',
  },
  'preposition': {
    'en': 'Preposition', 'fr': 'Préposition', 'de': 'Präposition', 'es': 'Preposición', 'it': 'Preposizione', 'pt': 'Preposição',
    'zh': '介词', 'ja': '前置詞', 'ko': '전치사', 'th': 'บุพบท', 'tr': 'Edat', 'ar': 'حرف جرّ',
  },
  'conjunction': {
    'en': 'Conjunction', 'fr': 'Conjonction', 'de': 'Konjunktion', 'es': 'Conjunción', 'it': 'Congiunzione', 'pt': 'Conjunção',
    'zh': '连词', 'ja': '接続詞', 'ko': '접속사', 'th': 'สันธาน', 'tr': 'Bağlaç', 'ar': 'حرف عطف',
  },
  'interjection': {
    'en': 'Interjection', 'fr': 'Interjection', 'de': 'Interjektion', 'es': 'Interjección', 'it': 'Interiezione', 'pt': 'Interjeição',
    'zh': '感叹词', 'ja': '感動詞', 'ko': '감탄사', 'th': 'คำอุทาน', 'tr': 'Ünlem', 'ar': 'أداة تعجب',
  },
  'article': {
    'en': 'Article', 'fr': 'Article', 'de': 'Artikel', 'es': 'Artículo', 'it': 'Articolo', 'pt': 'Artigo',
    'zh': '冠词', 'ja': '冠詞', 'ko': '관사', 'th': 'คำนำหน้านาม', 'tr': 'Artikl', 'ar': 'أداة تعريف/نكرة',
  },
  'determiner': {
    'en': 'Determiner', 'fr': 'Déterminant', 'de': 'Determinativ', 'es': 'Determinante', 'it': 'Determinante', 'pt': 'Determinante',
    'zh': '限定词', 'ja': '限定詞', 'ko': '한정사', 'th': 'ตัวกำหนด', 'tr': 'Belirteç', 'ar': 'محدِّد',
  },
  'numeral': {
    'en': 'Numeral', 'fr': 'Numéral', 'de': 'Zahlwort', 'es': 'Numeral', 'it': 'Numerale', 'pt': 'Numeral',
    'zh': '数词', 'ja': '数詞', 'ko': '수사', 'th': 'เลขลำดับ/จำนวน', 'tr': 'Sayı sözcüğü', 'ar': 'عدد',
  },
  'participle': {
    'en': 'Participle', 'fr': 'Participe', 'de': 'Partizip', 'es': 'Participio', 'it': 'Participio', 'pt': 'Particípio',
    'zh': '分词', 'ja': '分詞', 'ko': '분사', 'th': 'กริยานุเคราะห์ (participle)', 'tr': 'Ortaç', 'ar': 'اسم فاعل/مفعول',
  },
  'gerund': {
    'en': 'Gerund', 'fr': 'Gérondif', 'de': 'Gerundium', 'es': 'Gerundio', 'it': 'Gerundio', 'pt': 'Gerúndio',
    'zh': '动名词', 'ja': '動名詞', 'ko': '동명사', 'th': 'กริยานาม', 'tr': 'Ulaç/gerund', 'ar': 'مصدر مؤول',
  },
  'imperative': {
    'en': 'Imperative', 'fr': 'Impératif', 'de': 'Imperativ', 'es': 'Imperativo', 'it': 'Imperativo', 'pt': 'Imperativo',
    'zh': '祈使', 'ja': '命令', 'ko': '명령형', 'th': 'คำสั่ง', 'tr': 'Emir kipi', 'ar': 'أمر',
  },
  'phrase': {
    'en': 'Phrase', 'fr': 'Locution', 'de': 'Redewendung', 'es': 'Expresión', 'it': 'Locuzione', 'pt': 'Expressão',
    'zh': '短语', 'ja': '句', 'ko': '구/표현', 'th': 'วลี/สำนวน', 'tr': 'İfade', 'ar': 'تعبير',
  },
  'idiom': {
    'en': 'Idiom', 'fr': 'Expression idiomatique', 'de': 'Idiom', 'es': 'Modismo', 'it': 'Modo di dire', 'pt': 'Expressão idiomática',
    'zh': '习语', 'ja': '慣用句', 'ko': '관용구', 'th': 'สำนวน', 'tr': 'Deyim', 'ar': 'تعبير اصطلاحي',
  },
};

// Be forgiving with upstream values (e.g., "Adj.", "proper noun", "phrasalverb")
const Map<String, String> _GRAMMAR_ALIASES = {
  'n': 'noun',
  'noun': 'noun',
  'proper noun': 'proper_noun',
  'propernoun': 'proper_noun',
  'pn': 'proper_noun',

  'v': 'verb',
  'verb': 'verb',
  'aux verb': 'auxiliary_verb',
  'auxiliary verb': 'auxiliary_verb',
  'auxverb': 'auxiliary_verb',
  'phrasal verb': 'phrasal_verb',
  'phrasalverb': 'phrasal_verb',

  'adj': 'adjective',
  'adjective': 'adjective',

  'adv': 'adverb',
  'adverb': 'adverb',

  'pron': 'pronoun',
  'pronoun': 'pronoun',

  'prep': 'preposition',
  'preposition': 'preposition',

  'conj': 'conjunction',
  'conjunction': 'conjunction',

  'interj': 'interjection',
  'interjection': 'interjection',

  'article': 'article',
  'determiner': 'determiner',

  'numeral': 'numeral',
  'number': 'numeral',

  'phrase': 'phrase',
  'idiom': 'idiom',
};

String _canonicalize(String key) =>
    key.trim().toLowerCase().replaceAll('.', '').replaceAll(RegExp(r'\s+'), ' ');

/// Returns a canonical grammar key (e.g., "Adj." -> "adjective")
String normalizeGrammar(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final base = _canonicalize(raw);
  return _GRAMMAR_ALIASES[base] ?? base.replaceAll(RegExp(r'\s+'), '_');
}

String _primaryLocale(String langCode) {
  final lc = langCode.toLowerCase();
  // Accept en, en-GB, en_GB, etc.
  final sep = lc.contains('-') ? '-' : (lc.contains('_') ? '_' : '');
  return sep.isEmpty ? lc : lc.split(sep).first;
}

/// Translate a raw/aliased grammar token into a localized label.
/// Unknown key → original raw value. Missing locale → English → original.
String tGrammar(String? raw, {String langCode = 'en'}) {
  if (raw == null || raw.trim().isEmpty) return '';
  final key = normalizeGrammar(raw);
  final row = _GRAMMAR_LABELS[key];
  if (row == null) return raw;
  final lang = _primaryLocale(langCode);
  return row[lang] ?? row['en'] ?? raw;
}

/// Optional: quick dev-time validation
void validateGrammarTable([List<String> locales = const [
  'en','fr','de','es','it','pt','zh','ja','ko','th','tr','ar'
]]) {
  if (!kDebugMode) return;
  final missing = <String>[];
  _GRAMMAR_LABELS.forEach((key, row) {
    for (final loc in locales) {
      if (!row.containsKey(loc)) missing.add('$key.$loc');
    }
  });
  if (missing.isNotEmpty) {
    // ignore: avoid_print
    print('[grammar] Missing labels: '
        '${missing.take(20).toList()}'
        '${missing.length > 20 ? ' (+${missing.length - 20} more)' : ''}');
  }
}
