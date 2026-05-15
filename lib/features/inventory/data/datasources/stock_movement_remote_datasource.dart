import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';

@lazySingleton
class StockMovementRemoteDataSource {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<StockMovement> registerExit({
    required String productId,
    required double quantity,
    required String reason,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.stockExit,
        data: {
          'productId': productId,
          'quantity': quantity,
          'reason': reason,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return StockMovement.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<StockMovement> registerEntry({
    required String productId,
    required double quantity,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.stockEntry,
        data: {
          'productId': productId,
          'quantity': quantity,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return StockMovement.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<List<StockMovement>> getProductMovements(
    String productId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.stockProductMovements(productId),
        queryParameters: {'page': page, 'size': size},
      );
      final content = (response.data?['content'] as List?) ?? [];
      return content
          .cast<Map<String, dynamic>>()
          .map(StockMovement.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
