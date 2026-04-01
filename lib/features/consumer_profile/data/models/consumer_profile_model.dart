import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';

class ConsumerProfileModel extends ConsumerProfile {
  const ConsumerProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.fiscalNumber,
  });

  factory ConsumerProfileModel.fromJson(Map<String, dynamic> json) {
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

    return ConsumerProfileModel(
      id: json['id'] as String? ?? user['id'] as String,
      userId: user['id'] as String? ?? json['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      phone: user['phone'] as String? ?? '',
      address: addressStr,
      fiscalNumber: (json['fiscal_number'] ?? json['cpf']) as String?,
    );
  }

  static ConsumerProfileModel mock() {
    return const ConsumerProfileModel(
      id: 'consumer_1',
      userId: 'user_1',
      name: 'Ricardo Aguiar',
      email: 'ricardo.aguiar@ragro.com.br',
      phone: '+55 (11) 98765-4321',
      address: 'Rua Cândido Vieira',
      fiscalNumber: '000.000.000-00',
    );
  }
}
