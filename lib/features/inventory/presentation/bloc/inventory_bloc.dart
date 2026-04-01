import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/delete_inventory_product.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/get_inventory_products.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_state.dart';

@injectable
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc(this._getProducts, this._deleteProduct)
      : super(const InventoryInitial()) {
    on<InventoryStarted>(_onStarted);
    on<InventoryFilterChanged>(_onFilterChanged);
    on<InventoryProductDeleted>(_onProductDeleted);
    on<InventoryRefreshed>(_onRefreshed);
  }

  final GetInventoryProducts _getProducts;
  final DeleteInventoryProduct _deleteProduct;
  List<InventoryProduct> _allProducts = [];
  String _activeFilter = 'all';

  Future<void> _onStarted(
    InventoryStarted event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());
    try {
      _allProducts = await _getProducts();
      _activeFilter = 'all';
      emit(_buildLoaded());
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }

  Future<void> _onFilterChanged(
    InventoryFilterChanged event,
    Emitter<InventoryState> emit,
  ) async {
    _activeFilter = event.filter;
    emit(_buildLoaded());
  }

  Future<void> _onProductDeleted(
    InventoryProductDeleted event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _deleteProduct(event.productId);
      _allProducts.removeWhere((p) => p.id == event.productId);
      emit(_buildLoaded());
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    InventoryRefreshed event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());
    try {
      _allProducts = await _getProducts();
      emit(_buildLoaded());
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }

  InventoryLoaded _buildLoaded() {
    final filtered = switch (_activeFilter) {
      'active' => _allProducts.where((p) => p.active && p.stock > 0).toList(),
      'unavailable' =>
        _allProducts.where((p) => !p.active || p.stock == 0).toList(),
      _ => List<InventoryProduct>.from(_allProducts),
    };
    final totalValue =
        _allProducts.fold(0.0, (sum, p) => sum + p.price * p.stock);
    return InventoryLoaded(
      products: filtered,
      activeFilter: _activeFilter,
      totalItems: _allProducts.length,
      totalValue: totalValue,
    );
  }
}
