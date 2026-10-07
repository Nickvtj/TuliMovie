import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  const GroupModel({
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

  factory GroupModel.fromJson(String id, Map<String, dynamic> json) {
    return GroupModel(
      id: id,
      name: json['name'] as String? ?? 'Turma',
      inviteCode: (json['inviteCode'] as String? ?? '').toUpperCase(),
      memberIds: (json['memberIds'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'inviteCode': inviteCode,
        'memberIds': memberIds,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
