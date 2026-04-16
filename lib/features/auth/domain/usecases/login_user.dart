import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class LoginUser {
  const LoginUser(this._repository);
  final AuthRepository _repository;

  Future<({User user, String token})> call({
    required String email,
    required String password,
  }) => _repository.loginUser(email: email, password: password);
}
