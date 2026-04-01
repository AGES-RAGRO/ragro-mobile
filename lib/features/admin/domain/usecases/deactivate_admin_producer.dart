import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart';

@lazySingleton
class DeactivateAdminProducer {
  const DeactivateAdminProducer(this._repository);

  final AdminRepository _repository;

  Future<void> call(String id) => _repository.deactivateProducer(id);
}
