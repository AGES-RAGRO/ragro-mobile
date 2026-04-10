import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/consumer_profile/data/models/customer_profile_model.dart';

@lazySingleton
class CustomerProfileRemoteDataSource {
  const CustomerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Busca o perfil do customer autenticado.
  ///
  /// O backend expõe `GET /customers/me` e requer o header `Authorization: Bearer <token>`.
  /// O [userId] pode ser "me" ou o id do customer; quando for o usuário autenticado,
  /// recomenda-se passar "me" para evitar expor ids em código cliente.
  Future<CustomerProfileModel> getProfile(String userId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.customer(userId),
      );
      return CustomerProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Atualiza o perfil do customer autenticado.
  ///
  /// Faz `PUT /customers/{id}` (ou `/customers/me` quando aplicável). O backend
  /// espera os campos `name`, `phone`, `address` e opcionalmente `fiscal_number`.
  Future<CustomerProfileModel> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  }) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        ApiEndpoints.customer(userId),
        data: {
          'name': name,
          'phone': phone,
          'address': address,
          if (fiscalNumber != null) 'fiscal_number': fiscalNumber,
        },
      );
      return CustomerProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
