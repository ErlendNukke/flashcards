import 'package:flashcards/models/flash_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FlashCard.fromJson parses API payload', () {
    final card = FlashCard.fromJson({
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'question': 'Q?',
      'answer': 'A.',
      'createdAt': '2026-01-01T12:00:00Z',
      'updatedAt': '2026-01-01T12:00:00Z',
    });
    expect(card.question, 'Q?');
    expect(card.answer, 'A.');
  });
}
