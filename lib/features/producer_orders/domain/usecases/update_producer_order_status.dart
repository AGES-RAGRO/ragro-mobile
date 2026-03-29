import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';

@lazySingleton
class UpdateProducerOrderStatus {
  const UpdateProducerOrderStatus(this._repository);

  final ProducerOrdersRepository _repository;

  Future<void> call(String id, ProducerOrderStatus status) =>
      _repository.updateStatus(id, status);
}
