import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart';

@lazySingleton
class UpdateInventoryProduct {
  const UpdateInventoryProduct(this._repository);

  final InventoryRepository _repository;

  Future<InventoryProduct> call(InventoryProduct product) =>
      _repository.updateProduct(product);
}
