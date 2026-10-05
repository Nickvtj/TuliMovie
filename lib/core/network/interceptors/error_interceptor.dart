import 'package:dio/dio.dart';

import '../dio_exception_mapper.dart';

/// Normaliza erros Dio em [DioException] com mensagem amigável no `error`.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = DioExceptionMapper.fromDioException(err);
    handler.next(mapped);
  }
}
