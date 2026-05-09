import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';

@lazySingleton
class RefuseProducerOrder {
  const RefuseProducerOrder(this._repository);

  final ProducerOrdersRepository _repository;

  Future<void> call(String id, {required String reason, String? details}) =>
      _repository.refuseOrder(id, reason: reason, details: details);
}
