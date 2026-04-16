import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_availability.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_payment_method.dart';

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
    required this.description,
    this.producerAddress,
    this.paymentMethods,
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
  final String description;
  final AdminAddress? producerAddress;
  final List<AdminPaymentMethod>? paymentMethods;
  final List<AdminAvailability>? availability;

  AdminProducer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    String? fiscalNumber,
    String? fiscalNumberType,
    String? farmName,
    String? description,
    AdminAddress? producerAddress,
    List<AdminPaymentMethod>? paymentMethods,
    List<AdminAvailability>? availability,
  }) {
    return AdminProducer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      fiscalNumber: fiscalNumber ?? this.fiscalNumber,
      fiscalNumberType: fiscalNumberType ?? this.fiscalNumberType,
      farmName: farmName ?? this.farmName,
      description: description ?? this.description,
      producerAddress: producerAddress ?? this.producerAddress,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      availability: availability ?? this.availability,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    address,
    createdAt,
    updatedAt,
    active,
    fiscalNumber,
    fiscalNumberType,
    farmName,
    description,
  ];
}
