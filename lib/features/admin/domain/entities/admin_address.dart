import 'package:equatable/equatable.dart';

class AdminAddress extends Equatable {
  const AdminAddress({
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
    this.neighborhood,
    this.latitude,
    this.longitude,
  });

  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String? complement;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
    'street': street,
    'number': number,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    if (complement != null) 'complement': complement,
    if (neighborhood != null) 'neighborhood': neighborhood,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  @override
  List<Object?> get props => [street, number, city, state, zipCode];
}
