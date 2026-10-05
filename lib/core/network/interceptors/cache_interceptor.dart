import 'dart:collection';

import 'package:dio/dio.dart';

import '../network_constants.dart';

class _CacheEntry {
  _CacheEntry(this.response, this.expiresAt);

  final Response<dynamic> response;
  final DateTime expiresAt;

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

/// Cache in-memory para GET (LRU + TTL configurável por request).
class CacheInterceptor extends Interceptor {
  CacheInterceptor({
    this.defaultTtl = NetworkConstants.defaultCacheTtl,
    this.maxEntries = NetworkConstants.maxCacheEntries,
  });

  final Duration defaultTtl;
  final int maxEntries;
  final LinkedHashMap<String, _CacheEntry> _store = LinkedHashMap();

  static const extraCacheTtl = 'cache_ttl';
  static const extraSkipCache = 'skip_cache';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }
    if (options.extra[extraSkipCache] == true) {
      handler.next(options);
      return;
    }

    final key = _cacheKey(options);
    final hit = _store[key];
    if (hit != null && hit.isValid) {
      _store.remove(key);
      _store[key] = hit;
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          data: hit.response.data,
          statusCode: hit.response.statusCode,
          statusMessage: hit.response.statusMessage,
          headers: hit.response.headers,
          extra: {...hit.response.extra, 'from_cache': true},
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    if (options.method.toUpperCase() != 'GET') {
      handler.next(response);
      return;
    }
    if (options.extra[extraSkipCache] == true || response.extra['from_cache'] == true) {
      handler.next(response);
      return;
    }

    final ttl = options.extra[extraCacheTtl] as Duration? ?? defaultTtl;
    final key = _cacheKey(options);
    _store[key] = _CacheEntry(response, DateTime.now().add(ttl));
    _evictIfNeeded();
    handler.next(response);
  }

  void clear() => _store.clear();

  String _cacheKey(RequestOptions options) => '${options.uri}';

  void _evictIfNeeded() {
    while (_store.length > maxEntries) {
      _store.remove(_store.keys.first);
    }
  }
}
