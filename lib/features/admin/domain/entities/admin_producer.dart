import 'package:equatable/equatable.dart';

class AdminProducer extends Equatable {
  const AdminProducer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.fiscalNumber,
    required this.fiscalNumberType,
    required this.zipCode,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.bankName,
    required this.agency,
    required this.accountNumber,
    required this.holderName,
    required this.scheduleWeekdays,
    required this.scheduleStart,
    required this.scheduleEnd,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String fiscalNumber;
  final String fiscalNumberType;
  final String zipCode;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String bankName;
  final String agency;
  final String accountNumber;
  final String holderName;
  final List<bool> scheduleWeekdays;
  final String scheduleStart;
  final String scheduleEnd;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  String get location => '$city, $state';
  String get address => '$street, $city, $state';

  AdminProducer copyWith({
    String? name,
    String? email,
    String? phone,
    String? fiscalNumber,
    String? fiscalNumberType,
    String? zipCode,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? bankName,
    String? agency,
    String? accountNumber,
    String? holderName,
    List<bool>? scheduleWeekdays,
    String? scheduleStart,
    String? scheduleEnd,
    DateTime? updatedAt,
    bool? active,
  }) {
    return AdminProducer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fiscalNumber: fiscalNumber ?? this.fiscalNumber,
      fiscalNumberType: fiscalNumberType ?? this.fiscalNumberType,
      zipCode: zipCode ?? this.zipCode,
      street: street ?? this.street,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      bankName: bankName ?? this.bankName,
      agency: agency ?? this.agency,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      scheduleWeekdays: scheduleWeekdays ?? this.scheduleWeekdays,
      scheduleStart: scheduleStart ?? this.scheduleStart,
      scheduleEnd: scheduleEnd ?? this.scheduleEnd,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
        id, name, email, phone, fiscalNumber, fiscalNumberType,
        zipCode, street, neighborhood, city, state,
        bankName, agency, accountNumber, holderName,
        scheduleWeekdays, scheduleStart, scheduleEnd,
        createdAt, updatedAt, active,
      ];
}
