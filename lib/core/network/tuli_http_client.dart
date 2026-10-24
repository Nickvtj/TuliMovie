import 'package:dio/dio.dart';

import '../config/env_config.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/tmdb_auth_interceptor.dart';
import 'network_constants.dart';

/// Cliente HTTP centralizado (Dio) — TMDB e futuros backends REST.
class TuliHttpClient {
  TuliHttpClient({
    Dio? dio,
    CacheInterceptor? cacheInterceptor,
    bool enableLogging = true,
  })  : cacheInterceptor = cacheInterceptor ?? CacheInterceptor(),
        _dio = dio ?? Dio() {
    _dio
      ..options = BaseOptions(
        baseUrl: EnvConfig.tmdbBaseUrl,
        connectTimeout: NetworkConstants.connectTimeout,
        receiveTimeout: NetworkConstants.receiveTimeout,
        sendTimeout: NetworkConstants.sendTimeout,
        // Sem Content-Type fixo: em GET ele faz o navegador mandar um preflight
        // CORS (OPTIONS) antes de cada chamada ao TMDB. Com corpo, o Dio deduz.
        headers: {
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      )
      ..interceptors.addAll([
        TmdbAuthInterceptor(),
        this.cacheInterceptor,
        if (enableLogging) LoggingInterceptor(),
        ErrorInterceptor(),
      ]);
  }

  final Dio _dio;
  final CacheInterceptor cacheInterceptor;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheTtl,
    bool skipCache = false,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _mergeOptions(
        options,
        cacheTtl: cacheTtl,
        skipCache: skipCache,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  void clearCache() => cacheInterceptor.clear();

  Options _mergeOptions(
    Options? base, {
    Duration? cacheTtl,
    bool skipCache = false,
  }) {
    final extra = <String, dynamic>{
      ...?base?.extra,
      if (cacheTtl != null) CacheInterceptor.extraCacheTtl: cacheTtl,
      if (skipCache) CacheInterceptor.extraSkipCache: true,
    };
    return (base ?? Options()).copyWith(extra: extra);
  }
}
