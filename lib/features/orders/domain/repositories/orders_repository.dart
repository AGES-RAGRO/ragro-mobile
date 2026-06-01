import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders({OrderStatus? status});
  Future<OrderDetail> getCustomerOrderById(String id);
  Future<Order> createOrderFromCart();
  Future<void> cancelCustomerOrder(
    String id, {
    required String reason,
    String? details,
  });
  Future<OrderDetail> confirmCustomerDelivery(String id);
  Future<void> createReview(String orderId, int rating, String comment);
}
