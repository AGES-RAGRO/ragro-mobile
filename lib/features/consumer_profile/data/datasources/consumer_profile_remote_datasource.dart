import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/features/consumer_profile/data/models/consumer_profile_model.dart';
import 'package:dio/dio.dart';  
import 'package:ragro_mobile/core/network/api_exception.dart';  
import 'package:ragro_mobile/core/network/api_endpoints.dart';  

@lazySingleton
class ConsumerProfileRemoteDataSource {
  const ConsumerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Gets consumer profile of the authenticated customer.
  Future<ConsumerProfileModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.consumers,
      );
      return ConsumerProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
  
  
   //MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  // Future<ConsumerProfileModel> getProfile(String userId) async {
  //   await Future.delayed(const Duration(milliseconds: 600));
  //   return ConsumerProfileModel.mock();
  // }

  // /// Updates consumer profile for [userId].
  // ///
  // /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  // ///
  /// Updates consumer profile of the authenticated customer.
  Future<ConsumerProfileModel> updateProfile({
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  }) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        ApiEndpoints.consumers,
        data: {
          'name': name,
          'phone': phone,
          'address': address,
          if (fiscalNumber != null) 'fiscal_number': fiscalNumber,
        },
      );
      return ConsumerProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
  
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  /*Future<ConsumerProfileModel> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ConsumerProfileModel(
      id: 'consumer_1',
      userId: userId,
      name: name,
      email: 'ricardo.aguiar@ragro.com.br',
      phone: phone,
      address: address,
      fiscalNumber: fiscalNumber,
    );
  }///
   */
}
