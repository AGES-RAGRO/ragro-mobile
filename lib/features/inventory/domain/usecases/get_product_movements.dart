import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/stock_movement_repository.dart';

@lazySingleton
class GetProductMovements {
  const GetProductMovements(this._repository);

  final StockMovementRepository _repository;

  Future<List<StockMovement>> call(String productId) =>
      _repository.getProductMovements(productId);
}
