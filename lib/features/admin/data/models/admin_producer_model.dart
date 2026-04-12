import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

class AdminProducerModel extends AdminProducer {
  const AdminProducerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.fiscalNumber,
    required super.fiscalNumberType,
    required super.zipCode,
    required super.street,
    required super.neighborhood,
    required super.city,
    required super.state,
    required super.bankName,
    required super.agency,
    required super.accountNumber,
    required super.holderName,
    required super.scheduleWeekdays,
    required super.scheduleStart,
    required super.scheduleEnd,
    required super.createdAt,
    required super.updatedAt,
    required super.active,
  });

  factory AdminProducerModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final payments = json['paymentMethods'] as List<dynamic>? ?? [];
    final payment = payments.isNotEmpty
        ? payments.first as Map<String, dynamic>
        : <String, dynamic>{};

    final street = [
      address['street'] as String? ?? '',
      if ((address['number'] as String?)?.isNotEmpty ?? false)
        address['number'] as String,
    ].where((s) => s.isNotEmpty).join(', ');

    return AdminProducerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      fiscalNumber: json['fiscalNumber'] as String? ?? '',
      fiscalNumberType: json['fiscalNumberType'] as String? ?? 'CPF',
      zipCode: address['zipCode'] as String? ?? '',
      street: street,
      neighborhood: address['neighborhood'] as String? ?? '',
      city: address['city'] as String? ?? '',
      state: address['state'] as String? ?? '',
      bankName: payment['bankName'] as String? ?? '',
      agency: payment['agency'] as String? ?? '',
      accountNumber: payment['accountNumber'] as String? ?? '',
      holderName: payment['holderName'] as String? ?? '',
      // Horário de atendimento não faz parte do payload do backend ainda
      scheduleWeekdays: List.filled(7, false),
      scheduleStart: '',
      scheduleEnd: '',
      createdAt: json['memberSince'] != null
          ? DateTime.parse(json['memberSince'] as String)
          : DateTime.now(),
      updatedAt: DateTime.now(),
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'fiscalNumber': fiscalNumber,
      'fiscalNumberType': fiscalNumberType,
      'address': {
        'street': street,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'zipCode': zipCode,
      },
      'paymentMethods': [
        {
          'bankName': bankName,
          'agency': agency,
          'accountNumber': accountNumber,
          'holderName': holderName,
        },
      ],
    };
  }
}
