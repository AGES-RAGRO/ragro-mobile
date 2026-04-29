import 'package:ragro_mobile/features/producer_profile/domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.authorName,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.authorAvatarUrl,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['createdAt'] as String? ?? json['created_at'] as String?;

    return ReviewModel(
      id: json['id'] as String? ?? '',
      authorName:
          json['authorName'] as String? ??
          json['author_name'] as String? ??
          'Anônimo',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? json['text'] as String? ?? '',
      createdAt: createdAtRaw != null
          ? DateTime.parse(createdAtRaw)
          : DateTime.now(),
      authorAvatarUrl:
          json['authorAvatarUrl'] as String? ??
          json['author_avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'authorAvatarUrl': authorAvatarUrl,
  };
}
