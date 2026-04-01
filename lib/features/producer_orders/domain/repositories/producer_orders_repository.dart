import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

abstract class ProducerOrdersRepository {
  Future<List<ProducerOrder>> getOrders({ProducerOrderStatus? status});
  Future<ProducerOrder> getOrderById(String id);
  Future<void> confirmOrder(String id);
  Future<void> refuseOrder(String id);
  Future<void> updateStatus(String id, ProducerOrderStatus status);
}
