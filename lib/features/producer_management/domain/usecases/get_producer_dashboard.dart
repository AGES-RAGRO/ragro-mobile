import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';
import 'package:ragro_mobile/features/producer_management/domain/repositories/producer_management_repository.dart';

@lazySingleton
class GetProducerDashboard {
  const GetProducerDashboard(this._repository);

  final ProducerManagementRepository _repository;

  Future<ProducerDashboard> call() => _repository.getDashboard();
}
