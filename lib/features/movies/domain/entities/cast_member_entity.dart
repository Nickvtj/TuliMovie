import 'package:equatable/equatable.dart';

class CastMemberEntity extends Equatable {
  const CastMemberEntity({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order = 0,
  });

  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;

  @override
  List<Object?> get props => [id, name, character, profilePath, order];
}
