import '../../../../core/errors/app_exception.dart';
import 'rating_answer_set.dart';

/// Resultado consolidado de uma sessão (grupo).
class SessionRatingResult {
  const SessionRatingResult({
    required this.individualAverages,
    required this.sessionAverage,
  });

  /// userId -> média individual
  final Map<String, double> individualAverages;
  final double sessionAverage;
}

/// Motor puro de cálculo — sem Flutter/Firebase.
class RatingCalculator {
  const RatingCalculator._();

  /// Média aritmética das 5 respostas (até 5 estrelas).
  static double individualAverage(RatingAnswerSet answers) {
    answers.validate();
    final values = answers.orderedValues;
    return _average(values);
  }

  /// Média do grupo a partir das médias individuais já calculadas.
  static double sessionAverage(Iterable<double> individualAverages) {
    final values = individualAverages.where((v) => v > 0).toList();
    if (values.isEmpty) {
      throw const AppException(
        message: 'Nenhuma nota válida para consolidar a sessão.',
        type: AppExceptionType.validation,
      );
    }
    return _average(values);
  }

  /// Consolida vários participantes (cada um com seu conjunto de respostas).
  static SessionRatingResult consolidate(
    Map<String, RatingAnswerSet> participantAnswers,
  ) {
    if (participantAnswers.isEmpty) {
      throw const AppException(
        message: 'Adicione ao menos um participante com nota.',
        type: AppExceptionType.validation,
      );
    }

    final individual = <String, double>{};
    for (final entry in participantAnswers.entries) {
      individual[entry.key] = individualAverage(entry.value);
    }

    return SessionRatingResult(
      individualAverages: individual,
      sessionAverage: sessionAverage(individual.values),
    );
  }

  static double _average(List<double> values) {
    final sum = values.fold<double>(0, (acc, value) => acc + value);
    return double.parse((sum / values.length).toStringAsFixed(2));
  }
}
