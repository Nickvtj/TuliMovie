import 'package:equatable/equatable.dart';

class CrewMemberEntity extends Equatable {
  const CrewMemberEntity({
    required this.id,
    required this.name,
    required this.job,
    this.department,
    this.profilePath,
  });

  final int id;
  final String name;
  final String job;
  final String? department;
  final String? profilePath;

  bool get isDirector => job.toLowerCase() == 'director';

  @override
  List<Object?> get props => [id, name, job, department, profilePath];
}
