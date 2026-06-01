import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.name,
    required super.price,
    required super.unityType,
    required super.farmerId,
    required super.farmName,
    required super.categoryNames,
    required super.score,
    required super.reason,
    super.imageS3,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unityType: json['unityType'] as String,
      farmerId: json['farmerId'] as String,
      farmName: json['farmName'] as String,
      categoryNames: (json['categoryNames'] as List<dynamic>)
          .whereType<String>()
          .toList(),
      score: json['score'] as int,
      reason: json['reason'] as String,
      imageS3: json['imageS3'] != null
          ? ApiEndpoints.resolveMediaUrl(json['imageS3'] as String)
          : null,
    );
  }
}
