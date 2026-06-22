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

/// Nenhum pedido a caminho (ou ainda não carregado) — o banner fica escondido.
class ActiveDeliveryNone extends ActiveDeliveryState {
  const ActiveDeliveryNone();
}

/// Há um pedido a caminho com código de confirmação para exibir no banner.
class ActiveDeliveryAvailable extends ActiveDeliveryState {
  const ActiveDeliveryAvailable(this.order);
  final Order order;
  @override
  List<Object?> get props => [order];
}

/// Cubit do banner "seu pedido está a caminho" na home do consumidor.
/// Reusa [GetOrders] filtrando por IN_DELIVERY; o backend já devolve o
/// `confirmationCode` apenas nesse estado. Falhas são silenciosas (banner some).
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
