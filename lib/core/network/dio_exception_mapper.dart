import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

abstract final class DioExceptionMapper {
  static DioException fromDioException(DioException err) {
    final app = _toAppException(err);
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: app,
      message: app.message,
    );
  }

  static DioException validation(String message) {
    return DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.unknown,
      error: AppException(message: message, type: AppExceptionType.validation),
      message: message,
    );
  }

  static AppException _toAppException(DioException err) {
    if (err.error is AppException) {
      return err.error! as AppException;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppException(
          message: 'Tempo de conexão esgotado. Tente novamente.',
          type: AppExceptionType.timeout,
          cause: err,
        );
      case DioExceptionType.connectionError:
        return AppException(
          message: 'Sem conexão com a internet.',
          type: AppExceptionType.network,
          cause: err,
        );
      case DioExceptionType.badResponse:
        return _fromStatusCode(err);
      case DioExceptionType.cancel:
        return AppException(
          message: 'Requisição cancelada.',
          type: AppExceptionType.unknown,
          cause: err,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          message: err.message ?? 'Erro de rede desconhecido.',
          type: AppExceptionType.unknown,
          cause: err,
        );
    }
  }

  static AppException _fromStatusCode(DioException err) {
    final code = err.response?.statusCode;
    final data = err.response?.data;
    final backendMessage = data is Map ? data['status_message']?.toString() : null;

    if (code == 401 || code == 403) {
      return AppException(
        message: backendMessage ?? 'Não autorizado na API TMDB.',
        type: AppExceptionType.unauthorized,
        statusCode: code,
        cause: err,
      );
    }
    if (code == 404) {
      return AppException(
        message: backendMessage ?? 'Recurso não encontrado.',
        type: AppExceptionType.notFound,
        statusCode: code,
        cause: err,
      );
    }
    if (code != null && code >= 500) {
      return AppException(
        message: backendMessage ?? 'Erro no servidor. Tente mais tarde.',
        type: AppExceptionType.server,
        statusCode: code,
        cause: err,
      );
    }

    return AppException(
      message: backendMessage ?? 'Falha na requisição (${code ?? '?'}).',
      type: AppExceptionType.server,
      statusCode: code,
      cause: err,
    );
  }

  static AppException extract(Object error) {
    if (error is AppException) return error;
    if (error is DioException && error.error is AppException) {
      return error.error! as AppException;
    }
    if (error is DioException) {
      return _toAppException(error);
    }
    return AppException(message: error.toString(), cause: error);
  }
}
