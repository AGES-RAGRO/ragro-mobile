import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/stock_movement_repository.dart';

@lazySingleton
class RegisterStockExit {
  const RegisterStockExit(this._repository);

  final StockMovementRepository _repository;

  Future<StockMovement> call({
    required String productId,
    required double quantity,
    required String reason,
    String? notes,
  }) => _repository.registerExit(
    productId: productId,
    quantity: quantity,
    reason: reason,
    notes: notes,
  );
}
