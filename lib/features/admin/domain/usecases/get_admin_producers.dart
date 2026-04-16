import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart';

@lazySingleton
class GetAdminProducers {
  const GetAdminProducers(this._repository);

  final AdminRepository _repository;

  Future<List<AdminProducerSummary>> call() => _repository.getProducers();
}
