import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/core/network/paginated_response.dart';
import 'package:ragro_mobile/features/home/data/models/home_product_model.dart';
import 'package:ragro_mobile/features/home/data/models/producer_model.dart';

@lazySingleton
class HomeRemoteDataSource {
  const HomeRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Gets list of active producers for the home screen.
  Future<PaginatedResponse<ProducerModel>> getProducers({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producers,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PaginatedResponse.fromJson(
        response.data!,
        (json) => ProducerModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Gets recommended products for the home screen.
  Future<List<HomeProductModel>> getRecommendedProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return HomeProductModel.mocks();
  }
}
