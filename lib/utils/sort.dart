import '../data/card.dart';

/// Sort cards by type, then by headword.
/// Special case: if type == "numbers", order by numeric `value`.
List<Flashcard> sortByTypeThenHeadword(List<Flashcard> cards) {
  final grouped = <String, List<Flashcard>>{};

  for (final c in cards) {
    final type = (c.type ?? '').trim().toLowerCase();
    grouped.putIfAbsent(type, () => []).add(c);
  }

  final types = grouped.keys.toList()..sort();

  final result = <Flashcard>[];
  for (final t in types) {
    final list = [...grouped[t]!];

    if (t == 'numbers') {
      int asInt(int? v) => v ?? 999999; // nulls last
      list.sort((a, b) => asInt(a.value).compareTo(asInt(b.value)));
    } else {
      // 🔑 Always sort alphabetically by English (meaning)
      String asText(Flashcard c) =>
          (c.meaning ?? '').trim().toLowerCase();
      list.sort((a, b) => asText(a).compareTo(asText(b)));
    }

    result.addAll(list);
  }

  return result;
}
