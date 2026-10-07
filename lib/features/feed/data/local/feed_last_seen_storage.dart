import 'package:shared_preferences/shared_preferences.dart';

/// Momento em que o usuário viu o feed pela última vez (badge de novidades).
class FeedLastSeenStorage {
  static const _key = 'feed_last_seen_ms';

  Future<DateTime?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_key);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> write(DateTime seenAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, seenAt.millisecondsSinceEpoch);
  }
}
