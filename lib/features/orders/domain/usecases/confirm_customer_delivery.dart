import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class ConfirmCustomerDelivery {
  const ConfirmCustomerDelivery(this._repository);

  final OrdersRepository _repository;

  Future<OrderDetail> call(String orderId) =>
      _repository.confirmCustomerDelivery(orderId);
}
