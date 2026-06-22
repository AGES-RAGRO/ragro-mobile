import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/core/domain/order_status.dart';

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
    this.reviewed = false,
    this.cancellationReason,
    this.cancellationDetails,
    this.confirmationCode,
  });

  final String id;
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
  final bool reviewed;
  final String? cancellationReason;
  final String? cancellationDetails;
  final String? confirmationCode;

  String get displayNumber {
    final shortId = id.length > 4 ? id.substring(0, 4) : id;
    return '#$shortId';
  }

  bool get isPending => _normalizedStatus == 'PENDING';
  bool get isAccepted => _normalizedStatus == 'CONFIRMED';
  bool get isInDelivery => _normalizedStatus == 'IN_DELIVERY';
  bool get isDelivered => _normalizedStatus == 'DELIVERED';
  bool get isCancelled => _normalizedStatus == 'CANCELLED';

  bool get canConfirmDelivery => actions?.canConfirmDelivery ?? false;

  bool get canCancel => isPending || isAccepted;

  bool get canContactProducer =>
      (producerPhone?.trim().isNotEmpty ?? false) &&
      !isDelivered &&
      !isCancelled;

  String get friendlyStatusLabel {
    if (statusLabel != null && statusLabel!.isNotEmpty) return statusLabel!;
    return OrderStatus.tryParse(status)?.label ?? status;
  }

  String get _normalizedStatus => status.trim().toUpperCase();

  OrderDetail copyWith({
    String? status,
    String? statusLabel,
    OrderDetailActions? actions,
    bool? reviewed,
    String? cancellationReason,
    String? cancellationDetails,
    String? confirmationCode,
  }) {
    return OrderDetail(
      id: id,
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
      reviewed: reviewed ?? this.reviewed,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDetails: cancellationDetails ?? this.cancellationDetails,
      confirmationCode: confirmationCode ?? this.confirmationCode,
    );
  }

  @override
  List<Object?> get props => [
    id,
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
    reviewed,
    cancellationReason,
    cancellationDetails,
    confirmationCode,
  ];
}
