import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
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

  Future<void> createProduct(InventoryProduct product) async {
    try {
      await _apiClient.dio.post<void>(
        ApiEndpoints.producerInventory,
        data: product.toJson(),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> updateProduct(InventoryProduct product) async {
    try {
      await _apiClient.dio.put<void>(
        ApiEndpoints.producerInventoryItem(product.id),
        data: product.toJson(),
      );
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
}
