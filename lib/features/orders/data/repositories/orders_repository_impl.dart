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
  Future<Order> getOrderById(String id) => _datasource.getOrderById(id);

  @override
  Future<OrderDetail> getCustomerOrderById(String id) =>
      _datasource.getCustomerOrderById(id);

  @override
  Future<Order> createOrderFromCart() => _datasource.createOrderFromCart();

  @override
  Future<Order> cancelOrder(String id) => _datasource.cancelOrder(id);

  @override
  Future<OrderDetail> cancelCustomerOrder(String id) =>
      _datasource.cancelCustomerOrder(id);

  @override
  Future<OrderDetail> confirmCustomerDelivery(String id) =>
      _datasource.confirmCustomerDelivery(id);

  @override
  Future<Order> updateStatus(String id, OrderStatus status) =>
      _datasource.updateStatus(id, status);

  @override
  Future<Order> confirmOrder(String id) => _datasource.confirmOrder(id);

  @override
  Future<Order> repeatOrder(String id) => _datasource.repeatOrder(id);

  @override
  Future<void> rateProducer(String orderId, int rating) =>
      _datasource.rateProducer(orderId, rating);
}
