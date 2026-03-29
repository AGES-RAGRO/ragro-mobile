import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart';

@lazySingleton
class DeleteInventoryProduct {
  const DeleteInventoryProduct(this._repository);

  final InventoryRepository _repository;

  Future<void> call(String id) => _repository.deleteProduct(id);
}
