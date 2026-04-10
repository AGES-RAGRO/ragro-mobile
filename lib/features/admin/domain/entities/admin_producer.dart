import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_bank_account.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_availability.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';

class AdminProducer extends Equatable {
  const AdminProducer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.fiscalNumber,
    required this.fiscalNumberType,
    required this.farmName,
    this.producerAddress,
    this.bankAccount,
    this.availability,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;
  final String fiscalNumber;
  final String fiscalNumberType;
  final String farmName;
  final AdminAddress? producerAddress;
  final AdminBankAccount? bankAccount;
  final List<AdminAvailability>? availability;

  AdminProducer copyWith({bool? active}) {
    return AdminProducer(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      createdAt: createdAt,
      updatedAt: updatedAt,
      active: active ?? this.active,
      fiscalNumber: fiscalNumber ?? this.fiscalNumber,
      fiscalNumberType: fiscalNumberType,
      farmName: farmName ?? this.farmName,
      producerAddress: producerAddress,
      bankAccount: bankAccount,
      availability: availability,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, address, createdAt, updatedAt,
        active, fiscalNumber, fiscalNumberType, farmName,];
}
