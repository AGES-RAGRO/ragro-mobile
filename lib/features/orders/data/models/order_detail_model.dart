import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';

class OrderDetailActionsModel extends OrderDetailActions {
  const OrderDetailActionsModel({
    required super.canConfirmDelivery,
    required super.canCancel,
    required super.canContactProducer,
  });

  factory OrderDetailActionsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailActionsModel(
      canConfirmDelivery: json['canConfirmDelivery'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
      canContactProducer: json['canContactProducer'] as bool? ?? false,
    );
  }
}

class OrderDetailBankInfoModel extends OrderDetailBankInfo {
  const OrderDetailBankInfoModel({
    required super.bank,
    required super.agency,
    required super.account,
    required super.pixKey,
  });

  factory OrderDetailBankInfoModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailBankInfoModel(
      bank: json['bank'] as String? ?? '',
      agency: json['agency'] as String? ?? '',
      account: json['account'] as String? ?? '',
      pixKey: json['pixKey'] as String? ?? json['pix_key'] as String? ?? '',
    );
  }
}

class OrderDetailAddressModel extends OrderDetailAddress {
  const OrderDetailAddressModel({
    required super.street,
    required super.number,
    required super.complement,
    required super.neighborhood,
    required super.city,
    required super.state,
    required super.reference,
    super.zipCode,
  });

  factory OrderDetailAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailAddressModel(
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      complement: json['complement'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      zipCode:
          json['zipCode'] as String? ??
          json['zip_code'] as String? ??
          json['cep'] as String? ??
          '',
    );
  }
}

class OrderDetailItemModel extends OrderDetailItem {
  const OrderDetailItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productPhoto,
    required super.quantity,
    required super.unityType,
    required super.unitPrice,
    required super.subtotal,
  });

  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemModel(
      id: json['id'] as String? ?? '',
      productId:
          json['productId'] as String? ?? json['product_id'] as String? ?? '',
      productName:
          json['productName'] as String? ?? json['name'] as String? ?? '',
      productPhoto:
          json['productPhoto'] as String? ??
          json['productPhotoUrl'] as String? ??
          json['imageUrl'] as String? ??
          json['imageS3'] as String? ??
          '',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      unityType:
          json['unityType'] as String? ??
          json['unit'] as String? ??
          json['unity_type'] as String? ??
          '',
      unitPrice: (json['unitPrice'] as num? ?? json['unit_price'] as num? ?? 0)
          .toDouble(),
      subtotal:
          (json['subtotal'] as num? ??
                  json['totalPrice'] as num? ??
                  json['total'] as num? ??
                  0)
              .toDouble(),
    );
  }
}

class OrderDetailModel extends OrderDetail {
  const OrderDetailModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.statusLabel,
    required super.createdAt,
    required super.producerId,
    required super.producerName,
    required super.producerPhone,
    required super.producerPicture,
    required super.items,
    required super.totalAmount,
    required super.deliveryAddress,
    required super.actions,
    super.bankInfo,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderDetailItemModel.fromJson)
        .toList();
    final address = json['deliveryAddress'] as Map<String, dynamic>?;
    final actions = json['actions'] as Map<String, dynamic>?;
    final producerJson =
        json['producer'] as Map<String, dynamic>? ??
        json['farmer'] as Map<String, dynamic>?;
    final bankJson =
        json['bankInfo'] as Map<String, dynamic>? ??
        producerJson?['bankInfo'] as Map<String, dynamic>?;

    return OrderDetailModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String?,
      status: _normalizeStatus(json['status'] as String?),
      statusLabel: json['statusLabel'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      producerId:
          json['producerId'] as String? ??
          producerJson?['id'] as String? ??
          '',
      producerName:
          json['producerName'] as String? ??
          json['farmName'] as String? ??
          producerJson?['name'] as String? ??
          '',
      producerPhone:
          json['producerPhone'] as String? ??
          producerJson?['phone'] as String?,
      producerPicture:
          json['producerPicture'] as String? ??
          json['producerPhoto'] as String? ??
          json['producerPhotoUrl'] as String? ??
          producerJson?['photoUrl'] as String?,
      items: items,
      totalAmount:
          (json['totalAmount'] as num? ??
                  json['total'] as num? ??
                  json['totalPrice'] as num? ??
                  0)
              .toDouble(),
      deliveryAddress: OrderDetailAddressModel.fromJson(
        address ?? const <String, dynamic>{},
      ),
      actions: actions == null
          ? null
          : OrderDetailActionsModel.fromJson(actions),
      bankInfo: bankJson == null
          ? null
          : OrderDetailBankInfoModel.fromJson(bankJson),
    );
  }

  static String _normalizeStatus(String? status) {
    return switch (status?.trim().toUpperCase()) {
      'ACCEPTED' || 'CONFIRMED' => 'CONFIRMED',
      'INDELIVERY' || 'IN_DELIVERY' || 'OUT_FOR_DELIVERY' => 'IN_DELIVERY',
      'DELIVERED' => 'DELIVERED',
      'CANCELED' || 'CANCELLED' => 'CANCELLED',
      _ => 'PENDING',
    };
  }
}
