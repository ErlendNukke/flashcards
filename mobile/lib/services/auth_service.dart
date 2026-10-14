import 'dart:convert';

import 'package:flashcards/models/app_user.dart';
import 'package:flashcards/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  AuthService(this._api);

  final ApiClient _api;
  AppUser? user;
  bool ready = false;

  bool get isLoggedIn => user != null && _api.token != null;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('flashcards_token');
    final rawUser = prefs.getString('flashcards_user');
    if (token != null && rawUser != null) {
      _api.token = token;
      user = AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
      try {
        await refreshMe();
      } catch (_) {
        await logout();
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final res = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/auth/register',
      auth: false,
      includeDeviceId: true,
      body: {'username': username, 'password': password},
      parser: (v) => v as Map<String, dynamic>,
    );
    await _persist(res);
  }

  Future<void> login(String username, String password) async {
    final res = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/auth/login',
      auth: false,
      includeDeviceId: true,
      body: {'username': username, 'password': password},
      parser: (v) => v as Map<String, dynamic>,
    );
    await _persist(res);
  }

  Future<void> refreshMe() async {
    final json = await _api.request<Map<String, dynamic>>(
      'GET',
      '/api/auth/me',
      parser: (v) => v as Map<String, dynamic>,
    );
    user = AppUser.fromJson(json);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flashcards_user', jsonEncode(json));
    notifyListeners();
  }

  Future<void> logout() async {
    _api.token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flashcards_token');
    await prefs.remove('flashcards_user');
    notifyListeners();
  }

  Future<void> _persist(Map<String, dynamic> res) async {
    final token = res['token'] as String;
    final userJson = res['user'] as Map<String, dynamic>;
    _api.token = token;
    user = AppUser.fromJson(userJson);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flashcards_token', token);
    await prefs.setString('flashcards_user', jsonEncode(userJson));
    notifyListeners();
  }
}
