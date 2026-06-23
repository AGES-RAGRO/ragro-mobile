import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/get_orders.dart';

sealed class ActiveDeliveryState extends Equatable {
  const ActiveDeliveryState();
  @override
  List<Object?> get props => [];
}

/// No order in delivery (or not yet loaded); banner hidden.
class ActiveDeliveryNone extends ActiveDeliveryState {
  const ActiveDeliveryNone();
}

/// An order is in delivery with a confirmation code to show in the banner.
class ActiveDeliveryAvailable extends ActiveDeliveryState {
  const ActiveDeliveryAvailable(this.order);
  final Order order;
  @override
  List<Object?> get props => [order];
}

/// Drives the "order on the way" banner on the customer home. Reuses
/// [GetOrders] filtered by IN_DELIVERY (the only state with a
/// `confirmationCode`). Failures are silent (banner hides).
@lazySingleton
class ActiveDeliveryCubit extends Cubit<ActiveDeliveryState> {
  ActiveDeliveryCubit(this._getOrders) : super(const ActiveDeliveryNone());

  final GetOrders _getOrders;

  Future<void> load() async {
    try {
      final orders = await _getOrders(status: OrderStatus.inDelivery);
      final active = orders
          .where(
            (o) =>
                o.status == OrderStatus.inDelivery &&
                (o.confirmationCode?.isNotEmpty ?? false),
          )
          .toList();
      emit(
        active.isEmpty
            ? const ActiveDeliveryNone()
            : ActiveDeliveryAvailable(active.first),
      );
    } on Exception {
      emit(const ActiveDeliveryNone());
    }
  }
}
