import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String inviteCode;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, inviteCode, memberIds, createdBy, createdAt];
}
