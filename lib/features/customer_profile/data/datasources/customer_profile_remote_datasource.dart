import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/models/address_request.dart';
import 'package:ragro_mobile/features/customer_profile/data/models/customer_profile_model.dart';
import 'package:ragro_mobile/features/customer_profile/data/models/customer_update_request.dart';

@lazySingleton
class CustomerProfileRemoteDataSource {
  const CustomerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<CustomerProfileModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.customerMe,
      );
      return CustomerProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<CustomerProfileModel> updateProfile({
    required String name,
    required String phone,
    required String street,
    required String number,
    required String city,
    required String state,
    required String zipCode,
    String? complement,
    String? neighborhood,
  }) async {
    try {
      String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        ApiEndpoints.customerMe,
        data: CustomerUpdateRequest(
          name: name.trim(),
          phone: phone.trim(),
          address: AddressRequest(
            street: street.trim(),
            number: number.trim(),
            city: city.trim(),
            state: state.trim().toUpperCase(),
            zipCode: digitsOnly(zipCode),
            complement: complement?.trim(),
            neighborhood: neighborhood?.trim(),
          ),
        ).toJson(),
      );
      return CustomerProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
