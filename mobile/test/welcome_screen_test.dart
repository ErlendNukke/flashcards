import 'package:flashcards/screens/login_screen.dart';
import 'package:flashcards/screens/sign_up_screen.dart';
import 'package:flashcards/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome shows branding, features, and auth actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Flashcards'), findsOneWidget);
    expect(find.textContaining('question on one side'), findsOneWidget);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Flip & swipe'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign up'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Log in'), findsOneWidget);
  });

  testWidgets('welcome navigates to sign up and log in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
    await tester.pumpAndSettle();

    final signUp = find.widgetWithText(FilledButton, 'Sign up');
    await tester.scrollUntilVisible(signUp, 200);
    await tester.tap(signUp);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    final logIn = find.widgetWithText(OutlinedButton, 'Log in');
    await tester.scrollUntilVisible(logIn, 200);
    await tester.tap(logIn);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
