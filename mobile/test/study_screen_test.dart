import 'dart:math';

import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/screens/study_screen.dart';
import 'package:flashcards/widgets/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlashCard _card(String id, String question) {
  final now = DateTime.utc(2026, 1, 1);
  return FlashCard(
    id: id,
    question: question,
    answer: 'Answer $id',
    folderId: null,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('reshuffle resets to first card and question side', (tester) async {
    final cards = [
      _card('1', 'Alpha'),
      _card('2', 'Beta'),
      _card('3', 'Gamma'),
    ];
    final random = Random(99);

    await tester.pumpWidget(
      MaterialApp(
        home: StudyScreen(
          title: 'Test',
          cards: cards,
          shuffleRandom: random,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilterChip));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);

    await tester.tap(find.byType(FlipCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Answer '), findsWidgets);

    await tester.tap(find.byTooltip('Reshuffle'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.textContaining('Answer '), findsNothing);
  });

  testWidgets('horizontal swipe advances to next card with question first', (tester) async {
    final cards = [
      _card('1', 'One'),
      _card('2', 'Two'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: StudyScreen(title: 'Test', cards: cards),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);

    await tester.tap(find.byType(FlipCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Answer 1'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-420, 0));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.text('Answer 1'), findsNothing);
  });

  testWidgets('swipe right returns to previous card', (tester) async {
    final cards = [
      _card('1', 'First'),
      _card('2', 'Second'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: StudyScreen(title: 'Test', cards: cards),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(420, 0));
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
  });
}
