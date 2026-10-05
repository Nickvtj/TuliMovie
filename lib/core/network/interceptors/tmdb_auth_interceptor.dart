import 'package:dio/dio.dart';

import '../../config/env_config.dart';
import '../dio_exception_mapper.dart';

/// Injeta credenciais TMDB (query `api_key`) em todas as requisições.
class TmdbAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!EnvConfig.hasTmdbApiKey) {
      handler.reject(
        DioExceptionMapper.validation('TMDB_API_KEY não configurada. Use --dart-define=TMDB_API_KEY=sua_chave'),
      );
      return;
    }

    options.queryParameters = {
      ...options.queryParameters,
      'api_key': EnvConfig.tmdbApiKey,
    };
    handler.next(options);
  }
}
