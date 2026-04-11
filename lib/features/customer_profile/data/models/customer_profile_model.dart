import 'package:ragro_mobile/features/auth/data/models/address_model.dart';
import 'package:ragro_mobile/features/customer_profile/domain/entities/customer_profile.dart';

class CustomerProfileModel extends CustomerProfile {
  const CustomerProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.active,
    required super.addresses,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    final addressesJson = (json['addresses'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return CustomerProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      addresses: addressesJson.map(AddressModel.fromJson).toList(),
    );
  }
}
