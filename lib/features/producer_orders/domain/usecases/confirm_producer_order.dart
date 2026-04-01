import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';

@lazySingleton
class ConfirmProducerOrder {
  const ConfirmProducerOrder(this._repository);

  final ProducerOrdersRepository _repository;

  Future<void> call(String id) => _repository.confirmOrder(id);
}
