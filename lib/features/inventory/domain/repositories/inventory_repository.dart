import 'package:image_picker/image_picker.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

abstract class InventoryRepository {
  Future<List<InventoryProduct>> getProducts();
  Future<InventoryProduct> createProduct(InventoryProduct product);
  Future<InventoryProduct> updateProduct(InventoryProduct product);
  Future<void> deleteProduct(String id);
  Future<InventoryProduct> uploadProductPhoto(String productId, XFile file);
}
