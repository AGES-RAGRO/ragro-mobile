import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';

@lazySingleton
class GetProducerOrderDetail {
  const GetProducerOrderDetail(this._repository);

  final ProducerOrdersRepository _repository;

  Future<ProducerOrder> call(String id) => _repository.getOrderById(id);
}
