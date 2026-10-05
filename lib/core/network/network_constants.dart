abstract final class NetworkConstants {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  static const Duration defaultCacheTtl = Duration(minutes: 10);
  static const int maxCacheEntries = 128;
}
