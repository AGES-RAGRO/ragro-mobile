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
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producerProduct(producerId, productId),
      );
      return ProductDetailModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
