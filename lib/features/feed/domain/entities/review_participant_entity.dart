import 'package:equatable/equatable.dart';

class ReviewParticipantEntity extends Equatable {
  const ReviewParticipantEntity({
    required this.userId,
    required this.displayName,
    required this.rating,
    this.photoUrl,
    this.hasSubmittedRating = true,
  });

  final String userId;
  final String displayName;
  final double rating;
  final String? photoUrl;
  final bool hasSubmittedRating;

  bool get countsForSessionAverage => hasSubmittedRating && rating > 0;

  @override
  List<Object?> get props => [userId, displayName, rating, photoUrl, hasSubmittedRating];
}
