import 'package:equatable/equatable.dart';

class OrderDetailActions extends Equatable {
  const OrderDetailActions({
    required this.canConfirmDelivery,
    required this.canCancel,
    required this.canContactProducer,
  });

  final bool canConfirmDelivery;
  final bool canCancel;
  final bool canContactProducer;

  @override
  List<Object?> get props => [
    canConfirmDelivery,
    canCancel,
    canContactProducer,
  ];
}

class OrderDetailBankInfo extends Equatable {
  const OrderDetailBankInfo({
    required this.bank,
    required this.agency,
    required this.account,
    required this.pixKey,
  });

  final String bank;
  final String agency;
  final String account;
  final String pixKey;

  bool get hasAnyInfo =>
      bank.isNotEmpty || account.isNotEmpty || pixKey.isNotEmpty;

  @override
  List<Object?> get props => [bank, agency, account, pixKey];
}

class OrderDetailAddress extends Equatable {
  const OrderDetailAddress({
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.reference,
    this.zipCode = '',
  });

  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String reference;
  final String zipCode;

  String get streetLine {
    final base = [street, number].where((part) => part.isNotEmpty).join(', ');
    if (complement.isEmpty) return base;
    return '$base - $complement';
  }

  String get cityLine {
    final cityState = [
      city,
      state,
    ].where((part) => part.isNotEmpty).join(' - ');
    if (neighborhood.isEmpty) return cityState;
    if (cityState.isEmpty) return neighborhood;
    return '$neighborhood, $cityState';
  }

  @override
  List<Object?> get props => [
    street,
    number,
    complement,
    neighborhood,
    city,
    state,
    reference,
    zipCode,
  ];
}

class OrderDetailItem extends Equatable {
  const OrderDetailItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPhoto,
    required this.quantity,
    required this.unityType,
    required this.unitPrice,
    required this.subtotal,
  });

  final String id;
  final String productId;
  final String productName;
  final String productPhoto;
  final double quantity;
  final String unityType;
  final double unitPrice;
  final double subtotal;

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productPhoto,
    quantity,
    unityType,
    unitPrice,
    subtotal,
  ];
}

class OrderDetail extends Equatable {
  const OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.producerId,
    required this.producerName,
    required this.producerPhone,
    required this.producerPicture,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.actions,
    this.bankInfo,
  });

  final String id;
  final String? orderNumber;
  final String status;
  final String? statusLabel;
  final DateTime? createdAt;
  final String producerId;
  final String producerName;
  final String? producerPhone;
  final String? producerPicture;
  final List<OrderDetailItem> items;
  final double totalAmount;
  final OrderDetailAddress deliveryAddress;
  final OrderDetailActions? actions;
  final OrderDetailBankInfo? bankInfo;

  String get displayNumber {
    if (orderNumber != null && orderNumber!.isNotEmpty) return orderNumber!;
    final shortId = id.length > 4 ? id.substring(0, 4) : id;
    return '#$shortId';
  }

  bool get isPending => _normalizedStatus == 'PENDING';
  bool get isAccepted => _normalizedStatus == 'CONFIRMED';
  bool get isInDelivery => _normalizedStatus == 'IN_DELIVERY';

  bool get canConfirmDelivery => actions?.canConfirmDelivery ?? isInDelivery;

  bool get canCancel => actions?.canCancel ?? (isPending || isAccepted);

  bool get canContactProducer =>
      actions?.canContactProducer ??
      (producerPhone?.trim().isNotEmpty ?? false);

  String get friendlyStatusLabel {
    if (statusLabel != null && statusLabel!.isNotEmpty) return statusLabel!;
    return switch (_normalizedStatus) {
      'PENDING' => 'Pendente',
      'CONFIRMED' => 'Aceito',
      'IN_DELIVERY' => 'A caminho',
      'DELIVERED' => 'Entregue',
      'CANCELLED' => 'Cancelado',
      _ => status,
    };
  }

  String get _normalizedStatus => status.trim().toUpperCase();

  OrderDetail copyWith({
    String? status,
    String? statusLabel,
    OrderDetailActions? actions,
  }) {
    return OrderDetail(
      id: id,
      orderNumber: orderNumber,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      createdAt: createdAt,
      producerId: producerId,
      producerName: producerName,
      producerPhone: producerPhone,
      producerPicture: producerPicture,
      items: items,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      actions: actions ?? this.actions,
      bankInfo: bankInfo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    status,
    statusLabel,
    createdAt,
    producerId,
    producerName,
    producerPhone,
    producerPicture,
    items,
    totalAmount,
    deliveryAddress,
    actions,
    bankInfo,
  ];
}
