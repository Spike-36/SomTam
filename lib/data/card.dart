// lib/data/card.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class Flashcard {
  // multiple categories
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

  // numeric value
  final int? value;

  // NEW SUBCATEGORY FIELDS 👉
  final String drinksType;
  final String hasTypes;
  final String proteinTypes;

  // legacy extras
  final String ipa;
  final String showIndex;
  final Map<String, dynamic>? extra;

  const Flashcard({
    required this.id,
    required this.types,
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

    // NEW FIELDS 👉
    this.drinksType = '',
    this.hasTypes = '',
    this.proteinTypes = '',

    this.ipa = '',
    this.showIndex = '',
    this.extra,
  });

  // ============================================================
  // FIXED TYPE PARSER — handles JSON strings with commas safely
  // ============================================================
  static List<String> _parseTypes(dynamic raw) {
    if (raw == null) return [];

    // Already a List
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).toList();
    }

    // String case
    if (raw is String) {
      final s = raw.trim();

      // Case: string looks like JSON list → decode properly
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final decoded = jsonDecode(s);

          if (decoded is List) {
            return decoded
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } catch (_) {
          // fallback below
        }
      }

      // fallback: treat as a single category
      if (s.isNotEmpty) return [s];
    }

    return [];
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id']?.toString() ?? '',
      types: _parseTypes(json['type']),

      scottish: json['scottish']?.toString() ?? '',
      thai: json['thai']?.toString() ?? '',
      phonetic: json['phonetic']?.toString() ?? '',
      meaning: json['english']?.toString() ?? json['meaning']?.toString() ?? '',
      context: json['context']?.toString() ?? '',
      grammarType: json['grammarType']?.toString() ?? '',
      image: json['image']?.toString() ?? '',

      audioScottish: json['audioScottish'] as String?,
      audioScottishSlow: json['audioScottishSlow'] as String?,
      audioScottishContext: json['audioScottishContext'] as String?,
      audioThai: json['audioThai'] as String?,

      value: _asOptInt(json['value'] ?? json['numeral']),

      // NEW SUBCATEGORY MAPPINGS 👉
      drinksType: json['drinksType']?.toString() ?? '',
      hasTypes: json['hasTypes']?.toString() ?? '',
      proteinTypes: json['proteinTypes']?.toString() ?? '',

      ipa: json['ipa']?.toString() ?? '',
      showIndex: json['showIndex']?.toString() ?? '',
      extra: json,
    );
  }

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
