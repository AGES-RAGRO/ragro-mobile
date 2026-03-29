import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart';

@lazySingleton
class CreateInventoryProduct {
  const CreateInventoryProduct(this._repository);

  final InventoryRepository _repository;

  Future<void> call(InventoryProduct product) =>
      _repository.createProduct(product);
}
