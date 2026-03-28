import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/models/login_response_model.dart';
import 'package:ragro_mobile/features/auth/data/models/user_model.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';

@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    final endpoint = switch (userType) {
      UserType.consumer => ApiEndpoints.loginConsumer,
      UserType.producer => ApiEndpoints.loginProducer,
      UserType.admin    => ApiEndpoints.loginAdmin,
    };
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        endpoint,
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<UserModel> registerConsumer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String zipCode,
    required String street,
    required String number,
    required String city,
    required String state,
    String? complement,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.registerConsumer,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'address': {
            'zip_code': zipCode,
            'street': street,
            'number': number,
            'city': city,
            'state': state,
            if (complement != null) 'complement': complement,
          },
        },
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
