import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/create_inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/get_inventory_products.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/update_inventory_product.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_state.dart';

@injectable
class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  ProductFormBloc(this._getProducts, this._createProduct, this._updateProduct)
    : super(const ProductFormInitial()) {
    on<ProductFormStarted>(_onStarted);
    on<ProductFormSaved>(_onSaved);
  }

  final GetInventoryProducts _getProducts;
  final CreateInventoryProduct _createProduct;
  final UpdateInventoryProduct _updateProduct;

  String? _currentProductId;

  Future<void> _onStarted(
    ProductFormStarted event,
    Emitter<ProductFormState> emit,
  ) async {
    _currentProductId = event.productId;
    if (event.productId == null) {
      emit(const ProductFormReady());
      return;
    }
    emit(const ProductFormLoading());
    try {
      final products = await _getProducts();
      final product = products.firstWhere(
        (p) => p.id == event.productId,
        orElse: () => throw Exception('Produto não encontrado'),
      );
      emit(ProductFormReady(product: product));
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
        // Create mode
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
        );
        await _createProduct(newProduct);
      } else {
        // Edit mode — fetch current and update
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
        );
        await _updateProduct(updated);
      }
      emit(const ProductFormSuccess());
    } on Exception catch (e) {
      emit(ProductFormFailure(e.toString()));
    }
  }
}
