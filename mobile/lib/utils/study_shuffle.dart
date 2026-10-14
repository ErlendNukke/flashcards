import 'dart:math';

/// Returns a new list with the same elements in random order.
List<T> shuffledCopy<T>(List<T> items, Random random) {
  final copy = List<T>.from(items);
  copy.shuffle(random);
  return copy;
}

/// True when both lists contain the same elements with the same multiplicity.
bool sameMultiset<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  final counts = <T, int>{};
  for (final item in a) {
    counts[item] = (counts[item] ?? 0) + 1;
  }
  for (final item in b) {
    final left = counts[item];
    if (left == null || left == 0) return false;
    counts[item] = left - 1;
  }
  return counts.values.every((c) => c == 0);
}
