import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart';

@lazySingleton
class UploadProductPhoto {
  const UploadProductPhoto(this._repository);

  final InventoryRepository _repository;

  Future<InventoryProduct> call(String productId, XFile file) =>
      _repository.uploadProductPhoto(productId, file);
}
