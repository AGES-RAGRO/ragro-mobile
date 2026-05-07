import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/product_detail/data/models/product_detail_model.dart';

@lazySingleton
class ProductDetailRemoteDataSource {
  const ProductDetailRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ProductDetailModel> getProduct(
    String productId, {
    String producerId = '',
  }) async {
    try {
      final endpoint = producerId.isNotEmpty
          ? ApiEndpoints.producerProduct(producerId, productId)
          : ApiEndpoints.product(productId);

      // Fetch product and producer profile in parallel when producerId is known
      final futures = [
        _apiClient.dio.get<Map<String, dynamic>>(endpoint),
        if (producerId.isNotEmpty)
          _apiClient.dio.get<Map<String, dynamic>>(
            ApiEndpoints.producerPublicProfile(producerId),
          ),
      ];

      final results = await Future.wait(futures);
      final productData = (results[0] as dynamic).data as Map<String, dynamic>;
      final producerData = results.length > 1
          ? (results[1] as dynamic).data as Map<String, dynamic>?
          : null;

      return ProductDetailModel.fromJson(
        productData,
        farmName: producerData?['farmName'] as String? ?? '',
        producerName: producerData?['name'] as String? ?? '',
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
