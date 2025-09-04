class Flashcard {
  final int id;                 // if you have it
  final String term;
  final String meaning;
  final String image;           // asset path
  final String audio;           // asset path
  final String? video;          // nullable

  Flashcard({
    required this.id,
    required this.term,
    required this.meaning,
    required this.image,
    required this.audio,
    this.video,
  });

  factory Flashcard.fromJson(Map<String, dynamic> j) {
    // tolerate missing/null/mistyped values
    int _toInt(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    String _toStr(dynamic v, {String fallback = ''}) {
      return (v is String && v.isNotEmpty) ? v : fallback;
    }

    return Flashcard(
      id: _toInt(j['id'], fallback: 0),
      term: _toStr(j['term']),
      meaning: _toStr(j['meaning']),
      image: _toStr(j['image']),
      audio: _toStr(j['audio']),
      video: j['video'] == null || j['video'] == '' ? null : j['video'] as String,
    );
  }
}
