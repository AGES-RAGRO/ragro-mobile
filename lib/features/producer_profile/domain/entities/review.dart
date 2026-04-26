import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.authorAvatarUrl,
  });

  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? authorAvatarUrl;

  @override
  List<Object?> get props => [id, authorName, rating, comment, createdAt, authorAvatarUrl];
}
