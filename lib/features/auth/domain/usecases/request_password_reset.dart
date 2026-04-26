import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class RequestPasswordReset {
  const RequestPasswordReset(this._repository);
  final AuthRepository _repository;

  Future<void> call() {
    return _repository.requestPasswordReset();
  }
}
