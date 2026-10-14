import 'dart:math';

import 'package:flashcards/utils/study_shuffle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shuffledCopy contains all cards exactly once', () {
    const ids = ['a', 'b', 'c', 'd', 'e'];
    final random = Random(42);
    final shuffled = shuffledCopy(ids, random);
    expect(shuffled.length, ids.length);
    expect(sameMultiset(shuffled, ids), isTrue);
    expect(shuffled.toSet().length, ids.length);
  });

  test('shuffledCopy is deterministic for seeded Random', () {
    final first = shuffledCopy([1, 2, 3, 4], Random(7));
    final second = shuffledCopy([1, 2, 3, 4], Random(7));
    expect(first, second);
  });
}
