import 'package:ragro_mobile/features/auth/data/models/address_request.dart';

/// Payload for POST /auth/register/customer. The backend expects
/// [fiscalNumber] as an 11-digit CPF without punctuation.
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
