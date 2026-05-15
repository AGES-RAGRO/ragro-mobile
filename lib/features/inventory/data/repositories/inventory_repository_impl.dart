import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart';

@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._dataSource);

  final InventoryRemoteDataSource _dataSource;

  @override
  Future<List<InventoryProduct>> getProducts() => _dataSource.getProducts();

  @override
  Future<InventoryProduct> createProduct(InventoryProduct product) =>
      _dataSource.createProduct(product);

  @override
  Future<InventoryProduct> updateProduct(InventoryProduct product) =>
      _dataSource.updateProduct(product);

  @override
  Future<void> deleteProduct(String id) => _dataSource.deleteProduct(id);

  @override
  Future<InventoryProduct> uploadProductPhoto(String productId, XFile file) =>
      _dataSource.uploadProductPhoto(productId, file);
}
