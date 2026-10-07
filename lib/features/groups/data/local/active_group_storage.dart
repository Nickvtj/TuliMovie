import 'package:shared_preferences/shared_preferences.dart';

class ActiveGroupStorage {
  static const _key = 'active_group_id';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> write(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, groupId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
