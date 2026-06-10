import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/recommendations/data/models/recommendation_model.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';

@lazySingleton
class RecommendationsRemoteDatasource {
  const RecommendationsRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Recommendation>> getRecommendations() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.recommendations,
      );

      return _readList(
        response.data,
      ).map(RecommendationModel.fromJson).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  // Contrato do backend: RecommendationResponse{recommendations: [...], total} —
  // a leitura defensiva de 6 chaves alternativas mascarava mudanças de contrato.
  List<Map<String, dynamic>> _readList(dynamic data) {
    if (data is Map<String, dynamic> && data['recommendations'] is List<dynamic>) {
      return (data['recommendations'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return const [];
  }
}
