import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';

abstract class StockMovementRepository {
  Future<StockMovement> registerExit({
    required String productId,
    required double quantity,
    required String reason,
    String? notes,
  });

  Future<StockMovement> registerEntry({
    required String productId,
    required double quantity,
    String? notes,
  });

  Future<List<StockMovement>> getProductMovements(
    String productId, {
    int page = 0,
    int size = 20,
  });
}
