import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart';

@lazySingleton
class ActivateAdminProducer {
  const ActivateAdminProducer(this._repository);

  final AdminRepository _repository;

  Future<void> call(String id) => _repository.activateProducer(id);
}
