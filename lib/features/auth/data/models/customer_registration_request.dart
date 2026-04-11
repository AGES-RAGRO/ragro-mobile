import 'package:ragro_mobile/features/auth/data/models/address_request.dart';

/// Payload para POST /auth/register/customer.
///
/// O backend usa [fiscalNumber] para CPF (11 dígitos, sem pontuação).
class CustomerRegistrationRequest {
  const CustomerRegistrationRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.fiscalNumber,
    required this.password,
    required this.address,
  });

  final String name;
  final String email;
  final String phone;
  final String fiscalNumber;
  final String password;
  final AddressRequest address;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'fiscalNumber': fiscalNumber,
    'password': password,
    'address': address.toJson(),
  };
}
