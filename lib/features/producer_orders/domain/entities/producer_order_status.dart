import 'package:ragro_mobile/core/domain/order_status.dart';

export 'package:ragro_mobile/core/domain/order_status.dart';

/// Compat alias: the producer feature historically had its own status enum;
/// both sides now share the canonical [OrderStatus] from core.
typedef ProducerOrderStatus = OrderStatus;
