import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logger HTTP — ativo apenas em [kDebugMode].
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP →] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP ←] ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP ✕] ${err.requestOptions.method} ${err.requestOptions.uri} — ${err.message}',
      );
    }
    handler.next(err);
  }
}
