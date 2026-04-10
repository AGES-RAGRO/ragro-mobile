import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';

class CustomerProfileModel extends CustomerProfile {
  const CustomerProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.fiscalNumber,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    final addressData = json['address'] as Map<String, dynamic>?;
    String addressStr = '';
    if (addressData != null) {
      final parts = [
        addressData['street'],
        if (addressData['number'] != null) addressData['number'],
        if (addressData['city'] != null) addressData['city'],
      ].whereType<String>().toList();
      addressStr = parts.join(', ');
    }

    return CustomerProfileModel(
      id: json['id'] as String? ?? user['id'] as String,
      userId: user['id'] as String? ?? json['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      phone: user['phone'] as String? ?? '',
      address: addressStr,
      fiscalNumber: (json['fiscal_number'] ?? json['cpf']) as String?,
    );
  }

  // Removed mock data — API-backed implementation should be used.
}
