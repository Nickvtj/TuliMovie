import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/utils/username_rules.dart';
import '../repositories/social_repository.dart';

class SearchUsersUseCase {
  SearchUsersUseCase(this._repository);

  static const minQueryLength = 2;

  final SocialRepository _repository;

  /// Busca por prefixo de @ ou nome, sem o próprio usuário.
  Future<List<UserEntity>> call({
    required String query,
    required String currentUserId,
  }) async {
    final prefix = UsernameRules.normalize(query);
    if (prefix.length < minQueryLength) return const [];

    try {
      final users = await _repository.searchUsers(prefix);
      return users.where((user) => user.id != currentUserId).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Erro ao buscar pessoas.', cause: e);
    }
  }
}
