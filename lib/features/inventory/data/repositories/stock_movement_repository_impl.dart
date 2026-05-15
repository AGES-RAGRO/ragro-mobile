import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/data/datasources/stock_movement_remote_datasource.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/stock_movement_repository.dart';

@LazySingleton(as: StockMovementRepository)
class StockMovementRepositoryImpl implements StockMovementRepository {
  const StockMovementRepositoryImpl(this._dataSource);

  final StockMovementRemoteDataSource _dataSource;

  @override
  Future<StockMovement> registerExit({
    required String productId,
    required double quantity,
    required String reason,
    String? notes,
  }) => _dataSource.registerExit(
    productId: productId,
    quantity: quantity,
    reason: reason,
    notes: notes,
  );

  @override
  Future<StockMovement> registerEntry({
    required String productId,
    required double quantity,
    String? notes,
  }) => _dataSource.registerEntry(
    productId: productId,
    quantity: quantity,
    notes: notes,
  );

  @override
  Future<List<StockMovement>> getProductMovements(
    String productId, {
    int page = 0,
    int size = 20,
  }) => _dataSource.getProductMovements(productId, page: page, size: size);
}
