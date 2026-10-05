import 'package:equatable/equatable.dart';

import 'app_exception.dart';

/// Falhas expostas ao domínio/UI (Either / try-catch nos use cases).
class Failure extends Equatable {
  const Failure({
    required this.message,
    this.type = AppExceptionType.unknown,
    this.statusCode,
  });

  final String message;
  final AppExceptionType type;
  final int? statusCode;

  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.message,
      type: exception.type,
      statusCode: exception.statusCode,
    );
  }

  @override
  List<Object?> get props => [message, type, statusCode];
}
