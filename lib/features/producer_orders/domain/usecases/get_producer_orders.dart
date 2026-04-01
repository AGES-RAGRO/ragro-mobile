import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';

@lazySingleton
class GetProducerOrders {
  const GetProducerOrders(this._repository);

  final ProducerOrdersRepository _repository;

  Future<List<ProducerOrder>> call({ProducerOrderStatus? status}) =>
      _repository.getOrders(status: status);
}
