import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart';

@lazySingleton
class CreateAdminProducer {
  const CreateAdminProducer(this._repository);

  final AdminRepository _repository;

  Future<void> call(AdminProducer producer, String password) =>
      _repository.createProducer(producer, password);
}
