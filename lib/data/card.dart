import 'package:flutter/foundation.dart';

@immutable
class Flashcard {
  // 🔄 CHANGED: type → types (multiple categories)
  // 👉 Every card can now belong to multiple categories.
  final List<String> types;

  final String id;
  final String scottish;       // target word (legacy / Korean)
  final String thai;           
  final String phonetic;       
  final String meaning;        
  final String context;        
  final String grammarType;
  final String image;

  // audio
  final String? audioScottish;
  final String? audioScottishSlow;
  final String? audioScottishContext;

  // Thai audio
  final String? audioThai;

  // numeric value for number words
  final int? value;

  // legacy extras
  final String ipa;
  final String showIndex;
  final Map<String, dynamic>? extra;

  const Flashcard({
    required this.id,
    required this.types,  // 👉 NEW LIST FIELD
    this.scottish = '',
    this.thai = '',
    this.phonetic = '',
    this.meaning = '',
    this.context = '',
    this.grammarType = '',
    this.image = '',
    this.audioScottish,
    this.audioScottishSlow,
    this.audioScottishContext,
    this.audioThai,
    this.value,
    this.ipa = '',
    this.showIndex = '',
    this.extra,
  });

  // 🔧 helper: parse "['A','B']" or "A" into a List<String>
  static List<String> _parseTypes(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      // Already a real list
      return raw.map((e) => e.toString()).toList();
    }

    if (raw is String) {
      final s = raw.trim();

      // Case 1: JSON-style stringified list: ["A","B"]
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final cleaned = s
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
              .where((e) => e.isNotEmpty)
              .toList();
          return cleaned;
        } catch (_) {
          // fall through to single-value fallback
        }
      }

      // Case 2: plain string
      if (s.isNotEmpty) return [s];
    }

    return [];
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id']?.toString() ?? '',

      // 🔄 CHANGED: convert JSON 'type' → List<String> types
      types: _parseTypes(json['type']),   // 👉 NEW BEHAVIOUR

      scottish: json['scottish']?.toString() ?? '',
      thai: json['thai']?.toString() ?? '',
      phonetic: json['phonetic']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      context: json['context']?.toString() ?? '',
      grammarType: json['grammarType']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      audioScottish: json['audioScottish'] as String?,
      audioScottishSlow: json['audioScottishSlow'] as String?,
      audioScottishContext: json['audioScottishContext'] as String?,
      audioThai: json['audioThai'] as String?,
      value: _asOptInt(json['value'] ?? json['numeral']),
      ipa: json['ipa']?.toString() ?? '',
      showIndex: json['showIndex']?.toString() ?? '',
      extra: json,
    );
  }

  // --- helpers ---
  static int? _asOptInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  String meaningFor(String lang) {
    return meaning;
  }
}
