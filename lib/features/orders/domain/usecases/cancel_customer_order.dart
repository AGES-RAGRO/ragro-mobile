import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class CancelCustomerOrder {
  const CancelCustomerOrder(this._repository);

  final OrdersRepository _repository;

  Future<OrderDetail> call(String orderId) =>
      _repository.cancelCustomerOrder(orderId);
}
