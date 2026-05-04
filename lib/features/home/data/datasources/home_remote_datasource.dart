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
        queryParameters: {'page': page, 'size': size},
      );

      return PaginatedResponse.fromJson(response.data!, ProducerModel.fromJson);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Gets recommended products by loading products from the first active producers.
  Future<List<HomeProductModel>> getRecommendedProducts() async {
    try {
      final producersResp = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producers,
        queryParameters: {'page': 0, 'size': 4},
      );
      final paged = PaginatedResponse.fromJson(
        producersResp.data!,
        ProducerModel.fromJson,
      );

      final products = <HomeProductModel>[];
      for (final producer in paged.content) {
        final resp = await _apiClient.dio.get<dynamic>(
          ApiEndpoints.producerProducts(producer.id),
        );
        final raw = resp.data;
        final list = raw is List
            ? raw.cast<Map<String, dynamic>>()
            : ((raw as Map<String, dynamic>?))?['content']
                  as List<dynamic>? ??
              [];
        products.addAll(
          list
              .cast<Map<String, dynamic>>()
              .map(
                (json) => HomeProductModel.fromJson(
                  json,
                  fallbackFarmName: producer.name,
                ),
              ),
        );
        if (products.length >= 8) break;
      }
      return products.take(8).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
