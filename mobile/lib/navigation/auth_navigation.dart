import 'package:flutter/material.dart';

/// Clears auth sub-routes (welcome → log in / sign up) so [AuthGate] can show home.
void completeAuthentication(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}
