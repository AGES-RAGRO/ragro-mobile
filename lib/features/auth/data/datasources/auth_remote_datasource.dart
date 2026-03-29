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

  /// Authenticates a user by email and password.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<LoginResponseModel> loginUser({
  ///   required String email,
  ///   required String password,
  /// }) async {
  ///   try {
  ///     final response = await _apiClient.dio.post<Map<String, dynamic>>(
  ///       ApiEndpoints.login,
  ///       data: {'email': email, 'password': password},
  ///     );
  ///     return LoginResponseModel.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     if (e.response?.statusCode == 401) {
  ///       throw const InvalidCredentialsApiException();
  ///     }
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    const validPassword = '123456';

    final mockUsers = <String, UserModel>{
      'consumer@ragro.com.br': UserModel(
        id: 'user_c001',
        name: 'Ricardo Aguiar',
        email: 'consumer@ragro.com.br',
        phone: '(51) 99999-0001',
        type: UserType.consumer,
        active: true,
      ),
      'produtor@ragro.com.br': UserModel(
        id: 'user_p001',
        name: 'João Silva',
        email: 'produtor@ragro.com.br',
        phone: '(51) 99999-0002',
        type: UserType.producer,
        active: true,
      ),
      'admin@ragro.com.br': UserModel(
        id: 'user_a001',
        name: 'Admin RAGRO',
        email: 'admin@ragro.com.br',
        phone: '(51) 99999-0000',
        type: UserType.admin,
        active: true,
      ),
    };

    final user = mockUsers[email.toLowerCase()];
    if (user == null || password != validPassword) {
      throw const InvalidCredentialsApiException();
    }

    return LoginResponseModel(
      token: 'mock_token_${user.type.name}_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
    );
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
