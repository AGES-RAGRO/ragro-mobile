import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/core/utils/multipart_file_builder.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

@lazySingleton
class InventoryRemoteDataSource {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<InventoryProduct>> getProducts() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.producerInventory,
      );
      final raw = response.data;
      final list = raw is List
          ? raw
          : (raw as Map<String, dynamic>?)?['content'] as List? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(InventoryProduct.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<InventoryProduct> createProduct(InventoryProduct product) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.producerInventory,
        data: product.toJson(),
      );
      return InventoryProduct.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<InventoryProduct> updateProduct(InventoryProduct product) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        ApiEndpoints.producerInventoryItem(product.id),
        data: product.toJson(),
      );
      return InventoryProduct.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.dio.delete<void>(
        ApiEndpoints.producerInventoryItem(id),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<InventoryProduct> uploadProductPhoto(String productId, XFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await multipartFromXFile(file),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.producerProductPhoto(productId),
        data: formData,
      );
      return InventoryProduct.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
