import 'package:equatable/equatable.dart';

class Producer extends Equatable {
  const Producer({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.coverUrl,
    required this.averageRating,
    required this.ownerName,
  });

  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String coverUrl;
  final double averageRating;
  final String ownerName;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    avatarUrl,
    coverUrl,
    averageRating,
    ownerName,
  ];
}
