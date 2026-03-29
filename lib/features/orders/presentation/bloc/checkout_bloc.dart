import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/confirm_order.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_state.dart';

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc(this._confirmOrder) : super(const CheckoutInitial()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutConfirmed>(_onConfirmed);
  }

  final ConfirmOrder _confirmOrder;

  Future<void> _onStarted(CheckoutStarted event, Emitter<CheckoutState> emit) async {
    emit(const CheckoutLoading());
    try {
      // Load the order preview from the cart
      final order = await _confirmOrder(event.cartId);
      emit(CheckoutReady(order));
    } catch (e) {
      emit(CheckoutFailure(e.toString()));
    }
  }

  Future<void> _onConfirmed(CheckoutConfirmed event, Emitter<CheckoutState> emit) async {
    emit(const CheckoutLoading());
    try {
      final order = await _confirmOrder(event.cartId);
      emit(CheckoutSuccess(order));
    } catch (e) {
      emit(CheckoutFailure(e.toString()));
    }
  }
}
