import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/cart/data/models/cart_model.dart';

@lazySingleton
class CartRemoteDataSource {
  const CartRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<CartModel> getCart() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.customerCart,
      );
      return CartModel.fromJson(response.data!);
    } on DioException catch (e) {
      // Backend retorna 404 quando o consumidor não tem carrinho ativo.
      if (e.error is NotFoundException) {
        return const CartModel.empty();
      }
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<CartModel> addItem({
    required String productId,
    required double quantity,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.customerCartItems,
        data: {'productId': productId, 'quantity': quantity},
      );
      return CartModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<CartModel> updateQuantity({
    required String cartItemId,
    required double quantity,
  }) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.customerCartItem(cartItemId),
        data: {'quantity': quantity},
      );
      return CartModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<CartModel> removeItem(String cartItemId) async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        ApiEndpoints.customerCartItem(cartItemId),
      );
      return CartModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<CartModel> clear() async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        ApiEndpoints.customerCart,
      );
      return CartModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
