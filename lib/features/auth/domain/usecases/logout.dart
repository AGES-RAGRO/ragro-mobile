import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class Logout {
  const Logout(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
