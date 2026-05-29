import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_item.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

class ProducerOrder extends Equatable {
  const ProducerOrder({
    required this.id,
    required this.orderNumber,
    required this.consumerName,
    required this.consumerAvatarUrl,
    required this.consumerSince,
    required this.status,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.deliveryNeighborhood,
    required this.deliveryCityState,
    required this.deliveryComplement,
    required this.items,
    required this.createdAt,
    required this.isNew,
    required this.consumerPhone,
    this.cancellationReason,
    this.cancellationDetails,
  });

  final String id;
  final int orderNumber;
  final String consumerName;
  final String consumerAvatarUrl;
  final String consumerSince;
  final ProducerOrderStatus status;
  final double totalPrice;
  final String deliveryAddress;
  final String deliveryNeighborhood;
  final String deliveryCityState;
  final String deliveryComplement;
  final List<ProducerOrderItem> items;
  final DateTime createdAt;
  final bool isNew;
  final String consumerPhone;
  final String? cancellationReason;
  final String? cancellationDetails;

  ProducerOrder copyWith({
    ProducerOrderStatus? status,
    bool? isNew,
    String? cancellationReason,
    String? cancellationDetails,
  }) {
    return ProducerOrder(
      id: id,
      orderNumber: orderNumber,
      consumerName: consumerName,
      consumerAvatarUrl: consumerAvatarUrl,
      consumerSince: consumerSince,
      status: status ?? this.status,
      totalPrice: totalPrice,
      deliveryAddress: deliveryAddress,
      deliveryNeighborhood: deliveryNeighborhood,
      deliveryCityState: deliveryCityState,
      deliveryComplement: deliveryComplement,
      items: items,
      createdAt: createdAt,
      isNew: isNew ?? this.isNew,
      consumerPhone: consumerPhone,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDetails: cancellationDetails ?? this.cancellationDetails,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    consumerName,
    consumerAvatarUrl,
    consumerSince,
    status,
    totalPrice,
    deliveryAddress,
    deliveryNeighborhood,
    deliveryCityState,
    deliveryComplement,
    items,
    createdAt,
    isNew,
    consumerPhone,
    cancellationReason,
    cancellationDetails,
  ];
}
