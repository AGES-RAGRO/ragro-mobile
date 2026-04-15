import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/get_order_detail.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_state.dart';

@injectable
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc(this._getOrderDetail) : super(const OrderDetailInitial()) {
    on<OrderDetailStarted>(_onStarted);
  }

  final GetOrderDetail _getOrderDetail;

  Future<void> _onStarted(
    OrderDetailStarted event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(const OrderDetailLoading());
    try {
      final order = await _getOrderDetail(event.orderId);
      emit(OrderDetailLoaded(order));
    } on Exception catch (e) {
      emit(OrderDetailFailure(e.toString()));
    }
  }
}
