import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders({OrderStatus? status});
  Future<Order> getOrderById(String id);
  Future<Order> confirmOrder(String cartId);
  Future<void> rateProducer(String orderId, int rating);
}
