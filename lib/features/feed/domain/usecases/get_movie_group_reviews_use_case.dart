import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetMovieGroupReviewsUseCase {
  GetMovieGroupReviewsUseCase(this._repository);

  final ReviewRepository _repository;

  Future<List<ReviewEntity>> byMovie(int tmdbMovieId) {
    return _repository.getReviewsByMovieId(tmdbMovieId);
  }

  Future<List<ReviewEntity>> byMovies(List<int> tmdbMovieIds) {
    return _repository.getReviewsByMovieIds(tmdbMovieIds);
  }
}
