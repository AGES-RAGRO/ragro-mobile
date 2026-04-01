import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUser {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;

  Future<User?> call() => _repository.getCurrentUser();
}
