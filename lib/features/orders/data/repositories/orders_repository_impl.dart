import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._datasource);
  final OrdersRemoteDatasource _datasource;

  @override
  Future<List<Order>> getOrders({OrderStatus? status}) =>
      _datasource.getOrders(status: status);

  @override
  Future<OrderDetail> getCustomerOrderById(String id) =>
      _datasource.getCustomerOrderById(id);

  @override
  Future<Order> createOrderFromCart() => _datasource.createOrderFromCart();

  @override
  Future<void> cancelCustomerOrder(
    String id, {
    required String reason,
    String? details,
  }) => _datasource.cancelCustomerOrder(id, reason: reason, details: details);

  @override
  Future<OrderDetail> confirmCustomerDelivery(String id) =>
      _datasource.confirmCustomerDelivery(id);

  @override
  Future<void> createReview(String orderId, int rating, String comment) =>
      _datasource.createReview(orderId, rating, comment);
}
