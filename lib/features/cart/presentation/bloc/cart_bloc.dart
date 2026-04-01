import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
  }

  final GetCart _getCart;
  final AddToCart _addToCart;
  final UpdateCartItemQuantity _updateQuantity;
  final RemoveFromCart _removeFromCart;
  final ClearCart _clearCart;

  void _onStarted(CartStarted event, Emitter<CartState> emit) {
    emit(CartLoaded(_getCart()));
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    emit(CartLoaded(_addToCart(event.item)));
  }

  void _onQuantityUpdated(CartItemQuantityUpdated event, Emitter<CartState> emit) {
    emit(CartLoaded(_updateQuantity(event.productId, event.quantity)));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    emit(CartLoaded(_removeFromCart(event.productId)));
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(CartLoaded(_clearCart()));
  }
}
