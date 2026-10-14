import 'package:shared_preferences/shared_preferences.dart';

class StudyPreferences {
  static const _shuffleKey = 'study_shuffle_enabled';

  Future<bool> isShuffleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> setShuffleEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, value);
  }
}
