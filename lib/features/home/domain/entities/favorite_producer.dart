import 'package:equatable/equatable.dart';

class FavoriteProducer extends Equatable {
  const FavoriteProducer({
    required this.producerId,
    required this.producerName,
    required this.farmName,
    required this.avatarUrl,
    required this.averageRating,
    this.coverUrl = '',
  });

  final String producerId;
  final String producerName;
  final String farmName;
  final String avatarUrl;
  final String coverUrl;
  final double averageRating;

  @override
  List<Object?> get props => [
    producerId,
    producerName,
    farmName,
    avatarUrl,
    coverUrl,
    averageRating,
  ];
}
