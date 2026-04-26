import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class ForgotPassword {
  const ForgotPassword(this._repository);
  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.forgotPassword(email);
  }
}
