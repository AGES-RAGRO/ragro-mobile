import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';
import 'package:ragro_mobile/features/recommendations/domain/repositories/recommendations_repository.dart';

@lazySingleton
class GetRecommendationsUsecase {
  const GetRecommendationsUsecase(this._repository);

  final RecommendationsRepository _repository;

  Future<List<Recommendation>> call() => _repository.getRecommendations();
}
