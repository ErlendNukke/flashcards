import 'package:flashcards/models/app_user.dart';
import 'package:flashcards/screens/auth_gate.dart';
import 'package:flashcards/screens/home_screen.dart';
import 'package:flashcards/screens/login_screen.dart';
import 'package:flashcards/services/api_client.dart';
import 'package:flashcards/services/auth_service.dart';
import 'package:flashcards/services/card_service.dart';
import 'package:flashcards/services/folder_service.dart';
import 'package:flashcards/models/folder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthService extends AuthService {
  _TestAuthService(super.api);

  bool failLogin = false;

  @override
  Future<void> bootstrap() async {
    ready = true;
    notifyListeners();
  }

  @override
  Future<void> login(String username, String password) async {
    await Future<void>.delayed(Duration.zero);
    if (failLogin) {
      throw ApiException('Invalid username or password');
    }
    applyTestSession(
      token: 'test-token',
      user: AppUser(id: 'user-1', username: username.toLowerCase()),
    );
  }
}

class _StubFolderService extends FolderService {
  _StubFolderService(super.api);

  @override
  Future<LibrarySummary> fetchLibrary() async {
    return LibrarySummary(folders: [], unfiledCount: 0);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpAuthApp(WidgetTester tester, AuthService auth, ApiClient api) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          Provider<FolderService>.value(value: _StubFolderService(api)),
          Provider<CardService>.value(value: CardService(api)),
        ],
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('welcome then login reaches home', (tester) async {
    final api = ApiClient(baseUrl: 'http://test.local');
    final auth = _TestAuthService(api);
    auth.ready = true;
    await pumpAuthApp(tester, auth, api);

    expect(find.text('Flashcards'), findsWidgets);
    expect(find.byType(HomeScreen), findsNothing);

    final logIn = find.widgetWithText(OutlinedButton, 'Log in');
    await tester.scrollUntilVisible(logIn, 200);
    await tester.tap(logIn);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'erlen');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Unfiled'), findsOneWidget);
    expect(find.text('New folder'), findsOneWidget);
  });

  testWidgets('login shows error for invalid credentials', (tester) async {
    final api = ApiClient(baseUrl: 'http://test.local');
    final auth = _TestAuthService(api);
    auth.ready = true;
    auth.failLogin = true;
    await pumpAuthApp(tester, auth, api);

    final logIn = find.widgetWithText(OutlinedButton, 'Log in');
    await tester.scrollUntilVisible(logIn, 200);
    await tester.tap(logIn);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'erlen');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid username or password'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
