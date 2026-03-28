import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
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
    required UserType userType,
  }) async {
    final response = await _remote.loginUser(
      email: email,
      password: password,
      userType: userType,
    );
    try {
      await _local.saveSession(
        token: response.token,
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
    _apiClient.setAuthToken(response.token);
    return (user: response.user, token: response.token);
  }

  @override
  Future<User> registerConsumer({
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
  }) =>
      _remote.registerConsumer(
        name: name,
        phone: phone,
        email: email,
        password: password,
        zipCode: zipCode,
        street: street,
        number: number,
        city: city,
        state: state,
        complement: complement,
      );

  @override
  Future<void> logout() async {
    await _local.clearSession();
    _apiClient.clearAuthToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token  = _local.getToken();
    if (token == null) return null;
    final id     = _local.getUserId();
    final name   = _local.getUserName();
    final email  = _local.getUserEmail();
    final type   = _local.getUserType();
    final active = _local.getUserActive();
    if (id == null || name == null || email == null || type == null) return null;
    final phone = _local.getUserPhone();
    _apiClient.setAuthToken(token);
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
