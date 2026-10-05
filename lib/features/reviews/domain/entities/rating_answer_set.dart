import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import 'rating_dimension.dart';

/// Respostas das 5 perguntas de um participante (1.0 – 5.0).
class RatingAnswerSet extends Equatable {
  const RatingAnswerSet({required this.answers});

  final Map<RatingDimension, double> answers;

  factory RatingAnswerSet.fromMap(Map<RatingDimension, double> answers) {
    return RatingAnswerSet(answers: Map.unmodifiable(answers));
  }

  List<double> get orderedValues =>
      RatingDimension.all.map((dimension) => answers[dimension]!).toList();

  void validate() {
    if (answers.length != RatingDimension.all.length) {
      throw const AppException(
        message: 'Responda todas as 5 perguntas.',
        type: AppExceptionType.validation,
      );
    }

    for (final dimension in RatingDimension.all) {
      final value = answers[dimension];
      if (value == null || value < 1 || value > 5) {
        throw AppException(
          message: 'Nota inválida em "${dimension.title}". Use de 1 a 5.',
          type: AppExceptionType.validation,
        );
      }
    }
  }

  @override
  List<Object?> get props => [answers];
}
