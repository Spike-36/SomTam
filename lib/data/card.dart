class Flashcard {
  final String id;
  final String scottish;                 // e.g., "aye"
  final String meaning;                  // English meaning (for now)
  final String phonetic;                 // e.g., "eye"
  final String context;                  // e.g., sentence
  final String grammarType;              // e.g., "interjection"
  final String audioScottish;            // filename only, e.g., "Z005.aye.scottish.mp3"
  final String audioScottishContext;     // filename only
  final String audioScottishSlow;        // filename only

  // Optional fields if they exist in the JSON (safe defaults)
  final String ipa;

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
  });

  factory Flashcard.fromJson(Map<String, dynamic> j) {
    String s(dynamic v) => (v ?? '').toString().trim();

    return Flashcard(
      id: s(j['id']),
      scottish: s(j['scottish']),
      meaning: s(j['meaning']),
      phonetic: s(j['phonetic']),
      context: s(j['context']),
      grammarType: s(j['grammarType']),
      audioScottish: s(j['audioScottish']),
      audioScottishContext: s(j['audioScottishContext']),
      audioScottishSlow: s(j['audioScottishSlow']),
      ipa: s(j['ipa']),
    );
  }
}
