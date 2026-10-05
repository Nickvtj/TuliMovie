class CrewMemberModel {
  const CrewMemberModel({
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

  factory CrewMemberModel.fromJson(Map<String, dynamic> json) {
    return CrewMemberModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      job: json['job'] as String? ?? '',
      department: json['department'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }
}
