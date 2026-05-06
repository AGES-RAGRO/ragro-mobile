import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/create_inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/get_inventory_products.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/update_inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/upload_product_photo.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_state.dart';

@injectable
class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  ProductFormBloc(
    this._getProducts,
    this._createProduct,
    this._updateProduct,
    this._uploadPhoto,
    this._dataSource,
  ) : super(const ProductFormInitial()) {
    on<ProductFormStarted>(_onStarted);
    on<ProductFormSaved>(_onSaved);
  }

  final GetInventoryProducts _getProducts;
  final CreateInventoryProduct _createProduct;
  final UpdateInventoryProduct _updateProduct;
  final UploadProductPhoto _uploadPhoto;
  final InventoryRemoteDataSource _dataSource;

  String? _currentProductId;

  Future<void> _onStarted(
    ProductFormStarted event,
    Emitter<ProductFormState> emit,
  ) async {
    _currentProductId = event.productId;
    emit(const ProductFormLoading());
    try {
      final categories = await _dataSource.getCategories();
      if (event.productId == null) {
        emit(ProductFormReady(availableCategories: categories));
        return;
      }
      final products = await _getProducts();
      final product = products.firstWhere(
        (p) => p.id == event.productId,
        orElse: () => throw Exception('Produto não encontrado'),
      );
      emit(ProductFormReady(product: product, availableCategories: categories));
    } on Exception catch (e) {
      emit(ProductFormFailure(e.toString()));
    }
  }

  Future<void> _onSaved(
    ProductFormSaved event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(const ProductFormLoading());
    try {
      if (_currentProductId == null) {
        final newProduct = InventoryProduct(
          id: '',
          producerId: '',
          name: event.name,
          description: event.description,
          imageUrl: '',
          price: event.price,
          unit: event.unit,
          stock: event.stock,
          active: event.stock > 0,
          categoryIds: event.categoryIds,
        );
        final created = await _createProduct(newProduct);
        if (event.photo != null) {
          await _uploadPhoto(created.id, event.photo!);
        }
      } else {
        final products = await _getProducts();
        final existing = products.firstWhere(
          (p) => p.id == _currentProductId,
          orElse: () => throw Exception('Produto não encontrado'),
        );
        final updated = existing.copyWith(
          name: event.name,
          description: event.description,
          price: event.price,
          unit: event.unit,
          stock: event.stock,
          active: event.stock > 0,
          categoryIds: event.categoryIds,
        );
        await _updateProduct(updated);
        if (event.photo != null) {
          await _uploadPhoto(existing.id, event.photo!);
        }
      }
      emit(const ProductFormSuccess());
    } on Exception catch (e) {
      emit(ProductFormFailure(e.toString()));
    }
  }
}
