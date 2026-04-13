import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/address.dart';

class CustomerProfile extends Equatable {
  const CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.active,
    required this.addresses,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final bool active;
  final List<Address> addresses;

  Address? get primaryAddress {
    for (final address in addresses) {
      if (address.isPrimary) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  String get formattedPrimaryAddress {
    final address = primaryAddress;
    if (address == null) return 'Endereco nao cadastrado';

    final parts = <String>[
      '${address.street}, ${address.number}',
      if ((address.complement ?? '').trim().isNotEmpty)
        address.complement!.trim(),
      if ((address.neighborhood ?? '').trim().isNotEmpty)
        address.neighborhood!.trim(),
      '${address.city} - ${address.state}',
      address.zipCode,
    ];

    return parts.join(' - ');
  }

  @override
  List<Object?> get props => [id, name, email, phone, active, addresses];
}
