import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasUsername => username != null && username!.isNotEmpty;

  String get initials {
    final parts =
        displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final name = parts.first;
      return (name.length >= 2 ? name.substring(0, 2) : name).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, displayName, username, photoUrl, createdAt, updatedAt];
}
