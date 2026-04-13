import 'package:ragro_mobile/features/auth/domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.street,
    required super.number,
    required super.city,
    required super.state,
    required super.zipCode,
    required super.isPrimary,
    super.complement,
    super.neighborhood,
    super.latitude,
    super.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: (json['zipCode'] ?? json['zip_code']) as String,
      isPrimary:
          (json['isPrimary'] ?? json['primary'] ?? json['is_primary'])
              as bool? ??
          true,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
