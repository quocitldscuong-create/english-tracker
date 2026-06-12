import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyPrefix = 'lesson_completed_';

  static Future<bool> isLessonCompleted(int dayIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$dayIndex') ?? false;
  }

  static Future<void> setLessonCompleted(int dayIndex, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$dayIndex', value);
  }

  static Future<Map<int, bool>> getAllCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, bool> status = {};
    for (int i = 0; i < 5; i++) {
      status[i] = prefs.getBool('$_keyPrefix$i') ?? false;
    }
    return status;
  }

  static Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 5; i++) {
      await prefs.setBool('$_keyPrefix$i', false);
    }
  }
}
