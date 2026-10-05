class CastMemberModel {
  const CastMemberModel({
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

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}
