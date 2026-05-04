import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/add_to_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/clear_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/get_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/update_cart_item_quantity.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_state.dart';

@lazySingleton
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(
    this._getCart,
    this._addToCart,
    this._updateQuantity,
    this._removeFromCart,
    this._clearCart,
  ) : super(const CartInitial()) {
    on<CartStarted>(_onStarted);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemQuantityUpdated>(_onQuantityUpdated);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
    on<CartOrderPlaced>(_onOrderPlaced);
  }

  final GetCart _getCart;
  final AddToCart _addToCart;
  final UpdateCartItemQuantity _updateQuantity;
  final RemoveFromCart _removeFromCart;
  final ClearCart _clearCart;

  Cart? _currentCart() => switch (state) {
    CartLoaded(:final cart) => cart,
    CartUpdating(:final cart) => cart,
    CartUpdateFailure(:final cart) => cart,
    _ => null,
  };

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    try {
      final cart = await _getCart();
      emit(CartLoaded(cart));
    } on ApiException catch (e) {
      emit(CartFailure(e.message));
    } on Exception catch (_) {
      emit(const CartFailure('Erro ao carregar carrinho.'));
    }
  }

  Future<void> _runMutation(
    Future<Cart> Function() mutate,
    String defaultMessage,
    Emitter<CartState> emit,
  ) async {
    final current = _currentCart();
    if (current != null) emit(CartUpdating(current));

    try {
      final cart = await mutate();
      emit(CartLoaded(cart));
    } on ApiException catch (e) {
      if (current != null) {
        emit(CartUpdateFailure(current, e.message));
        return;
      }
      emit(CartFailure(e.message));
    } on Exception catch (_) {
      if (current != null) {
        emit(CartUpdateFailure(current, defaultMessage));
        return;
      }
      emit(CartFailure(defaultMessage));
    }
  }

  Future<void> _onItemAdded(CartItemAdded event, Emitter<CartState> emit) =>
      _runMutation(
        () => _addToCart(productId: event.productId, quantity: event.quantity),
        'Erro ao adicionar item ao carrinho.',
        emit,
      );

  Future<void> _onQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) => _runMutation(
    () =>
        _updateQuantity(cartItemId: event.cartItemId, quantity: event.quantity),
    'Erro ao atualizar quantidade.',
    emit,
  );

  Future<void> _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) =>
      _runMutation(
        () => _removeFromCart(event.cartItemId),
        'Erro ao remover item do carrinho.',
        emit,
      );

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) =>
      _runMutation(_clearCart.call, 'Erro ao limpar carrinho.', emit);

  void _onOrderPlaced(CartOrderPlaced event, Emitter<CartState> emit) {
    emit(const CartInitial());
  }
}
