import 'package:equatable/equatable.dart';

enum AppExceptionType {
  network,
  timeout,
  unauthorized,
  notFound,
  server,
  cache,
  validation,
  unknown,
}

/// Exceções da camada de dados — convertidas em [Failure] no domínio/presentation.
class AppException extends Equatable implements Exception {
  const AppException({
    required this.message,
    this.type = AppExceptionType.unknown,
    this.statusCode,
    this.cause,
  });

  final String message;
  final AppExceptionType type;
  final int? statusCode;
  final Object? cause;

  @override
  List<Object?> get props => [message, type, statusCode];

  @override
  String toString() => 'AppException($type): $message';
}
