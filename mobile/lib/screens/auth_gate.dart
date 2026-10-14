import 'package:flashcards/screens/home_screen.dart';
import 'package:flashcards/screens/login_screen.dart';
import 'package:flashcards/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
