import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart';

@lazySingleton
class GetAdminProducerById {
  const GetAdminProducerById(this._repository);

  final AdminRepository _repository;

  Future<AdminProducer> call(String id) => _repository.getProducerById(id);
}
