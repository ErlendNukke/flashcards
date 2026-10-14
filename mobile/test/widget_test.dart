import 'package:flashcards/widgets/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FlipCard shows question and flips on tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlipCard(
            frontLabel: 'Question',
            frontText: 'Hello',
            backLabel: 'Answer',
            backText: 'World',
          ),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    await tester.tap(find.byType(FlipCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('World'), findsOneWidget);
  });
}
