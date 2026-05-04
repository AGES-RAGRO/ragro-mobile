import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/get_cart.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/confirm_order.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_state.dart';

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc(this._confirmOrder, this._getCart)
    : super(const CheckoutInitial()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutConfirmed>(_onConfirmed);
  }

  final ConfirmOrder _confirmOrder;
  final GetCart _getCart;

  Future<void> _onStarted(
    CheckoutStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());
    try {
      final cart = await _getCart();
      emit(CheckoutReady(cart));
    } on Exception catch (e) {
      emit(CheckoutFailure(message: e.toString()));
    }
  }

  Future<void> _onConfirmed(
    CheckoutConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    final cart = switch (state) {
      CheckoutReady(:final cart) => cart,
      CheckoutFailure(:final cart) => cart,
      _ => null,
    };
    if (cart == null) return;
    emit(CheckoutConfirming(cart));
    try {
      final order = await _confirmOrder(event.cartId);
      emit(CheckoutSuccess(order));
    } on Exception catch (e) {
      emit(CheckoutFailure(cart: cart, message: e.toString()));
    }
  }
}
