import 'package:equatable/equatable.dart';

class CinepassEntryEntity extends Equatable {
  const CinepassEntryEntity({
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  List<Object?> get props => [userId, displayName];
}

class CinepassStateEntity extends Equatable {
  const CinepassStateEntity({
    required this.queue,
    required this.currentIndex,
  });

  final List<CinepassEntryEntity> queue;
  final int currentIndex;

  CinepassEntryEntity? get current {
    if (queue.isEmpty) return null;
    return queue[currentIndex % queue.length];
  }

  @override
  List<Object?> get props => [queue, currentIndex];
}
