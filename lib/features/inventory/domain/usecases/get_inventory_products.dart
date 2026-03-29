import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart';

@lazySingleton
class GetInventoryProducts {
  const GetInventoryProducts(this._repository);

  final InventoryRepository _repository;

  Future<List<InventoryProduct>> call() => _repository.getProducts();
}
