import 'package:equatable/equatable.dart';

class AdminProducerSummary extends Equatable {
  const AdminProducerSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminProducerSummary copyWith({bool? active}) {
    return AdminProducerSummary(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      active: active ?? this.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, address, active, createdAt, updatedAt];
}
