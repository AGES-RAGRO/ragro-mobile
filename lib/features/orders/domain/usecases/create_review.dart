import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class CreateReview {
  const CreateReview(this._repository);
  final OrdersRepository _repository;
  Future<void> call(String orderId, int rating, String comment) =>
      _repository.createReview(orderId, rating, comment);
}
