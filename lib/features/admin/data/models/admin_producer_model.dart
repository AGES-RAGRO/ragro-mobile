import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
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
    super.producerAddress,
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
      producerAddress: producerAddress,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
