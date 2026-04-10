import 'package:equatable/equatable.dart';

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
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

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
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, address, createdAt, updatedAt, active];
}
