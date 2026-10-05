import 'package:equatable/equatable.dart';

class ReviewParticipantEntity extends Equatable {
  const ReviewParticipantEntity({
    required this.userId,
    required this.displayName,
    required this.rating,
    this.photoUrl,
  });

  final String userId;
  final String displayName;
  final double rating;
  final String? photoUrl;

  @override
  List<Object?> get props => [userId, displayName, rating, photoUrl];
}
