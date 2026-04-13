import 'package:ragro_mobile/features/auth/data/models/address_request.dart';

class CustomerUpdateRequest {
  const CustomerUpdateRequest({
    required this.name,
    required this.phone,
    required this.address,
  });

  final String name;
  final String phone;
  final AddressRequest address;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address': address.toJson(),
  };
}
