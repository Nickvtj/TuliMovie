import 'package:equatable/equatable.dart';

enum StreamingAvailability { flatrate, rent, buy }

class StreamingProviderEntity extends Equatable {
  const StreamingProviderEntity({
    required this.providerId,
    required this.name,
    this.logoPath,
    required this.availability,
  });

  final int providerId;
  final String name;
  final String? logoPath;
  final StreamingAvailability availability;

  @override
  List<Object?> get props => [providerId, name, logoPath, availability];
}
