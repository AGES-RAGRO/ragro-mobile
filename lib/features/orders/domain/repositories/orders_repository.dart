import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders({OrderStatus? status});
  Future<Order> getOrderById(String id);
  Future<OrderDetail> getCustomerOrderById(String id);
  Future<Order> createOrderFromCart();
  Future<Order> cancelOrder(String id);
  Future<void> cancelCustomerOrder(String id, {required String reason, String? details});
  Future<OrderDetail> confirmCustomerDelivery(String id);
  Future<Order> updateStatus(String id, OrderStatus status);
  Future<Order> confirmOrder(String id);
  Future<Order> repeatOrder(String id);
  Future<void> rateProducer(String orderId, int rating);
}
