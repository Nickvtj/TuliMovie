import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/core/errors/app_exception.dart';
import 'package:tulimovie/features/auth/domain/entities/favorite_actor_entity.dart';
import 'package:tulimovie/features/auth/domain/entities/favorite_movie_entity.dart';
import 'package:tulimovie/features/auth/domain/repositories/auth_repository.dart';
import 'package:tulimovie/features/profile/domain/usecases/update_profile_use_case.dart';

class _FakeAuthRepository implements AuthRepository {
  String? savedName;
  String? savedBio;

  @override
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? photoUrl,
    List<FavoriteMovieEntity>? favoriteMovies,
    List<FavoriteActorEntity>? favoriteActors,
  }) async {
    savedName = displayName;
    savedBio = bio;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('salva nome e bio aparados', () async {
    final repository = _FakeAuthRepository();
    await UpdateProfileUseCase(repository)(
      userId: 'me',
      displayName: '  Nick  ',
      bio: ' Fã de terror ',
    );

    expect(repository.savedName, 'Nick');
    expect(repository.savedBio, 'Fã de terror');
  });

  test('rejeita nome curto, bio longa e mais de 4 favoritos', () {
    final useCase = UpdateProfileUseCase(_FakeAuthRepository());
    const movie = FavoriteMovieEntity(tmdbMovieId: 1, title: 'Filme');

    expect(() => useCase(userId: 'me', displayName: 'N'), throwsA(isA<AppException>()));
    expect(
      () => useCase(userId: 'me', bio: 'a' * (UpdateProfileUseCase.bioMaxLength + 1)),
      throwsA(isA<AppException>()),
    );
    expect(
      () => useCase(userId: 'me', favoriteMovies: List.filled(5, movie)),
      throwsA(isA<AppException>()),
    );
  });
}
