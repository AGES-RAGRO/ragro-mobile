import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

abstract class InventoryRepository {
  Future<List<InventoryProduct>> getProducts();
  Future<void> createProduct(InventoryProduct product);
  Future<void> updateProduct(InventoryProduct product);
  Future<void> deleteProduct(String id);
}
