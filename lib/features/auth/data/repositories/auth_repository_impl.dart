import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ragro_mobile/features/auth/data/models/address_request.dart';
import 'package:ragro_mobile/features/auth/data/models/customer_registration_request.dart';
import 'package:ragro_mobile/features/auth/data/models/user_model.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local, this._apiClient);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final ApiClient _apiClient;

  @override
  Future<({User user, String token})> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _remote.loginUser(
      email: email,
      password: password,
    );
    try {
      await _local.saveSession(
        token: response.accessToken,
        refreshToken: response.refreshToken,
        tokenUrl: response.tokenUrl,
        clientId: response.clientId,
        userType: response.user.type.name,
        userId: response.user.id,
        userName: response.user.name,
        userEmail: response.user.email,
        active: response.user.active,
        phone: response.user.phone,
      );
    } on Exception catch (_) {
      // Network auth succeeded but local persistence failed.
      // Session will not survive app restart, but current session still works.
    }
    _apiClient.setAuthToken(response.accessToken);
    return (user: response.user, token: response.accessToken);
  }

  @override
  Future<User> registerConsumer({
    required String name,
    required String phone,
    required String email,
    required String fiscalNumber,
    required String password,
    required String zipCode,
    required String street,
    required String number,
    required String city,
    required String state,
    String? complement,
    String? neighborhood,
  }) {
    String digits(String s) => s.replaceAll(RegExp(r'\D'), '');
    final request = CustomerRegistrationRequest(
      name: name.trim(),
      email: email.trim(),
      phone: digits(phone),
      fiscalNumber: digits(fiscalNumber),
      password: password,
      address: AddressRequest(
        street: street.trim(),
        number: number.trim(),
        city: city.trim(),
        state: state.trim().toUpperCase(),
        zipCode: digits(zipCode),
        complement: complement?.trim(),
        neighborhood: neighborhood?.trim(),
      ),
    );
    return _remote.registerCustomer(request);
  }

  @override
  Future<void> logout() async {
    await _local.clearSession();
    _apiClient.clearAuthToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    // DEMO_MODE: bypass auth — used for Playwright visual testing only.
    // Run with: flutter run -d chrome --dart-define=DEMO_MODE=true
    const demoMode = bool.fromEnvironment('DEMO_MODE');
    const demoRole =
        String.fromEnvironment('DEMO_ROLE', defaultValue: 'producer');
    if (demoMode) {
      final (id, name, email) = switch (demoRole) {
        'consumer' => (
            'demo_consumer_001',
            'Ricardo Aguiar (Demo)',
            'consumer@ragro.com.br'
          ),
        'admin' => (
            'demo_admin_001',
            'Admin RAGRO (Demo)',
            'admin@ragro.com.br'
          ),
        _ => (
            'demo_producer_001',
            'João Silva (Demo)',
            'produtor@ragro.com.br'
          ),
      };
      return UserModel(
        id: id,
        name: name,
        email: email,
        phone: '(51) 99999-0000',
        type: UserType.fromApiValue(demoRole),
        active: true,
      );
    }

    final token = _local.getToken();
    if (token == null) return null;

    final refreshToken = _local.getRefreshToken();
    final tokenUrl = _local.getTokenUrl();
    final clientId = _local.getClientId();

    // Try to refresh the access token if we have the Keycloak data saved
    if (refreshToken != null && tokenUrl != null && clientId != null) {
      try {
        final newToken = await _remote.refreshAccessToken(
          refreshToken: refreshToken,
          tokenUrl: tokenUrl,
          clientId: clientId,
        );
        _apiClient.setAuthToken(newToken.accessToken);
        await _local.saveSession(
          token: newToken.accessToken,
          refreshToken: newToken.refreshToken,
          tokenUrl: tokenUrl,
          clientId: clientId,
          userType: _local.getUserType()!,
          userId: _local.getUserId()!,
          userName: _local.getUserName()!,
          userEmail: _local.getUserEmail()!,
          active: _local.getUserActive() ?? true,
          phone: _local.getUserPhone(),
        );
      } on Exception catch (_) {
        // Refresh failed — session expired, force re-login
        await _local.clearSession();
        _apiClient.clearAuthToken();
        return null;
      }
    } else {
      // No refresh data (legacy session) — use saved access token as-is
      _apiClient.setAuthToken(token);
    }

    final id = _local.getUserId();
    final name = _local.getUserName();
    final email = _local.getUserEmail();
    final type = _local.getUserType();
    final active = _local.getUserActive();
    if (id == null || name == null || email == null || type == null) return null;
    final phone = _local.getUserPhone();
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      type: UserType.fromApiValue(type),
      active: active ?? true,
    );
  }
}
