import 'package:equatable/equatable.dart';

/// Relação do usuário logado com outro perfil.
class FollowStatusEntity extends Equatable {
  const FollowStatusEntity({
    this.isFollowing = false,
    this.followsYou = false,
  });

  /// Eu sigo a pessoa.
  final bool isFollowing;

  /// A pessoa me segue.
  final bool followsYou;

  /// Os dois se seguem — exibido como "Amigos".
  bool get isMutual => isFollowing && followsYou;

  @override
  List<Object?> get props => [isFollowing, followsYou];
}
