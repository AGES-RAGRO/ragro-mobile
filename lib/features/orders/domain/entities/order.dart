import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_item.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';

class ProducerBankInfo extends Equatable {
  const ProducerBankInfo({
    required this.bank,
    required this.agency,
    required this.account,
    required this.pixKey,
  });

  final String bank;
  final String agency;
  final String account;
  final String pixKey;

  @override
  List<Object?> get props => [bank, agency, account, pixKey];
}

class DeliveryAddress extends Equatable {
  const DeliveryAddress({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  String get fullAddress => '$street, $neighborhood';
  String get cityStateZip => '$city - $state, $zipCode';

  @override
  List<Object?> get props => [street, neighborhood, city, state, zipCode];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.producerId,
    required this.producerPhone,
    required this.farmName,
    required this.farmAvatarUrl,
    required this.ownerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    required this.bankInfo,
    this.avaliado = false,
  });

  final String id;
  final String producerId;
  final String producerPhone;
  final String farmName;
  final String farmAvatarUrl;
  final String ownerName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DeliveryAddress deliveryAddress;
  final ProducerBankInfo bankInfo;
  final bool avaliado;

  Order copyWith({
    String? id,
    String? producerId,
    String? producerPhone,
    String? farmName,
    String? farmAvatarUrl,
    String? ownerName,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DeliveryAddress? deliveryAddress,
    ProducerBankInfo? bankInfo,
    bool? avaliado,
  }) {
    return Order(
      id: id ?? this.id,
      producerId: producerId ?? this.producerId,
      producerPhone: producerPhone ?? this.producerPhone,
      farmName: farmName ?? this.farmName,
      farmAvatarUrl: farmAvatarUrl ?? this.farmAvatarUrl,
      ownerName: ownerName ?? this.ownerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      bankInfo: bankInfo ?? this.bankInfo,
      avaliado: avaliado ?? this.avaliado,
    );
  }

  String get shortItemsPreview {
    if (items.isEmpty) return '';
    return items
            .take(3)
            .map((i) => '${i.name} ${_formatQuantityWithUnit(i)}')
            .join(' | ') +
        (items.length > 3 ? ' ...' : '');
  }

  static String _formatQuantityWithUnit(OrderItem item) {
    final localizedUnit = localizeUnityType(item.unityType);
    if (localizedUnit.isEmpty) {
      return item.quantityLabel;
    }
    return '${item.quantityLabel} $localizedUnit';
  }

  @override
  List<Object?> get props => [
    id,
    producerId,
    producerPhone,
    farmName,
    farmAvatarUrl,
    ownerName,
    items,
    totalAmount,
    status,
    createdAt,
    deliveryAddress,
    bankInfo,
    avaliado,
  ];
}
