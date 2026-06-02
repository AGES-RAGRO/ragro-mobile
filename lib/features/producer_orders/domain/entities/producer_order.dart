import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_item.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

class ProducerOrder extends Equatable {
  const ProducerOrder({
    required this.id,
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
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.cancellationReason,
    this.cancellationDetails,
  });

  final String id;
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

  /// Delivery address coordinates (order snapshot). Null if the customer's
  /// address was not geocoded; route calculation then falls back to the
  /// address string.
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  final String? cancellationReason;
  final String? cancellationDetails;

  /// Full readable address for display and geocoding fallback.
  String get fullDeliveryAddress {
    final parts = <String>[
      if (deliveryAddress.isNotEmpty) deliveryAddress,
      if (deliveryNeighborhood.isNotEmpty) deliveryNeighborhood,
      if (deliveryCityState.isNotEmpty) deliveryCityState,
    ];
    return parts.join(', ');
  }

  /// "lat,lng" when coordinates exist, otherwise the textual address. The
  /// backend (Directions API) accepts both as origin/destination/waypoint.
  String get routeStop {
    if (deliveryLatitude != null && deliveryLongitude != null) {
      return '$deliveryLatitude,$deliveryLongitude';
    }
    return fullDeliveryAddress;
  }

  ProducerOrder copyWith({
    ProducerOrderStatus? status,
    bool? isNew,
    String? cancellationReason,
    String? cancellationDetails,
  }) {
    return ProducerOrder(
      id: id,
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
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDetails: cancellationDetails ?? this.cancellationDetails,
    );
  }

  @override
  List<Object?> get props => [
    id,
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
    deliveryLatitude,
    deliveryLongitude,
    cancellationReason,
    cancellationDetails,
  ];
}
