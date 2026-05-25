import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';
import 'package:ragro_mobile/features/recommendations/domain/repositories/recommendations_repository.dart';

@LazySingleton(as: RecommendationsRepository)
class RecommendationsRepositoryImpl implements RecommendationsRepository {
  const RecommendationsRepositoryImpl(this._datasource);

  final RecommendationsRemoteDatasource _datasource;

  @override
  Future<List<Recommendation>> getRecommendations() =>
      _datasource.getRecommendations();
}
