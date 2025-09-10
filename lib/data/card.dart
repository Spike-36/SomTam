// lib/data/card.dart
import 'package:flutter/foundation.dart';

@immutable
class Flashcard {
  final String id;
  final String type;
  final String scottish;       // target word (non-null, defaults to '')
  final String phonetic;       // romanization
  final String meaning;        // index-language gloss
  final String context;        // optional sentence
  final String grammarType;
  final String image;

  // audio
  final String? audioScottish;
  final String? audioScottishSlow;
  final String? audioScottishContext;

  // NEW: numeric value for number words
  final int? value;

  // extra fields from legacy data
  final String ipa;
  final String showIndex;
  final Map<String, dynamic>? extra;

  const Flashcard({
    required this.id,
    required this.type,
    this.scottish = '',
    this.phonetic = '',
    this.meaning = '',
    this.context = '',
    this.grammarType = '',
    this.image = '',
    this.audioScottish,
    this.audioScottishSlow,
    this.audioScottishContext,
    this.value,
    this.ipa = '',
    this.showIndex = '',
    this.extra,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      scottish: json['scottish']?.toString() ?? '',
      phonetic: json['phonetic']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      context: json['context']?.toString() ?? '',
      grammarType: json['grammarType']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      audioScottish: json['audioScottish'] as String?,
      audioScottishSlow: json['audioScottishSlow'] as String?,
      audioScottishContext: json['audioScottishContext'] as String?,
      value: _asOptInt(json['value']),
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

  /// Return localized meaning if available, else fallback.
  String meaningFor(String lang) {
    // Right now just return meaning, could be extended later
    return meaning;
  }
}
