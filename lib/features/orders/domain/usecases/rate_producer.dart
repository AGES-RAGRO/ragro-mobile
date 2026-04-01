import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class RateProducer {
  const RateProducer(this._repository);
  final OrdersRepository _repository;
  Future<void> call(String orderId, int rating) => _repository.rateProducer(orderId, rating);
}
