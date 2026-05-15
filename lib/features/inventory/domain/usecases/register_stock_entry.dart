import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/stock_movement_repository.dart';

@lazySingleton
class RegisterStockEntry {
  const RegisterStockEntry(this._repository);

  final StockMovementRepository _repository;

  Future<StockMovement> call({
    required String productId,
    required double quantity,
    String? notes,
  }) => _repository.registerEntry(
    productId: productId,
    quantity: quantity,
    notes: notes,
  );
}
