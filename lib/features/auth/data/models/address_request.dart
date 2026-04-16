/// Payload de endereço para POST /auth/register/customer (alinhado ao [AddressRequest] do backend).
class AddressRequest {
  const AddressRequest({
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
    this.neighborhood,
  });

  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String? complement;
  final String? neighborhood;

  Map<String, dynamic> toJson() => {
    'street': street,
    'number': number,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    if (complement != null && complement!.trim().isNotEmpty)
      'complement': complement!.trim(),
    if (neighborhood != null && neighborhood!.trim().isNotEmpty)
      'neighborhood': neighborhood!.trim(),
  };
}
