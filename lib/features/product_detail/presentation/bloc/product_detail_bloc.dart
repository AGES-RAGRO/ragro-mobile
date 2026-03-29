import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/product_detail/domain/usecases/get_product_detail.dart';
import 'package:ragro_mobile/features/product_detail/presentation/bloc/product_detail_event.dart';
import 'package:ragro_mobile/features/product_detail/presentation/bloc/product_detail_state.dart';

@injectable
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc(this._getProduct) : super(const ProductDetailInitial()) {
    on<ProductDetailStarted>(_onStarted);
    on<ProductDetailQuantityIncremented>(_onIncrement);
    on<ProductDetailQuantityDecremented>(_onDecrement);
  }

  final GetProductDetail _getProduct;

  Future<void> _onStarted(
    ProductDetailStarted event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());
    try {
      final product = await _getProduct(event.productId);
      emit(ProductDetailLoaded(product: product));
    } on ApiException catch (e) {
      emit(ProductDetailFailure(e.message));
    } catch (_) {
      emit(const ProductDetailFailure('Erro ao carregar produto.'));
    }
  }

  void _onIncrement(
    ProductDetailQuantityIncremented event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state is ProductDetailLoaded) {
      final s = state as ProductDetailLoaded;
      if (s.quantity < s.product.stockQuantity) {
        emit(s.copyWith(quantity: s.quantity + 1));
      }
    }
  }

  void _onDecrement(
    ProductDetailQuantityDecremented event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state is ProductDetailLoaded) {
      final s = state as ProductDetailLoaded;
      if (s.quantity > 1) emit(s.copyWith(quantity: s.quantity - 1));
    }
  }
}
