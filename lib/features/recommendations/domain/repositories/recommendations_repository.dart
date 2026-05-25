import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';

abstract class RecommendationsRepository {
  Future<List<Recommendation>> getRecommendations();
}
