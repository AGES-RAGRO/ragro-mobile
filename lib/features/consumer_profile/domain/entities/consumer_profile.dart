// US-03 — Retrieve Consumer Profile
// US-04 — Update Consumer Profile
import 'package:equatable/equatable.dart';

class CustomerProfile extends Equatable {
  const CustomerProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.fiscalNumber,
  });

  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? fiscalNumber;

  CustomerProfile copyWith({
    String? name,
    String? phone,
    String? address,
    String? fiscalNumber,
  }) {
    return CustomerProfile(
      id: id,
      userId: userId,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      fiscalNumber: fiscalNumber ?? this.fiscalNumber,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, email, phone, address, fiscalNumber];
}
