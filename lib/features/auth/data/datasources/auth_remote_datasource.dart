import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/models/auth_config_model.dart';
import 'package:ragro_mobile/features/auth/data/models/customer_registration_request.dart';
import 'package:ragro_mobile/features/auth/data/models/keycloak_token_model.dart';
import 'package:ragro_mobile/features/auth/data/models/login_response_model.dart';
import 'package:ragro_mobile/features/auth/data/models/user_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  ApiException _mapKeycloakLoginError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final responseMap = responseData is Map<String, dynamic>
        ? responseData
        : null;
    final errorCode = responseMap?['error'] as String?;
    final errorDescription = responseMap?['error_description'] as String?;

    if (statusCode == 400 && errorCode == 'invalid_grant') {
      return const InvalidCredentialsApiException();
    }

    if (statusCode == 401) {
      return const InvalidCredentialsApiException();
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiTimeoutException();
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'Falha ao conectar com o servidor de login. Verifique se o backend e o Keycloak estao ativos e liberados para a UI web.',
      );
    }

    return UnknownApiException(errorDescription ?? 'Erro desconhecido');
  }

  /// Authenticates a user via the three-step Keycloak flow:
  /// 1. GET /auth/config — fetch Keycloak token URL and client ID
  /// 2. POST {tokenUrl} — authenticate directly with Keycloak
  /// 3. GET /auth/session — fetch user data from our backend
  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
    // Step 1: Get Keycloak configuration from our backend
    final AuthConfigModel config;
    try {
      final configResponse = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.authConfig,
      );
      final data = configResponse.data;
      if (data == null) {
        throw const UnknownApiException(
          'Resposta inválida ao carregar configuração de autenticação.',
        );
      }
      config = AuthConfigModel.fromJson(data);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }

    // Rewrite tokenUrl host so devices/emulators can reach Keycloak
    // (backend returns localhost which is unreachable outside the host machine).
    final resolvedTokenUrl = ApiEndpoints.resolveMediaUrl(config.tokenUrl);

    // Step 2: Authenticate directly with Keycloak (form-urlencoded)
    // Uses a separate Dio instance because Keycloak expects
    // application/x-www-form-urlencoded and has a different error format.
    final keycloakDio = Dio();
    final KeycloakTokenModel keycloakToken;
    try {
      final tokenResponse = await keycloakDio.post<Map<String, dynamic>>(
        resolvedTokenUrl,
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
      throw _mapKeycloakLoginError(e);
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
        tokenUrl: resolvedTokenUrl,
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

  /// Cadastro de consumidor — POST /auth/register/customer (201 + corpo do cliente).
  Future<UserModel> registerCustomer(
    CustomerRegistrationRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.registerCustomer,
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Solicita redefinição de senha via e-mail — POST /auth/password/reset-email (204 No Content).
  Future<void> requestPasswordReset() async {
    try {
      await _apiClient.dio.post<void>(ApiEndpoints.resetPasswordEmail);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Esqueceu a senha — POST /auth/password/forgot (204 No Content).
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post<void>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
