import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_availability.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_payment_method.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

class AdminProducerModel extends AdminProducer {
  const AdminProducerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.createdAt,
    required super.updatedAt,
    required super.active,
    required super.fiscalNumber,
    required super.fiscalNumberType,
    required super.farmName,
    required super.description,
    super.producerAddress,
    super.paymentMethods,
    super.availability,
  });

  factory AdminProducerModel.fromJson(Map<String, dynamic> json) {
    final addressData = json['address'];
    AdminAddress? producerAddress;
    String flattenedAddress = '';

    if (addressData is Map<String, dynamic>) {
      producerAddress = AdminAddress(
        street: addressData['street'] as String? ?? '',
        number: addressData['number'] as String? ?? '',
        city: addressData['city'] as String? ?? '',
        state: addressData['state'] as String? ?? '',
        zipCode: addressData['zipCode'] as String? ?? '',
        complement: addressData['complement'] as String?,
        neighborhood: addressData['neighborhood'] as String?,
        latitude: (addressData['latitude'] as num?)?.toDouble(),
        longitude: (addressData['longitude'] as num?)?.toDouble(),
      );
      flattenedAddress = [
        producerAddress.street,
        producerAddress.number,
        producerAddress.city,
        producerAddress.state,
      ].where((s) => s.isNotEmpty).join(', ');
    } else if (addressData is String) {
      flattenedAddress = addressData;
    }

    final paymentMethodsData = json['paymentMethods'];
    final paymentMethods = paymentMethodsData is List
        ? paymentMethodsData
            .whereType<Map<String, dynamic>>()
            .map(_paymentMethodFromJson)
            .toList()
        : null;

    final availabilityData = json['availability'];
    final availability = availabilityData is List
        ? availabilityData
            .whereType<Map<String, dynamic>>()
            .map(_availabilityFromJson)
            .toList()
        : null;

    return AdminProducerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: flattenedAddress,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      active: json['active'] as bool? ?? true,
      fiscalNumber: json['fiscalNumber'] as String? ?? '',
      fiscalNumberType: json['fiscalNumberType'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      producerAddress: producerAddress,
      paymentMethods: paymentMethods,
      availability: availability,
    );
  }

  static AdminPaymentMethod _paymentMethodFromJson(Map<String, dynamic> json) {
    return AdminPaymentMethod(
      type: json['type'] as String? ?? '',
      pixKeyType: json['pixKeyType'] as String?,
      pixKey: json['pixKey'] as String?,
      bankCode: json['bankCode'] as String?,
      bankName: json['bankName'] as String?,
      agency: json['agency'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountType: json['accountType'] as String?,
      holderName: json['holderName'] as String?,
      fiscalNumber: json['fiscalNumber'] as String?,
    );
  }

  static AdminAvailability _availabilityFromJson(Map<String, dynamic> json) {
    return AdminAvailability(
      weekday: (json['weekday'] as num?)?.toInt() ?? 0,
      opensAt: json['opensAt'] as String? ?? '',
      closesAt: json['closesAt'] as String? ?? '',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
