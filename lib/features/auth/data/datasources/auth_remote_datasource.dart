import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/models/auth_config_model.dart';
import 'package:ragro_mobile/features/auth/data/models/keycloak_token_model.dart';
import 'package:ragro_mobile/features/auth/data/models/login_response_model.dart';
import 'package:ragro_mobile/features/auth/data/models/user_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  /// Authenticates a user via the three-step Keycloak flow:
  /// 1. GET /auth/config — fetch Keycloak token URL and client ID
  /// 2. POST {tokenUrl} — authenticate directly with Keycloak
  /// 3. GET /auth/session — fetch user data from our backend
  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
    // Step 1: Get Keycloak configuration from our backend
    final configResponse = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.authConfig,
    );
    final config = AuthConfigModel.fromJson(configResponse.data!);

    // Step 2: Authenticate directly with Keycloak (form-urlencoded)
    // Uses a separate Dio instance because Keycloak expects
    // application/x-www-form-urlencoded and has a different error format.
    final keycloakDio = Dio();
    final KeycloakTokenModel keycloakToken;
    try {
      final tokenResponse = await keycloakDio.post<Map<String, dynamic>>(
        config.tokenUrl,
        data: {
          'grant_type': 'password',
          'client_id': config.clientId,
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      keycloakToken = KeycloakTokenModel.fromJson(tokenResponse.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const InvalidCredentialsApiException();
      }
      throw const UnknownApiException();
    } finally {
      keycloakDio.close();
    }

    // Step 3: Fetch user session from our backend using the access token
    _apiClient.setAuthToken(keycloakToken.accessToken);
    try {
      final sessionResponse = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.authSession,
      );
      final user = UserModel.fromJson(sessionResponse.data!);

      return LoginResponseModel(
        accessToken: keycloakToken.accessToken,
        refreshToken: keycloakToken.refreshToken,
        tokenUrl: config.tokenUrl,
        clientId: config.clientId,
        user: user,
      );
    } on DioException catch (e) {
      _apiClient.clearAuthToken();
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Refreshes an expired access token using the refresh token.
  Future<KeycloakTokenModel> refreshAccessToken({
    required String refreshToken,
    required String tokenUrl,
    required String clientId,
  }) async {
    final keycloakDio = Dio();
    try {
      final response = await keycloakDio.post<Map<String, dynamic>>(
        tokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'refresh_token': refreshToken,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return KeycloakTokenModel.fromJson(response.data!);
    } on DioException catch (_) {
      throw const UnauthorizedException();
    } finally {
      keycloakDio.close();
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
        ApiEndpoints.registerCustomer,
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
