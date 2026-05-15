import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class CancelCustomerOrder {
  const CancelCustomerOrder(this._repository);

  final OrdersRepository _repository;

  Future<void> call(String orderId, {required String reason, String? details}) =>
      _repository.cancelCustomerOrder(orderId, reason: reason, details: details);
}
